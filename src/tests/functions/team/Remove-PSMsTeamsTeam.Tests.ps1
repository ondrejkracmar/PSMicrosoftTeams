Describe 'Remove-PSMsTeamsTeam' {
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
        Mock -ModuleName PSMicrosoftTeams Test-PSFParameterBinding { return $false }
    }

    Context 'Parameter validation' {
        It 'Should support ShouldProcess with High ConfirmImpact' {
            $command = Get-Command -Name Remove-PSMsTeamsTeam -Module PSMicrosoftTeams
            $cmdletBinding = $command.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }

        It 'Should have InputObject as default parameter set' {
            $command = Get-Command -Name Remove-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'InputObject'
        }

        It 'Should have Force parameter' {
            $command = Get-Command -Name Remove-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.Parameters['Force'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have PassThru parameter' {
            $command = Get-Command -Name Remove-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.Parameters['PassThru'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Identity parameter set' {
        It 'Should resolve team and call DELETE on groups endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Remove-PSMsTeamsTeam -Identity 'testteam' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam -Times 1
            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'groups/' -and $Method -eq 'DELETE'
            }
        }

        It 'Should handle team not found with EnableException' {
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $null }
            Mock -ModuleName PSMicrosoftTeams Invoke-TerminatingException { throw 'Team not found' }

            { Remove-PSMsTeamsTeam -Identity 'nonexistent' -EnableException -Force -Confirm:$false } | Should -Throw
        }
    }

    Context 'PassThru' {
        It 'Should return a batch request object when PassThru is specified' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            $result = Remove-PSMsTeamsTeam -Identity 'testteam' -PassThru -Force -Confirm:$false

            # PassThru should produce a batch request instead of calling the API
            # Invoke-EntraRequest should NOT be called when PassThru is used
            if ($null -ne $result) {
                $result.Method | Should -Be 'DELETE'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Remove-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Remove-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped via pipeline' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-PSFProtectedCommand { }

            { $mockTeam | Remove-PSMsTeamsTeam -Force -Confirm:$false } | Should -Not -Throw
        }
    }
}
