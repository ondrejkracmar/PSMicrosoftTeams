Describe 'ConvertFrom-RestObject' {
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
        It 'Should have Type parameter as mandatory' {
            $command = Get-Command -Name ConvertFrom-RestObject -Module PSMicrosoftTeams -ErrorAction SilentlyContinue
            if ($command) {
                $param = $command.Parameters['Type']
                $param | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should have InputObject parameter accepting pipeline input' {
            $command = Get-Command -Name ConvertFrom-RestObject -Module PSMicrosoftTeams -ErrorAction SilentlyContinue
            if ($command) {
                $param = $command.Parameters['InputObject']
                ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and ($_.ValueFromPipeline -or $_.ValueFromPipelineByPropertyName) }).Count |
                    Should -BeGreaterThan 0
            }
        }
    }

    Context 'JSON deserialization' {
        It 'Should handle null or empty InputObject gracefully' {
            InModuleScope PSMicrosoftTeams {
                { ConvertFrom-RestObject -InputObject $null -Type ([PSMicrosoftTeams.Teams.Team]) } | Should -Not -Throw
            }
        }
    }
}
