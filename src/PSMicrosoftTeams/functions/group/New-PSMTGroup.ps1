﻿function New-PSMTGroup
{
	[CmdletBinding(DefaultParameterSetName='CreateTeam')]
	param(
	    [Parameter(ParameterSetName='CreateGroup', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
	    [ValidateNotNullOrEmpty()]
	    [string]
	    $DisplayName,
	    [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [string]
	    $Description,
	    [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [string]
        $MailNickName,
        [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [System.Nullable[bool]]
        $MailEnabled,
        [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [System.Nullable[bool]]
        $IsAssignableToRole,
        [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [System.Nullable[bool]]
	    $SecurityEnabled=$true,
	    [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [string]
	    $Classification,
	    [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Unified','Dynamic')]
	    [string[]]
	    $GroupTypes,
	    [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Public','Private','HiddenMembership')]
	    [string]
	    $Visibility,
        [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    [string[]]
        $Owners,
        [Parameter(ParameterSetName='CreateGroup', ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    [string[]]
        $Members,
        [Parameter(ParameterSetName='CreateGroupViaJson')]
	    [string]
        $JsonRequest,
        [switch]
        $Status
    )
	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $graphApiParameters=@{
                Method = 'Post'
                AuthorizationToken = "Bearer $authorizationToken"
                Uri = $url
            }
            #$property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
		} 
		catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
        $requestBodyCreateGroupTemplateJSON = '{
            "displayName": "",
            "mailNickname" : "",
            "mailEnabled": true,
            "securityEnabled": true,
            "description": "",
            "visibility": "Public",
            "groupTypes" : []
        }'
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {
            Switch ($PSCmdlet.ParameterSetName)
            {
                'CreateGroupViaJson' {                               
                    $bodyParameters = $JsonRequest | ConvertFrom-Json | ConvertTo-PSFHashtable
                }
                'CreateGroup' 
                {
                    $bodyParameters = $requestBodyCreateGroupTemplateJSON| ConvertFrom-Json | ConvertTo-PSFHashtable
                    $bodyParameters['displayName'] = $DisplayName
                    if(Test-PSFParameterBinding -Parameter Description)
                    {
                        $bodyParameters['description'] = $Description
                    }

                    if(Test-PSFParameterBinding -Parameter MailNickName)
                    {
                        $bodyParameters['mailNickName'] = $MailNickName
                    }

                    if(Test-PSFParameterBinding -Parameter MailEnabled)
                    {
                        $bodyParameters['mailEnabled'] = $MailEnabled
                    }

                    if(Test-PSFParameterBinding -Parameter Visibility)
                    {
                        $bodyParameters['visibility'] = $Visibility
                    }
                    
                    if(Test-PSFParameterBinding -Parameter SecurityEnabled)
                    {
                        $bodyParameters['securityEnabled'] = $SecurityEnabled
                    }

                    if(Test-PSFParameterBinding -Parameter IsAssignableToRole)
                    {
                        $bodyParameters['isAssignableToRole'] = $IsAssignableToRole
                    }

                    if(Test-PSFParameterBinding -Parameter GroupTypes)
                    {
                        $bodyParameters['groupTypes'] = @($GroupTypes)
                    }

                    if(Test-PSFParameterBinding -Parameter Owners)
                    { 
                        $userIdUriPathList = [System.Collections.ArrayList]::new()
                        foreach ($owner in $Owners) {
                            $userUriPath = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath 'users'
                            $userIdUriPath = Join-UriPath -Uri $userUriPath -ChildPath $owner
                            [void]($userIdUriPathList.Add($userIdUriPath))
                        }                        
                        $bodyParameters['owners@odata.bind'] = [array]$userIdUriPathList 
                    }

                    if(Test-PSFParameterBinding -Parameter Members)
                    {   
                        $userIdUriPathList = [System.Collections.ArrayList]::new()
                        foreach ($member in $Members) {
                            $userUriPath = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath 'users'
                            $userIdUriPath = Join-UriPath -Uri $userUriPath -ChildPath $member
                            [void]($userIdUriPathList.Add($userIdUriPath))
                        }                                   
                        $bodyParameters['owners@odata.bind'] = [array]$userIdUriPathList
                    }
                }
                'Default'
                {
                    $bodyParameters = $requestBodyCreateGroupTemplateJSON | ConvertFrom-Json | ConvertTo-PSFHashtable
                }
            }
    
            [string]$requestJSONQuery = $bodyParameters | ConvertTo-Json -Depth 10 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_)}
            $graphApiParameters['body'] = $requestJSONQuery
            
            If($Status.IsPresent){
                $graphApiParameters['Status'] = $true
            }
            Invoke-GraphApiQuery @graphApiParameters
        } 
        catch {
            Stop-PSFFunction -String 'FailedNewGroup' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Continue -ena -ErrorRecord $_ -Tag GraphApi,Post
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Get -Data $graphApiParameters
	}
	end
	{

	}
}