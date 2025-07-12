function Remove-PSMsTeamsTeamChannel {
<#
.SYNOPSIS
    Delete a channel from a Microsoft Teams team.

.DESCRIPTION
    Deletes the specified channel from the specified Microsoft Teams team (Graph API DELETE /teams/{team-id}/channels/{channel-id}).

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER ChannelId
    Id of the channel to delete.

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.EXAMPLE
    Remove-PSMsTeamsTeamChannel -Identity team1 -ChannelId 19:xxxx...
#>
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Default')]
    param(
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
        
    }
    process {
        $path = "teams/$teamId/channels/$ChannelId"
        if ($PSCmdlet.ShouldProcess("$ChannelId", "Delete channel from team $teamId")) {
            Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Remove' -ActionStringValues $ChannelId -Target $teamId -ScriptBlock {
                [void](Invoke-EntraRequest -Service $service -Path $path -Method Delete -Verbose:$cmdLetVerbose -ErrorAction Stop)
            } -EnableException:$EnableException -Confirm:$Force -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
