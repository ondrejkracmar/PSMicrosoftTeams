Describe 'Remove-PSMsTeamsTeamChannel' {
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
            $command = Get-Command -Name Remove-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $cmdletBinding = $command.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Deleting a channel' {
        It 'Should resolve team and DELETE specific channel' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Remove-PSMsTeamsTeamChannel -Identity 'testteam' -ChannelId '19:channel@thread.tacv2' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/.+/channels/.+' -and $Method -eq 'DELETE'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept Channel from pipeline by property name' {
            $command = Get-Command -Name Remove-PSMsTeamsTeamChannel -Module PSMicrosoftTeams
            $param = $command.Parameters['Channel']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
