Describe 'Connect-PSMicrosoftTeams' {
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
        Mock -ModuleName PSMicrosoftTeams Get-PSFConfigValue { return $null }
        Mock -ModuleName PSMicrosoftTeams Test-PSFFunctionInterrupt { return $false }
    }

    Context 'Parameter validation' {
        It 'Should have multiple parameter sets for auth flows' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $command.ParameterSets.Name | Should -Contain 'Browser'
            $command.ParameterSets.Name | Should -Contain 'DeviceCode'
            $command.ParameterSets.Name | Should -Contain 'AppCertificate'
            $command.ParameterSets.Name | Should -Contain 'AppSecret'
            $command.ParameterSets.Name | Should -Contain 'UsernamePassword'
            $command.ParameterSets.Name | Should -Contain 'KeyVault'
            $command.ParameterSets.Name | Should -Contain 'Federated'
        }

        It 'Should have mandatory Service parameter' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['Service']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have TenantId parameter' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['TenantId']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have ClientId parameter' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['ClientId']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have Certificate parameter for Certificate flow' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['Certificate']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have ClientSecret parameter for AppSecret flow' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['ClientSecret']
            $param | Should -Not -BeNullOrEmpty
        }

        It 'Should have Browser switch for Browser flow' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['Browser']
            $param.ParameterType | Should -Be ([switch])
        }

        It 'Should have DeviceCode switch for DeviceCode flow' {
            $command = Get-Command -Name Connect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['DeviceCode']
            $param.ParameterType | Should -Be ([switch])
        }
    }

    Context 'Browser flow' {
        It 'Should invoke Connect-EntraService internally' {
            Mock -ModuleName PSMicrosoftTeams Connect-EntraService { }
            Mock -ModuleName PSMicrosoftTeams Get-EntraService { [PSCustomObject]@{ Name = 'PSMicrosoftTeams.Graph' } }
            Mock -ModuleName PSMicrosoftTeams Get-PSFConfigValue {
                if ($FullName -match 'DefaultService') { return 'PSMicrosoftTeams.Graph' }
                return $null
            }

            Connect-PSMicrosoftTeams -Service 'PSMicrosoftTeams.Graph' -ClientId '00000000-0000-0000-0000-000000000001' -TenantId 'contoso.onmicrosoft.com' -Browser

            Should -Invoke -ModuleName PSMicrosoftTeams Connect-EntraService -Times 1
        }
    }
}
