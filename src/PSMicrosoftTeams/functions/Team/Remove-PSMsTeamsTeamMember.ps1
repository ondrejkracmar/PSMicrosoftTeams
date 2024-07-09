function Remove-PSMsTeamsTeamMember {
    <#
    .SYNOPSIS
        Remove member from the team.

    .DESCRIPTION
        This cmdlet remove member from the team.

    .PARAMETER Identity
        MailNickName or Id of  team

    .PARAMETER MembershipId
        MembershipId of team memebr

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Remove-PSMsTeamsTeamMember -Identity teammailnickname -MembershipId ZWUwZjVhZTItOGJjNi00YWU1LTg0NjYtN2RhZWViYmZhMDYyIyM3Mzc2MWYwNi0yYWM5LTQ2OWMtOWYxMC0yNzlhOGNjMjY3Zjk=

		Get properties of team members


#>
    [OutputType('PSMicrosoftEntraID.TeamMember')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Identity')]
    param([Parameter(Mandatory = $True, ParameterSetName = 'Identity')]
        [ValidateGroupIdentity()]
        [string]$Identity,
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [string[]]$MembershipId,
        [switch]$EnableException
    )

    begin {
        $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Identity' {
                foreach ($itemMembershipId in $MembershipId) {

                    Invoke-PSFProtectedCommand -ActionString 'TeamMember.Remove' -ActionStringValues $Identity, (($itemMembershipId | ForEach-Object { "{0}" -f $_ }) -join ',') -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        if (([object]::Equals($team, $null))) {
                            $team = Get-PSMsTeamsTeam -Identity $Identity
                        }
                        if (-not([object]::Equals($team, $null))) {
                            $path = ('teams/{0}/members/{1}' -f $team.Id, $itemMembershipId)
                            Invoke-EntraRequest -Service $service -Path $path -Method Delete -ErrorAction Stop
                        }
                        else {
                            if ($EnableException.IsPresent) {
                                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $itemIdentity)
                            }
                        }
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }

    end {

    }
}