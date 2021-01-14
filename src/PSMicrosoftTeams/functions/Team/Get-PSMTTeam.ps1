function Get-PSMTTeam
{
	[CmdletBinding()]
	param(
	    [Parameter(ParameterSetName='Filters', ValueFromPipelineByPropertyName=$true)]
	    [Parameter(ParameterSetName='Identity')]
	    [System.Nullable[bool]]
	    ${Archived},
	
	    [Parameter(ParameterSetName='Filters', ValueFromPipelineByPropertyName=$true)]
	    [Parameter(ParameterSetName='Identity')]
	    [string]
	    ${DisplayName},
	
	    [Parameter(ParameterSetName='Identity', Mandatory=$true)]
	    [string]
	    ${TeamId},
	
	    [Parameter(ParameterSetName='Filters', ValueFromPipelineByPropertyName=$true)]
	    [Parameter(ParameterSetName='Identity')]
	    [string]
	    ${MailNickName},
	
	    [Parameter(ParameterSetName='Filters', ValueFromPipelineByPropertyName=$true)]
	    [Parameter(ParameterSetName='Identity')]
	    [string]
	    ${Visibility})
	
	begin
	{
	    try {
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
	    } catch {
	        Stop-PSFFunction -Message "Failed to receive uri $url." -ErrorRecord $_
        }
	}
	
	process
	{
		if (Test-PSFFunctionInterrupt) { return }
        try {
            if(Test-PSFParameterBinding -Parameter TeamId)
            {
				$format = "?`$format=json"
				$url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams/$($TeamId)$format" 
			}
			if(Test-PSFParameterBinding -Parameter MailNickName)
            {
				$filter = "`$filter=startswith(mail,'{0}')" -f [System.Net.WebUtility]::UrlEncode($MailNickName)
				$format = "?`$format=json"
				$queryString = (($format, $filter)) -join '&' 
				$url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups$queryString" 
				Write-Verbose $url
			}
			if(Test-PSFPowerShell -Edition Core){
				$getUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"}  -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
			}
			else {
				$getUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"}  -Method Get #-MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
			}
            return $getUserTeamResult 
        }
        catch {
			Stop-PSFFunction -Message "Failed to get data from $url." -ErrorRecord $_
        }
	}

	end
	{
    }
	
}