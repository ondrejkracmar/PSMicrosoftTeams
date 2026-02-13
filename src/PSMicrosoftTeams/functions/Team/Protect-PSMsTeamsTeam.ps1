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
        PS C:\> Protect-PSMsTeamsTeam -Identity "teamname@contoso.com"

        Archives the team with the specified identity. If the team is not found, an error is thrown.
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'InputObject')]
    param ([Parameter(Mandatory = $True, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftTeams.Teams.Team[]] $InputObject,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "TeamId", "GroupId", "MailNickname")]
        [string[]]$Identity,
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
        [string] $method = 'POST'
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
    }
    process {
        switch -Regex ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($itemInputObject in $InputObject) {
                    [string] $path = ("teams/{0}/archive" -f $itemInputObject.Id)
                    $body = @{
                        'shouldSetSpoSiteReadOnlyForMembers' = $true
                    }
                    if ($PassThru.IsPresent) {
                        [PSMicrosoftEntraID.Batch.Request]@{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        Invoke-PSFProtectedCommand -ActionString 'Team.Archive' -ActionStringValues $itemInputObject.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method $method -ErrorAction Stop)
                        } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }

            }
            'Identity' {
                foreach ($itemIdentity in $Identity) {
                    [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                    if (-not([object]::Equals($team, $null))) {
                        [string] $path = ("teams/{0}/archive" -f $team.Id)
                        $body = @{
                            'shouldSetSpoSiteReadOnlyForMembers' = $true
                        }
                        if ($PassThru.IsPresent) {
                            [PSMicrosoftEntraID.Batch.Request]@{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                        }
                        else {
                            Invoke-PSFProtectedCommand -ActionString 'Team.Archive' -ActionStringValues $team.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                                [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
                            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                            if (Test-PSFFunctionInterrupt) { return }
                        }
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $itemIdentity)
                        }
                    }
                }
            }
        }
    }
    end {}
}
