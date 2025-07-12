function Remove-PSMsTeamsTeamMember {
<#
.SYNOPSIS
    Remove a member from a Microsoft Teams team.

.DESCRIPTION
    Removes a member from the specified Microsoft Teams team using the MembershipId (Graph API DELETE /teams/{id}/members/{membershipId}).

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique attribute identifying the team.

.PARAMETER MembershipId
    MembershipId of the team member(s) to remove (as returned by Get-PSMsTeamsTeamMember).

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.PARAMETER WhatIf
    Simulates the operation.

.PARAMETER Confirm
    Prompts for confirmation before removing the member.

.EXAMPLE
    Remove-PSMsTeamsTeamMember -Identity teammailnickname -MembershipId ZWUwZjVhZTItOGJjNi...

#>
    [OutputType('PSMicrosoftTeams.User')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Identity')]
    param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [string[]] $MembershipId,

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
        $cmdLetConfirm = if ($Force.IsPresent) { $false } else { $true }
        $cmdLetVerbose = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')
    }
    process {
        $team = Get-PSMsTeamsTeam -Identity $Identity
        if ([object]::Equals($team, $null) -or -not $team.Id) {
            $msg = "Team '$Identity' not found or missing Id. Skipping."
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            } else {
                Write-Warning $msg
            }
            return
        }

        foreach ($itemMembershipId in $MembershipId) {
            Invoke-PSFProtectedCommand -ActionString 'TeamMember.Remove' -ActionStringValues "$($team.DisplayName ?? $team.Id)", $itemMembershipId -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                $path = "teams/$($team.Id)/members/$itemMembershipId"
                if ($PSCmdlet.ShouldProcess($path, "Remove Teams member")) {
                    try {
                        [void](Invoke-EntraRequest -Service $service -Path $path -Method Delete -Verbose:$cmdLetVerbose -ErrorAction Stop)
                    }
                    catch {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name TeamMember.Remove.Failed) -f $itemMembershipId)
                        }
                    }
                }
                if (Test-PSFFunctionInterrupt) { return }
            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
