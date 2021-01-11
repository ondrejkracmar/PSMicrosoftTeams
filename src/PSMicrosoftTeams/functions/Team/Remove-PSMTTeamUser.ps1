function Remove-PSMTTeamUser
{
<#
    .SYNOPSIS
        Remove an owner or member from the team, and to the unified group which backs the team.
              
    .DESCRIPTION
        This cmdlet removes an owner or member from the team, and to the unified group which backs the team.
              
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
	
	    [Parameter(ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Member','Owner')]
	    [string]
        ${Role},
        
        [switch]
        $Status
    )

	begin
	{
	    try {
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
            $CONTENT_TYPE = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.PostConrtentType)
	    } catch {
	        $PSCmdlet.ThrowTerminatingError($PSItem)
        }
	}
	
	process
	{
	    try {
            if(Test-PSFParameterBinding -Parameter Role -Not)
            {
                $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "group/$($TeamId)/members/$UserId/`$ref"
            }
            else {
                $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "group/$($TeamId)/owners/$UserId/`$ref"
            }
                
             $addUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"} -Method Delete -ContentType $CONTENT_TYPE  -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            
            if(Test-PSFParameterBinding -ParameterName $Status){
                return $addUserTeamResult                
            }
            else {
                    return $responseHeaders
                }
        }
        catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
        }
	}
	
	end
	{
	
	}
}