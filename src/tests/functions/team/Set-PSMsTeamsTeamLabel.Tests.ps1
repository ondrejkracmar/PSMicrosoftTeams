Describe 'Set-PSMsTeamsTeamLabel' {
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
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
            $command.Parameters.Keys | Should -Contain 'Confirm'
        }

        It 'Should have LabelId parameter' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'LabelId'
        }

        It 'Should have LabelName parameter' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'LabelName'
        }

        It 'Should have Identity parameter with aliases' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'GroupId'
            $param.Aliases | Should -Contain 'TeamId'
        }

        It 'Should have multiple parameter sets for LabelId and LabelName' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'IdentityLabelId'
            $command.ParameterSets.Name | Should -Contain 'IdentityLabelName'
            $command.ParameterSets.Name | Should -Contain 'InputObjectLabelId'
            $command.ParameterSets.Name | Should -Contain 'InputObjectLabelName'
        }
    }

    Context 'Identity with LabelId parameter set' {
        It 'Should resolve team and call PATCH on groups endpoint with assignedLabels body' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Set-PSMsTeamsTeamLabel -Identity 'testteam' -LabelId 'aaaa-bbbb-cccc' -LabelName 'Confidential' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'groups/' -and $Method -eq 'Patch'
            }
        }
    }

    Context 'Identity with LabelName only parameter set' {
        It 'Should resolve label from current group labels and call PATCH' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            $mockLabelResponse = [PSCustomObject]@{
                id             = '00000000-0000-0000-0000-000000000001'
                displayName    = 'TestTeam'
                assignedLabels = @(
                    [PSCustomObject]@{ labelId = 'aaaa-bbbb-cccc'; displayName = 'Confidential' }
                )
            }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            # First call is the GET to resolve labels, second is the PATCH
            $script:callCount = 0
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' {
                $script:callCount++
                if ($Method -eq 'Get') { return $mockLabelResponse }
            }

            Set-PSMsTeamsTeamLabel -Identity 'testteam' -LabelName 'Confidential' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }
            { Set-PSMsTeamsTeamLabel -Identity 'test' -LabelId 'abc' -LabelName 'Test' } | Should -Throw
        }

        It 'Should have EnableException parameter' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'EnableException'
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Set-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped via pipeline' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }
            Mock -ModuleName PSMicrosoftTeams Invoke-PSFProtectedCommand { }

            { $mockTeam | Set-PSMsTeamsTeamLabel -LabelId 'aaaa-bbbb-cccc' -LabelName 'Confidential' -Force -Confirm:$false } | Should -Not -Throw
        }
    }
}
