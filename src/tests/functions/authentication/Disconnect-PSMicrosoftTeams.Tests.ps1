Describe 'Disconnect-PSMicrosoftTeams' {
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
        It 'Should have Service parameter' {
            $command = Get-Command -Name Disconnect-PSMicrosoftTeams -Module PSMicrosoftTeams
            $param = $command.Parameters['Service']
            $param | Should -Not -BeNullOrEmpty
        }
    }
}
