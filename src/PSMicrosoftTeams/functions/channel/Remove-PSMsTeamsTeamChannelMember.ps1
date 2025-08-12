function Remove-PSMsTeamsTeamChannelMember {
    <#
    .SYNOPSIS
        Remove a user (member/owner/guest) from a Microsoft Teams channel (standard/private/shared), including cross-tenant users.

    .DESCRIPTION
        Removes a user from the specified Teams channel using Microsoft Graph API DELETE /teams/{team-id}/channels/{channel-id}/members/{membership-id}.
        Supports pipeline input, handles all channel types, and batch (PassThru).

    .PARAMETER Identity
        Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER Channel
        Id of the channel within the team.

    .PARAMETER MembershipId
        The membershipId (object id) of the member in the channel. You can retrieve these via Get-PSMsTeamsTeamChannelMember.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user frien
        dly, but allows catching exceptions in calling scripts.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Force
        The Force switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Force switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .PARAMETER Confirm
        The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .PARAMETER PassThru
        When specified, the cmdlet will not execute the disable license action but will instead
        return a `PSMicrosoftEntraID.Batch.Request` object for batch processing.

    .EXAMPLE
        PS C:\> Remove-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:... -MembershipId aabbcc1122

        Removes the user with membershipId `aabbcc1122` from the channel with Id `19:...` in team `team1`.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:... | Where-Object { $_.displayName -eq "User1" } | Remove-PSMsTeamsTeamChannelMember -Identity team1 -Channel 19:...

        Removes the user with displayName "User1" from the channel with Id `19:...` in team `team1`.
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'RemoveMemberById')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'RemoveMemberById')]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(Mandatory = $true, ParameterSetName = 'RemoveMemberById')]
        [Alias("ChannelId")]
        [string] $Channel,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RemoveMemberById')]
        [Alias("Membership")]
        [string[]] $MembershipId,
        [Parameter()]
        [switch] $EnableException,
        [Parameter()]
        [switch] $Force,
        [Parameter()]
        [switch] $PassThru
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{ 'Content-Type' = 'application/json' }
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
        [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity
        if ([object]::Equals($team, $null)) {
            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
        }
        [PSMicrosoftTeams.Channels.Channel] $teamChannel = Get-PSMsTeamsTeamChannel -Identity $Identity -Channel $Channel
        if ([object]::Equals($teamChannel, $null)) {
            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
        }
    }
    process {
        foreach ($itemMembershipId in $MembershipId) {
            [string] $path = "teams/{0}/channels/{1}/members/{2}" -f $team.Id, $teamChannel.Id, $itemMembershipId
            if ($PassThru.IsPresent) {
                [PSMicrosoftTeams.Batch.Request] @{Method = 'DELETE'; Url = ('/{0}' -f $path); Headers = $header}
            }
            else {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannelMember.Remove' -ActionStringValues $itemMembershipId -Target $teamChannel.DisplayName, $team.DisplayName -ScriptBlock {
                    [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Method Delete -ErrorAction Stop)
                } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                if (Test-PSFFunctionInterrupt) { return }
            }
        }
    }
    end {}
}
