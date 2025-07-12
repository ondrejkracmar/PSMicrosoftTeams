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
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.PARAMETER WhatIf
    Simulates the operation.

.PARAMETER Confirm
    Prompts for confirmation before adding.

.EXAMPLE
    Add-PSMsTeamsTeamMember -Identity "team1" -User "user1@contoso.com","user2@contoso.com" -Role Owner
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType('PSMicrosoftTeams.Members.Member')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'User')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'User')]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'User', ValueFromPipelineByPropertyName = $true)]
        [Alias("UserId", "UserPrincipalName", "Mail")]
        [ValidateUserIdentity()]
        [string[]] $User,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftTeams.Users.User[]] $InputObject,

        [Parameter(ParameterSetName = 'User')]
        [Parameter(ParameterSetName = 'InputObject')]
        [ValidateSet("Member", "Owner")]
        [string] $Role = "Member",

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
        $cmdLetConfirm = if ($Force.IsPresent) { $false } else { $true }
        $cmdLetVerbose = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')
    }
    process {
        $team = Get-PSMsTeamsTeam -Identity $Identity
        if ([object]::Equals($team, $null)) {
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
            return
        }

        $membersToAdd = @()
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            foreach ($userObj in $InputObject) {
                if ($null -eq $userObj -or -not $userObj.Id) {
                    Write-Warning "InputObject missing Id, skipping."
                    continue
                }
                $userUrl = "{0}/users/{1}" -f (Get-EntraService -Name $service).ServiceUrl, $userObj.Id
                $membersToAdd += @{
                    '@odata.type'     = "#microsoft.graph.aadUserConversationMember"
                    'roles'           = @($Role.ToLower())
                    'user@odata.bind' = $userUrl
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'User') {
            foreach ($userId in $User) {
                $userObj = Get-PSMsTeamsUser -Identity $userId
                if ([object]::Equals($team, $null)) {

                    if ($EnableException.IsPresent) {
                        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $userId)
                    }
                }
                $userUrl = "{0}/users/{1}" -f (Get-EntraService -Name $service).ServiceUrl, $userObj.Id
                $membersToAdd += @{
                    '@odata.type'     = "#microsoft.graph.aadUserConversationMember"
                    'roles'           = @($Role.ToLower())
                    'user@odata.bind' = $userUrl
                }
            }
        }

        if ($membersToAdd.Count -eq 0) {
            Write-Warning "No members to add for team '$($team.DisplayName ?? $team.Id)'."
            return
        }

        $path = "teams/$($team.Id)/members/add"
        $body = @{ values = $membersToAdd }

        if ($PSCmdlet.ShouldProcess($team.DisplayName ?? $team.Id, "Add Teams member(s)")) {
            Invoke-PSFProtectedCommand -ActionString 'TeamMember.Add' -ActionStringValues (($membersToAdd | ForEach-Object { $_['user@odata.bind'] }) -join ", ") -Target $Identity -ScriptBlock {
                try {
                    [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -Verbose:$cmdLetVerbose -ErrorAction Stop)
                }
                catch {
                    if ($EnableException.IsPresent) {
                        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name TeamMember.Add.Failed) -f $Identity)
                    }
                }
            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
