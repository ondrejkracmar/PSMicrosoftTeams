Describe 'Set-PSMsTeamsTeam' {
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
            $command = Get-Command -Name Set-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
            $command.Parameters.Keys | Should -Contain 'Confirm'
        }

        It 'Should have multiple parameter sets for different settings' {
            $command = Get-Command -Name Set-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'IdentityUpdateCommon'
            $command.ParameterSets.Name | Should -Contain 'IdentityFunSettings'
            $command.ParameterSets.Name | Should -Contain 'IdentityMemberSettings'
            $command.ParameterSets.Name | Should -Contain 'IdentityGuestSettings'
            $command.ParameterSets.Name | Should -Contain 'IdentityMessagingSettings'
        }

        It 'Should have valid Visibility values' {
            $command = Get-Command -Name Set-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Visibility']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Public'
            $validateSet.ValidValues | Should -Contain 'Private'
        }

        It 'Should have hashtable-typed settings parameters' {
            $command = Get-Command -Name Set-PSMsTeamsTeam -Module PSMicrosoftTeams
            foreach ($p in @('FunSettings', 'MemberSettings', 'GuestSettings', 'MessagingSettings')) {
                $command.Parameters[$p].ParameterType | Should -Be ([hashtable]) -Because "Parameter '$p' should be hashtable"
            }
        }
    }

    Context 'Identity parameter set' {
        It 'Should resolve team and call PATCH on teams endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            Set-PSMsTeamsTeam -Identity 'testteam' -DisplayName 'NewName' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/' -and $Method -eq 'Patch'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Set-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Set-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped via pipeline' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { }

            { $mockTeam | Set-PSMsTeamsTeam -DisplayName 'NewName' -Force -Confirm:$false } | Should -Not -Throw
        }
    }
}
