Describe 'New-PSMsTeamsTeam' {
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
                { $_ -match 'PageSize' } { return 100 }
                { $_ -match 'RetryCount' } { return 3 }
                { $_ -match 'RetryWaitInSeconds' } { return 5 }
                default { return $null }
            }
        }
        Mock -ModuleName PSMicrosoftTeams Get-PSFLocalizedString { return 'Microsoft Graph' }
        Mock -ModuleName PSMicrosoftTeams Test-PSFFunctionInterrupt { return $false }
        Mock -ModuleName PSMicrosoftTeams Get-EntraService {
            [PSCustomObject]@{ ServiceUrl = 'https://graph.microsoft.com/v1.0' }
        }
    }

    Context 'Parameter validation' {
        It 'Should have InputObject as default parameter set' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.DefaultParameterSet | Should -Be 'InputObject'
        }

        It 'Should support ShouldProcess' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.Parameters.Keys | Should -Contain 'WhatIf'
            $command.Parameters.Keys | Should -Contain 'Confirm'
        }

        It 'Should have DisplayName as mandatory in Team set' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['DisplayName']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have valid Visibility values' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Visibility']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'Public'
            $validateSet.ValidValues | Should -Contain 'Private'
            $validateSet.ValidValues | Should -Contain 'HiddenMembership'
        }

        It 'Should have Force and PassThru switch parameters' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $command.Parameters['Force'].ParameterType | Should -Be ([switch])
            $command.Parameters['PassThru'].ParameterType | Should -Be ([switch])
        }

        It 'Should have team settings parameters' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $settingsParams = @('AllowGiphy', 'AllowStickersAndMemes', 'AllowCustomMemes',
                'AllowGuestCreateUpdateChannels', 'AllowGuestDeleteChannels',
                'AllowCreateUpdateChannels', 'AllowDeleteChannels',
                'AllowAddRemoveApps', 'AllowCreateUpdateRemoveTabs',
                'AllowUserEditMessages', 'AllowUserDeleteMessages',
                'AllowOwnerDeleteMessages', 'AllowTeamMentions', 'AllowChannelMentions')
            foreach ($p in $settingsParams) {
                $command.Parameters[$p] | Should -Not -BeNullOrEmpty -Because "Parameter '$p' should exist"
            }
        }
    }

    Context 'Team creation via Identity' {
        It 'Should call Invoke-EntraRequest with POST to teams endpoint' {
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return @{ id = 'new-team-id' } }
            Mock -ModuleName PSMicrosoftTeams Test-PSFParameterBinding { return $false }

            New-PSMsTeamsTeam -Identity '00000000-0000-0000-0000-000000000001' -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Method -eq 'Post' -or $Method -eq 'PUT'
            }
        }
    }

    Context 'Error handling' {
        It 'Should assert connection before executing' {
            Mock -ModuleName PSMicrosoftTeams Assert-EntraConnection { throw 'Not connected' }

            { New-PSMsTeamsTeam -Identity 'test' -Force -Confirm:$false } | Should -Throw
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept DisplayName from pipeline by property name' {
            $command = Get-Command -Name New-PSMsTeamsTeam -Module PSMicrosoftTeams
            $param = $command.Parameters['DisplayName']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }
    }
}
