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
    [CmdletBinding(DefaultParameterSetName = 'IdentityChannelType')]
    param([Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelDisplayName')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelMembershipType')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelType')]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannel')]
        [Alias("ChannelId")]
        [string] $Channel,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelDisplayName')]
        [ValidateNotNullOrEmpty()]
        [string] $DisplayName,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelMembershipType')]
        [ValidateSet('Standard', 'Private', 'Shared')]
        [ValidateNotNullOrEmpty()]
        [string] $MembershipType = 'Standard',
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityChannelType')]
        [ValidateSet('Team', 'Incomming', 'All')]
        [ValidateNotNullOrEmpty()]
        [string] $ChannelType = 'All',
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
                    [PSMicrosoftTeams.Teams.Team]$team = Get-PSMsTeamsTeam -Identity $Identity
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
                    [PSMicrosoftTeams.Teams.Team]$team = Get-PSMsTeamsTeam -Identity $Identity
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
                Invoke-PSFProtectedCommand -ActionString 'TeamChannel.List' -ActionStringValues $MembershipType -Target $Identity -ScriptBlock {
                    [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity
                    if (-not([object]::Equals($team, $null))) {
                        [hashtable] $query = @{}
                        $query['$Filter'] = ("membershipType eq '{0}'" -f $MembershipType)
                        [string] $path = ("teams/{0}/allChannels") -f $team.Id
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
            'IdentityChannelType' {

                Invoke-PSFProtectedCommand -ActionString 'TeamChannel.List' -ActionStringValues $ChannelType -Target $Identity -ScriptBlock {
                    [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity

                    if (-not([object]::Equals($team, $null))) {
                        [hashtable] $query = @{}
                        switch ($ChannelType) {
                            'Team' {
                                [string] $path = ('teams/{0}/channels' -f $team.Id)
                            }
                            'Incomming' {
                                [string] $path = ('teams/{0}/incomingChannels' -f $team.Id)
                            }
                            'All' {
                                [string] $path = ('teams/{0}/allChannels' -f $team.Id)
                            }
                            'Default' {
                                [string] $path = ('teams/{0}/allChannels' -f $team.Id)
                            }

                        }
                        if (Test-PSFParameterBinding -ParameterName 'MembershipType') {
                            $query['$Filter'] = ('membershipType eq ''{0}''' -f $MembershipType.ToLower())
                        }
                        else {
                            $query['$Filter'] = ('membershipType eq ''{0}''' -f 'Standard')
                        }
                        
                        ConvertFrom-RestTeamChannel -InputObject( Invoke-EntraRequest -Service $service -Path $path -Query $query -Method Get -ErrorAction Stop)
                    }
                    else {

                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $teamIdentity)
                        }
                    }
                    'Pica'
                } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
                if (Test-PSFFunctionInterrupt) { return }
            }
        }
    }
    end {}
}
