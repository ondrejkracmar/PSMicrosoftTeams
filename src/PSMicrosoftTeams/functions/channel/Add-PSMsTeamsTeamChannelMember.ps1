function Add-PSMsTeamsTeamChannelMember {
    <#
    .SYNOPSIS
    Add a user (member/owner/guest) to a Microsoft Teams channel (standard/private/shared), including cross-tenant users.

    .DESCRIPTION
    Adds each user from the pipeline to the specified channel, using Microsoft Graph API POST /teams/{team-id}/channels/{channel-id}/members.

    .PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER Channel
    Id of the channel within the team.

    .PARAMETER TenantId
    (For external users in shared channels) The external tenant Id.

    .PARAMETER User
    UserPrincipalName, UserId, email, or (for cross-tenant) directoryObjectId; pipeline input.

    .PARAMETER Role
    Membership role for the channel. Valid values: member, owner.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

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
        PS C:\> 'user1@contoso.com','user2@extdomain.com' | Add-PSMsTeamsTeamChannelMember -Identity team1 -Channel channel1

        Add users to channel1 of team1, using their UPNs.

    .EXAMPLE
        PS C:\> 'externaluser@extdomain.com | Add-PSMsTeamsTeamChannelMember -Identity team1 -Channel channel1 -TenantId <tenant-guid>

        Add an external user to channel1 of team1, specifying the external tenant Id.
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'IdentityInputObject')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityInputObject')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityUser')]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityInputObject')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityUser')]
        [Alias("ChannelId")]
        [string] $Channel,
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ParameterSetName = 'IdentityInputObject')]
        [PSMicrosoftEntraID.Users.User[]] $InputObject,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUser')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Alias("UserId", "UserPrincipalName", "Mail")]
        [ValidateUserIdentity()]
        [string[]] $User,
        [Parameter()]
        [ValidateSet('Member', 'Owner')]
        [string] $Role = 'Member',
        [Parameter()]
        [ValidateGuid()]
        [string] $TenantId,
        [Parameter()]
        [switch] $EnableException,
        [Parameter()]
        [switch] $Force,
        [Parameter()]
        [switch]$PassThru
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{
            'Content-Type' = 'application/json'
        }
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
        switch ($PSCmdlet.ParameterSetName) {
            'IdentityUser' {
                [string] $userActionString = ($User | ForEach-Object { "{0}" -f $_ }) -join ','
            }
            'IdentityInputObject' {
                [string] $userActionString = ($InputObject.UserPrincipalName | ForEach-Object { "{0}" -f $_ }) -join ','
            }
        }
        switch ($PSCmdlet.ParameterSetName) {
            'IdentityInputObject' {
                foreach ($itemInputObject in $InputObject) {
                    [hashtable] $body = @{}
                    $body['@odata.type'] = 'microsoft.graph.aadUserConversationMember'
                    $body['user@odata.bind'] = ("{0}/users/'1}'" -f (Get-EntraService -Name $service).ServiceUrl, $itemInputObject.Id)
                    if (Test-PSFParameterBinding -ParameterName 'Roles') {
                        $body['roles'] = @($Role.ToLower())
                    }
                    else {
                        $body['roles'] = @($Role.ToLower())
                    }
                    if (Test-PSFParameterBinding -ParameterName 'TenantId') { $body['tenantId'] = $TenantID }
                    [string] $path = ("teams/{0}/channels/{1}/members" -f $team.Id, $Channel)
                    if ($PassThru.IsPresent) {
                        [PSMicrosoftTeams.Batch.Request] @{ Method = 'POST'; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        Invoke-PSFProtectedCommand -ActionString 'TeamChannelMember.Add' -ActionStringValues $userActionString -Target $teamChannel.DisplayName, $team.DisplayName, -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method $requestHash.Method -ErrorAction Stop)
                        } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }
            }
            'IdentityUser' {
                foreach ($itemUser in $User) {
                    [PSMicrosoftEntraID.Users.User] $aADUser = Get-PSMsTeamsTeamUser -Identity $itemUser
                    if (-not([object]::Equals($aADUser, $null))) {
                        [hashtable] $body = @{}
                        $body['@odata.type'] = 'microsoft.graph.aadUserConversationMember'
                        $body['user@odata.bind'] = ("{0}/users/'1}'" -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                        if (Test-PSFParameterBinding -ParameterName 'Roles') {
                            $body['roles'] = @($Role.ToLower())
                        }
                        else {
                            $body['roles'] = @($Role.ToLower())
                        }
                        if (Test-PSFParameterBinding -ParameterName 'TenantId') { $body['tenantId'] = $TenantID }
                        [string] $path = ("teams/{0}/channels/{1}/members" -f $team.Id, $Channel)
                        if ($PassThru.IsPresent) {
                            [PSMicrosoftTeams.Batch.Request] @{ Method = 'POST'; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                        }
                        else {
                            Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Add' -ActionStringValues $userActionString -Target $teamChannel.DisplayName, $team.DisplayName, -ScriptBlock {
                                [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method $requestHash.Method -ErrorAction Stop)
                            } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                            if (Test-PSFFunctionInterrupt) { return }
                        }
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $itemUser)
                        }
                    }
                }
            }
        }
    }
    end {}
}
