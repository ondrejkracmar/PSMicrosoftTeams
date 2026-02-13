Describe 'Get-PSMsTeamsTeamUser' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        $script:mockUser = [PSCustomObject]@{
            Id              = 'user-001'
            DisplayName     = 'John Doe'
            Mail            = 'john@contoso.com'
            UserPrincipalName = 'john@contoso.com'
        }
    }

    BeforeEach {
        Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { }
        Mock -ModuleName PSMicrosoftTeams Get-PSFConfigValue {
            switch ($FullName) {
                { $_ -match 'DefaultService' } { return 'PSMicrosoftTeams.Graph' }
                { $_ -match 'PageSize' } { return 100 }
                { $_ -match 'RetryCount' } { return 3 }
                { $_ -match 'RetryWaitInSeconds' } { return 5 }
                default { return $null }
            }
        }
        Mock -ModuleName PSMicrosoftTeams Get-PSFConfig {
            [PSCustomObject]@{ Value = $true }
        }
        Mock -ModuleName PSMicrosoftTeams Get-PSFLocalizedString { return 'Microsoft Graph' }
        Mock -ModuleName PSMicrosoftTeams Test-PSFFunctionInterrupt { return $false }
    }

    Context 'Parameter validation' {
        It 'Should have correct OutputType' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftEntraID.Users.User'
        }

        It 'Should have Identity parameter with aliases' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'UserPrincipalName'
        }

        It 'Should have Name parameter (not DisplayName)' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['Name'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have CompanyName parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['CompanyName'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have Disabled switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['Disabled'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have AdvancedFilter switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['AdvancedFilter'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have All switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['All'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have Filter parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['Filter'] | Should -Not -BeNullOrEmpty
        }

        It 'Should accept Identity from pipeline by value' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }

    Context 'Identity parameter set' {
        It 'Should query users/{id} endpoint for GUID identity' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockUser }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockUser }

            Get-PSMsTeamsTeamUser -Identity '00000000-0000-0000-0000-000000000001'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'users/'
            }
        }

        It 'Should query users endpoint with filter for email/UPN identity' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockUser }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockUser }

            Get-PSMsTeamsTeamUser -Identity 'john@contoso.com'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1
        }
    }

    Context 'Name parameter set' {
        It 'Should query users endpoint with displayName/givenName/surName filter' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockUser }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockUser }

            Get-PSMsTeamsTeamUser -Name 'John'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Query -and ($Query['$Filter'] -match 'displayName')
            }
        }
    }

    Context 'Hashtable clone fix verification' {
        It 'Should not contaminate query across pipeline items' {
            $mockUser1 = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000011'; DisplayName = 'User1'; Mail = 'u1@contoso.com' }
            $mockUser2 = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000012'; DisplayName = 'User2'; Mail = 'u2@contoso.com' }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $mockUser1 }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { param($InputObject) return $InputObject }

            # Pipeline with multiple items should not throw or produce unexpected results
            $ids = @('user001@contoso.com', 'user002@contoso.com')
            { $ids | ForEach-Object { Get-PSMsTeamsTeamUser -Identity $_ } } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }

            { Get-PSMsTeamsTeamUser -Identity 'test' } | Should -Throw
        }

        It 'Should have EnableException parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.Parameters['EnableException'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Pipeline input' {
        It 'Should accept multiple Identity values from pipeline' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockUser }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockUser }

            { @('user001@contoso.com', 'user002@contoso.com') | ForEach-Object { Get-PSMsTeamsTeamUser -Identity $_ } } | Should -Not -Throw
        }
    }

    Context 'Parameter sets' {
        It 'Should have All as default parameter set' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'All'
        }

        It 'Should have Identity, Name, CompanyName, Filter, All parameter sets' {
            $command = Get-Command -Name Get-PSMsTeamsTeamUser -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'Identity'
            $command.ParameterSets.Name | Should -Contain 'Name'
            $command.ParameterSets.Name | Should -Contain 'CompanyName'
            $command.ParameterSets.Name | Should -Contain 'Filter'
            $command.ParameterSets.Name | Should -Contain 'All'
        }
    }
}
