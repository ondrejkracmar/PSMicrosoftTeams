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
            This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
            but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeam -Identity team1 | Get-PSMsTeamsTeamChannel

        Get channels for team1, using the team object returned by Get-PSMsTeamsTeam.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamChannel -Identity team1 -ChannelDisplayName "General"

        Get channels for team1, filtering by the display name "General".
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType('PSMicrosoftTeams.Channels.Channel')]
    [CmdletBinding(DefaultParameterSetName = 'IdentityChannelTypeMembershipType')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelTypeMembershipType')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelMembershipType')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelType')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelDisplayName')]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Alias("ChannelId")]
        [string] $Channel,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelDisplayName')]
        [ValidateNotNullOrEmpty()]
        [string[]] $DisplayName,
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityChannelTypeMembershipType')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityChannelMembershipType')]
        [ValidateSet('Standard', 'Private', 'Shared')]
        [ValidateNotNullOrEmpty()]
        [string] $MembershipType,
        [ValidateSet('Team', 'Incomming', 'All')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityChannelTypeMembershipType')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IdentityChannelType')]
        [ValidateNotNullOrEmpty()]
        [switch] $ChannelType,
        [Parameter()]
        [switch] $EnableException
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $channelQuery = @{
            '$count'  = 'true'
            '$top'    = Get-PSFConfigValue -FullName ('{0}.Settings.GraphApiQuery.PageSize' -f $script:ModuleName)
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Cahnnel).Value -join ',')
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'IdentityChannel' {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Get' -ActionStringValues $Channel, $Identity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                    [PSMicrosoftTeams.teams.Teeam]$team = Get-PSMsTeamsTeam -Identity $Identity
                    if (-not([object]::Equals($team, $null))) {
                        $path = ("teams/{0}/channels/{1}") -f $team.Id, $Channel
                        ConvertFrom-RestTeamChannel -InputObject( Invoke-EntraRequest -Service $service -Path $path -Query $query -Method Get -ErrorAction Stop)
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamIdentity)
                        }
                    }
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                if (Test-PSFFunctionInterrupt) { return }
            }
            'IdentityChannelDisplayName' {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Get' -ActionStringValues $DisplayName, $Identity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                    [PSMicrosoftTeams.teams.Teeam]$team = Get-PSMsTeamsTeam -Identity $Identity
                    if (-not([object]::Equals($team, $null))) {
                        $query['$Filter'] = ("startswith(displayName,'{0}')" -f $DisplayName)
                        $path = ("teams/{0}/allChannels/") -f $team.Id, $Channel
                        ConvertFrom-RestTeamChannel -InputObject( Invoke-EntraRequest -Service $service -Path $path -Query $query -Method Get -ErrorAction Stop)
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamIdentity)
                        }
                    }
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                if (Test-PSFFunctionInterrupt) { return }
            }
            'IdentityChannelMembershipType' {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannel.List' -ActionStringValues $MembershipType -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                    [PSMicrosoftTeams.teams.Teeam] $team = Get-PSMsTeamsTeam -Identity $Identity
                    if (-not([object]::Equals($team, $null))) {
                        $query['$Filter'] = ("membershipType eq '{0}'" -f $MembershipType)
                        $path = ("teams/{0}/allChannels") -f $team.Id
                        ConvertFrom-RestTeamChannel -InputObject( Invoke-EntraRequest -Service $service -Path $path -Query $query -Method Get -ErrorAction Stop)
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamIdentity)
                        }
                    }
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                if (Test-PSFFunctionInterrupt) { return }
            }
            'IdentityChannelType\w' {
                Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Get' -ActionStringValues $ChannelType -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                    [PSMicrosoftTeams.teams.Teeam] $team = Get-PSMsTeamsTeam -Identity $Identity
                    if (Test-PSFParameterBinding -ParameterName 'MembershipType') { $query['$Filter'] = ("membershipType eq '{0}'" -f $MembershipType) }
                    if (-not([object]::Equals($team, $null))) {
                        switch ($ChannelType) {
                            'Team' {
                                $path = ("teams/{0}/channels") -f $team.Id
                            }
                            'Incomming' {
                                $path = ("teams/{0}/incomingChannels") -f $team.Id
                            }
                            'All' {
                                $path = ("teams/{0}/allChannels") -f $team.Id
                            }
                        }
                        ConvertFrom-RestTeamChannel -InputObject( Invoke-EntraRequest -Service $service -Path $path -Query $query -Method Get -ErrorAction Stop)
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamIdentity)
                        }
                    }
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                if (Test-PSFFunctionInterrupt) { return }
            }
        }
    }
    end {}
}
