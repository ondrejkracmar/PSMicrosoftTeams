function New-PSMsTeamsTeamChannel {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    <#
    .SYNOPSIS
        Create new Microsoft Teams channel (standard, private, shared).

    .DESCRIPTION
        Creates a Microsoft Teams channel via Microsoft Graph API POST /teams/{team-id}/channels.
        For private/shared channels, supports initial owners/members assignment.

    .PARAMETER Identity
        Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER DisplayName
        Channel name (required, max 50 chars).

    .PARAMETER Description
        Channel description (optional).

    .PARAMETER MembershipType
        Channel type: standard (default), private, or shared.

    .PARAMETER Owners
        UPNs/Ids of channel owners (for private/shared only).

    .PARAMETER Members
        UPNs/Ids of channel members (for private/shared only).

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
        PS C:\> New-PSMsTeamsTeamChannel -Identity team1 -DisplayName "IT Only" -MembershipType private -Owners "owner1@contoso.com" -Members "member1@contoso.com"

        Creates a private channel named "IT Only" in the team identified by `team1`, with specified owners and members.
#>
    [OutputType('PSMicrosoftTeams.Channel')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'CreateChannel')]
    param(
        [Parameter(ParameterSetName = 'CreateChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(ParameterSetName = 'CreateChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 50)]
        [string] $DisplayName,
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [string] $Description,
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('standard', 'private', 'shared')]
        [string] $MembershipType = 'standard',
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [ValidateUserIdentity()]
        [string[]] $Owners,
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [ValidateUserIdentity()]
        [string[]] $Members,
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
        [hashtable] $header = @{ 'Content-Type' = 'application/json' }
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
    }

    process {
        [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity
        if ([object]::Equals($team, $null)) {
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
        [string] $path = "teams/{0}/channels" -f $team.Id
        [hashtable] $body = @{}
        $body['displayName'] = $DisplayName
        $body['membershipType'] = $MembershipType
        if (Test-PSFParameterBinding -ParameterName 'Description') { $body['description'] = $Description }
        $userIdUriPathList = [System.Collections.ArrayList]::new()

        foreach ($owner in $Owners) {
            [PSMicrosoftEntraID.Users.User] $aADUser = Get-PSMsTeamsTeamUser -Identity $itemUser
            if (-not([object]::Equals($aADUser, $null))) {
                [void] $userIdUriPathList.Add(@{
                        '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                        'roles'           = @('owner')
                        'user@odata.bind' = ("{0}/users/'1}'" -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                    }
                )
            }
            else {
                if ($EnableException.IsPresent) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $owner)
                }
            }
        }
        foreach ($member in $Members) {
            [PSMicrosoftEntraID.Users.User] $aADUser = Get-PSMsTeamsTeamUser -Identity $itemUser
            if (-not([object]::Equals($aADUser, $null))) {
                [void]$userIdUriPathList.Add(
                    @{
                        '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                        'roles'           = @('member')
                        'user@odata.bind' = ("{0}/users/'1}'" -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                    }
                )
            }
            else {
                if ($EnableException.IsPresent) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $owner)
                }
            }
        }
        $body['members'] = $userIdUriPathList
        if ($PassThru.IsPresent) {
            [PSMicrosoftEntraID.Batch.Request] @{ Method = 'POST'; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
        }
        else {
            Invoke-PSFProtectedCommand -ActionString 'TeamChannel.New' -ActionStringValues $DisplayName -Target $team.DisplayName -ScriptBlock {
                ConvertFrom-RestTeamChannel -InputObject Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop
            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }

    }
    end {}
}
