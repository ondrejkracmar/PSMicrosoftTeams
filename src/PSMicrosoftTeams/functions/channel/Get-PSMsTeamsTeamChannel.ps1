function Get-PSMsTeamsTeamChannel {
    <#
.SYNOPSIS
    Get the channels of a Microsoft Teams team.

.DESCRIPTION
    Returns one or more channels for a given Microsoft Teams team, by object (InputObject) or team identifier.

.PARAMETER InputObject
    Team object(s) from Get-PSMsTeamsTeam (pipeline support).

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER ChannelDisplayName
    (Optional) Filter returned channels by their display name.

.PARAMETER Filter
    OData filter to filter returned channels (applies after team lookup).

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.EXAMPLE
    Get-PSMsTeamsTeam -Identity team1 | Get-PSMsTeamsTeamChannel

.EXAMPLE
    Get-PSMsTeamsTeamChannel -Identity team1 -ChannelDisplayName "General"
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType('PSMicrosoftTeams.Channel')]
    [CmdletBinding(DefaultParameterSetName = 'InputObject')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftTeams.Teams.Team[]] $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string[]] $Identity,

        [Parameter(Mandatory = $false)]
        [string] $ChannelDisplayName,

        [Parameter(Mandatory = $false)]
        [string] $Filter,

        [Parameter()]
        [switch] $EnableException
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $channelQuery = @{
            '$top'    = 100
            '$count'  = 'true'
            '$select' = 'id,displayName,description,isFavoriteByDefault,email,membershipType'
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')) {
            [boolean] $cmdLetVerbose = $true
        }
        else {
            [boolean] $cmdLetVerbose = $false
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($team in $InputObject) {
                    if ([object]::Equals($team, $null) -or -not $team.Id) {

                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f ($team.DisplayName ?? '<no team>'))
                        }
                    }
                    $query = $channelQuery.Clone()
                    if ($Filter) { $query['$filter'] = $Filter }
                    Write-Verbose "Querying channels for Team '$($team.DisplayName ?? $team.Id)'"
                    Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Get' -ActionStringValues $team.Id -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        Invoke-EntraRequest -Service $service -Path ("teams/$($team.Id)/channels") -Query $query -Method Get -Verbose:$cmdLetVerbose -ErrorAction Stop | ConvertFrom-RestTeamChannel
                    } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if ($ChannelDisplayName) {
                        $channels = $channels | Where-Object { $_.DisplayName -eq $ChannelDisplayName }
                    }
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            'Identity' {
                foreach ($teamIdentity in $Identity) {
                    $teamObj = Get-PSMsTeamsTeam -Identity $teamIdentity -EnableException:$EnableException
                    if ([object]::Equals($teamObj, $null) -or -not $teamObj.Id) {

                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamIdentity)
                        }
                    }
                    $query = $channelQuery.Clone()
                    if ($Filter) { $query['$filter'] = $Filter }

                    Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Get' -ActionStringValues $teamObj.Id -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        Invoke-EntraRequest -Service $service -Path ("teams/$($teamObj.Id)/channels") -Query $query -Method Get -Verbose:$cmdLetVerbose -ErrorAction Stop | ConvertFrom-RestTeamChannel
                    } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }
    end {}
}
