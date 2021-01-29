function Remove-PSMTTeamU
{
<#
    .SYNOPSIS
        Removed Team (Office 365 unified group).
              
    .DESCRIPTION
        This cmdlet removes tam (Office 365 unified group).
              
    .PARAMETER TeamId
        Id of Team (unified group)

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
        
        [switch]
        $Status
    )

	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
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
            $urlGroup = Join-UriPath -Uri $url -ChildPath "('$UserId')"
            if(Test-PSFPowerShell -Edition Core){
                $removeTeamResult = Invoke-RestMethod -Uri $urlGroup -Headers @{Authorization = "Bearer $authorizationToken"} -Method Delete -ContentType $CONTENT_TYPE  -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            else {
                $removeTeamResult = Invoke-RestMethod -Uri $urlGroup -Headers @{Authorization = "Bearer $authorizationToken"} -Method Delete -ContentType $CONTENT_TYPE  #-MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            if((Test-PSFParameterBinding -ParameterName $Status) -and (Test-PSFPowerShell -PSMinVersion 6.1)){
                return $removeTeamResult                
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