function Get-PSMsTeamsTeamLabel {
    <#
    .SYNOPSIS
        Get the sensitivity labels assigned to a Microsoft Teams team.

    .DESCRIPTION
        Retrieves the assignedLabels property of the underlying Microsoft 365 group via
        Microsoft Graph API GET /groups/{id}?$select=id,displayName,assignedLabels.
        Each returned object contains the labelId and displayName of the sensitivity label
        together with the team DisplayName for easy identification.

    .PARAMETER InputObject
        One or more PSMicrosoftTeams.Teams.Team objects (accepts pipeline input).

    .PARAMETER Identity
        MailNickName, Mail or Id of the team / group.

    .PARAMETER DisplayName
        DisplayName of the team. A startsWith filter is used to locate the group.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions.
        This is less user friendly, but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamLabel -Identity '00000000-0000-0000-0000-000000000001'

        Gets the sensitivity labels assigned to the team with the specified Id.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeam -Identity 'engineering' | Get-PSMsTeamsTeamLabel

        Gets the sensitivity labels for the engineering team via pipeline.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamLabel -DisplayName 'Project Alpha'

        Gets the sensitivity labels for teams whose display name starts with 'Project Alpha'.
    #>
    [OutputType('PSMicrosoftEntraID.Groups.AssignedLabel')]
    [CmdletBinding(DefaultParameterSetName = 'Identity')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftTeams.Teams.Team[]]
        $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId", "TeamId")]
        [ValidateGroupIdentity()]
        [string[]]
        $Identity,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $false, ParameterSetName = 'DisplayName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $DisplayName,

        [Parameter()]
        [switch]$EnableException
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $labelQuery = @{
            '$select' = 'id,displayName,assignedLabels'
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($itemInputObject in $InputObject) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Label.Get' -ActionStringValues $itemInputObject.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        $response = Invoke-EntraRequest -Service $service -Path ('groups/{0}' -f $itemInputObject.Id) -Query $labelQuery -Method Get -ErrorAction Stop
                        if ($response.assignedLabels) {
                            ConvertFrom-RestObject -Type ([PSMicrosoftEntraID.Groups.AssignedLabel]) -InputObject $response.assignedLabels
                        }
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'Identity' {
                foreach ($itemIdentity in $Identity) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Label.Get' -ActionStringValues $itemIdentity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                        if (-not([object]::Equals($team, $null))) {
                            $response = Invoke-EntraRequest -Service $service -Path ('groups/{0}' -f $team.Id) -Query $labelQuery -Method Get -ErrorAction Stop
                            if ($response.assignedLabels) {
                                ConvertFrom-RestObject -Type ([PSMicrosoftEntraID.Groups.AssignedLabel]) -InputObject $response.assignedLabels
                            }
                        }
                        else {
                            if ($EnableException.IsPresent) {
                                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $itemIdentity)
                            }
                        }
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'DisplayName' {
                foreach ($teamName in $DisplayName) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Label.Get' -ActionStringValues $teamName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [hashtable] $nameQuery = @{
                            '$select' = 'id,displayName,assignedLabels'
                            '$filter' = ("resourceProvisioningOptions/Any(x:x eq 'Team') and startswith(displayName,'{0}')" -f $teamName)
                            '$count'  = 'true'
                        }
                        [hashtable] $header = @{}
                        $header['ConsistencyLevel'] = 'eventual'
                        $groups = Invoke-EntraRequest -Service $service -Path 'groups' -Query $nameQuery -Header $header -Method Get -ErrorAction Stop
                        if ($groups) {
                            foreach ($group in $groups) {
                                if ($group.assignedLabels) {
                                    ConvertFrom-RestObject -Type ([PSMicrosoftEntraID.Groups.AssignedLabel]) -InputObject $group.assignedLabels
                                }
                            }
                        }
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }
    end {
    }
}
