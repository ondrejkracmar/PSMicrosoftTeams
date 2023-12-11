function New-PSMsTeamsTeam {
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