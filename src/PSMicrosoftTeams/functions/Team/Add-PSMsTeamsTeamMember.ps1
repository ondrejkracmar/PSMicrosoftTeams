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
        [ValidateSet("Member", "Owner")]
        [string[]]$Role,
        [switch]$EnableException
    )

    begin {
        $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        $graphService = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultGraphService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        $header = @{
            'Content-Type' = 'application/json'
        }
    }

    process {
        Invoke-PSFProtectedCommand -ActionString 'TeamMember.Add' -ActionStringValues ((($User | ForEach-Object { "{0}" -f $_ }) -join ',')), ((($Role | ForEach-Object { "{0}" -f $_ }) -join ',')) -Target $Identity -ScriptBlock {
            if (([object]::Equals($team, $null))) {
                $team = Get-PSMsTeamsTeam -Identity $Identity
            }
            if (-not([object]::Equals($team, $null))) {
                $path = Join-UriPath -Uri ($graphService) -ChildPath ('teams/{0}/{1})' -f $team.Id, 'memebrs')
                if ($User.Count -eq 0) {
                    $aADUser = Get-PSMsTeamsUser -Identity $User
                    if (-not([object]::Equals($aADUser, $null))) {
                        $body = @{
                            '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                            roles             = @()
                            'user@odata.bind' = Join-UriPath -Uri (Get-EntraService -Name $graphService).ServiceUrl -ChildPath "users('{0}')" -f $aADUser.UserPrincipalName
                        }

                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $itemUser)
                        }
                    }
                    if (Test-PSFParameterBinding -Parameter Role) {
                        $body['roles'] = $Role
                    }
                    else {
                        $body['roles'] = @()
                    }

                }
                else {
                    $path = = Join-UriPath -Uri ($graphService) -ChildPath ('{0}/members/add' -f $team.Id)
                    $body = @{values = @() }
                    foreach ($userItem in  $User) {
                        $aADUser = Get-PSMsTeamsUser -Identity $userItem
                        if (-not([object]::Equals($aADUser, $null))) {
                            $urlUser = Join-UriPath -Uri (Get-EntraService -Name $graphService).ServiceUrl -ChildPath "users('{0}')" -f $aADUser.UserPrincipalName
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
                try {
                    [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
                }
                catch {
                    if ($EnableException.IsPresent) {
                        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name TeamMember.Add.Failed) -f $Identity)
                    }
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
