function Add-PSMsTeamsTeamMember {
    <#
    .SYNOPSIS
    Add a member or owner to a Microsoft Teams team.

    .DESCRIPTION
    Adds a user (or multiple users) as member/owner to the specified Microsoft Teams team (POST /teams/{id}/members/add).
    Accepts user identities (UPN, ID, email) or InputObject (user object).

    .PARAMETER Identity
    Team Id, GroupId, MailNickname, or other unique team identifier.

    .PARAMETER InputObject
    User object(s) (from Get-PSMsTeamsUser).

    .PARAMETER User
    UserPrincipalName, Mail, or Id of the user(s) to add.

    .PARAMETER Role
    Role for new member(s): "Member" (default) or "Owner".

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
        PS C:\> Add-PSMsTeamsTeamMember -Identity "team1" -User "user1@contoso.com","user2@contoso.com" -Role Owner

        Adds user1 and user2 as owners to the team with identity "team1".
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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUser')]
        [Alias("UserId", "UserPrincipalName", "Mail")]
        [ValidateUserIdentity()]
        [string[]] $User,
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ParameterSetName = 'IdentityInputObject')]
        [PSMicrosoftEntraID.Users.User[]] $InputObject,
        [Parameter(ParameterSetName = 'IdentityInputObject')]
        [Parameter(ParameterSetName = 'IdentityUser')]
        [ValidateSet("Member", "Owner")]
        [ValidateNotNullOrEmpty()]
        [string] $Role = "Member",
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
        $team = Get-PSMsTeamsTeam -Identity $Identity
        if ([object]::Equals($team, $null)) {
            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
        }
    }
    process {
        [System.Collections.ArrayList] $bodyMemberUrlList = [System.Collections.ArrayList]::new()
        [System.Collections.ArrayList] $memberUserPrincipalListList = [System.Collections.ArrayList]::new()
        switch ($PSCmdlet.ParameterSetName) {
            'IdentityInputObject' {
                foreach ($itemInputObject in $InputObject) {
                    [void] $bodyMemberUrlList.Add(
                        @{
                            '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                            'roles'           = @($Role.ToLower())
                            'user@odata.bind' = ('{0}/users(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $itemInputObject.Id)
                        }
                    )
                    [void] $memberUserPrincipalListList.Add($itemInputObject.UserPrincipalName)
                }
            }
            'IdentityUser' {
                foreach ($itemUser in $User) {
                    [PSMicrosoftEntraID.Users.User] $teamUser = Get-PSMsTeamsUser -Identity $itemUser
                    if (-not([object]::Equals($teamUser, $null))) {
                        [void] $bodyMemberUrlList.Add(
                            @{
                                '@odata.type'     = "#microsoft.graph.aadUserConversationMember"
                                'roles'           = @($Role.ToLower())
                                'user@odata.bind' = ('{0}/users(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $teamUser.Id)
                            }
                        )
                        [void] $memberUserPrincipalListList.Add($teamUser.UserPrincipalName)
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
    end {
        if ($bodyMemberUrlList.count -eq 1) {
            $path = ('teams/{0}/members' -f $team.Id)
            $method = 'POST'
            $body = $bodyMemberUrlList[0]

        }
        else {
            $path = ('teams/{0}/members/add' -f $team.Id)
            $body = @{ values = @($bodyMemberUrlList) }
            $method = 'POST'
        }

        Invoke-PSFProtectedCommand -ActionString 'TeamMember.Add' -ActionStringValues (($memberUserPrincipalListList | ForEach-Object { "{0}" -f $PSItem }) -join ','), $Role -Target $team.DisplayName -ScriptBlock {
            if ($PassThru.IsPresent) {
                [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
            }
            else {
                [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
            }
        } -EnableException $EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
        if (Test-PSFFunctionInterrupt) { return }
    }
}
