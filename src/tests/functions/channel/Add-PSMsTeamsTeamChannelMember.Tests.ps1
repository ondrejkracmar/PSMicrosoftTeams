Describe 'Add-PSMsTeamsTeamChannelMember' {
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
        It 'Should support ShouldProcess' {
            $command = Get-Command -Name Add-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
        }

        It 'Should have valid Role values' {
            $command = Get-Command -Name Add-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Role']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Member'
            $validateSet.ValidValues | Should -Contain 'Owner'
        }
    }

    Context 'Adding a channel member' {
        It 'Should POST to channel members endpoint' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            $mockChannel = [PSMicrosoftTeams.Channels.Channel]@{ Id = '19:ch@thread.tacv2'; DisplayName = 'General' }
            $mockUser = [PSMicrosoftEntraID.Users.User]@{ Id = 'user-001'; DisplayName = 'John'; UserPrincipalName = 'john@contoso.com' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeamChannel { return $mockChannel }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeamUser { return $mockUser }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Add-PSMsTeamsTeamChannelMember -Identity 'testteam' -Channel '19:ch@thread.tacv2' -User 'john@contoso.com' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -ParameterFilter {
                $Path -match 'teams/.+/channels/.+/members' -and $Method -eq 'Post'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Add-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept User from pipeline by property name' {
            $command = Get-Command -Name Add-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['User']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped via pipeline' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            $mockChannel = [PSMicrosoftTeams.Channels.Channel]@{ Id = '19:ch@thread.tacv2'; DisplayName = 'General' }
            $mockUser = [PSMicrosoftEntraID.Users.User]@{ Id = 'user-001'; DisplayName = 'John'; UserPrincipalName = 'john@contoso.com' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeamChannel { return $mockChannel }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            { $mockUser | Add-PSMsTeamsTeamChannelMember -Identity 'testteam' -Channel '19:ch@thread.tacv2' -Force -Confirm:$false } | Should -Not -Throw
        }
    }
}
