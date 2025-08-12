using namespace PSMicrosoftTeams.Users
function Get-PSMsTeamsTeamMember {
    <#
    .SYNOPSIS
        Get an owner or member to the team, and to the unified group which backs the team.

    .DESCRIPTION
        This cmdlet get an owner or member of the team, and to the unified group which backs the team.

    .PARAMETER InputObject
        PSMicrosoftTeams.Groups.Group object in tenant/directory.

    .PARAMETER Identity
        MailNickName or Id of group or team.

    .PARAMETER Filter
        Filter expressions of groups in tenant/directory.

    .PARAMETER AdvancedFilter
        Switch advanced filter for filtering groups in tenant/directory.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamMember -Identity team1@contoso.com

		Get members of team11@contoso.com

#>
    [OutputType('PSMicrosoftTeams.Members.ConversationMember')]
    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
    param([Parameter(Mandatory = $True, ValueFromPipeline = $True, ParameterSetName = 'InputObject')]
        [PSMicrosoftTeams.Teams.Team[]]$InputObject,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId", "TeamId", "MailNickName")]
        [ValidateGroupIdentity()]
        [string[]] $Identity,
        [Parameter(Mandatory = $False, ParameterSetName = 'InputObject')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [string] $Filter,
        [Parameter(Mandatory = $False, ParameterSetName = 'InputObject')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [switch] $AdvancedFilter,
        [Parameter()]
        [switch] $EnableException
    )

    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [hashtable] $query = @{
            #'$count'  = 'true'
            '$top' = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            #'$select' = (Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.ConversationMember).Value -join ','
        }
        [hashtable] $header = @{}
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($itemInputObject in $InputObject) {
                    Invoke-PSFProtectedCommand -ActionString 'TeamMember.List' -ActionStringValues $itemInputObject.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [string] $path = ('teams/{0}/members' -f $itemInputObject.Id)
                        if (Test-PSFParameterBinding -ParameterName 'Filter') {
                            $query['$Filter'] = $Filter
                            if ($AdvancedFilter.IsPresent) {
                                $header['ConsistencyLevel'] = 'eventual'
                            }
                        }
                        ConvertFrom-RestConversationMember -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
                    } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'Identity' {
                foreach ($itemIdentity in $Identity) {
                    Invoke-PSFProtectedCommand -ActionString 'TeamMember.List' -ActionStringValues $itemIdentity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                        if (-not([object]::Equals($team, $null))) {
                            [string] $path = ('teams/{0}/members' -f $team.Id)
                            if (Test-PSFParameterBinding -ParameterName 'Filter') {
                                $query['$Filter'] = $Filter
                                if ($AdvancedFilter.IsPresent) {
                                    $header['ConsistencyLevel'] = 'eventual'
                                }
                            }
                            ConvertFrom-RestConversationMember -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $query -Header $header -Method Get -ErrorAction Stop)
                            if (Test-PSFFunctionInterrupt) { return }
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