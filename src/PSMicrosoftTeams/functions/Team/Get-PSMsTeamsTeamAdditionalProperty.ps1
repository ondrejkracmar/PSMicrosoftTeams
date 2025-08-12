function Get-PSMsTeamsTeamAdditionalProperty {
    <#
    .SYNOPSIS
        Get the properties and relationships of a group or the team, and to the unified group which backs the team.

    .DESCRIPTION
        This cmdlet gets properties and relationships of a group or the team, and to the unified group which backs the team.

    .PARAMETER InputObject
        PSMicrosoftTeams.Groups.Group object in tenant/directory.

    .PARAMETER Identity
        MailNickName or Id of group or team.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamAdditionalProperty -Identity team1@contoso.com

		Get theadditional properties and relationships of a team team1@contoso.com

#>
    [OutputType('PSMicrosoftTeams.Teams.TeamAdditionalProperty')]
    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
    param([Parameter(Mandatory = $True, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftTeams.Teams.Team[]] $InputObject,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [ValidateGroupIdentity()]
        [string[]] $Identity,
        [Parameter()]
        [switch] $EnableException
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [hashtable] $query = @{
            '$count'  = 'true'
            '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.TeamAdditionalProperty).Value -join ',') + ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.GroupProperty).Value -join ',')
        }
        [hashtable] $header = @{}
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($itemInputObject in $InputObject) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.AdditionalProperty' -ActionStringValues $itemInputObject.MailNickname -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [string] $path = ('teams/{0}' -f $itemInputObject.Id)
                        ConvertFrom-RestTeamAdditionalProperty -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'Identity' {
                foreach ($itemIdentity in $Identity) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.AdditionalProperty' -ActionStringValues $itemIdentity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                        if (-not([object]::Equals($team, $null))) {
                            [string] $path = ('teams/{0}' -f $itemIdentity.Id)
                            ConvertFrom-RestTeamAdditionalProperty -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
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
        }
    }
    end {

    }
}