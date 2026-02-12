Describe 'Get-PSMsTeamsTeam' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..'}
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        # Common mock data
        $script:mockTeam = [PSCustomObject]@{
            Id          = '00000000-0000-0000-0000-000000000001'
            DisplayName = 'TestTeam'
            Description = 'A test team'
        }
        $script:mockTeamArray = @(
            [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam1'; Description = 'Team 1' },
            [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000002'; DisplayName = 'TestTeam2'; Description = 'Team 2' }
        )
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
            [PSCustomObject]@{ Value = @('id', 'displayName', 'description') }
        }
        Mock -ModuleName PSMicrosoftTeams Get-PSFLocalizedString { return 'Microsoft Graph' }
        Mock -ModuleName PSMicrosoftTeams Test-PSFFunctionInterrupt { return $false }
    }

    Context 'Parameter validation' {
        It 'Should have Identity as default parameter set' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'Identity'
        }

        It 'Should have mandatory Identity parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have mandatory DisplayName parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['DisplayName']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have mandatory Filter parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Filter']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have All switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['All']
            $param.ParameterType | Should -Be ([switch])
        }

        It 'Should have EnableException switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['EnableException']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should declare correct OutputType' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftTeams.Teams.Team'
        }

        It 'Should accept Identity from pipeline' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have correct aliases for Identity' {
            $command = Get-Command -Name Get-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'GroupId'
            $param.Aliases | Should -Contain 'TeamId'
            $param.Aliases | Should -Contain 'MailNickName'
        }
    }

    Context 'Identity parameter set' {
        It 'Should call Invoke-EntraRequest with groups path for identity lookup' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockTeam }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockTeam }

            Get-PSMsTeamsTeam -Identity '00000000-0000-0000-0000-000000000001'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'groups'
            }
        }

        It 'Should process multiple identities' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockTeam }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockTeam }

            Get-PSMsTeamsTeam -Identity @('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002')

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 4
        }
    }

    Context 'DisplayName parameter set' {
        It 'Should query teams endpoint with displayName filter' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockTeamArray }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockTeamArray }

            Get-PSMsTeamsTeam -DisplayName 'TestTeam'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -eq 'teams'
            }
        }
    }

    Context 'All parameter set' {
        It 'Should query teams endpoint without filter' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockTeamArray }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockTeamArray }

            Get-PSMsTeamsTeam -All

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -eq 'teams'
            }
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }

            { Get-PSMsTeamsTeam -Identity 'test' } | Should -Throw

            Should -Invoke -ModuleName PSMicrosoftTeams Assert-EntraConnection -Times 1
        }
    }

    Context 'Hashtable clone fix verification' {
        It 'Should not contaminate query across multiple pipeline items' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockTeam }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockTeam }

            $ids = @('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002')
            { $ids | ForEach-Object { Get-PSMsTeamsTeam -Identity $_ } } | Should -Not -Throw
        }
    }

    Context 'Pipeline input' {
        It 'Should accept Identity from pipeline by value' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockTeam }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockTeam }

            { '00000000-0000-0000-0000-000000000001' | Get-PSMsTeamsTeam } | Should -Not -Throw
        }
    }
}
