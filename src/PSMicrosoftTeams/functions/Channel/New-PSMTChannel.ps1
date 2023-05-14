function New-PSMTChannel {
    [CmdletBinding(DefaultParameterSetName = 'CreateChannel')]
    param(
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                try {
                    [System.Guid]::Parse($_) | Out-Null
                    $true
                }
                catch {
                    $false
                }
            })]
        [Alias("Id")]
        $TeamId,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Description,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Standard', 'Private')]
        [string]
        $MembershipType,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('AuthorAndModerators', 'Everyone')]
        [string]
        $ReplyrRestriction,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('EveryoneExceptGuests', 'Moderators')]
        [string]
        $UserNewMessageRestriction,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [boolean]
        $AllowNewMessageFromBots,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateChannel', ValueFromPipelineByPropertyName = $true)]
        [boolean]
        $AllowNewMessageFromConnectors,
        [Parameter(ParameterSetName = 'CreateTeamBehalfOUser', ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                try {
                    [System.Guid]::Parse($_) | Out-Null
                    $true
                }
                catch {
                    $false
                }
            })]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $Owner,
        [Parameter(ParameterSetName = 'CreateTeamMigrationMode', ValueFromPipelineByPropertyName = $true)]
        [switch]
        $MigrationMode,
        [Parameter(ParameterSetName = 'CreateChannelViaJson')]
        [string]
        $JsonRequest,
        [switch]
        $Status
    )
    begin {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Get-PSMTAuthorizationToken
            $graphApiParameters = @{
                Method             = 'Post'
                AuthorizationToken = "Bearer $authorizationToken"
            }
            $requestBodyCreateChannelTemplateJSON = '{
                "displayName": "",
                "description": "",
                "membershipType": "standard",
                "moderationSettings": {
                    "userNewMessageRestriction": "everyoneExceptGuests",
                    "replyRestriction": "everyone",
                    "allowNewMessageFromBots": true,
                    "allowNewMessageFromConnectors": true
                }
            }'
            $requestBodyCreateChannelTemplateMigrationJSON = '{
                "@microsoft.graph.channelCreationMode": "migration",
                "displayName": "",
                "description": "",
                "membershipType": "standard",
                "createdDateTime": "",
                "moderationSettings": {
                    "userNewMessageRestriction": "everyoneExceptGuests",
                    "replyRestriction": "everyone",
                    "allowNewMessageFromBots": true,
                    "allowNewMessageFromConnectors": true
                }
            }'
            $requestBodyCreateChannelTemplateBehalfOUserJSON = '{
                "@odata.type": "#Microsoft.Graph.channel",
                "membershipType": "private",
                "displayName": "",
                "description": "",
                    "members":
                       [
                          {
                             "@odata.type":"#microsoft.graph.aadUserConversationMember",
                             "user@odata.bind":"",
                             "roles":["owner"]
                          }
                       ],
                       "moderationSettings": {
                        "userNewMessageRestriction": "everyoneExceptGuests",
                        "replyRestriction": "everyone",
                        "allowNewMessageFromBots": true,
                        "allowNewMessageFromConnectors": true
                    }
                  }'
            
        } 
        catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
    }
	
    process {
        if (Test-PSFFunctionInterrupt) { return }

        $graphApiParameters['uri'] = $url
        Switch ($PSCmdlet.ParameterSetName) {
            'CreateChannelViaJson' {                               
                $bodyParameters = $JsonRequest | ConvertFrom-Json | ConvertTo-PSFHashtable
            }
            'CreateChannel' {
                $bodyParameters = $requestBodyCreateTeamFromGroupTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                    
                if (Test-PSFParameterBinding -Parameter Template) {
                    $bodyParameters['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teamsTemplates('$($Template)')"
                }
                else {
                    $bodyParameters['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teamsTemplates('standard')"
                }
            }
            'CreateTeamBehalfOUser' {
                $bodyParameters = $requestBodyCreateChannelTemplateBehalfOUserJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                $bodyParameters['displayName'] = $DisplayName
            }
            'CreateTeamMigrationMode' {
                $bodyParameters = $requestBodyCreateChannelTemplateMigrationJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                $bodyParameters['@microsoft.graph.channelCreationMode'] = 'migration'
            }
            'Default' {
                $bodyParameters = $requestBodyCreateChannelTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
            }
        }

        if (Test-PSFParameterBinding -Parameter Description) {
            $bodyParameters['description'] = $Description
        }

        if (Test-PSFParameterBinding -Parameter MailNickName) {
            $bodyParameters['mailNickName'] = $MailNickName
        }

        if (Test-PSFParameterBinding -Parameter MailEnabled) {
            $bodyParameters['mailEnabled'] = $MailEnabled
        }

        if (Test-PSFParameterBinding -Parameter Visibility) {
            $bodyParameters['visibility'] = $Visibility
        }

        if (Test-PSFParameterBinding -Parameter Template) {
            $bodyParameters['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teamsTemplates('$($Template)')"
        }
        else {
            $bodyParameters['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teamsTemplates('standard')"
        }

        if (Test-PSFParameterBinding -Parameter Owner) {                                         
            $bodyParameters['owners@odata.bind'] = @(Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users('$($owner)')")
        }
            
        if (Test-PSFParameterBinding -Parameter allowCreateUpdateChannels) {
            $bodyParameters['memberSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateChannels) {
            $bodyParameters['memberSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
        }

        if (Test-PSFParameterBinding -Parameter allowDeleteChannels) {
            $bodyParameters['memberSettings']['allowDeleteChannels'] = $AllowDeleteChannels
        }

        if (Test-PSFParameterBinding -Parameter allowAddRemoveApps) {
            $bodyParameters['memberSettings']['allowAddRemoveApps'] = $AllowAddRemoveApps
        }

        if (Test-PSFParameterBinding -Parameter allowAddRemoveApps) {
            $bodyParameters['memberSettings']['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateRemoveConnectors) {
            $bodyParameters['memberSettings']['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateChannels) {
            $bodyParameters['guestSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
        }

        if (Test-PSFParameterBinding -Parameter allowCreateUpdateChannels) {
            $bodyParameters['guestSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
        }

        if (Test-PSFParameterBinding -Parameter allowDeleteChannels) {
            $bodyParameters['guestSettings']['allowDeleteChannels'] = $AllowDeleteChannels
        }
            
        if (Test-PSFParameterBinding -Parameter allowGiphy) {
            $bodyParameters['funSettings']['allowGiphy'] = $AllowGiphy
        }

        if (Test-PSFParameterBinding -Parameter giphyContentRating) {
            $bodyParameters['funSettings']['giphyContentRating'] = $GiphyContentRating
        }

        if (Test-PSFParameterBinding -Parameter allowStickersAndMemes) {
            $bodyParameters['funSettings']['allowStickersAndMemes'] = $AllowStickersAndMemes
        }

        if (Test-PSFParameterBinding -Parameter allowCustomMemes) {
            $bodyParameters['funSettings']['allowCustomMemes'] = $AllowCustomMemes
        }
            
        if (Test-PSFParameterBinding -Parameter allowUserEditMessages) {
            $bodyParameters['messagingSettings']['allowUserEditMessages'] = $allowUserEditMessages
        }
            
        if (Test-PSFParameterBinding -Parameter allowUserDeleteMessages) {
            $bodyParameters['messagingSettings']['allowUserDeleteMessages'] = $AllowUserDeleteMessages
        }

        if (Test-PSFParameterBinding -Parameter allowOwnerDeleteMessages) {
            $bodyParameters['messagingSettings']['allowOwnerDeleteMessages'] = $AllowOwnerDeleteMessages
        }

        if (Test-PSFParameterBinding -Parameter allowTeamMentions) {
            $bodyParameters['messagingSettings']['allowTeamMentions'] = $AllowTeamMentions
        }

        if (Test-PSFParameterBinding -Parameter allowChannelMentions) {
            $bodyParameters['messagingSettings']['allowChannelMentions'] = $AllowChannelMentions
        }

        if (Test-PSFParameterBinding -Parameter showInTeamsSearchAndSuggestions) {
            $bodyParametersy['discoverySettings']['showInTeamsSearchAndSuggestions'] = $ShowInTeamsSearchAndSuggestions
        }
        
        else {
            [string]$requestJSONQuery = $bodyParameters | ConvertTo-Json -Depth 10 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
            $graphApiParameters['body'] = $requestJSONQuery
                
            If ($Status.IsPresent) {
                $graphApiParameters['Status'] = $true
            }
            $newTeamResult = Invoke-GraphApiQuery @graphApiParameters
            $newTeamResult
        }
    
    }
    end {

    }
}