function Get-PSMsTeamsTeamChannelFilesFolder {
    <#
    .SYNOPSIS
        Get the files folder (DriveItem) for a Microsoft Teams channel.

    .DESCRIPTION
        Returns the files folder (DriveItem) for a given Microsoft Teams channel using the specified team and channel identifiers.
        This cmdlet calls the Graph API endpoint: GET https://graph.microsoft.com/v1.0/teams/{id}/channels/{id}/filesFolder

    .PARAMETER Identity
        Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER Channel
        The unique identifier of the channel within the team.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeamChannelFilesFolder -Identity "team1" -ChannelId "19:channelid@thread.tacv2"

        Get the files folder for the specified channel in team1.

    .EXAMPLE
        PS C:\> Get-PSMsTeamsTeam -Identity "team1" | Get-PSMsTeamsTeamChannel | Get-PSMsTeamsTeamChannelFilesFolder

        Get the files folder for all channels in team1 using pipeline input.

    .NOTES
        Requires appropriate permissions to access team channels and their files.
        The returned object is a DriveItem representing the SharePoint folder for the channel.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType('PSMicrosoftTeams.Channels.FileFolder')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("ChannelId")]
        [ValidateNotNullOrEmpty()]
        [string] $Channel,
        
        [Parameter()]
        [switch] $EnableException
    )
    
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $channelQuery = @{
            '$select' = ((Get-PSFConfig -Module $script:ModuleName -Name Settings.GraphApiQuery.Select.Channel.FileFolder).Value -join ',')
        }
    }
    
    process {
        Invoke-PSFProtectedCommand -ActionString 'TeamChannelFilesFolder.Get' -ActionStringValues $Channel, $Identity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
            [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity -EnableException:$EnableException
            if (-not([object]::Equals($team, $null))) {
                [string] $path = ("teams/{0}/channels/{1}/filesFolder") -f $team.Id, $Channel
                ConvertFrom-RestTeamChannelFilesFolder -InputObject (Invoke-EntraRequest -Service $service -Path $path -Query $channelQuery -Method Get -ErrorAction Stop)
            }
            else {
                if ($EnableException.IsPresent) {
                    Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
                }
            }
        } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait -WhatIf:$false
        if (Test-PSFFunctionInterrupt) { return }
    }
    
    end {}
}
