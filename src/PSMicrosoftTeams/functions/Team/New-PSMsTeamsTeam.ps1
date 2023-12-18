function New-PSMsTeamsTeam {
    <#
    .SYNOPSIS
        Create new  Microsoft Teams team.

    .DESCRIPTION
        Create new  Microsoft Teams team.

    .PARAMETER Identity
        MailnicName, Mail or Id of the team attribute populated in tenant/directory..

    .PARAMETER Displayname
        The display name for the team.

    .PARAMETER Description
       The description for the team.

    .PARAMETER MailNickname
        The mail alias for the team, unique for Microsoft 365 groups in the organization. Maximum length is 64 characters.

    .PARAMETER MailEnabled
        Specifies whether the group is mail-enabled.

    .PARAMETER Classification
        Describes a classification for the team.
    
    .PARAMETER Visibility
        Specifies the team join policy and team content visibility for groups. Possible values are: Private, Public, or HiddenMembership.

    .PARAMETER Template
        Specifies team template.

    .PARAMETER AllowGiphy
        Eable giphy for team.

    .PARAMETER GiphyContentRating
        Rating for giphy. Can be "Strict" or "Moderate".

    .PARAMETER AllowStickersAndMemes
        Enable Stickers and memes.

    .PARAMETER AllowCustomMemes
        Allow custom memes.

    .PARAMETER AllowGuestCreateUpdateChannels
        Setting that determines whether or not guests can create channels in the team.

    .PARAMETER AllowGuestDeleteChannels
        Setting that determines whether or not guests can delete in the team.

    .PARAMETER AllowCreateUpdateChannels
        Setting that determines whether or not members (and not just owners) are allowed to create channels.

    .PARAMETER AllowDeleteChannels
        Setting that determines whether or not members (and not only owners) can delete channels in the team.

    .PARAMETER AllowAddRemoveApps
        Boolean value that determines whether or not members (not only owners) are allowed to add apps to the team.

    .PARAMETER AllowCreateUpdateRemoveTabs
        Setting that determines whether or not members (and not only owners) can manage tabs in channels.

    .PARAMETER AllowCreateUpdateRemoveConnectors
        Setting that determines whether or not members (and not only owners) can manage connectors in the team.

    .PARAMETER AllowUserEditMessages
        Setting that determines whether or not users can edit messages that they have posted.

    .PARAMETER AllowUserDeleteMessages
        Setting that determines whether or not members can delete messages that they have posted.

    .PARAMETER AllowOwnerDeleteMessages
        Setting that determines whether or not owners can delete messages that they or other members of the team have posted.

    .PARAMETER AllowTeamMentions
        Setting that determines whether the entire team can be @ mentioned (which means that all users will be notified).

    .PARAMETER AllowChannelMentions
        Boolean value that determines whether or not channels in the team can be @ mentioned so that all users who follow the channel are notified.

    .PARAMETER ShowInTeamsSearchAndSuggestions
        The parameter has been deprecated.

    .PARAMETER EnableException
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user frien
        dly, but allows catching exceptions in calling scripts.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Confirm
        The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.


    .EXAMPLE
        PS C:\> New-PSEntraIDUser -DisplayName 'New Team' -Description 'Description of new team'

		Create new  Microsoft Teams team
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Team')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Identity')]
        [Alias("Id", "GroupId")]
        [ValidateGroupIdentity()]
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
        Assert-RestConnection -Service 'graph' -Cmdlet $PSCmdlet
        $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        $path = 'teams'
    }

    process {
        Switch ($PSCmdlet.ParameterSetName) {
            'Identity' {
                $body = [ordered]@{'group@odata.bind' = ''
                    'template@odata.bind'             = ''
                    'memberSettings'                  = @{
                        'allowCreateUpdateChannels'         = $false
                        'allowDeleteChannels'               = $false
                        'allowAddRemoveApps'                = $false
                        'allowCreateUpdateRemoveTabs'       = $false
                        'allowCreateUpdateRemoveConnectors' = $false
                    }
                    'guestSettings'                   = @{
                        'allowCreateUpdateChannels' = $false
                        'allowDeleteChannels'       = $false
                    }
                    'funSettings'                     = @{
                        'allowGiphy'            = $true
                        'giphyContentRating'    = 'Moderate'
                        'allowStickersAndMemes' = $true
                        'allowCustomMemes'      = $true
                    }
                    'messagingSettings'               = @{
                        'allowUserEditMessages'    = $true
                        'allowUserDeleteMessages'  = $true
                        'allowOwnerDeleteMessages' = $true
                        'allowTeamMentions'        = $true
                        'allowChannelMentions'     = $true
                    }
                    'discoverySettings'               = @{
                        'showInTeamsSearchAndSuggestions' = $false
                    }
                }
                $body['group@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath ('groups({0}{1}{2})' -f "'", $Identity, "'")
                $DisplayName = $Identity
            }
            'Team' {
                $body = [ordered]@{
                    'template@odata.bind' = ''
                    'displayName'         = ''
                    'mailNickname'        = ''
                    'mailEnabled'         = $true
                    'description'         = ''
                    'visibility'          = 'Public'
                    'owners@odata.bind'   = @()
                    'memberSettings'      = @{
                        'allowCreateUpdateChannels'         = $false
                        'allowDeleteChannels'               = $false
                        'allowAddRemoveApps'                = $false
                        'allowCreateUpdateRemoveTabs'       = $false
                        'allowCreateUpdateRemoveConnectors' = $false
                    }
                    'guestSettings'       = @{
                        'allowCreateUpdateChannels' = $false
                        'allowDeleteChannels'       = $false
                    }
                    'funSettings'         = @{
                        'allowGiphy'            = $true
                        'giphyContentRating'    = 'Moderate'
                        'allowStickersAndMemes' = $true
                        'allowCustomMemes'      = $true
                    }
                    'messagingSettings'   = @{
                        'allowUserEditMessages'    = $true
                        'allowUserDeleteMessages'  = $true
                        'allowOwnerDeleteMessages' = $true
                        'allowTeamMentions'        = $true
                        'allowChannelMentions'     = $true
                    }
                    'discoverySettings'   = @{
                        'showInTeamsSearchAndSuggestions' = $false
                    }
                }
                $body['displayName'] = $DisplayName
                if (Test-PSFParameterBinding -Parameter Description) {
                    $body['description'] = $Description
                }

                if (Test-PSFParameterBinding -Parameter MailNickName) {
                    $body['mailNickName'] = $MailNickName
                }

                if (Test-PSFParameterBinding -Parameter MailEnabled) {
                    $body['mailEnabled'] = $MailEnabled
                }

                if (Test-PSFParameterBinding -Parameter Classification) {
                    $body['classification'] = $Classification
                }

                if (Test-PSFParameterBinding -Parameter Visibility) {
                    $body['visibility'] = $Visibility
                }

            }
        }
        if (Test-PSFParameterBinding -Parameter Template) {
            $body['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath ('teamsTemplates({0}{1}{2})' -f "'", $template, "'")
        }
        else {
            $body['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath ('teamsTemplates({0}standard{1})' -f "'", "'")
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateChannels) {
            $body['memberSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
        }

        if (Test-PSFParameterBinding -Parameter allowDeleteChannels) {
            $body['memberSettings']['allowDeleteChannels'] = $AllowDeleteChannels
        }

        if (Test-PSFParameterBinding -Parameter allowAddRemoveApps) {
            $body['memberSettings']['allowAddRemoveApps'] = $AllowAddRemoveApps
        }

        if (Test-PSFParameterBinding -Parameter allowAddRemoveApps) {
            $body['memberSettings']['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateRemoveConnectors) {
            $body['memberSettings']['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateChannels) {
            $body['guestSettings']['allowCreateUpdateChannels'] = $AllowGuestCreateUpdateChannels
        }

        if (Test-PSFParameterBinding -Parameter allowDeleteChannels) {
            $body['guestSettings']['allowDeleteChannels'] = $AllowGuestDeleteChannels
        }

        if (Test-PSFParameterBinding -Parameter allowGiphy) {
            $body['funSettings']['allowGiphy'] = $AllowGiphy
        }

        if (Test-PSFParameterBinding -Parameter giphyContentRating) {
            $body['funSettings']['giphyContentRating'] = $GiphyContentRating
        }

        if (Test-PSFParameterBinding -Parameter allowStickersAndMemes) {
            $body['funSettings']['allowStickersAndMemes'] = $AllowStickersAndMemes
        }

        if (Test-PSFParameterBinding -Parameter allowCustomMemes) {
            $body['funSettings']['allowCustomMemes'] = $AllowCustomMemes
        }

        if (Test-PSFParameterBinding -Parameter allowUserEditMessages) {
            $body['messagingSettings']['allowUserEditMessages'] = $allowUserEditMessages
        }

        if (Test-PSFParameterBinding -Parameter allowUserDeleteMessages) {
            $body['messagingSettings']['allowUserDeleteMessages'] = $AllowUserDeleteMessages
        }

        if (Test-PSFParameterBinding -Parameter allowOwnerDeleteMessages) {
            $body['messagingSettings']['allowOwnerDeleteMessages'] = $AllowOwnerDeleteMessages
        }

        if (Test-PSFParameterBinding -Parameter allowTeamMentions) {
            $body['messagingSettings']['allowTeamMentions'] = $AllowTeamMentions
        }

        if (Test-PSFParameterBinding -Parameter allowTeamMentions) {
            $body['messagingSettings']['allowChannelMentions'] = $AllowChannelMentions
        }

        if (Test-PSFParameterBinding -Parameter showInTeamsSearchAndSuggestions) {

            $body['discoverySettings']['showInTeamsSearchAndSuggestions'] = $ShowInTeamsSearchAndSuggestions
        }
        Invoke-PSFProtectedCommand -ActionString 'Team.New' -ActionStringValues $Displayname -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
            [void](Invoke-RestRequest -Service 'graph' -Path $path -Body $body -Method Post -ErrorAction Stop)
        } -EnableException $EnableException -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
        if (Test-PSFFunctionInterrupt) { return }
    }
    end {

    }
}