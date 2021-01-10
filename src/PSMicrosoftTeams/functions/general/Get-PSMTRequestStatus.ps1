function Get-PSMTRequestStatus
{
    [CmdletBinding(DefaultParametersetName="Token")]    
    param(
        [Parameter(ParameterSetName="Header", Mandatory=$false, Position=0)]
        [psobject]$RespopnseData)
    
    begin {
        try{
            $childPathdUrl = $responseData.Headers.Location
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath $childPathdUrl
            $responseStatus = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"} -Method Get -ContentType "application/json"  -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            return $responseStatus
        }
        catch{
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}