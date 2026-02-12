Describe 'Get-PSMsTeamsTeamLabel' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        $script:mockLabelResponse = [PSCustomObject]@{
            id              = '00000000-0000-0000-0000-000000000001'
            displayName     = 'TestTeam'
            assignedLabels  = @(
                [PSCustomObject]@{ labelId = 'aaaa-bbbb-cccc'; displayName = 'Confidential' }
                [PSCustomObject]@{ labelId = 'dddd-eeee-ffff'; displayName = 'Internal' }
            )
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
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftEntraID.Groups.AssignedLabel'
        }

        It 'Should have Identity parameter with aliases' {
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
            $param.Aliases | Should -Contain 'GroupId'
            $param.Aliases | Should -Contain 'TeamId'
        }

        It 'Should have DisplayName parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'DisplayName'
        }

        It 'Should have EnableException parameter' {
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'EnableException'
        }

        It 'Should have Identity, InputObject and DisplayName parameter sets' {
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'Identity'
            $command.ParameterSets.Name | Should -Contain 'InputObject'
            $command.ParameterSets.Name | Should -Contain 'DisplayName'
        }
    }

    Context 'Identity parameter set' {
        It 'Should resolve team and query groups/{id} endpoint with assignedLabels select' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockLabelResponse }

            $result = Get-PSMsTeamsTeamLabel -Identity '00000000-0000-0000-0000-000000000001'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'groups/' -and $Method -eq 'Get'
            }
        }

        It 'Should return TeamLabel objects with LabelId and DisplayName' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockLabelResponse }

            $result = Get-PSMsTeamsTeamLabel -Identity '00000000-0000-0000-0000-000000000001'

            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].LabelId | Should -Be 'aaaa-bbbb-cccc'
            $result[0].DisplayName | Should -Be 'Confidential'
            $result[1].LabelId | Should -Be 'dddd-eeee-ffff'
            $result[1].DisplayName | Should -Be 'Internal'
        }
    }

    Context 'DisplayName parameter set' {
        It 'Should query groups endpoint with displayName filter' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return @($script:mockLabelResponse) }

            $result = Get-PSMsTeamsTeamLabel -DisplayName 'TestTeam'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -eq 'groups' -and $Method -eq 'Get'
            }
        }
    }

    Context 'InputObject parameter set' {
        It 'Should query groups/{id} for labels when InputObject is provided' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockLabelResponse }

            Get-PSMsTeamsTeamLabel -InputObject $mockTeam

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'groups/' -and $Method -eq 'Get'
            }
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }
            { Get-PSMsTeamsTeamLabel -Identity 'test' } | Should -Throw
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Get-PSMsTeamsTeamLabel -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped from Get-PSMsTeamsTeam' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockLabelResponse }

            { $mockTeam | Get-PSMsTeamsTeamLabel } | Should -Not -Throw
        }
    }
}
