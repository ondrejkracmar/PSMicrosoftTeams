function Add-PSMsTeamsTeamChannelUser {
    <#
.SYNOPSIS
    Add a user (member/owner/guest) to a Microsoft Teams channel (standard/private/shared), including cross-tenant users.

.DESCRIPTION
    Adds each user from the pipeline to the specified channel, using Microsoft Graph API POST /teams/{team-id}/channels/{channel-id}/members.

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER ChannelId
    Id of the channel within the team.

.PARAMETER TenantId
    (For external users in shared channels) The external tenant Id.

.PARAMETER User
    UserPrincipalName, UserId, email, or (for cross-tenant) directoryObjectId; pipeline input.

.PARAMETER Role
    Membership role for the channel. Valid values: member, owner.

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.EXAMPLE
    'user1@contoso.com','user2@extdomain.com' | Add-PSMsTeamsTeamChannelUser -Identity team1 -ChannelId channel1

.EXAMPLE
    'externaluser@extdomain.com' | Add-PSMsTeamsTeamChannelUser -Identity team1 -ChannelId channel1 -TenantId <tenant-guid>
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType('PSMicrosoftTeams.Members.Member')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'User')]
    param(

        [Parameter(Mandatory = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $true)]
        [Alias("Channel")]
        [string] $ChannelId,

        [Parameter(Mandatory = $false)]
        [string] $TenantId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias("UserId", "UserPrincipalName", "Mail")]
        [string] $User,

        [Parameter(Mandatory = $false)]
        [ValidateSet('member', 'owner')]
        [string] $Role = 'member',

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
        [hashtable] $header = @{ 'Content-Type' = 'application/json' }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')) {
            [boolean] $cmdLetVerbose = $true
        }
        else {
            [boolean] $cmdLetVerbose = $false
        }
        $teamObj = Get-PSMsTeamsTeam -Identity $Identity -EnableException:$EnableException
        if ([object]::Equals($teamObj, $null) -or -not $teamObj.Id) {
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
        $teamId = $teamObj.Id
        $path = "teams/$teamId/channels/$ChannelId/members"
    }
    process {
        $memberObj = @{
            '@odata.type' = 'microsoft.graph.aadUserConversationMember'
            'roles'       = @($Role.ToLower())
        }
        if ($TenantId) {
            # Cross-tenant: shared channel B2B/B2B Direct
            $memberObj['user@odata.bind'] = ('{0}/directoryObjects/{1}' -f (Get-EntraService -Name $service).ServiceUrl, $User)
            $memberObj['tenantId'] = $TenantId
        }
        else {
            # Lokální user (UPN/email/Id)
            $userObj = Get-PSMsTeamsUser -Identity $User
            if ([object]::Equals($userObj, $null) -or -not $userObj.Id) {
                if ($EnableException.IsPresent) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $User)
                }
            }
            $memberObj['user@odata.bind'] = ('{0}/users/{1}' -f (Get-EntraService -Name $service).ServiceUrl, $userObj.Id)
        }
        $body = $memberObj
        if ($PSCmdlet.ShouldProcess("$User -> $ChannelId", "Add user to channel")) {
            Invoke-PSFProtectedCommand -ActionString 'TeamChannelUser.Add' -ActionStringValues $User, $ChannelId -Target $teamId -ScriptBlock {
                [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -Verbose:$cmdLetVerbose -ErrorAction Stop)
            } -EnableException:$EnableException -Confirm:$Force -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
