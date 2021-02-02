function Add-PSMTTeamMember
{
<#
    .SYNOPSIS
    Adds an owner or member to the team, and to the unified group which backs the team.
              
    .DESCRIPTION
        This cmdlet adds an owner or member to the team, and to the unified group which backs the team.
              
    .PARAMETER TeamId
        Id of Team (unified group)

    .PARAMETER UserId
        Id of User

    .PARAMETER Status
        Switch response header or result

#>
	[CmdletBinding(DefaultParameterSetName='AddSingleMember')]
	param(
        [Parameter(ParameterSetName='AddSingleMember',Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='AddBulkMebers',Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
	    [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    [string]
        $TeamId,
        [Parameter(ParameterSetName='AddSingleMember',Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
        [Alias("Id")]
	    [string]
	    $UserId,
	    [Parameter(ParameterSetName='AddSingleMember', ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Member','Owner')]
	    [string]
        $Role,
        [Parameter(ParameterSetName='AddBulkMebers',Mandatory=$true)]
        [hashtable[]]$Members,
        [switch]
        $Status
    )
    
	begin
	{
       try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $graphApiParameters=@{
                Method = 'Post'
				AuthorizationToken = "Bearer $authorizationToken"
            }
            #$property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
        } 
        catch {
            Stop-PSFFunction -String 'FailedAddMember' -StringValues $graphApiParameters['Uri'] -ErrorRecord $_
        }  
    }
    
    process
	{
        if (Test-PSFFunctionInterrupt) { return }
        try {   
            Switch ($PSCmdlet.ParameterSetName)
            {
                'AddSingleMember'
                {
                    $graphApiParameters['uri'] = Join-UriPath -Uri $url -ChildPath "$($TeamId)/members"
                    $urlUser = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users('$($UserId)')"                            
                    $bodyParameters=@{
                        '@odata.type' = "#microsoft.graph.aadUserConversationMember"
                        roles = @() 
                        'user@odata.bind' = $urlUser
                    }
                        
                    if(Test-PSFParameterBinding -Parameter Role)
                    {
                        if($Role -eq 'Owner'){
                                $bodyParameters['roles'] = @($Role)
                        }
                    }

                }
                'AddBulkMebers'
                {
                    $graphApiParameters['uri'] =  = Join-UriPath -Uri $url -ChildPath "$($TeamId)/members/add"   
                    $urlUser = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users('$($UserId)')"
                    [array]$bodyParameters=@{values = @()}
                    foreach($memberItem in  $Members)
                    {                            
                        $value=@{
                            '@odata.type' = "#microsoft.graph.aadUserConversationMember"
                            roles = @() 
                            'user@odata.bind' = $memberItem['UserId']
                        }
                        if(Test-PSFParameterBinding -Parameter Role)
                        {
                            if($memberItem['Role'] -eq 'Owner'){
                                $value['roles'] = $memberItem['Role']
                            }
                        }
                        $bodyParameters.values+=$value
                    }
                }
            }
            [string]$requestJSONQuery = $bodyParameters | ConvertTo-Json -Depth 10 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_)}
            $graphApiParameters['body'] = $requestJSONQuery
            $addTeamMembeResult = Invoke-GraphApiQuery @graphApiParameters
            If(-not ($Status.IsPresent -or ($responseHeaders))){
                $addTeamMembeResult
            }
            else {
                $responseHeaders
            }
        }
        catch {
            Stop-PSFFunction -String 'FailedAddMember' -StringValues $UserId,$TeamId -Target $graphApiParameters['Uri'] -Continue -ErrorRecord $_ -Tag GraphApi,Get
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Get -Data $graphApiParameters
	}
	
	end
	{
	
	}
}