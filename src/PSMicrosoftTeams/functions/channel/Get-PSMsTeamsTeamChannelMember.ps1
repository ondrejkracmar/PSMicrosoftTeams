function Get-PSMsTeamsTeamChannelMember {
<#
.SYNOPSIS
    Get members of a Microsoft Teams channel.

.DESCRIPTION
    Returns the members (including guests, cross-tenant) of the specified Teams channel via Microsoft Graph API (GET /teams/{team-id}/channels/{channel-id}/members).

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER ChannelId
    Id of the channel within the team.

.PARAMETER Filter
    Optional OData filter to restrict results (applies after retrieval).

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.EXAMPLE
    Get-PSMsTeamsTeamChannelMember -Identity team1 -ChannelId 19:...

.EXAMPLE
    # With OData filter (e.g. only owners)
    Get-PSMsTeamsTeamChannelMember -Identity team1 -ChannelId 19:... | Where-Object { $_.Roles -contains "owner" }
#>
    [OutputType('PSMicrosoftTeams.Members.Member')]
    [CmdletBinding(SupportsShouldProcess = $false, DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $true)]
        [Alias("Channel")]
        [string] $ChannelId,

        [Parameter()]
        [switch] $EnableException
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        $query = @{
            '$top'    = 100
            '$count'  = 'true'
            '$select' = 'id,roles,displayName,email,userId,tenantId'
        }

        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')) {
            [boolean] $cmdLetVerbose = $true
        } else {
            [boolean] $cmdLetVerbose = $false
        }
        $teamObj = Get-PSMsTeamsTeam -Identity $Identity -EnableException:$EnableException
        if ([object]::Equals($teamObj, $null) -or -not $teamObj.Id) {
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
        $teamId = $teamObj.Id
    }
    process {
        
        $path = "teams/$teamId/channels/$ChannelId/members"
        Write-Verbose "Retrieving channel members from $path"
        Invoke-PSFProtectedCommand -ActionString 'TeamChannelMember.Get' -ActionStringValues $ChannelId -Target $teamId -ScriptBlock {
            Invoke-EntraRequest -Service $service -Path $path -Query $query -Method Get -Verbose:$cmdLetVerbose -ErrorAction Stop | ConvertFrom-RestTeamChannelMember
        } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
        if (Test-PSFFunctionInterrupt) { return }
    }
    end {}
}
