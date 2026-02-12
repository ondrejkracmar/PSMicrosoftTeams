Describe 'Get-PSMsTeamsTeamChannelMember' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        $script:mockChannelMember = [PSCustomObject]@{
            Id          = 'cmember-001'
            DisplayName = 'Jane Doe'
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
        It 'Should have correct OutputType' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftTeams.Members.ConversationMember'
        }

        It 'Should require Channel parameter with ChannelId alias' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            $param | Should -Not -BeNullOrEmpty
            $param.Aliases | Should -Contain 'ChannelId'
        }

        It 'Should have All switch parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $command.Parameters['All'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have EnableException parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $command.Parameters['EnableException'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Channel member retrieval' {
        It 'Should resolve team and query channel members endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockChannelMember }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockChannelMember }

            Get-PSMsTeamsTeamChannelMember -Identity 'testteam' -Channel '19:channel@thread.tacv2'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels/.+/members'
            }
        }

        It 'Should use allMembers endpoint when -All is specified' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockChannelMember }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockChannelMember }
            Mock -ModuleName PSMicrosoftTeams Test-PSFParameterBinding { return $true } -ParameterFilter { $ParameterName -eq 'All' }

            Get-PSMsTeamsTeamChannelMember -Identity 'testteam' -Channel '19:channel@thread.tacv2' -All

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels/.+/allMembers'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Channel from pipeline by property name' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannelMember -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
