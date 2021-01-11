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
	    [ValidateRange(1, 20)]
	    [string]
	    ${NumberOfThreads},
	
	    [Parameter(ParameterSetName='Filters', ValueFromPipelineByPropertyName=$true)]
	    [Parameter(ParameterSetName='Identity')]
	    [string]
	    ${User},
	
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
            if(Test-PSFParameterBinding -Parameter MailNickName)
            {
                $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams/$($TeamId)"   
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