Describe 'Send-PSMsTeamsTeamChannelMessage' {
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
        It 'Should support ShouldProcess' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
        }

        It 'Should have mandatory Subject parameter' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Subject']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have mandatory Message parameter' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Message']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have Channel parameter with ChannelId alias' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            $param | Should -Not -BeNullOrEmpty
            $param.Aliases | Should -Contain 'ChannelId'
        }

        It 'Should have valid ContentType values' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['ContentType']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet | Should -Not -BeNullOrEmpty
            $validateSet.ValidValues | Should -Contain 'Text'
            $validateSet.ValidValues | Should -Contain 'Html'
        }

        It 'Should have optional Attachments parameter' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $command.Parameters['Attachments'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have PassThru switch' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $command.Parameters['PassThru'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Sending a message' {
        It 'Should resolve team and POST to channel messages endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return @{ id = 'msg-001' } }

            Send-PSMsTeamsTeamChannelMessage -Identity 'testteam' -Channel '19:ch@thread.tacv2' -Subject 'Test Subject' -Message 'Hello World' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels/.+/messages' -and $Method -eq 'Post'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Channel from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Subject from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Subject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Message from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsTeamChannelMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Message']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
