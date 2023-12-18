function Get-PSMsTeamsTeam {
    <#
        .SYNOPSIS
            Get the properties of the specified team.

        .DESCRIPTION
            Get the properties of the specified team.

        .PARAMETER Identity
            MailnicName, Mail or Id of the team attribute populated in tenant/directory.

        .PARAMETER DisplayName
            DIsplayName of the group attribute populated in tenant/directory.

        .PARAMETER Filter
            Filter expressions of accounts in tenant/directory.

        .PARAMETER AdvancedFilter
            Switch advanced filter for filtering accounts in tenant/directory.

        .PARAMETER All
            Return all accounts in tenant/directory.

        .PARAMETER EnableException
            This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
            but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS C:\> Get-PSMsTeamsTeam -Identity team1

            Get properties of Microsoft Teams team1

    #>
    [OutputType('PSMicrosoftEntraID.Team')]
    [CmdletBinding(DefaultParameterSetName = 'Identity')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [ValidateGroupIdentity()]
        [string[]]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        $Identity,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'DisplayName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $DisplayName,
        [Parameter(Mandatory = $True, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [switch]$AdvancedFilter,
        [Parameter(Mandatory = $True, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'All')]
        [ValidateNotNullOrEmpty()]
        [switch]$All,
        [switch]$EnableException
    )

    begin {
        Assert-RestConnection -Service 'graph' -Cmdlet $PSCmdlet
        $query = @{
            '$count'  = 'true'
            '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Team).Value -join ',')
        }
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Identity' {
                foreach ($group in $Identity) {
                    $mailNickNameQuery = @{
                        #'$count'  = 'true'
                        '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
                        '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Team).Value -join ',')
                    }
                    $mailNickNameQuery['$Filter'] = ("resourceProvisioningOptions/Any(x:x eq 'Team') and mailNickName eq '{0}'" -f $group)

                    Invoke-PSFProtectedCommand -ActionString 'Team.Get' -ActionStringValues $group -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        $mailNickName = Invoke-RestRequest -Service 'graph' -Path ('groups') -Query $mailNickNameQuery -Method Get -ErrorAction Stop | ConvertFrom-RestTeam
                        if (-not([object]::Equals($mailNickName, $null))) {
                            $groupId = $mailNickName[0].Id
                        }
                        else {
                            $groupId = $group
                        }
                        Invoke-RestRequest -Service 'graph' -Path ('groups/{0}' -f $groupId) -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeam
                    } -EnableException $EnableException -Continue -PSCmdlet $PSCmdlet -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'DisplayName' {
                foreach ($group in $DisplayName) {
                    $query['$Filter'] = ("resourceProvisioningOptions/Any(x:x eq 'Team') and startswith(displayName,'{0}')" -f $group)
                    Invoke-PSFProtectedCommand -ActionString 'Team.Get' -ActionStringValues $group -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        Invoke-RestRequest -Service 'graph' -Path ('groups') -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeam
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'Filter' {
                $query['$Filter'] = ("resourceProvisioningOptions/Any(x:x eq 'Team') and {0}" -f $Filter)
                if ($AdvancedFilter.IsPresent) {
                    $header = @{}
                    $header['ConsistencyLevel'] = 'eventual'
                    Invoke-PSFProtectedCommand -ActionString 'Team.Filter' -ActionStringValues $query['$Filter'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        Invoke-RestRequest -Service 'graph' -Path ('groups') -Query $query -Method Get -Header $header -ErrorAction Stop | ConvertFrom-RestTeam
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                }
                else {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Filter' -ActionStringValues $query['$Filter'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        Invoke-RestRequest -Service 'graph' -Path ('groups') -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeam
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                }
                if (Test-PSFFunctionInterrupt) { return }
            }
            'All' {
                if ($All.IsPresent) {
                    $query['$Filter'] = "resourceProvisioningOptions/Any(x:x eq 'Team')"
                    Invoke-PSFProtectedCommand -ActionString 'Team.List' -ActionStringValues $query['$Filter'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        Invoke-RestRequest -Service 'graph' -Path ('groups') -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeam
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }
    end {}
}