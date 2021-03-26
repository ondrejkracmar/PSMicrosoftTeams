function New-PSMTTeam {
    [CmdletBinding(DefaultParameterSetName = 'CreateTeam')]
    param(
        [Parameter(ParameterSetName = 'CreateTeamFromGroup', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
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
        $GroupId,
        [Parameter(ParameterSetName = 'CreateTeam', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
        [string]
        $Description,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
        [string]
        $MailNickName,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[bool]]
        $MailEnabled = $true,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
        [string]
        $Classification,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Public', 'Private', 'HiddenMembership')]
        [string]
        $Visibility,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'CreateTeamFromGroup', ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                try {
                    [System.Guid]::Parse($_) | Out-Null
                    $true
                }
                catch {
                    $false
                }
            })]
        $Template,
        [Parameter(ParameterSetName = 'CreateTeam', ValueFromPipelineByPropertyName = $true)]
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
        [System.Nullable[bool]]
        $AllowGiphy,
        [string]
        $GiphyContentRating,
        [System.Nullable[bool]]
        $AllowStickersAndMemes,
        [System.Nullable[bool]]
        $AllowCustomMemes,
        [System.Nullable[bool]]
        $AllowGuestCreateUpdateChannels,
        [System.Nullable[bool]]
        $AllowGuestDeleteChannels,
        [System.Nullable[bool]]
        $AllowCreateUpdateChannels,
        [System.Nullable[bool]]
        $AllowDeleteChannels,
        [System.Nullable[bool]]
        $AllowAddRemoveApps,
        [System.Nullable[bool]]
        $AllowCreateUpdateRemoveTabs,
        [System.Nullable[bool]]
        $AllowCreateUpdateRemoveConnectors,
        [System.Nullable[bool]]
        $AllowUserEditMessages,
        [System.Nullable[bool]]
        $AllowUserDeleteMessages,
        [System.Nullable[bool]]
        $AllowOwnerDeleteMessages,
        [System.Nullable[bool]]
        $AllowTeamMentions,
        [System.Nullable[bool]]
        $AllowChannelMentions,
        [System.Nullable[bool]]
        $ShowInTeamsSearchAndSuggestions,
        [Parameter(ParameterSetName = 'CreateTeamViaJson')]
        [string]
        $JsonRequest,
        [switch]
        $Status
    )
    begin {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $graphApiParameters = @{
                Method             = 'Post'
                AuthorizationToken = "Bearer $authorizationToken"
            }
            $requestBodyCreateTeamTemplateJSON = '{
                "template@odata.bind": "",
                "displayName": "",
                "mailNickname" : "",
                "mailEnabled": true,  
                "description": "",
                "visibility": "Public",
                "owners@odata.bind": [
                ],
                "memberSettings": {
                    "allowCreateUpdateChannels": true,
                    "allowDeleteChannels": true,
                    "allowAddRemoveApps": true,
                    "allowCreateUpdateRemoveTabs": true,
                    "allowCreateUpdateRemoveConnectors": true
                },
                "guestSettings": {
                    "allowCreateUpdateChannels": true,
                    "allowDeleteChannels": true
                },
                "funSettings": {
                    "allowGiphy": true,
                    "giphyContentRating": "Moderate",
                    "allowStickersAndMemes": true,
                    "allowCustomMemes": true
                },
                "messagingSettings": {
                    "allowUserEditMessages": true,
                    "allowUserDeleteMessages": true,
                    "allowOwnerDeleteMessages": true,
                    "allowTeamMentions": true,
                    "allowChannelMentions": true
                },
                "discoverySettings": {
                    "showInTeamsSearchAndSuggestions": true
                }
            }'
            $requestBodyCreateTeamFromGroupTemplateJSON = '{
                "group@odata.bind":"",
                "template@odata.bind": "",
                "memberSettings": {
                    "allowCreateUpdateChannels": true,
                    "allowDeleteChannels": true,
                    "allowAddRemoveApps": true,
                    "allowCreateUpdateRemoveTabs": true,
                    "allowCreateUpdateRemoveConnectors": true
                },
                "guestSettings": {
                    "allowCreateUpdateChannels": true,
                    "allowDeleteChannels": true
                },
                "funSettings": {
                    "allowGiphy": true,
                    "giphyContentRating": "Moderate",
                    "allowStickersAndMemes": true,
                    "allowCustomMemes": true
                },
                "messagingSettings": {
                    "allowUserEditMessages": true,
                    "allowUserDeleteMessages": true,
                    "allowOwnerDeleteMessages": true,
                    "allowTeamMentions": true,
                    "allowChannelMentions": true
                },
                "discoverySettings": {
                    "showInTeamsSearchAndSuggestions": true
                }
            }'
        } 
        catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
    }
	
    process {
        if (Test-PSFFunctionInterrupt) { return }
        try {
            $graphApiParameters['uri'] = $url
            Switch ($PSCmdlet.ParameterSetName) {
                'CreateTeamViaJson' {                               
                    $bodyParameters = $JsonRequest | ConvertFrom-Json | ConvertTo-PSFHashtable
                }
                'CreateTeamFromGroup' {
                    $bodyParameters = $requestBodyCreateTeamFromGroupTemplateJSON | ConvertFrom-Json -AsHashtable -Depth 4 #| ConvertTo-PSFHashtable
                    $bodyParameters['group@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups('$($GroupId)')"
                    if (Test-PSFParameterBinding -Parameter Template) {
                        $bodyParameters['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teamsTemplates('$($Template)')"
                    }
                    else {
                        $bodyParameters['template@odata.bind'] = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teamsTemplates('standard')"
                    }
                }
                'CreateTeam' {
                    $bodyParameters = $requestBodyCreateTeamTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                    $bodyParameters['displayName'] = $DisplayName
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
                }
                'Default' {
                    $bodyParameters = $requestBodyCreateTeamTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                }
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
                $bodyParameters['guestSettings']['allowCreateUpdateChannels'] = $AllowGuestCreateUpdateChannels
            }

            if (Test-PSFParameterBinding -Parameter allowDeleteChannels) {
                $bodyParameters['guestSettings']['allowDeleteChannels'] = $AllowGuestDeleteChannels
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

            if (Test-PSFParameterBinding -Parameter showInTeamsSearchAndSuggestions) {
                
                $bodyParameters['discoverySettings']['showInTeamsSearchAndSuggestions'] = $ShowInTeamsSearchAndSuggestions
            }
        
            [string]$requestJSONQuery = $bodyParameters | ConvertTo-Json -Depth 10 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
            $graphApiParameters['body'] = $requestJSONQuery
                
            If ($Status.IsPresent) {
                $graphApiParameters['Status'] = $true
            }               
            Invoke-GraphApiQuery @graphApiParameters
        } 
        catch {
            Stop-PSFFunction -String 'FailedNewTeam' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -SilentlyContinue -ErrorRecord $_ -Tag GraphApi, Post
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi, Post -Data $graphApiParameters
    }
    end {

    }
}