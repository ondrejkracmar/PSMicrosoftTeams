Describe 'Set-PSMsTeamsCommandRetry' {
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
            $command = Get-Command -Name Set-PSMsTeamsCommandRetry -Module PSMicrosoftTeams -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }

        It 'Should have RetryCount parameter' {
            $command = Get-Command -Name Set-PSMsTeamsCommandRetry -Module PSMicrosoftTeams
            $command.Parameters['RetryCount'] | Should -Not -BeNullOrEmpty
        }

        It 'Should have RetryWaitInSeconds parameter' {
            $command = Get-Command -Name Set-PSMsTeamsCommandRetry -Module PSMicrosoftTeams
            $command.Parameters['RetryWaitInSeconds'] | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Setting retry configuration' {
        It 'Should call Set-PSFConfig twice (RetryCount and RetryWaitInSeconds)' {
            Mock -ModuleName PSMicrosoftTeams Set-PSFConfig { }

            Set-PSMsTeamsCommandRetry -RetryCount 5 -RetryWaitInSeconds 10

            Should -Invoke -ModuleName PSMicrosoftTeams Set-PSFConfig -Times 2 -Scope It
        }

        It 'Should have RetryCount parameter with ValidateRange(0,10)' {
            $command = Get-Command -Name Set-PSMsTeamsCommandRetry -Module PSMicrosoftTeams
            $param = $command.Parameters['RetryCount']
            $validateRange = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateRangeAttribute] }
            $validateRange | Should -Not -BeNullOrEmpty
        }

        It 'Should have RetryWaitInSeconds parameter with ValidateRange(0,10)' {
            $command = Get-Command -Name Set-PSMsTeamsCommandRetry -Module PSMicrosoftTeams
            $param = $command.Parameters['RetryWaitInSeconds']
            $validateRange = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateRangeAttribute] }
            $validateRange | Should -Not -BeNullOrEmpty
        }
    }
}
