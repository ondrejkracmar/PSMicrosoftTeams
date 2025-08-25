function Send-PSMsTeamsTeamChannelMessage {
    <#
    .SYNOPSIS
        Send a formatted message to a Microsoft Teams channel via Microsoft Graph API.

    .DESCRIPTION
        Sends a message (plain text or HTML) to a specified Teams channel. Supports basic formatting (bold, italics, links, lists) via HTML.
        Uses POST /teams/{team-id}/channels/{channel-id}/messages.

    .PARAMETER Identity
        Team Id, GroupId, MailNickname, or any unique team identifier.

    .PARAMETER Channel
        Id of the channel to post the message to.

    .PARAMETER Message
        The message content (string) or object (pipeline input supported).

    .PARAMETER ContentType
        Format of message: "text" (default) or "html". "html" supports formatting (bold, links, etc).

    .PARAMETER Subject
        Optional subject/title for the message (shown in activity feed and channel).

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly,
        but allows catching exceptions in calling scripts.

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
        PS C:\> Send-PSMsTeamsTeamChannelMessage -Identity team1 -ChannelId channel1 -Message "Hello, team!"

        Send plain text

    .EXAMPLE
        PS C:\> $html = "<b>Build completed:</b> <a href='https://dev.azure.com'>Check logs here</a><ul><li>Step 1 OK</li><li>Step 2 OK</li></ul>"
        PS C:\> Send-PSMsTeamsTeamChannelMessage -Identity team1 -ChannelId channel1 -Message $html -ContentType html

        Send HTML-formatted message
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'SendMessage')]
    param(
        [Parameter(ParameterSetName = 'SendMessage', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,
        [Parameter(ParameterSetName = 'SendMessage', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("ChannelId")]
        [string] $Channel,
        [Parameter(ParameterSetName = 'SendMessage', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Subject,
        [Parameter(ParameterSetName = 'SendMessage', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Message,
        [Parameter(ParameterSetName = 'SendMessage', ValueFromPipelineByPropertyName = $true)]
        [hashtable[]] $Attachments,
        [Parameter()]
        [ValidateSet('Text', 'Html')]
        [string] $ContentType = 'Text',
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

    }
    process {
        [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $Identity
        if ([object]::Equals($team, $null)) {
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
        [PSMicrosoftTeams.Channels.Channel] $teamChannel = Get-PSMsTeamsTeamChannel -Identity $Identity -Channel $Channel
        if ([object]::Equals($teamChannel, $null)) {
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
        $path = "teams/{0}/channels/{1}/messages" -f $team.id, $teamChannel.id
        $body = @{
            'body' = @{
                'contentType' = $ContentType.ToLower()
                'content'     = $Message
            }
        }
        if (Test-PSFParameterBinding -ParameterName 'Subject') { $body['subject'] = $Subject }
        if (Test-PSFParameterBinding -ParameterName 'Attachments') { $body['attachments'] = @($Attachments) }
        if ($PassThru.IsPresent) {
            [PSMicrosoftEntraID.Batch.Request]@{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
        }
        else {
            Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Message.Send' -ActionStringValues $Subject, $teamChannel.DisplayName -Target $team.DisplayName -ScriptBlock {
                [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
            } -EnableException:$EnableException -Confirm:$Force -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
