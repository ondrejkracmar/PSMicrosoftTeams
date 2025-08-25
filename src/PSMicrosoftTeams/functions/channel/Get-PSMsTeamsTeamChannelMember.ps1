function Get-PSMsTeamsTeamChannelMember {
    <#
    .SYNOPSIS
    Get members of a Microsoft Teams channel.

    .DESCRIPTION
    Returns members of the specified Teams channel using Microsoft Graph API.
    By default, retrieves only explicit channel members (owners, members, guests) via `/teams/{team-id}/channels/{channel-id}/members`.
    When the `-All` switch is used, retrieves **all users who have access to the channel** (including inherited membership, e.g. for standard channels – all team members; for private/shared channels – explicit channel members and any guests), via `/teams/{team-id}/channels/{channel-id}/allMembers`.
    For details, see [List members](https://learn.microsoft.com/en-us/graph/api/channel-list-members?view=graph-rest-1.0&tabs=http) and [List allMembers](https://learn.microsoft.com/en-us/graph/api/channel-list-allmembers?view=graph-rest-1.0&tabs=http) in Microsoft Graph API documentation.

    .PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER Channel
    Id of the channel within the team.

    .PARAMETER All
    When specified, lists all users who have access to the channel (not just explicit channel members).

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:xxxxxxxxxx@thread.tacv2

        Returns explicit members of the channel (owners, members, guests – only users directly added to this channel)

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:xxxxxxxxxx@thread.tacv2 -All

        Returns **all users who have access** to the channel, including inherited team membership

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:xxxxxxxxxx@thread.tacv2 | Where-Object { $_.Roles -contains 'owner' }

        List only owners of the channel

    .EXAMPLE

        PS C:\> Get-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:xxxxxxxxxx@thread.tacv2 | Where-Object { $_.UserType -eq 'Guest' }

        List all external (guest or B2B) members in a private channel

    .NOTES
        - Using the `-All` switch calls `/teams/{team-id}/channels/{channel-id}/allMembers` and includes all users with access to the channel, not just explicit channel members.
        - Without `-All`, only direct channel members (owners, members, guests) are returned (via `/members` endpoint).
        - See: https://learn.microsoft.com/en-us/graph/api/channel-list-members
           https://learn.microsoft.com/en-us/graph/api/channel-list-allmembers
#>
    [OutputType('PSMicrosoftTeams.Members.ConversationMember')]
    [CmdletBinding(SupportsShouldProcess = $false, DefaultParameterSetName = 'IdentityChannel')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Alias("ChannelId")]
        [string] $Channel,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch] $All,
        [Parameter()]
        [switch] $EnableException
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        $query = @{
            #'$count'  = 'true'
            '$top' = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            #'$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.ChannelMember).Value -join ',')
        }
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{}

    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'IdentityChannel' {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannelCahnnelMember.Get' -ActionStringValues $Channel -Target $Identity -ScriptBlock {
                    [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity -EnableException:$EnableException
                    if (-not([object]::Equals($team, $null))) {
                        if (Test-PSFParameterBinding -ParameterName 'All') {
                            [string] $path = ('teams/{0}/channels/{1}/allMembers' -f $team.Id, $Channel)
                        }
                        else {
                            [string] $path = ('teams/{0}/channels/{1}/members' -f $team.Id, $Channel)
                        }
                        ConvertFrom-RestConversationMember -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
                        }
                    }
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                if (Test-PSFFunctionInterrupt) { return }
            }
        }
    }
    end {}
}
