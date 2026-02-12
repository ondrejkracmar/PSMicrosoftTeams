function Set-PSMsTeamsTeamLabel {
    <#
    .SYNOPSIS
        Sets (assigns) sensitivity labels on a Microsoft Teams team.

    .DESCRIPTION
        Updates the assignedLabels property of the underlying Microsoft 365 group via
        Microsoft Graph API PATCH /groups/{id} with the body { "assignedLabels": [...] }.

        You can specify labels by LabelId directly, or by LabelName — in which case the cmdlet
        first reads the current labels from the group, finds the matching label, and uses its
        LabelId. When using -LabelId you must also supply -LabelName as the display name for
        the label (required by the Graph API).

    .PARAMETER InputObject
        One or more PSMicrosoftTeams.Teams.Team objects (accepts pipeline input).

    .PARAMETER Identity
        Team Id or GroupId.

    .PARAMETER LabelId
        The GUID identifier of the sensitivity label to assign.

    .PARAMETER LabelName
        The display name of the sensitivity label. When used with -LabelId, it is sent
        as the displayName in the request body. When used alone (without -LabelId),
        the cmdlet retrieves the current labels to resolve the LabelId automatically.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions.
        This is less user friendly, but allows catching exceptions in calling scripts.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Force
        Suppresses the confirmation prompt.

    .PARAMETER Confirm
        Displays a confirmation prompt before executing.

    .EXAMPLE
        PS C:\> Set-PSMsTeamsTeamLabel -Identity $teamId -LabelId '00000000-1111-2222-3333-444444444444' -LabelName 'Confidential'

        Assigns the 'Confidential' sensitivity label to the specified team.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeam -Identity 'engineering' | Set-PSMsTeamsTeamLabel -LabelId $labelId -LabelName 'Internal'

        Assigns the 'Internal' label to the engineering team via pipeline.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'InputObjectLabelId')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObjectLabelId')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObjectLabelName')]
        [PSMicrosoftTeams.Teams.Team[]]
        $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityLabelId')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityLabelName')]
        [Alias("Id", "GroupId", "TeamId")]
        [string[]]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName = 'InputObjectLabelId')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityLabelId')]
        [ValidateNotNullOrEmpty()]
        [string]
        $LabelId,

        [Parameter(Mandatory = $true, ParameterSetName = 'InputObjectLabelId')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityLabelId')]
        [Parameter(Mandatory = $true, ParameterSetName = 'InputObjectLabelName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityLabelName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $LabelName,

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
        [string] $method = 'Patch'
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
    }

    process {
        switch -Regex ($PSCmdlet.ParameterSetName) {
            '^InputObject\w' {
                foreach ($itemInputObject in $InputObject) {
                    [string] $groupId = $itemInputObject.Id
                    [string] $teamDisplayName = $itemInputObject.DisplayName

                    [hashtable] $body = Get-LabelBody -GroupId $groupId -Service $service -LabelId $(if ($PSBoundParameters.ContainsKey('LabelId')) { $LabelId } else { $null }) -LabelName $LabelName -EnableException:$EnableException -PSCmdlet $PSCmdlet
                    if ($null -eq $body) { continue }

                    Invoke-PSFProtectedCommand -ActionString 'Team.Label.Set' -ActionStringValues $teamDisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [void] (Invoke-EntraRequest -Service $service -Path ('groups/{0}' -f $groupId) -Header $header -Body $body -Method $method -ErrorAction Stop)
                    } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            '^Identity\w' {
                foreach ($itemIdentity in $Identity) {
                    [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                    if (-not([object]::Equals($team, $null))) {
                        [string] $groupId = $team.Id
                        [string] $teamDisplayName = $team.DisplayName

                        [hashtable] $body = Get-LabelBody -GroupId $groupId -Service $service -LabelId $(if ($PSBoundParameters.ContainsKey('LabelId')) { $LabelId } else { $null }) -LabelName $LabelName -EnableException:$EnableException -PSCmdlet $PSCmdlet
                        if ($null -eq $body) { continue }

                        Invoke-PSFProtectedCommand -ActionString 'Team.Label.Set' -ActionStringValues $teamDisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path ('groups/{0}' -f $groupId) -Header $header -Body $body -Method $method -ErrorAction Stop)
                        } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
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
    end {
    }
}

function Get-LabelBody {
    <#
    .SYNOPSIS
        Internal helper to build the assignedLabels PATCH body.
    #>
    [CmdletBinding()]
    param(
        [string] $GroupId,
        [string] $Service,
        [AllowNull()]
        [string] $LabelId,
        [string] $LabelName,
        [switch] $EnableException,
        [System.Management.Automation.PSCmdlet] $PSCmdlet
    )

    if (-not [string]::IsNullOrEmpty($LabelId)) {
        # LabelId was provided explicitly — use it directly with supplied LabelName
        return @{
            assignedLabels = @(
                @{ labelId = $LabelId; displayName = $LabelName }
            )
        }
    }

    # LabelName only — resolve by reading current labels from the group
    [hashtable] $labelQuery = @{ '$select' = 'id,displayName,assignedLabels' }
    $response = Invoke-EntraRequest -Service $Service -Path ('groups/{0}' -f $GroupId) -Query $labelQuery -Method Get -ErrorAction Stop
    if ($response.assignedLabels) {
        $matchingLabel = $response.assignedLabels | Where-Object { $_.displayName -eq $LabelName } | Select-Object -First 1
        if ($matchingLabel) {
            return @{
                assignedLabels = @(
                    @{ labelId = $matchingLabel.labelId; displayName = $matchingLabel.displayName }
                )
            }
        }
    }

    # Label not found
    if ($EnableException.IsPresent) {
        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ("Sensitivity label '{0}' not found on group '{1}'" -f $LabelName, $GroupId)
    }
    return $null
}
