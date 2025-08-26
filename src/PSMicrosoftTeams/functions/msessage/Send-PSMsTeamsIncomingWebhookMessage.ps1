function Send-PSMsTeamsIncomingWebhookMessage {
    <#
    .SYNOPSIS
        Sends a MessageCard (Markdown) to a Microsoft Teams Incoming Webhook.

    .DESCRIPTION
        Posts a MessageCard payload to a Teams channel Incoming Webhook URL.
        Supports Markdown text, optional facts (name/value pairs), and actions (buttons/links).
        This does NOT use Microsoft Graph; it calls the webhook endpoint directly.

    .PARAMETER WebhookUrl
        Incoming Webhook URL obtained from the Teams channel (Connectors -> Incoming Webhook).

    .PARAMETER Title
        Card title (also used as the card summary).

    .PARAMETER Text
        Card body in Markdown (bold **text**, _italics_, [link](https://…), lists, etc.).

    .PARAMETER ThemeColor
        Hex color without leading '#'. Default: 6264A7 (Teams purple-ish).

    .PARAMETER Facts
        Optional list of name/value pairs rendered as a fact table on the card.
        Example: @{ name='Build'; value='20250826.1' }

    .PARAMETER Actions
        Optional actions (buttons). Each item must be a hashtable in MessageCard schema format,
        e.g.: @{ '@type'='OpenUri'; name='Open Build'; targets=@(@{ os='default'; uri='https://…' }) }

    .PARAMETER Sections
        Optional raw 'sections' array (advanced). If supplied, it replaces the auto-generated section.
        Each section should comply with the MessageCard schema.

    .PARAMETER EnableException
        If set, the cmdlet throws on failure. Otherwise it writes warnings.

    .PARAMETER Force
        Suppresses confirmation prompts.

    .EXAMPLE
        Send-PSMsTeamsIncomingWebhookMessage -WebhookUrl $url -Title 'Build completed' -Text '**Status:** _Success_'

    .EXAMPLE
        $facts = @(
            @{ name='Build';  value='20250826.1' }
            @{ name='Status'; value='**Success**' }
        )
        $actions = @(
            @{ '@type'='OpenUri'; name='Open Build'; targets=@(@{ os='default'; uri='https://dev.azure.com/contoso/build/12345' }) }
        )
        Send-PSMsTeamsIncomingWebhookMessage -WebhookUrl $url -Title 'Release v1.4.2' -Text 'Changelog: - Added X' -Facts $facts -Actions $actions

    .NOTES
        - MessageCard supports Markdown (not HTML).
        - For full Teams message features (mentions, threads, files), use Graph (delegated/RSC) instead of webhooks.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https?://')]
        [string] $WebhookUrl,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Title,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Text,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidatePattern('^[A-Fa-f0-9]{6}$')]
        [string] $ThemeColor = '6264A7',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [hashtable[]] $Facts,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [hashtable[]] $Actions,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [hashtable[]] $Sections,

        [Parameter()]
        [switch] $EnableException,

        [Parameter()]
        [switch] $Force
    )

    begin {
        [int] $commandRetryCount = (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName) -ErrorAction SilentlyContinue)
        if (-not $commandRetryCount) { $commandRetryCount = 1 }
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName) -ErrorAction SilentlyContinue)
        if (-not $commandRetryWait) { $commandRetryWait = [TimeSpan]::FromSeconds(1) }

        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }

        $card = @{
            '@type'    = 'MessageCard'
            '@context' = 'http://schema.org/extensions'
            summary    = $Title
            themeColor = $ThemeColor
            title      = $Title
        }
    }

    process {
        if ($Sections -and $Sections.Count -gt 0) {
            $card['sections'] = @($Sections)
        }
        else {
            $section = @{ text = $Text }
            if ($Facts -and $Facts.Count -gt 0) { $section['facts'] = $Facts }
            $card['sections'] = @($section)
        }

        if ($Actions -and $Actions.Count -gt 0) {
            $card['potentialAction'] = $Actions
        }

        $json = $card | ConvertTo-Json -Depth 10
        Invoke-PSFProtectedCommand -ActionString 'Webhook.Message.Send' -ActionStringValues $Title -Target $WebhookUrl -ScriptBlock {
            Invoke-RestMethod -Method Post -Uri $WebhookUrl -Body $json -ContentType 'application/json' -ErrorAction Stop | Out-Null
        } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue
        if (Test-PSFFunctionInterrupt) { return }
    }

    end { }
}
