function Send-PSMsTeamsTeamChannelMessage {
<#
.SYNOPSIS
    Send a formatted message to a Microsoft Teams channel via Microsoft Graph API.

.DESCRIPTION
    Sends a message (plain text or HTML) to a specified Teams channel. Supports basic formatting (bold, italics, links, lists) via HTML.
    Uses POST /teams/{team-id}/channels/{channel-id}/messages.

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER ChannelId
    Id of the channel to post the message to.

.PARAMETER Message
    The message content (string) or object (pipeline input supported).

.PARAMETER ContentType
    Format of message: "text" (default) or "html". "html" supports formatting (bold, links, etc).

.PARAMETER Subject
    Optional subject/title for the message (shown in activity feed and channel).

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.EXAMPLE
    # Send plain text
    Send-PSMsTeamsTeamChannelMessage -Identity team1 -ChannelId channel1 -Message "Hello, team!"

.EXAMPLE
    # Send HTML-formatted message
    $html = "<b>Build completed:</b> <a href='https://dev.azure.com'>Check logs here</a><ul><li>Step 1 OK</li><li>Step 2 OK</li></ul>"
    Send-PSMsTeamsTeamChannelMessage -Identity team1 -ChannelId channel1 -Message $html -ContentType html

.EXAMPLE
    # Pipeline
    "Automaticky vygenerovaná zpráva" | Send-PSMsTeamsTeamChannelMessage -Identity team1 -ChannelId channel1
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = 'StringMessage')]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $true)]
        [Alias("Channel")]
        [string] $ChannelId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('text', 'html')]
        [string] $ContentType = 'text',

        [Parameter(Mandatory = $false)]
        [string] $Subject,

        [Parameter()]
        [switch] $EnableException,

        [Parameter()]
        [switch] $Force
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{ 'Content-Type' = 'application/json' }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')) {
            [boolean] $cmdLetVerbose = $true
        } else {
            [boolean] $cmdLetVerbose = $false
        }
        $teamObj = Get-PSMsTeamsTeam -Identity $Identity -EnableException:$EnableException
        if ([object]::Equals($teamObj, $null) -or -not $teamObj.Id) {
            
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            }
        }
        $teamId = $teamObj.Id
        $path = "teams/$teamId/channels/$ChannelId/messages"
    }
    process {
        $body = @{
            'body' = @{
                'contentType' = $ContentType
                'content'     = $Message
            }
        }
        if ($Subject) { $body['subject'] = $Subject }
        if ($PSCmdlet.ShouldProcess("$Identity/$ChannelId", "Send message to Teams channel")) {
            Invoke-PSFProtectedCommand -ActionString 'TeamChannel.Message.Send' -ActionStringValues ($Message.Substring(0, [Math]::Min($Message.Length, 32))) -Target $teamId -ScriptBlock {
                [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -Verbose:$cmdLetVerbose -ErrorAction Stop)
            } -EnableException:$EnableException -Confirm:$Force -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
