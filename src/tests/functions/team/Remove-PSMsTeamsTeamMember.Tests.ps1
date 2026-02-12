Describe 'Remove-PSMsTeamsTeamMember' {
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
        It 'Should support ShouldProcess (default ConfirmImpact Medium)' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
        }

        It 'Should have MembershipId parameter set' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'MembershipId'
        }
    }

    Context 'MembershipId parameter set' {
        It 'Should call DELETE on members/{membershipId} endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Remove-PSMsTeamsTeamMember -Identity 'testteam' -MembershipId 'member-001' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -ParameterFilter {
                $Path -match 'teams/.+/members/' -and $Method -eq 'DELETE'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept MembershipId from pipeline by property name' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamMember -Module PSMicrosoftTeams
            $param = $command.Parameters['MembershipId']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
