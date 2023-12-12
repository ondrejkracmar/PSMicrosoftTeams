function Add-PSMsTeamsTeamMember {
    <#
    .SYNOPSIS
        Add a member to a Microsoft Teams team.

    .DESCRIPTION
        Add a member to a Microsoft Teams team.

    .PARAMETER Identity
        MailNickName or Id of  team

    .PARAMETER User
        UserPrincipalName, Mail or Id of the user attribute populated in tenant/directory.

    .PARAMETER Role
        Membership role (Member/Owner).

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Confirm
        The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .EXAMPLE
            PS C:\> Add-PSMsTeamsTeamMember -Identity team1 -User user1,user2

            Add member to Microsoft Teams taam team1
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Identity')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [ValidateGroupIdentity()]
        [string]$Identity,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("UserId", "UserPrincipalName", "Mail")]
        [ValidateUserIdentity()]
        [string[]]$User,
        [Parameter(ParameterSetName = 'Identity', ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Member', 'Owner')]
        [string[]]$Role,
        [switch]$EnableException
    )

    begin {
        Assert-RestConnection -Service 'graph' -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        Invoke-PSFProtectedCommand -ActionString 'TeamMember.Add' -ActionStringValues ((($User | ForEach-Object { "{0}" -f $_ }) -join ',')) -Target $Identity -ScriptBlock {
            $team = Get-PSMsTeamsTeam -Identity $Identity
            if (-not([object]::Equals($team, $null))) {
                $path = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath ('teams/{0}/{1})' -f $team.Id, 'memebrs' )
                if ($User.Count -eq 0) {
                    $aADUser = Get-PSMsTeamsUser -Identity $User
                    if (-not([object]::Equals($aADUser, $null))) {
                        $body = @{
                            '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                            roles             = @()
                            'user@odata.bind' = ('{0}/users/{1}' -f (Get-GraphApiUriPath), $aADUser.Id)
                        }
                        if (Test-PSFParameterBinding -Parameter Role) {
                            $body['roles'] = $Role
                        }
                        else {
                            $body['roles'] = @()
                        }
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $itemUser)
                        }
                    }
                }
                else {
                    $path = = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath ('{0}/members/add' -f $team.Id)
                    $body = @{values = @() }
                    foreach ($memberItem in  $Members) {
                        $aADUser = Get-PSMsTeamsUser -Identity $memberItem
                        if (-not([object]::Equals($aADUser, $null))) {
                            $urlUser = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users('{0}')" -f $aADUser.UserPrincipalName
                            $value = @{
                                '@odata.type'     = "#microsoft.graph.aadUserConversationMember"
                                roles             = @()
                                'user@odata.bind' = $urlUser
                            }
                            if (Test-PSFParameterBinding -Parameter Role) {
                                if ($memberItem['Role'] -eq 'Owner') {
                                    roles = $Role
                                }
                            }
                        }
                        else {
                            if ($EnableException.IsPresent) {
                                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $itemUser)
                            }
                        }
                    }
                    $body = @{values = $values }
                }
            }
            else {
                if ($EnableException.IsPresent) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
                }
            }
        } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue #-RetryCount $commandRetryCount -RetryWait $commandRetryWait
    }
    end {

    }
}