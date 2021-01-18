function New-PSMTTeam
{
	[CmdletBinding(DefaultParameterSetName='CreateTeam')]
	param(
	    [Parameter(ParameterSetName='CreateTeam', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
	    [ValidateNotNullOrEmpty()]
	    [string]
	    ${DisplayName},
	
	    [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [string]
	    ${Description},
	
	    [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [string]
        ${MailNickName},
        
        [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [System.Nullable[bool]]
	    ${MailEnabled},
	
	    [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [string]
	    ${Classification},
	
	    [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Public','Private','HiddenMembership')]
	    [string]
	    ${Visibility},
	
	    [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    ${Template},
        
        [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    [string]
	    ${Owner},
    
	    [System.Nullable[bool]]
	    ${AllowGiphy},
        
        [string]
	    ${GiphyContentRating},
        
        [System.Nullable[bool]]
	    ${AllowStickersAndMemes},
    
        [System.Nullable[bool]]
	    ${AllowCustomMemes},
        
        [System.Nullable[bool]]
	    ${AllowGuestCreateUpdateChannels},
    
        [System.Nullable[bool]]
	    ${AllowGuestDeleteChannels},
    
        [System.Nullable[bool]]
	    ${AllowCreateUpdateChannels},
    
        [System.Nullable[bool]]
	    ${AllowDeleteChannels},
    
        [System.Nullable[bool]]
	    ${AllowAddRemoveApps},
        
        [System.Nullable[bool]]
	    ${AllowCreateUpdateRemoveTabs},
    
        [System.Nullable[bool]]
	    ${AllowCreateUpdateRemoveConnectors},
    
        [System.Nullable[bool]]
	    ${AllowUserEditMessages},
    
        [System.Nullable[bool]]
	    ${AllowUserDeleteMessages},
    
        [System.Nullable[bool]]
	    ${AllowOwnerDeleteMessages},
    
        [System.Nullable[bool]]
	    ${AllowTeamMentions},
    
        [System.Nullable[bool]]
	    ${AllowChannelMentions},
    
        [System.Nullable[bool]]
	    ${ShowInTeamsSearchAndSuggestions},
	
	    [Parameter(ParameterSetName='CreateTeam', ValueFromPipelineByPropertyName=$true)]
	    [switch]
        ${RetainCreatedGroup},
        
        [Parameter(ParameterSetName='CreateTeamViaJson')]
	    [string]
        $JsonRequest,

        [switch]
        $Status
    )
	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
            $CONTENT_TYPE = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.PostConrtentType)
	    } catch {
	        Stop-PSFFunction -Message "Failed to receive uri $url" -ErrorRecord $_
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
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {

            Switch ($PSCmdlet.ParameterSetName)
            {
                'CreateTeamViaJson' {                               
                    $requestHashTableQuery = $JsonRequest | ConvertFrom-Json | ConvertTo-PSFHashtable
                }
                'CreateTeam' 
                {
                    $requestHashTableQuery = $requestBodyCreateTeamTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                    
                    if(Test-PSFParameterBinding -Parameter Description)
                    {
                        $requestHashTableQuery['description'] = $Description
                    }

                    if(Test-PSFParameterBinding -Parameter MailNickName)
                    {
                        $requestHashTableQuery['mailNickName'] = $MailNickName
                    }

                    if(Test-PSFParameterBinding -Parameter MailEnabled)
                    {
                        $requestHashTableQuery['mailEnabled'] = $MailEnabled
                    }

                    if(Test-PSFParameterBinding -Parameter Visibility)
                    {
                        $requestHashTableQuery['visibility'] = $Visibility
                    }

                    if(Test-PSFParameterBinding -Parameter Template)
                    {
                        #"https://graph.microsoft.com/v1.0/teamsTemplates(''$($Template)'')"
                        $urlTemoplatge = Join-UriPath -Uri $url -ChildPath -JoimPath "teamsTemplates('$($Template)')"
                        $requestHashTableQuery['template'] = $urlTemoplatge
                    }
                    else {
                        $urlTemoplatge = Join-UriPath -Uri $url -ChildPath -JoimPath "teamsTemplates('standard')"
                        $requestHashTableQuery['template'] = $urlTemoplatge
                    }

                    if(Test-PSFParameterBinding -Parameter Owner)
                    {                     
                        $urlOwner = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath (-join 'users','/',$owner)                    
                        $requestHashTableQuery['owners@odata.bind'] = @($urlOwner)
                    }
                }
                'Default'
                {
                    $requestHashTableQuery = $requestBodyCreateTeamTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                }
            }
            
            if(Test-PSFParameterBinding -Parameter allowCreateUpdateChannels)
            {
                $requestHashTableQuery['memberSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
            }

            if(Test-PSFParameterBinding -Parameter allowCreateUpdateChannels)
            {
                $requestHashTableQuery['memberSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
            }

            if(Test-PSFParameterBinding -Parameter allowDeleteChannels)
            {
                $requestHashTableQuery['memberSettings']['allowDeleteChannels'] = $AllowDeleteChannels
            }

            if(Test-PSFParameterBinding -Parameter allowAddRemoveApps)
            {
                $requestHashTableQuery['memberSettings']['allowAddRemoveApps'] = $AllowAddRemoveApps
            }

            if(Test-PSFParameterBinding -Parameter allowAddRemoveApps)
            {
                $requestHashTableQuery['memberSettings']['allowCreateUpdateRemoveTabs'] = $AllowCreateUpdateRemoveTabs
            }

            if(Test-PSFParameterBinding -Parameter allowCreateUpdateRemoveConnectors)
            {
                $requestHashTableQuery['memberSettings']['allowCreateUpdateRemoveConnectors'] = $AllowCreateUpdateRemoveConnectors
            }

            if(Test-PSFParameterBinding -Parameter allowCreateUpdateChannels)
            {
                $requestHashTableQuery['guestSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
            }

            if(Test-PSFParameterBinding -Parameter allowCreateUpdateChannels)
            {
                $requestHashTableQuery['guestSettings']['allowCreateUpdateChannels'] = $AllowCreateUpdateChannels
            }

            if(Test-PSFParameterBinding -Parameter allowDeleteChannels)
            {
                $requestHashTableQuery['guestSettings']['allowDeleteChannels'] = $AllowDeleteChannels
            }
            
            if(Test-PSFParameterBinding -Parameter allowGiphy)
            {
                $requestHashTableQuery['funSettings']['allowGiphy'] = $AllowGiphy
            }

            if(Test-PSFParameterBinding -Parameter giphyContentRating)
            {
                $requestHashTableQuery['funSettings']['giphyContentRating'] = $GiphyContentRating
            }

            if(Test-PSFParameterBinding -Parameter allowStickersAndMemes)
            {
                $requestHashTableQuery['funSettings']['allowStickersAndMemes'] = $AllowStickersAndMemes
            }

            if(Test-PSFParameterBinding -Parameter allowCustomMemes)
            {
                $requestHashTableQuery['funSettings']['allowCustomMemes'] = $AllowCustomMemes
            }
            
            if(Test-PSFParameterBinding -Parameter allowUserEditMessages)
            {
                $requestHashTableQuery['messagingSettings']['allowUserEditMessages'] = $allowUserEditMessages
            }
            
            if(Test-PSFParameterBinding -Parameter allowUserDeleteMessages)
            {
                $requestHashTableQuery['messagingSettings']['allowUserDeleteMessages'] = $AllowUserDeleteMessages
            }

            if(Test-PSFParameterBinding -Parameter allowOwnerDeleteMessages)
            {
                $requestHashTableQuery['messagingSettings']['allowOwnerDeleteMessages'] = $AllowOwnerDeleteMessages
            }

            if(Test-PSFParameterBinding -Parameter allowTeamMentions)
            {
                $requestHashTableQuery['messagingSettings']['allowTeamMentions'] = $AllowTeamMentions
            }

            if(Test-PSFParameterBinding -Parameter allowChannelMentions)
            {
                $requestHashTableQuery['messagingSettings']['allowChannelMentions'] = $AllowChannelMentions
            }

             if(Test-PSFParameterBinding -Parameter showInTeamsSearchAndSuggestions)
            {
                $requestHashTableQuery['discoverySettings']['showInTeamsSearchAndSuggestions'] = $ShowInTeamsSearchAndSuggestions
            }   

            [string]$requestJSONQuery = $requestHashTableQuery | ConvertTo-Json -Depth 10 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_)}
            
                $newTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"} -Body ]$requestJSONQuery -Method Post -ContentType $CONTENT_TYPE -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            
            else {
                $newTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"} -Body ]$requestJSONQuery -Method Post -ContentType $CONTENT_TYPE #-MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            if((Test-PSFParameterBinding -ParameterName $Status) -and (Test-PSFPowerShell -PSMinVersion 6.1)){
                return $newTeamResult                
            }
            else {
                return $responseHeaders
            }
        } catch {
	        Stop-PSFFunction -Message "Failed to post data from $url." -ErrorRecord $_
	    }
	}
	
	end
	{

	}
	
}