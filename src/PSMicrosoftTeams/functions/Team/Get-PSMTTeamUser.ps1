function Get-PSMTTeamUser
{
<#
    .SYNOPSIS
    Get an owner or member to the team, and to the unified group which backs the team.
              
    .DESCRIPTION
        This cmdlet get an owner or member of the team, and to the unified group which backs the team.
              
    .PARAMETER TeamId
        Id of Team (unified group)

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
	
	    [Parameter(ValueFromPipelineByPropertyName=$true)]
	    [ValidateSet('Member','Owner')]
	    [string]
        ${Role}
    )
	
	begin
	{
	    try {
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
	    } catch {
	        Stop-PSFFunction -Message "Failed to receive uri $url" -ErrorRecord $_
        }
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams/$($TeamId)/members"
            if(Test-PSFPowerShell -Edition Core){    
                $getUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"}  -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            else {
                $getUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"}  -Method Get #-MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            if((Test-PSFParameterBinding -ParameterName Role) -or $Role -eq 'member')
            {
                return $getUserTeamResult #| Where-Object
            }
            else {
                return $getUserTeamResult #| Where-Object
            }
        }
        catch {
            Stop-PSFFunction -Message "Failed to get data from $urlUser." -ErrorRecord $_
        }
    }
	
	end
	{
	
	}
	
	
}