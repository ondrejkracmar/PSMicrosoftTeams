﻿function Get-PSMsTeamsTeamMember {
    <#
    .SYNOPSIS
        Get an owner or member to the team, and to the unified group which backs the team.

    .DESCRIPTION
        This cmdlet get an owner or member of the team, and to the unified group which backs the team.

    .PARAMETER Identity
        MailNickName or Id of group or team.

    .PARAMETER Owner
        Member type owner.

    .PARAMETER Filter
        Filter expressions of groups in tenant/directory.

    .PARAMETER AdvancedFilter
        Switch advanced filter for filtering groups in tenant/directory.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamMember -Identity user1@contoso.com

		Get properties of Azure AD user user1@contoso.com


#>
    [OutputType('PSMicrosoftEntraID.User')]
    [CmdletBinding(DefaultParameterSetName = 'Identity')]
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [ValidateGroupIdentity()]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [string[]]$Identity,
        [Parameter(Mandatory = $False, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [switch]$Owner,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [switch]$AdvancedFilter,
        [switch]$EnableException
    )

    begin {
        Assert-RestConnection -Service 'graph' -Cmdlet $PSCmdlet
        $query = @{
            '$count'  = 'true'
            '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.TeamMember).Value -join ',')
        }
        $header = @{}
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Identity' {
                foreach ($itemIdentity in $Identity) {
                    $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                    if (-not([object]::Equals($team, $null))) {
                        if ($Owner.IsPresent) {
                            $path = ('groups/{0}/owners' -f $team.Id)
                        }
                        else {
                            $path = ('groups/{0}/members' -f $team.Id)
                        }
                        if (Test-PSFParameterBinding -ParameterName 'Filter') {
                            $query['$Filter'] = $Filter
                            if ($AdvancedFilter.IsPresent) {
                                $header['ConsistencyLevel'] = 'eventual'
                            }
                        }
                        Invoke-PSFProtectedCommand -ActionString 'TeamMember.List' -ActionStringValues $itemIdentity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                            Invoke-RestRequest -Service 'graph' -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop | ConvertFrom-RestTeamMember
                        } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $itemIdentity)
                        }
                    }
                }
            }
        }
    }
    end {

    }
}