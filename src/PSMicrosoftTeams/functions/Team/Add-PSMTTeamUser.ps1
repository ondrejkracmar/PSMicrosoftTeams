function Add-PSMTTeamUser
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
	[CmdletBinding()]
	param(
	    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
	    [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    [string]
	    ${TeamId},
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
	    [string]
	    ${UserId},
	    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Member','Owner')]
	    [string]
        ${Role},
        [switch]
        $Status
    )
    
	begin
	{
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            authorizationToken = Receive-PSMTAuthorizationToken
            #$property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
        } 
        catch {
            Stop-PSFFunction -String 'FailedGetUsers' -StringValues $graphApiParameters['Uri'] -ErrorRecord $_
        }
        
    }
    
    process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "$($TeamId)/members"
            $urlUser = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users('$($UserId)')"
            $graphApiParameters=@{
                Method = 'Post'
				AuthorizationToken = "Bearer $authorizationToken"
				Uri = $url
            }
            $bodyParameters-@{
                '@odata.type' = "#microsoft.graph.aadUserConversationMember"
                roles = @() 
                'user@odata.bind' = $urlUser
            }
            
            if(Test-PSFParameterBinding -Parameter Role)
            {
                if($riole -eq 'Owner'){
                    $bodyParameters['roles'] = @($Role)
                }
            }
            [string]$requestJSONQuery = $bodyParameters | ConvertTo-Json -Depth 10 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_)}
            $graphApiParameters['body'] = $requestJSONQuery
            $addTeamMemberesult = Invoke-GraphApiQuery @graphApiParameters
            If(-not ($Status.IsPresent -or ($responseHeaders)))
            {
                $addTeamMemberesult
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