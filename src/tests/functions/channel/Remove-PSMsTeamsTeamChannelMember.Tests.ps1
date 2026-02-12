Describe 'Remove-PSMsTeamsTeamChannelMember' {
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
    }

    Context 'Parameter validation' {
        It 'Should support ShouldProcess with High ConfirmImpact' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $cmdletBinding = $command.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Removing a channel member' {
        It 'Should resolve team and DELETE specific member from channel' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            $mockChannel = [PSMicrosoftTeams.Channels.Channel]@{ Id = '19:ch@thread.tacv2'; DisplayName = 'General' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeamChannel { return $mockChannel }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Remove-PSMsTeamsTeamChannelMember -Identity 'testteam' -Channel '19:ch@thread.tacv2' -MembershipId 'member-001' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -ParameterFilter {
                $Path -match 'teams/.+/channels/.+/members/' -and $Method -eq 'DELETE'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept MembershipId from pipeline' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['MembershipId']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept MembershipId from pipeline by property name' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['MembershipId']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
