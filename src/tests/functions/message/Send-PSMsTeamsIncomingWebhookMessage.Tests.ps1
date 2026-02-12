Describe 'Send-PSMsTeamsIncomingWebhookMessage' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'
    }

    Context 'Parameter validation' {
        It 'Should support ShouldProcess' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
        }

        It 'Should have mandatory WebhookUrl parameter' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['WebhookUrl']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have mandatory Title parameter' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Title']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have mandatory Text parameter' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Text']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have optional ThemeColor parameter with validation' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['ThemeColor']
            $param | Should -Not -BeNullOrEmpty
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidatePatternAttribute] }) | Should -Not -BeNullOrEmpty
        }

        It 'Should have optional Facts parameter' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $command.Parameters['Facts'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have optional Actions parameter' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $command.Parameters['Actions'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have optional Sections parameter' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $command.Parameters['Sections'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Webhook message sending' {
        It 'Should invoke Invoke-RestMethod with POST to webhook URI' {
            Mock -ModuleName PSMicrosoftTeams Invoke-RestMethod { }

            Send-PSMsTeamsIncomingWebhookMessage -WebhookUrl 'https://contoso.webhook.office.com/test' -Title 'Test' -Text 'Hello' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-RestMethod -Times 1 -ParameterFilter {
                $Method -eq 'Post' -and $Uri -match 'webhook'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept WebhookUrl from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['WebhookUrl']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Title from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Title']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Text from pipeline by property name' {
            $command = Get-Command -Name Send-PSMsTeamsIncomingWebhookMessage -Module PSMicrosoftTeams
            $param = $command.Parameters['Text']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
