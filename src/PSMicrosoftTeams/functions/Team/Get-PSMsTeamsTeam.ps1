function Get-PSMsTeamsTeam {
    <#
    .SYNOPSIS
     Get the properties of the specified team.

    .DESCRIPTION
       Get the properties of the specified team.

    .PARAMETER Identity
         MailnicName, Mail or Id of the team attribute populated in tenant/directory.

    .PARAMETER DisplayName
         DIsplayName of theoup attribute populated in tenant/directory.

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
    [OutputType('PSMicrosoftTeams.Teams.Team')]
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
        [Parameter()]
        [switch]$EnableException
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [hashtable] $query = @{
            '$count'  = 'true'
            '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Team).Value -join ',')
        }
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        [hashtable] $queryLocal = $query.Clone()
        switch ($PSCmdlet.ParameterSetName) {
            'Identity' {
                foreach ($team in $Identity) {
                    [hashtable] $mailNickNameQuery = @{
                        #'$count'  = 'true'
                        '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
                        '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Team).Value -join ',')
                    }
                    $mailNickNameQuery['$Filter'] = ("resourceProvisioningOptions/Any(x:x eq 'Team') and mailNickName eq '{0}'" -f $team)

                    Invoke-PSFProtectedCommand -ActionString 'Team.Get' -ActionStringValues $team -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        $mailNickName = Invoke-EntraRequest -Service $service -Path 'groups' -Query $mailNickNameQuery -Method Get -ErrorAction Stop
                        if (-not([object]::Equals($mailNickName, $null))) {
                            [string] $teamId = $mailNickName[0].Id
                        }
                        else {
                            [string] $teamId = $team
                        }
                        ConvertFrom-RestObject -Type ([PSMicrosoftTeams.Teams.Team]) -InputObject (Invoke-EntraRequest -Service $service -Path ('groups/{0}' -f $teamId) -Query $queryLocal -Method Get -ErrorAction Stop)
                    } -EnableException $EnableException -Continue -PSCmdlet $PSCmdlet -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'DisplayName' {
                foreach ($team in $DisplayName) {
                    $queryLocal['$Filter'] = ("startswith(displayName,'{0}')" -f $team)
                    Invoke-PSFProtectedCommand -ActionString 'Team.Get' -ActionStringValues $team -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        ConvertFrom-RestObject -Type ([PSMicrosoftTeams.Teams.Team]) -InputObject (Invoke-EntraRequest -Service $service -Path 'teams' -Query $queryLocal -Method Get -ErrorAction Stop)
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'Filter' {
                $queryLocal['$Filter'] = ("resourceProvisioningOptions/Any(x:x eq 'Team') and {0}" -f $Filter)
                if ($AdvancedFilter.IsPresent) {
                    [hashtable] $header = @{}
                    $header['ConsistencyLevel'] = 'eventual'
                    Invoke-PSFProtectedCommand -ActionString 'Team.Filter' -ActionStringValues $queryLocal['$Filter'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        ConvertFrom-RestObject -Type ([PSMicrosoftTeams.Teams.Team]) -InputObject (Invoke-EntraRequest -Service $service -Path 'teams' -Query $queryLocal -Method Get -Header $header -ErrorAction Stop)
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                }
                else {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Filter' -ActionStringValues $queryLocal['$Filter'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        ConvertFrom-RestObject -Type ([PSMicrosoftTeams.Teams.Team]) -InputObject (Invoke-EntraRequest -Service $service -Path ('teams') -Query $queryLocal -Method Get -ErrorAction Stop)
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                }
                if (Test-PSFFunctionInterrupt) { return }
            }
            'All' {
                if ($All.IsPresent) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.List' -ActionStringValues 'All' -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        ConvertFrom-RestObject -Type ([PSMicrosoftTeams.Teams.Team]) -InputObject (Invoke-EntraRequest -Service $service -Path 'teams' -Query $queryLocal -Method Get -ErrorAction Stop)
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }
    end {}
}