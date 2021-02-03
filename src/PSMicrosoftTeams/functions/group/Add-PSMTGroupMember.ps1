function Add-PSMTGroupMember
{
<#
    .SYNOPSIS
    Adds an owner or member to the team, and to the unified group which backs the team.
              
    .DESCRIPTION
        This cmdlet adds an owner or member to the team, and to the unified group which backs the team.
              
    .PARAMETER Groupd
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
                
            }
            #$property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
        } 
        catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }  
    }
    
    process
	{
        if (Test-PSFFunctionInterrupt) { return }
        try {   
            $urlMembers = Join-UriPath -Uri $url -ChildPath "$($GroupId)/members"
            $graphApiParameters['Uri'] = Join-UriPath -Uri $urlMembers -ChildPath '$ref'
            $bodyParameters=@{
                "@odata.id"= Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "directoryObjects('$($UserId)')"
            }
                        
            if(Test-PSFParameterBinding -Parameter Role)
            {
                $urlOwners = Join-UriPath -Uri $url -ChildPath "$($GroupId)/owners"
                $graphApiParameters['Uri'] = Join-UriPath -Uri $urlOwners -ChildPath '$ref'
                $bodyParameters=@{
                    "@odata.id"= Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users/$($UserId)"
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