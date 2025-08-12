function Remove-PSMsTeamsTeamMember {
    <#
    .SYNOPSIS
        Remove member(s) from a Microsoft Teams team.

    .DESCRIPTION
        Removes team members via Microsoft Graph API.
        - By membershipId: DELETE /teams/{team-id}/members/{membership-id}
        - By users (UPN/Id): resolves membershipId for each user and removes them.
        Supports bulk removal, robust error handling, confirmation, and retries.

    .PARAMETER Identity
        Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER MembershipId
        One or more membership IDs (microsoft.graph.conversationMember.Id) to remove.

    .PARAMETER User
        One or more users (UPN or Id) to remove from the team; their membershipId will be resolved before deletion.

    .PARAMETER InputObject
        Pipeline of user objects (PSMicrosoftTeams.Users.User) to remove; their membershipId will be resolved.

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
        PS C:\>  Remove-PSMsTeamsTeamMember -Identity team1 -MembershipId "ZWUwZjVhZTItOGJjNi00..."

        Remove membership with specified membershipId from team1.

    .EXAMPLE
        PS C:\> Remove-PSMsTeamsTeamMember -Identity team1 -User user1@contoso.com, 11111111-2222-3333-4444-555555555555

        Remove user(s) from team1 by resolving their membershipId.

    .EXAMPLE
        PS C:\>  Get-PSMsTeamsUser -Identity user1,user2 | Remove-PSMsTeamsTeamMember -Identity team1

        Remove users from team1 by resolving their membershipId from the pipeline.
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'InputObject')]
    param(
        # Team identity
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'MembershipId')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUser')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityInputObject')]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'MembershipId')]
        [string[]] $MembershipId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUser')]
        [Alias("UserId", "UserPrincipalName", "Mail")]
        [ValidateUserIdentity()]
        [string[]] $User,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IdentityInputObject')]
        [PSMicrosoftTeams.Users.User[]] $InputObject,
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
    }

    process {
        [System.Collections.ArrayList] $bodyMemberUrlList = [System.Collections.ArrayList]::new()
        [System.Collections.ArrayList] $memberUserPrincipalListList = [System.Collections.ArrayList]::new()
        switch ($PSCmdlet.ParameterSetName) {
            'MembershipId' {
                $method = 'DELETE'
                foreach ($itemMembershipId in $MembershipId) {
                    [string] $path = ('teams/{0}/members/{1}' -f $team.Id, $itemMembershipId)
                    if ($PassThru.IsPresent) {
                        [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        Invoke-PSFProtectedCommand -ActionString 'TeamMember.Remove.MembershipId' -ActionStringValues $team.DisplayName, $itemMembershipId -Target $teamId -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path $path -Method $method -ErrorAction Stop)
                        } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }
            }
            'IdentityUser' {
                foreach ($itemInputObject in $InputObject) {
                    [void] $bodyMemberUrlListt.Add(
                        @{
                            '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                            'user@odata.bind' = ('{0}/users/(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $itemInputObject.Id)
                        }
                    )
                    [void] $memberUserPrincipalListList.Add($itemInputObject.UserPrincipalName)
                }
            }
            'IdentityUser' {
                foreach ($itemUser in $User) {
                    [PSMicrosoftTeams.Users.User] $teamUser = Get-PSMsTeamsUser -Identity $itemUser
                    if (-not([object]::Equals($teamUser, $null))) {
                        $userUrl = "{0}/users/{1}" -f (Get-EntraService -Name $service).ServiceUrl, $userObj.Id
                        [void] $bodyMemberUrlList.Add(
                            @{
                                '@odata.type'     = "#microsoft.graph.aadUserConversationMember"
                                'user@odata.bind' = ('{0}/users/(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $itemInputObject.Id)
                            }
                        )
                        [void] $memberUserPrincipalListList.Add($teamUser.UserPrincipalName)
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $userId)
                        }
                    }
                }
            }
        }
    }
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'IdentityUser' {
                $method = 'DELETE'
                $path = ('teams/{0}/members/remove' -f $team.Id)
                $body = @{ values = @($bodyMemberUrlList) }
                $method = 'POST'
                if ($PassThru.IsPresent) {
                    [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                }
                else {
                    Invoke-PSFProtectedCommand -ActionString 'TeamMember.Remove' -ActionStringValues $team.DisplayName, (($memberUserPrincipalListList | ForEach-Object { "{0}" -f $psiTEM }) -join ',') -Target $teamId -ScriptBlock {
                        [void] (Invoke-EntraRequest -Service $service -Path $path -Method $method  -ErrorAction Stop)
                    } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'IdentityUser' {
                $path = ('teams/{0}/members/remove' -f $team.Id)
                $body = @{ values = @($bodyMemberUrlList) }
                $method = 'POST'
                if ($PassThru.IsPresent) {
                    [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                }
                else {
                    Invoke-PSFProtectedCommand -ActionString 'TeamMember.Remove' -ActionStringValues $team.DisplayName, (($memberUserPrincipalListList | ForEach-Object { "{0}" -f $psiTEM }) -join ',') -Target $teamId -ScriptBlock {
                        [void] (Invoke-EntraRequest -Service $service -Path $path -Method $method -ErrorAction Stop)
                    } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }
}
