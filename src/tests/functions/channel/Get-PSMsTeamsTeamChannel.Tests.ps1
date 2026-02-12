Describe 'Get-PSMsTeamsTeamChannel' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        $script:mockChannel = [PSCustomObject]@{
            Id            = '19:channel-001@thread.tacv2'
            DisplayName   = 'General'
            Description   = 'General channel'
            MembershipType = 'standard'
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
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftTeams.Channels.Channel'
        }

        It 'Should have Identity parameter with aliases' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'GroupId'
            $param.Aliases | Should -Contain 'TeamId'
        }

        It 'Should have Channel parameter with ChannelId alias' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            $param | Should -Not -BeNullOrEmpty
            $param.Aliases | Should -Contain 'ChannelId'
        }

        It 'Should have DisplayName parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $command.Parameters['DisplayName'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have MembershipType parameter with ValidateSet' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['MembershipType']
            $param | Should -Not -BeNullOrEmpty
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Standard'
            $validateSet.ValidValues | Should -Contain 'Private'
            $validateSet.ValidValues | Should -Contain 'Shared'
        }

        It 'Should have ChannelType parameter with ValidateSet' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['ChannelType']
            $param | Should -Not -BeNullOrEmpty
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Team'
            $validateSet.ValidValues | Should -Contain 'Incomming'
            $validateSet.ValidValues | Should -Contain 'All'
        }

        It 'Should have EnableException parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $command.Parameters['EnableException'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Channel retrieval by team Identity' {
        It 'Should resolve team and query channels endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockChannel }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockChannel }

            Get-PSMsTeamsTeamChannel -Identity 'testteam'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels'
            }
        }

        It 'Should query specific channel when ChannelId is provided' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockChannel }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockChannel }

            Get-PSMsTeamsTeamChannel -Identity 'testteam' -Channel '19:channel-001@thread.tacv2'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels/.+'
            }
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }

            { Get-PSMsTeamsTeamChannel -Identity 'test' } | Should -Throw
        }
    }

    Context 'Parameter sets' {
        It 'Should have IdentityChannelType as default parameter set' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'IdentityChannelType'
        }

        It 'Should have multiple parameter sets for different query modes' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'IdentityChannel'
            $command.ParameterSets.Name | Should -Contain 'IdentityChannelDisplayName'
            $command.ParameterSets.Name | Should -Contain 'IdentityChannelMembershipType'
            $command.ParameterSets.Name | Should -Contain 'IdentityChannelType'
        }
    }

    Context 'DisplayName parameter set' {
        It 'Should query channels filtering by displayName' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockChannel }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockChannel }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeamChannel { return $script:mockChannel }

            { Get-PSMsTeamsTeamChannel -Identity 'testteam' -DisplayName 'General' } | Should -Not -Throw
        }
    }

    Context 'MembershipType parameter set' {
        It 'Should query allChannels with membershipType filter' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return @() }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return @() }

            { Get-PSMsTeamsTeamChannel -Identity 'testteam' -MembershipType 'Private' } | Should -Not -Throw
        }
    }

    Context 'Pipeline input' {
        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Channel from pipeline by property name' {
            $command = Get-Command -Name Get-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
