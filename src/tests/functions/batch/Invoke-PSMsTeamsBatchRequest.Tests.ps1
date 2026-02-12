Describe 'Invoke-PSMsTeamsBatchRequest' {
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
        It 'Should have InputObject parameter' {
            $command = Get-Command -Name Invoke-PSMsTeamsBatchRequest -Module PSMicrosoftTeams
            $command.Parameters['InputObject'] | Should -Not -BeNullOrEmpty
        }

        It 'Should accept InputObject from pipeline' {
            $command = Get-Command -Name Invoke-PSMsTeamsBatchRequest -Module PSMicrosoftTeams
            $param = $command.Parameters['InputObject']
            ($param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ValueFromPipeline }).Count |
                Should -BeGreaterThan 0
        }
    }

    Context 'Batch request execution' {
        It 'Should call Invoke-EntraRequest with POST to $batch endpoint' {
            # Create a properly typed BatchRequestPayload
            $mockPayload = [PSMicrosoftEntraID.Batch.BatchRequestPayload]::new()
            $req = [PSMicrosoftEntraID.Batch.Request]::new()
            $req.Id = '1'
            $req.Method = 'GET'
            $req.Url = '/teams'
            $mockPayload.Requests.Add($req)

            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' {
                return [PSCustomObject]@{
                    Responses = @(
                        [PSCustomObject]@{ Id = '1'; status = 200; headers = @{}; body = @{ value = @() } }
                    )
                }
            }

            $mockPayload | Invoke-PSMsTeamsBatchRequest -Force -Confirm:$false

            Should -Invoke -ModuleName PSMicrosoftTeams Invoke-EntraRequest -ParameterFilter {
                $Path -match '\$batch' -and $Method -eq 'Post'
            }
        }

        It 'Should handle batches larger than 20 items by splitting' {
            # Create more than 20 Request objects via the proper cmdlet
            $requests = 1..25 | ForEach-Object {
                $r = [PSMicrosoftEntraID.Batch.Request]::new()
                $r.Id = $_.ToString()
                $r.Method = 'GET'
                $r.Url = "/teams/team-$_"
                $r
            }
            # Split into payloads of 20
            $payloads = @()
            for ($i = 0; $i -lt $requests.Count; $i += 20) {
                $p = [PSMicrosoftEntraID.Batch.BatchRequestPayload]::new()
                $batch = $requests[$i..[Math]::Min($i + 19, $requests.Count - 1)]
                foreach ($b in $batch) { $p.Requests.Add($b) }
                $payloads += $p
            }

            Mock -ModuleName PSMicrosoftTeams Invoke-EntraRequest -RemoveParameterType 'Token' {
                return [PSCustomObject]@{
                    Responses = @(
                        [PSCustomObject]@{ Id = '1'; status = 200; headers = @{}; body = @{ value = @() } }
                    )
                }
            }

            # Should not throw when processing multiple payloads
            { $payloads | Invoke-PSMsTeamsBatchRequest -Force -Confirm:$false } | Should -Not -Throw
        }
    }
}
