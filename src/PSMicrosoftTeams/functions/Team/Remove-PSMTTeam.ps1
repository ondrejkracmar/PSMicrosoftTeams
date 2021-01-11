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
            $urlGroup = Join-UriPath -Uri $url -ChildPath "('$UserId')"
            $removeTeamResult = Invoke-RestMethod -Uri $urlGroup -Headers @{Authorization = "Bearer $authorizationToken"} -Method Delete -ContentType $CONTENT_TYPE  -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            
            if(Test-PSFParameterBinding -ParameterName $Status){
                return $removeTeamResult                
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