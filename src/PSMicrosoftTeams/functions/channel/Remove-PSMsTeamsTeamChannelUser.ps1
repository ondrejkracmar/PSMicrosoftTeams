function Remove-PSMsTeamsTeamChannelUser {
<#
.SYNOPSIS
    Remove a user from a Microsoft Teams channel.

.DESCRIPTION
    Removes a user (channel member) from the specified channel using Microsoft Graph API DELETE /teams/{team-id}/channels/{channel-id}/members/{membershipId}.

.PARAMETER MembershipId
    MembershipId of the channel member to remove. **Pipeline input**.

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER ChannelId
    Id of the channel within the team.

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.EXAMPLE
    # Remove by explicit MembershipId(s)
    Remove-PSMsTeamsTeamChannelUser -Identity team1 -ChannelId channel1 -MembershipId 7f0b...

.EXAMPLE
    # Remove by pipeline from Get-PSMsTeamsTeamChannelMember
    Get-PSMsTeamsTeamChannelMember -Identity team1 -ChannelId channel1 | Remove-PSMsTeamsTeamChannelUser -Identity team1 -ChannelId channel1
#>
    [OutputType('PSMicrosoftTeams.Members.Member')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Membership')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
        [string[]] $MembershipId,

        [Parameter(Mandatory = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $true)]
        [Alias("Channel")]
        [string] $ChannelId,

        [Parameter()]
        [switch] $EnableException,

        [Parameter()]
        [switch] $Force
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
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
        foreach ($id in $MembershipId) {
            $path = "teams/$teamId/channels/$ChannelId/members/$id"
            if ($PSCmdlet.ShouldProcess("$id", "Remove user from channel")) {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannelUser.Remove' -ActionStringValues $id, $ChannelId -Target $teamId -ScriptBlock {
                    [void](Invoke-EntraRequest -Service $service -Path $path -Method Delete -Verbose:$cmdLetVerbose -ErrorAction Stop)
                } -EnableException:$EnableException -Confirm:$Force -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                if (Test-PSFFunctionInterrupt) { return }
            }
        }
    }
    end {}
}
