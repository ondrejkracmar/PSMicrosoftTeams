Describe 'Get-PSMsTeamsTeamMember' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        $script:mockMember = [PSCustomObject]@{
            Id          = 'member-001'
            DisplayName = 'John Doe'
            Mail        = 'john@contoso.com'
            Roles       = @('owner')
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
        Mock -ModuleName PSMicrosoftTeams Get-PSFLocalizedString { return 'Microsoft Graph' }
        Mock -ModuleName PSMicrosoftTeams Test-PSFFunctionInterrupt { return $false }
    }

    Context 'Parameter validation' {
        It 'Should have InputObject as default parameter set' {
            $command = Get-Command -Name Get-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'InputObject'
        }

        It 'Should declare correct OutputType' {
            $command = Get-Command -Name Get-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftTeams.Members.ConversationMember'
        }

        It 'Should have Identity parameter with correct aliases' {
            $command = Get-Command -Name Get-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'GroupId'
            $param.Aliases | Should -Contain 'TeamId'
            $param.Aliases | Should -Contain 'MailNickName'
        }

        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Get-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have Filter parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Filter']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have AdvancedFilter switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['AdvancedFilter']
            $param.ParameterType | Should -Be ([switch])
        }
    }

    Context 'Identity parameter set' {
        It 'Should resolve team and query members endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockMember }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockMember }

            Get-PSMsTeamsTeamMember -Identity 'testteam'

            Should -Invoke -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam -Times 1
            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/members'
            }
        }

        It 'Should handle team not found with EnableException' {
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $null }
            Mock -ModuleName PSMicrosoftTeams Invoke-TerminatingException { throw 'Team not found' }

            { Get-PSMsTeamsTeamMember -Identity 'nonexistent' -EnableException } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }

            { Get-PSMsTeamsTeamMember -Identity 'test' } | Should -Throw
        }
    }
}
