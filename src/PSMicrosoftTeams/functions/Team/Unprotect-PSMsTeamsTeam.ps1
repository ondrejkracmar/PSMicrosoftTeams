function Unprotect-PSMsTeamsTeam {
    <#
	.SYNOPSIS
		Archive team

	.DESCRIPTION
		Unarchive MIcrosoft Teams team
        Restore an archived team. This restores users' ability to send messages and edit the team, abiding by tenant and team settings..

	.PARAMETER Identity
        teamPrincipalName, Mail or Id of the team attribute populated in tenant/directory.

    .PARAMETER EnableException
        Archive the specified team. When a team is archived, users can no longer send or like messages on any channel in the team, edit the team's name, description, or other settings, or in general make most changes to the team.
        Membership changes to the team continue to be allowed.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Confirm
        The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

	.EXAMPLE
		PS C:\> Unprotect-PSMsTeamsTeam -Identity teamname@contoso.com

		Unprotect team teamname@contoso.com from Microsoft Teams

	#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Identity')]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "TeamId", "GroupId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string[]]$Identity,
        [switch]$EnableException
    )
    begin {
        Assert-RestConnection -Service 'graph' -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        foreach ($group in $Identity) {
            Invoke-PSFProtectedCommand -ActionString 'Team.Unarchive' -ActionStringValues $group -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                $aADGroup = Get-PSMsTeamsTeam -Identity $group
                if (-not([object]::Equals($aADGroup, $null))) {
                    $path = ("teams/{0}/unarchive" -f $aADGroup.Id)
                    [void](Invoke-RestRequest -Service 'graph' -Path $path -Method Post -ErrorAction Stop)
                }
                else {
                    if ($EnableException.IsPresent) {
                        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $group)
                    }
                }
            } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue #-RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }

    end
    {}
}
