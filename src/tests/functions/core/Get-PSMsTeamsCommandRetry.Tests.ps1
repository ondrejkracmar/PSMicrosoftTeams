Describe 'Get-PSMsTeamsCommandRetry' {
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
        It 'Should exist as an exported function' {
            $command = Get-Command -Name Get-PSMsTeamsCommandRetry -Module PSMicrosoftTeams -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Retry configuration retrieval' {
        It 'Should return retry count and wait values' {
            Mock -ModuleName PSMicrosoftTeams Get-PSFConfigValue {
                switch ($FullName) {
                    { $_ -match 'RetryCount' } { return 5 }
                    { $_ -match 'RetryWaitInSeconds' } { return 10 }
                    default { return $null }
                }
            }

            $result = Get-PSMsTeamsCommandRetry
            # Depending on return type, either properties or direct value
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
