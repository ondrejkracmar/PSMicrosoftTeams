function New-PSMsTeamsTeam {
    <#
    .SYNOPSIS
        Creates a new Microsoft Teams team.

    .DESCRIPTION
        Creates a new Microsoft Teams team, including support for advanced settings (funSettings, memberSettings, guestSettings, messagingSettings, etc.).
        All settings and properties are only included if explicitly set as a parameter, resulting in minimal, clean, and API-compliant request bodies.

    .PARAMETER Identity
        Group ID, MailNickName, or Mail of the existing Microsoft 365 Group to teamify.

    .PARAMETER DisplayName
        The display name for the team.

    .PARAMETER Description
        The description for the team.

    .PARAMETER MailNickName
        The mail alias for the team, unique within Microsoft 365 tenant.

    .PARAMETER MailEnabled
        Specifies whether the group is mail-enabled.

    .PARAMETER Classification
        Describes a classification for the team.

    .PARAMETER Visibility
        Specifies the team join policy and content visibility (Private, Public, or HiddenMembership).

    .PARAMETER Template
        Specifies the team template.

    .PARAMETER Owners
        List of owners of the new team.

    .PARAMETER Members
        List of members of the new team.

    .PARAMETER AllowGiphy, GiphyContentRating, AllowStickersAndMemes, AllowCustomMemes
        Fun settings for the team.

    .PARAMETER AllowGuestCreateUpdateChannels, AllowGuestDeleteChannels
        Guest settings for the team.

    .PARAMETER AllowCreateUpdateChannels, AllowDeleteChannels, AllowAddRemoveApps, AllowCreateUpdateRemoveTabs, AllowCreateUpdateRemoveConnectors
        Member settings for the team.

    .PARAMETER AllowUserEditMessages, AllowUserDeleteMessages, AllowOwnerDeleteMessages, AllowTeamMentions, AllowChannelMentions
        Messaging settings for the team.

    .PARAMETER ShowInTeamsSearchAndSuggestions
        The parameter has been deprecated.

    .PARAMETER EnableException
        Enables the throwing of exceptions for advanced scripting scenarios.

    .EXAMPLE
        PS C:\> New-PSMsTeamsTeam -DisplayName 'New Team' -Description 'Description of new team'
        Creates a new Microsoft Teams team.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Team')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId")]
        [string]$Identity,

        [Parameter(ParameterSetName = 'Team', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(ParameterSetName = 'Team', ValueFromPipelineByPropertyName = $true)]
        [string]$Description,

        [Parameter(ParameterSetName = 'Team', ValueFromPipelineByPropertyName = $true)]
        [string]$MailNickName,

        [Parameter(ParameterSetName = 'Team', ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[bool]]$MailEnabled = $true,

        [Parameter(ParameterSetName = 'Team', ValueFromPipelineByPropertyName = $true)]
        [string]$Classification,

        [Parameter(ParameterSetName = 'Team', ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Public', 'Private', 'HiddenMembership')]
        [string]$Visibility,

        [Parameter(ParameterSetName = 'Team', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'Identity', ValueFromPipelineByPropertyName = $true)]
        [string]$Template,

        [Parameter(ParameterSetName = 'Team', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Owners,

        [Parameter(ParameterSetName = 'Team')]
        [string[]]$Members,

        [System.Nullable[bool]]$AllowGiphy,
        [string]$GiphyContentRating,
        [System.Nullable[bool]]$AllowStickersAndMemes,
        [System.Nullable[bool]]$AllowCustomMemes,
        [System.Nullable[bool]]$AllowGuestCreateUpdateChannels,
        [System.Nullable[bool]]$AllowGuestDeleteChannels,
        [System.Nullable[bool]]$AllowCreateUpdateChannels,
        [System.Nullable[bool]]$AllowDeleteChannels,
        [System.Nullable[bool]]$AllowAddRemoveApps,
        [System.Nullable[bool]]$AllowCreateUpdateRemoveTabs,
        [System.Nullable[bool]]$AllowCreateUpdateRemoveConnectors,
        [System.Nullable[bool]]$AllowUserEditMessages,
        [System.Nullable[bool]]$AllowUserDeleteMessages,
        [System.Nullable[bool]]$AllowOwnerDeleteMessages,
        [System.Nullable[bool]]$AllowTeamMentions,
        [System.Nullable[bool]]$AllowChannelMentions,
        [System.Nullable[bool]]$ShowInTeamsSearchAndSuggestions,
        [switch]$EnableException
    )
    begin {
        $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        $path = 'teams'
        $header = @{ 'Content-Type' = 'application/json' }
    }
    process {
        $body = [ordered]@{}

        # Bind common properties only if set
        if ($PSCmdlet.ParameterSetName -eq 'Identity') {
            $body['group@odata.bind'] = ('{0}/groups(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $Identity)
        }
        else {
            if (Test-PSFParameterBinding -ParameterName 'DisplayName') { $body['displayName'] = $DisplayName }
            if (Test-PSFParameterBinding -ParameterName 'MailNickName') { $body['mailNickName'] = $MailNickName }
            if (Test-PSFParameterBinding -ParameterName 'MailEnabled') { $body['mailEnabled'] = $MailEnabled }
            if (Test-PSFParameterBinding -ParameterName 'Description') { $body['description'] = $Description }
            if (Test-PSFParameterBinding -ParameterName 'Visibility') { $body['visibility'] = $Visibility }
            if (Test-PSFParameterBinding -ParameterName 'Classification') { $body['classification'] = $Classification }
        }

        # Template binding (always present, fallback to standard)
        if (Test-PSFParameterBinding -ParameterName 'Template' -BoundParameters $PSBoundParameters) {
            $body['template@odata.bind'] = ('{0}/teamsTemplates(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $Template)
        }
        else {
            $body['template@odata.bind'] = ('{0}/teamsTemplates(''standard'')' -f (Get-EntraService -Name $service).ServiceUrl)
        }

        # Owners & Members
        $memberBodyList = [System.Collections.ArrayList]::new()
        if ($Owners) {
            foreach ($owner in $Owners) {
                $memberBody = @{}
                $aADUser = Get-PSMsTeamsUser -Identity $owner
                if ($aADUser) {
                    $memberBody['@odata.type'] = '#microsoft.graph.aadUserConversationMember'
                    $memberBody['user@odata.bind'] = ('{0}/users/{1}' -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                    $memberBody['roles'] = @('owner')
                    [void]$memberBodyList.Add($memberBody)
                }
            }
        }
        if ($Members) {
            foreach ($member in $Members) {
                $memberBody = @{}
                $aADUser = Get-PSMsTeamsUser -Identity $member
                if ($aADUser) {
                    $memberBody['@odata.type'] = '#microsoft.graph.aadUserConversationMember'
                    $memberBody['user@odata.bind'] = ('{0}/users/{1}' -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                    $memberBody['roles'] = @('member')
                    [void]$memberBodyList.Add($memberBody)
                }
            }
        }
        if ($memberBodyList.Count -gt 0) {
            $body['members'] = [array]$memberBodyList
        }

        # MemberSettings – build only if at least one is set
        $memberSettings = @{}
        if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateChannels') { $memberSettings['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels }
        if (Test-PSFParameterBinding -ParameterName 'AllowDeleteChannels') { $memberSettings['allowDeleteChannels'] = $AllowDeleteChannels }
        if (Test-PSFParameterBinding -ParameterName 'AllowAddRemoveApps') { $memberSettings['allowAddRemoveApps'] = $AllowAddRemoveApps }
        if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveTabs') { $memberSettings['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs }
        if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveConnectors') { $memberSettings['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors }
        if ($memberSettings.Count -gt 0) { $body['memberSettings'] = $memberSettings }

        # GuestSettings – build only if at least one is set
        $guestSettings = @{}
        if (Test-PSFParameterBinding -ParameterName 'AllowGuestCreateUpdateChannels') { $guestSettings['allowCreateUpdateChannels'] = $AllowGuestCreateUpdateChannels }
        if (Test-PSFParameterBinding -ParameterName 'AllowGuestDeleteChannels') { $guestSettings['allowDeleteChannels'] = $AllowGuestDeleteChannels }
        if ($guestSettings.Count -gt 0) { $body['guestSettings'] = $guestSettings }

        # FunSettings – build only if at least one is set
        $funSettings = @{}
        if (Test-PSFParameterBinding -ParameterName 'AllowGiphy') { $funSettings['allowGiphy'] = $AllowGiphy }
        if (Test-PSFParameterBinding -ParameterName 'GiphyContentRating') { $funSettings['giphyContentRating'] = $GiphyContentRating }
        if (Test-PSFParameterBinding -ParameterName 'AllowStickersAndMemes') { $funSettings['allowStickersAndMemes'] = $AllowStickersAndMemes }
        if (Test-PSFParameterBinding -ParameterName 'AllowCustomMemes') { $funSettings['allowCustomMemes'] = $AllowCustomMemes }
        if ($funSettings.Count -gt 0) { $body['funSettings'] = $funSettings }

        # MessagingSettings – build only if at least one is set
        $messagingSettings = @{}
        if (Test-PSFParameterBinding -ParameterName 'AllowUserEditMessages') { $messagingSettings['allowUserEditMessages'] = $AllowUserEditMessages }
        if (Test-PSFParameterBinding -ParameterName 'AllowUserDeleteMessages') { $messagingSettings['allowUserDeleteMessages'] = $AllowUserDeleteMessages }
        if (Test-PSFParameterBinding -ParameterName 'AllowOwnerDeleteMessages') { $messagingSettings['allowOwnerDeleteMessages'] = $AllowOwnerDeleteMessages }
        if (Test-PSFParameterBinding -ParameterName 'AllowTeamMentions') { $messagingSettings['allowTeamMentions'] = $AllowTeamMentions }
        if (Test-PSFParameterBinding -ParameterName 'AllowChannelMentions') { $messagingSettings['allowChannelMentions'] = $AllowChannelMentions }
        if ($messagingSettings.Count -gt 0) { $body['messagingSettings'] = $messagingSettings }

        if (Test-PSFParameterBinding -ParameterName 'ShowInTeamsSearchAndSuggestions') {
            $body['discoverySettings'] = @{ 'showInTeamsSearchAndSuggestions' = $ShowInTeamsSearchAndSuggestions }
        }

        Invoke-PSFProtectedCommand -ActionString 'Team.New' -ActionStringValues $body['displayName'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
            [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
        } -EnableException:$EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
        if (Test-PSFFunctionInterrupt) { return }
    }
    end { }
}
