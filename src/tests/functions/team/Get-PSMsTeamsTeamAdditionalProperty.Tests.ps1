Describe 'Get-PSMsTeamsTeamAdditionalProperty' {
    BeforeAll {
        $global:testroot = $global:testroot | Where-Object { $_ }
        if (-not $global:testroot) { $global:testroot = Join-Path (Split-Path $PSScriptRoot -Parent) -ChildPath '..' }
        $moduleRoot = Join-Path $global:testroot 'PSMicrosoftTeams'
        if (-not (Get-Module PSMicrosoftTeams)) {
            Import-Module "$moduleRoot/PSMicrosoftTeams.psd1" -Force -ErrorAction Stop
        }
        $global:ConfirmPreference = 'None'

        $script:mockAdditionalProp = [PSCustomObject]@{
            Id            = '00000000-0000-0000-0000-000000000001'
            DisplayName   = 'TestTeam'
            FunSettings   = @{ AllowGiphy = $true }
            GuestSettings = @{ AllowGuestCreateUpdateChannels = $false }
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
            $command = Get-Command -Name Get-PSMsTeamsTeamAdditionalProperty -Module PSMicrosoftTeams
            $command.OutputType.Name | Should -Contain 'PSMicrosoftTeams.Teams.TeamAdditionalProperty'
        }

        It 'Should have Identity parameter with aliases' {
            $command = Get-Command -Name Get-PSMsTeamsTeamAdditionalProperty -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            $param.Aliases | Should -Contain 'Id'
        }
    }

    Context 'Identity parameter set' {
        It 'Should resolve team and query teams/{id} endpoint' {
            $mockTeam = [PSCustomObject]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockAdditionalProp }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockAdditionalProp }

            Get-PSMsTeamsTeamAdditionalProperty -Identity 'testteam'

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -Times 1 -ParameterFilter {
                $Path -match 'teams/'
            }
        }
    }

    Context 'Pipeline input' {
        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Get-PSMsTeamsTeamAdditionalProperty -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should accept Identity from pipeline by property name' {
            $command = Get-Command -Name Get-PSMsTeamsTeamAdditionalProperty -Module PSMicrosoftTeams
            $param = $command.Parameters['Identity']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipelineByPropertyName }).Count |
                Should -BeGreaterThan 0
        }

        It 'Should process InputObject piped from Get-PSMsTeamsTeam' {
            $mockTeam = [PSMicrosoftTeams.Teams.Team]@{ Id = '00000000-0000-0000-0000-000000000001'; DisplayName = 'TestTeam' }
            Mock -ModuleName PSMicrosoftTeams Get-PSMsTeamsTeam { return $mockTeam }
            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' { return $script:mockAdditionalProp }
            Mock -ModuleName PSMicrosoftTeams ConvertFrom-RestObject { return $script:mockAdditionalProp }

            { $mockTeam | Get-PSMsTeamsTeamAdditionalProperty } | Should -Not -Throw
        }
    }
}
