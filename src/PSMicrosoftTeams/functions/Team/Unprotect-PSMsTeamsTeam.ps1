function Unprotect-PSMsTeamsTeam {
    <#
.SYNOPSIS
    Unarchives (restores) a Microsoft Teams team.

.DESCRIPTION
    Restores an archived Microsoft Teams team (via Microsoft Graph API POST /teams/{id}/unarchive).
    Restores users' ability to send messages and edit the team, abiding by tenant and team settings.

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique attribute identifying the team.

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.PARAMETER WhatIf
    Simulates the operation.

.PARAMETER Confirm
    Prompts for confirmation before unarchiving.

.EXAMPLE
    Unprotect-PSMsTeamsTeam -Identity "teamname@contoso.com"
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
            Invoke-PSFProtectedCommand -ActionString 'Team.Unarchive' -ActionStringValues $teamId -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                $teamObj = Get-PSMsTeamsTeam -Identity $teamId
                if ($null -ne $teamObj -and $teamObj.Id) {
                    [string] $path = ("teams/{0}/unarchive" -f $teamObj.Id)
                    if ($PSCmdlet.ShouldProcess($teamObj.DisplayName ?? $teamObj.Id, "Unarchive Microsoft Teams team")) {
                        [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Method Post -Verbose:$cmdLetVerbose -ErrorAction Stop)
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
