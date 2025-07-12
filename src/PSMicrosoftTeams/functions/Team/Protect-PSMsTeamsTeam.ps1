function Protect-PSMsTeamsTeam {
    <#
.SYNOPSIS
    Archive (protect) a Microsoft Teams team.

.DESCRIPTION
    Archives a Microsoft Teams team via Microsoft Graph API POST /teams/{id}/archive.
    When archived, users cannot send or like messages, or make most changes to the team, but membership changes are still allowed.

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique attribute identifying the team.

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.PARAMETER WhatIf
    Simulates the operation.

.PARAMETER Confirm
    Prompts for confirmation before archiving.

.EXAMPLE
    Protect-PSMsTeamsTeam -Identity "teamname@contoso.com"
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Identity')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "TeamId", "GroupId", "MailNickname")]
        [string[]]$Identity,

        [Parameter()]
        [switch]$EnableException,

        [Parameter()]
        [switch]$Force
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
        foreach ($teamId in $Identity) {
            Invoke-PSFProtectedCommand -ActionString 'Team.Archive' -ActionStringValues $teamId -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                $teamObj = Get-PSMsTeamsTeam -Identity $teamId
                if ($null -ne $teamObj -and $teamObj.Id) {
                    [string] $path = ("teams/{0}/archive" -f $teamObj.Id)
                    $body = @{
                        'shouldSetSpoSiteReadOnlyForMembers' = $true
                    }
                    if ($PSCmdlet.ShouldProcess($teamObj.DisplayName ?? $teamObj.Id, "Archive Microsoft Teams team")) {
                        [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -Verbose:$cmdLetVerbose -ErrorAction Stop)
                    }
                }
                else {
                    if ($EnableException.IsPresent) {
                        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamId)
                    }
                }
                if (Test-PSFFunctionInterrupt) { return }
            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
