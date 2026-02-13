function Remove-PSMsTeamsTeamChannel {
    <#
    .SYNOPSIS
        Delete a Microsoft Teams channel (standard, private, or shared).

    .DESCRIPTION
        Removes a channel from a Microsoft Teams team via Microsoft Graph API DELETE /teams/{team-id}/channels/{channel-id}.
        Fully supports pipeline, batch requests (PassThru), and robust error handling.

    .PARAMETER Identity
        Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER Channel
        Id of the channel to delete.

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
        PS C:\> Remove-PSMsTeamsTeamChannel -Identity team1 -ChannelId 19:xxxx@thread.tacv2

        Deletes the channel with Id `19:
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'RemoveChannel')]
    param(
        [Parameter(ParameterSetName = 'RemoveChannel', Mandatory = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(ParameterSetName = 'RemoveChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("ChannelId")]
        [ValidateNotNullOrEmpty()]
        [string] $Channel,
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
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
    }

    process {
        [string] $path = "teams/{0}/channels/{1}" -f $team.Id, $Channel
        if ($PassThru.IsPresent) {
            [PSMicrosoftEntraID.Batch.Request] @{Method = 'DELETE'; Url = ('/{0}' -f $path); Headers = $header }
        }
        else {
            Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Remove' -ActionStringValues $Channel -Target $team.DisplayName -ScriptBlock {
                [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Method Delete -ErrorAction Stop)
            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
