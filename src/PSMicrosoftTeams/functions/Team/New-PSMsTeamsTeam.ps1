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
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user frien
        dly, but allows catching exceptions in calling scripts.

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
        PS C:\> New-PSMsTeamsTeam -DisplayName 'New Team' -Description 'Description of new team'

        Creates a new Microsoft Teams team.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'InputObject')]
    param([Parameter(Mandatory = $True, ValueFromPipeline = $true, ParameterSetName = 'InputObject')]
        [PSMicrosoftEntraID.Groups.Group[]] $InputObject,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId")]
        [ValidateGroupIdentity()]
        [string[]]$Identity,
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
        [Parameter(ParameterSetName = 'InputObject', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'Identity', ValueFromPipelineByPropertyName = $true)]
        [string]$Template,
        [Parameter(ParameterSetName = 'Team', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Owners,
        [Parameter(ParameterSetName = 'Team')]
        [string[]]$Members,
        [System.Nullable[bool]]$AllowGiphy,
        [Parameter()]
        [string]$GiphyContentRating,
        [Parameter()]
        [System.Nullable[bool]]$AllowStickersAndMemes,
        [Parameter()]
        [System.Nullable[bool]]$AllowCustomMemes,
        [Parameter()]
        [System.Nullable[bool]]$AllowGuestCreateUpdateChannels,
        [Parameter()]
        [System.Nullable[bool]]$AllowGuestDeleteChannels,
        [Parameter()]
        [System.Nullable[bool]]$AllowCreateUpdateChannels,
        [Parameter()]
        [System.Nullable[bool]]$AllowDeleteChannels,
        [Parameter()]
        [System.Nullable[bool]]$AllowAddRemoveApps,
        [Parameter()]
        [System.Nullable[bool]]$AllowCreateUpdateRemoveTabs,
        [Parameter()]
        [System.Nullable[bool]]$AllowCreateUpdateRemoveConnectors,
        [Parameter()]
        [System.Nullable[bool]]$AllowUserEditMessages,
        [Parameter()]
        [System.Nullable[bool]]$AllowUserDeleteMessages,
        [Parameter()]
        [System.Nullable[bool]]$AllowOwnerDeleteMessages,
        [Parameter()]
        [System.Nullable[bool]]$AllowTeamMentions,
        [Parameter()]
        [System.Nullable[bool]]$AllowChannelMentions,
        [Parameter()]
        [System.Nullable[bool]]$ShowInTeamsSearchAndSuggestions,
        [Parameter()]
        [switch] $EnableException,
        [Parameter()]
        [switch] $Force,
        [Parameter()]
        [switch]$PassThru
    )
    begin {
        $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        $path = 'teams'
        $header = @{ 'Content-Type' = 'application/json' }
        $method = 'POST'
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
    }
    process {
        $body = [ordered]@{}
        switch -Regex ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                foreach ($itemInputObject in $InputObject) {
                    $body['group@odata.bind'] = ('{0}/groups(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $itemInputObject.Id)
                    if (Test-PSFParameterBinding -ParameterName 'DisplayName') { $body['displayName'] = $DisplayName }
                    if (Test-PSFParameterBinding -ParameterName 'MailNickName') { $body['mailNickName'] = $MailNickName }
                    if (Test-PSFParameterBinding -ParameterName 'MailEnabled') { $body['mailEnabled'] = $MailEnabled }
                    if (Test-PSFParameterBinding -ParameterName 'Description') { $body['description'] = $Description }
                    if (Test-PSFParameterBinding -ParameterName 'Visibility') { $body['visibility'] = $Visibility }
                    if (Test-PSFParameterBinding -ParameterName 'Classification') { $body['classification'] = $Classification }
                    $memberSettings = @{}
                    if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateChannels') { $memberSettings['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels }
                    if (Test-PSFParameterBinding -ParameterName 'AllowDeleteChannels') { $memberSettings['allowDeleteChannels'] = $AllowDeleteChannels }
                    if (Test-PSFParameterBinding -ParameterName 'AllowAddRemoveApps') { $memberSettings['allowAddRemoveApps'] = $AllowAddRemoveApps }
                    if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveTabs') { $memberSettings['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs }
                    if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveConnectors') { $memberSettings['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors }
                    if ($memberSettings.Count -gt 0) { $body['memberSettings'] = $memberSettings }

                    $guestSettings = @{}
                    if (Test-PSFParameterBinding -ParameterName 'AllowGuestCreateUpdateChannels') { $guestSettings['allowCreateUpdateChannels'] = $AllowGuestCreateUpdateChannels }
                    if (Test-PSFParameterBinding -ParameterName 'AllowGuestDeleteChannels') { $guestSettings['allowDeleteChannels'] = $AllowGuestDeleteChannels }
                    if ($guestSettings.Count -gt 0) { $body['guestSettings'] = $guestSettings }

                    $funSettings = @{}
                    if (Test-PSFParameterBinding -ParameterName 'AllowGiphy') { $funSettings['allowGiphy'] = $AllowGiphy }
                    if (Test-PSFParameterBinding -ParameterName 'GiphyContentRating') { $funSettings['giphyContentRating'] = $GiphyContentRating }
                    if (Test-PSFParameterBinding -ParameterName 'AllowStickersAndMemes') { $funSettings['allowStickersAndMemes'] = $AllowStickersAndMemes }
                    if (Test-PSFParameterBinding -ParameterName 'AllowCustomMemes') { $funSettings['allowCustomMemes'] = $AllowCustomMemes }
                    if ($funSettings.Count -gt 0) { $body['funSettings'] = $funSettings }

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
                    if (Test-PSFParameterBinding -ParameterName 'Template' -BoundParameters $PSBoundParameters) {
                        $body['template@odata.bind'] = ('{0}/teamsTemplates(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $Template)
                    }
                    else {
                        $body['template@odata.bind'] = ('{0}/teamsTemplates(''standard'')' -f (Get-EntraService -Name $service).ServiceUrl)
                    }

                    if ($PassThru.IsPresent) {
                        [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        Invoke-PSFProtectedCommand -ActionString 'Team.NewTeamFromGroup' -ActionStringValues $itemInputObject.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
                        } -EnableException:$EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }
            }
            'Identity' {
                foreach ($itemIdentity in $Identity) {
                    $body['group@odata.bind'] = ('{0}/groups(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $itemIdentity)
                    if (Test-PSFParameterBinding -ParameterName 'DisplayName') { $body['displayName'] = $DisplayName }
                    if (Test-PSFParameterBinding -ParameterName 'MailNickName') { $body['mailNickName'] = $MailNickName }
                    if (Test-PSFParameterBinding -ParameterName 'MailEnabled') { $body['mailEnabled'] = $MailEnabled }
                    if (Test-PSFParameterBinding -ParameterName 'Description') { $body['description'] = $Description }
                    if (Test-PSFParameterBinding -ParameterName 'Visibility') { $body['visibility'] = $Visibility }
                    if (Test-PSFParameterBinding -ParameterName 'Classification') { $body['classification'] = $Classification }
                    $memberSettings = @{}
                    if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateChannels') { $memberSettings['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels }
                    if (Test-PSFParameterBinding -ParameterName 'AllowDeleteChannels') { $memberSettings['allowDeleteChannels'] = $AllowDeleteChannels }
                    if (Test-PSFParameterBinding -ParameterName 'AllowAddRemoveApps') { $memberSettings['allowAddRemoveApps'] = $AllowAddRemoveApps }
                    if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveTabs') { $memberSettings['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs }
                    if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveConnectors') { $memberSettings['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors }
                    if ($memberSettings.Count -gt 0) { $body['memberSettings'] = $memberSettings }

                    $guestSettings = @{}
                    if (Test-PSFParameterBinding -ParameterName 'AllowGuestCreateUpdateChannels') { $guestSettings['allowCreateUpdateChannels'] = $AllowGuestCreateUpdateChannels }
                    if (Test-PSFParameterBinding -ParameterName 'AllowGuestDeleteChannels') { $guestSettings['allowDeleteChannels'] = $AllowGuestDeleteChannels }
                    if ($guestSettings.Count -gt 0) { $body['guestSettings'] = $guestSettings }

                    $funSettings = @{}
                    if (Test-PSFParameterBinding -ParameterName 'AllowGiphy') { $funSettings['allowGiphy'] = $AllowGiphy }
                    if (Test-PSFParameterBinding -ParameterName 'GiphyContentRating') { $funSettings['giphyContentRating'] = $GiphyContentRating }
                    if (Test-PSFParameterBinding -ParameterName 'AllowStickersAndMemes') { $funSettings['allowStickersAndMemes'] = $AllowStickersAndMemes }
                    if (Test-PSFParameterBinding -ParameterName 'AllowCustomMemes') { $funSettings['allowCustomMemes'] = $AllowCustomMemes }
                    if ($funSettings.Count -gt 0) { $body['funSettings'] = $funSettings }

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
                    if (Test-PSFParameterBinding -ParameterName 'Template' -BoundParameters $PSBoundParameters) {
                        $body['template@odata.bind'] = ('{0}/teamsTemplates(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $Template)
                    }
                    else {
                        $body['template@odata.bind'] = ('{0}/teamsTemplates(''standard'')' -f (Get-EntraService -Name $service).ServiceUrl)
                    }

                    if ($PassThru.IsPresent) {
                        [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        Invoke-PSFProtectedCommand -ActionString 'Team.NewTeamFromGroup' -ActionStringValues $Identity -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
                        } -EnableException:$EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }
            }
            'Team' {
                if (Test-PSFParameterBinding -ParameterName 'DisplayName') { $body['displayName'] = $DisplayName }
                if (Test-PSFParameterBinding -ParameterName 'MailNickName') { $body['mailNickName'] = $MailNickName }
                if (Test-PSFParameterBinding -ParameterName 'MailEnabled') { $body['mailEnabled'] = $MailEnabled }
                if (Test-PSFParameterBinding -ParameterName 'Description') { $body['description'] = $Description }
                if (Test-PSFParameterBinding -ParameterName 'Visibility') { $body['visibility'] = $Visibility }
                if (Test-PSFParameterBinding -ParameterName 'Classification') { $body['classification'] = $Classification }
                $memberSettings = @{}
                if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateChannels') { $memberSettings['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels }
                if (Test-PSFParameterBinding -ParameterName 'AllowDeleteChannels') { $memberSettings['allowDeleteChannels'] = $AllowDeleteChannels }
                if (Test-PSFParameterBinding -ParameterName 'AllowAddRemoveApps') { $memberSettings['allowAddRemoveApps'] = $AllowAddRemoveApps }
                if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveTabs') { $memberSettings['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs }
                if (Test-PSFParameterBinding -ParameterName 'AllowCreateUpdateRemoveConnectors') { $memberSettings['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors }
                if ($memberSettings.Count -gt 0) { $body['memberSettings'] = $memberSettings }

                $guestSettings = @{}
                if (Test-PSFParameterBinding -ParameterName 'AllowGuestCreateUpdateChannels') { $guestSettings['allowCreateUpdateChannels'] = $AllowGuestCreateUpdateChannels }
                if (Test-PSFParameterBinding -ParameterName 'AllowGuestDeleteChannels') { $guestSettings['allowDeleteChannels'] = $AllowGuestDeleteChannels }
                if ($guestSettings.Count -gt 0) { $body['guestSettings'] = $guestSettings }

                $funSettings = @{}
                if (Test-PSFParameterBinding -ParameterName 'AllowGiphy') { $funSettings['allowGiphy'] = $AllowGiphy }
                if (Test-PSFParameterBinding -ParameterName 'GiphyContentRating') { $funSettings['giphyContentRating'] = $GiphyContentRating }
                if (Test-PSFParameterBinding -ParameterName 'AllowStickersAndMemes') { $funSettings['allowStickersAndMemes'] = $AllowStickersAndMemes }
                if (Test-PSFParameterBinding -ParameterName 'AllowCustomMemes') { $funSettings['allowCustomMemes'] = $AllowCustomMemes }
                if ($funSettings.Count -gt 0) { $body['funSettings'] = $funSettings }

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
                if (Test-PSFParameterBinding -ParameterName 'Template' -BoundParameters $PSBoundParameters) {
                    $body['template@odata.bind'] = ('{0}/teamsTemplates(''{1}'')' -f (Get-EntraService -Name $service).ServiceUrl, $Template)
                }
                else {
                    $body['template@odata.bind'] = ('{0}/teamsTemplates(''standard'')' -f (Get-EntraService -Name $service).ServiceUrl)
                }

                if (Test-PSFParameterBinding -ParameterName 'Owners') {
                    [System.Collections.ArrayList] $bodyOwnerUrlList = [System.Collections.ArrayList]::new()
                    foreach ($itemOwner in $Owners) {
                        [PSMicrosoftTeams.Users.User] $aADUser = Get-PSEntraIDUser -Identity $itemOwner
                        [hashtable] $ownerBody = @{}
                        if (-not([object]::Equals($aADUser, $null))) {
                            $ownerBody['@odata.type'] = '#microsoft.graph.aadUserConversationMember'
                            $ownerBody['user@odata.bind'] = ('{0}/users/''({1})''' -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                            $ownerBody['roles'] = @('owner')
                            [void] $bodyOwnerUrlList.Add($ownerBody )
                            $body = @{ members = [array]$bodyOwnerUrlList }
                        }
                        else {
                            if ($EnableException.IsPresent) {
                                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $itemOwner)
                            }
                        }
                    }
                }
                if (Test-PSFParameterBinding -ParameterName 'Members') {
                    [System.Collections.ArrayList] $bodyMemberUrlList = [System.Collections.ArrayList]::new()
                    foreach ($itemMember in $Members) {
                        [hashtable] $memberBody = @{}
                        [PSMicrosoftTeams.Users.User] $aADUser = Get-PSEntraIDUser -Identity $itemMember
                        if (-not([object]::Equals($aADUser, $null))) {
                            $memberBody['@odata.type'] = '#microsoft.graph.aadUserConversationMember'
                            $memberBody['user@odata.bind'] = ('{0}/users/''({1})''' -f (Get-EntraService -Name $service).ServiceUrl, $aADUser.Id)
                            $memberBody['roles'] = @('member')
                            [void]$memberBodyList.Add($memberBody)
                        }
                        else {
                            if ($EnableException.IsPresent) {
                                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $itemMember)
                            }
                        }
                    }
                }

                if ($PassThru.IsPresent) {
                    [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                }
                else {
                    Invoke-PSFProtectedCommand -ActionString 'Team.New' -ActionStringValues $body['displayName'] -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -ErrorAction Stop)
                    } -EnableException:$EnableException -Confirm:$($cmdLetConfirm) -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
        }
    }
    end { }
}

