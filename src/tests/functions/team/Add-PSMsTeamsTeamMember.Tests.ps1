Describe 'Add-PSMsTeamsTeamMember' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'
    }

    BeforeEach {
        Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { }
        Mock -ModuleName PSMicrosoftTeams Get-PSFConfigValue {
            switch ($FullName) {
                { $_ -match 'DefaultService' } { return 'PSMicrosoftTeams.Graph' }
                { $_ -match 'RetryCount' } { return 3 }
                { $_ -match 'RetryWaitInSeconds' } { return 5 }
                default { return $null }
            }
        }
        Mock -ModuleName PSMicrosoftTeams Get-PSFLocalizedString { return 'Microsoft Graph' }
        Mock -ModuleName PSMicrosoftTeams Test-PSFFunctionInterrupt { return $false }
        Mock -ModuleName PSMicrosoftTeams Get-EntraService {
            [PSCustomObject]@{ ServiceUrl = 'https://graph.microsoft.com/v1.0' }
        }
    }

    Context 'Parameter validation' {
        It 'Should have IdentityInputObject as default parameter set' {
            $command = Get-Command -Name Add-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'IdentityInputObject'
        }

        It 'Should have valid Role values' {
            $command = Get-Command -Name Add-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Role']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Member'
            $validateSet.ValidValues | Should -Contain 'Owner'
        }

        It 'Should have Identity parameter with correct aliases' {
            $command = Get-Command -Name Add-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'GroupId'
            $param.Aliases | Should -Contain 'TeamId'
        }

        It 'Should support ShouldProcess' {
            $command = Get-Command -Name Add-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
        }
    }

    Context 'Adding a member via Identity' {
        It 'Should resolve team, then POST to members endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            $mockUser = [PSCustomObject]@{ Id = 'user-001'; DisplayName = 'John'; Mail = 'john@contoso.com' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeamUser { return $mockUser }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Add-PSMsTeamsTeamMember -Identity 'testteam' -User 'john@contoso.com' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -ParameterFilter {
                $Path -match 'teams/.+/members' -and $Method -eq 'Post'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Add-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept User from pipeline by property name' {
            $command = Get-Command -Name Add-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['User']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped via pipeline' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            $mockUser = [PSMicrosoftEntraID.Users.User]@{ Id = 'user-001'; DisplayName = 'John'; UserPrincipalName = 'john@contoso.com' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            { $mockUser | Add-PSMsTeamsTeamMember -Identity 'testteam' -Force -Confirm:$false } | Should -Not -Throw
        }
    }
}
