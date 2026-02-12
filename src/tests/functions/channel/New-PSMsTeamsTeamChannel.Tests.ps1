Describe 'New-PSMsTeamsTeamChannel' {
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
            $command = Get-Command -Name New-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
        }

        It 'Should have mandatory DisplayName' {
            $command = Get-Command -Name New-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['DisplayName']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should have valid MembershipType values' {
            $command = Get-Command -Name New-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['MembershipType']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Standard'
            $validateSet.ValidValues | Should -Contain 'Private'
            $validateSet.ValidValues | Should -Contain 'Shared'
        }
    }

    Context 'Creating a channel' {
        It 'Should resolve team and POST to channels endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return @{ id = 'new-channel' } }

            New-PSMsTeamsTeamChannel -Identity 'testteam' -DisplayName 'NewChannel' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels' -and $Method -eq 'Post'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept DisplayName from pipeline by property name' {
            $command = Get-Command -Name New-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['DisplayName']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Description from pipeline by property name' {
            $command = Get-Command -Name New-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['Description']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept MembershipType from pipeline by property name' {
            $command = Get-Command -Name New-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['MembershipType']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
