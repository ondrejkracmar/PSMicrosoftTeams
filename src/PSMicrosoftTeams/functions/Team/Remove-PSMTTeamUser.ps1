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
        [Alias("Id")]
	    [string]
	    $TeamId,
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
	    $UserId,
	    [Parameter(ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Member','Owner')]
	    [string]
        $Role,
        [switch]
        $Status
    )

	begin
	{
	    try {
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
            $CONTENT_TYPE = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.PostConrtentType)
	    } catch {
	        Stop-PSFFunction -Message "Failed to receive uri $url" -ErrorRecord $_
        }
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
        try {
            if(Test-PSFParameterBinding -Parameter Role -Not)
            {
                $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "group/$($TeamId)/members/$UserId/`$ref"
            }
            else {
                $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "group/$($TeamId)/owners/$UserId/`$ref"
            }
            if(Test-PSFPowerShell -Edition Core){    
                $addUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"} -Method Delete -ContentType $CONTENT_TYPE  -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            else {
                $addUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"} -Method Delete -ContentType $CONTENT_TYPE  #-MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
             if((Test-PSFParameterBinding -ParameterName $Status) -and (Test-PSFPowerShell -PSMinVersion 6.1)){
                return $addUserTeamResult                
            }
            else {
                    return $responseHeaders
                }
        }
        catch {
            Stop-PSFFunction -Message "Failed to delete data from $url." -ErrorRecord $_
        }
	}
	
	end
	{
	
	}
}