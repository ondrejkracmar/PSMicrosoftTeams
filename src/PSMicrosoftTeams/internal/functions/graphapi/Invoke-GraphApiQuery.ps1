Function Invoke-GraphApiQuery{
<#

#>
    [CmdletBinding(DefaultParametersetname="Default")]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Default')]
        [string]$Uri,
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [string]$Body,
        [Parameter(Mandatory=$true,ParameterSetName='Default')]
        [string]$AuthorizationToken,
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
        [string]$Method = "GET",
        [string]$Accept = 'application/json',
        [string]$ContentType = 'application/json',
        [ValidateRange(5, 100)]
        [int]$Top,
        [ValidateRange(1, [int]::MaxValue)]
        #[ValidateRange("Positive")]
        [int]$Skip,
        [switch]$Count,
        [stringh]$Filer,
        [stringh]$Select,
        [stringh]$Expand,
        [switch]$All,
        [Switch]$Raw
    )
    begin{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $authHeader = @{
            'Accept'= $Accept
            'Content-Type'= $ContentType
            'Authorization'= $AuthorizationToken
        }
    }

    process
    {
        Try{ 
            if (if Test-PSFParameterBinding -Parameter Filter) {
                $queryFlter = "`$filter={0}" -f [System.Net.WebUtility]::UrlEncode($Filter)
            }

            if (if Test-PSFParameterBinding -Parameter Select) {
                $querySelect = "`$select={0}" -f [System.Net.WebUtility]::UrlEncode($Select)
            }

            if (if Test-PSFParameterBinding -Parameter Expand) {
                $queryExpand = "`$expand={0}" -f [System.Net.WebUtility]::UrlEncode($Expand)
            }
            if (if Test-PSFParameterBinding -Parameter Format) {
                $queryFormat = "`$format={0}" -f [System.Net.WebUtility]::UrlEncode($Format)
            }           
            
            $queryString = (($queryFlter -ne $null, $querySelect -ne $null, $queryExpand, $queryExpand-ne $null, $queryFormat -ne $null) -join "&")
            
            if([string]::IsNullOrWhitespace($queryString)){
                $queryUri = $Uri
            }
            else {
                $queryUristring = "{0}?{1}"
                $queryUri =  $queryUristring -f $Uri,$queryString                
            }

            $queryParameters=@{
                Uri = $queryUri
                Method = $Method
                Headres = $authHeader
                ContentType = $CONTENT_TYPE
            }

            if(Test-PSFPowerShell -PSMinVersion 7){
                $queryParameters['MaximumRetryCount'] = $NUMBER_OF_RETRIES
                $queryParameters['RetryIntervalSec'] = $RETRY_TIME_SEC
                $queryParameters['ErrorVariable'] = 'responseError'
                $queryParameters['ErrorAction'] = 'Stop'
                $queryParameters['ResponseHeadersVariable'] = 'responseHeaders'
            }

            If(Test-PSFParameterBinding -Parameter Body){
            {
                $queryParameters['Body'] = $Body
            }
            
            $response = Invoke-RestMethod @queryParameter     
            
            if(Test-PSFParameterBinding -Parameter Raw){
                return $response.Value | Select-Object -Property * -ExcludeProperty "@odata.type"
            }
            else{
                return $response
            }
            If(-not (Test-PSFParameterBinding -Parameter All) -and $response.'@odata.nextLink'){
                Write-Warning "Query contains more data, use recursive to get all!"
                Start-Sleep 1
            }
            if(Test-PSFParameterBinding -Parameter All){
                while($null -ne $response.'@odata.nextLink')
                {
                    $queryParameters['ErrorAction'] = 'SilentlyContinue'
                    $response = Invoke-RestMethod @queryParameter
                    if(Test-PSFParameterBinding -Parameter Raw){
                        return $response.Value | Select-Object -Property * -ExcludeProperty "@odata.type"
                    }
                    else{
                        return $response
                    }
                }
            }
        }
        Catch{
            If(($Error[0].ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue).error.Message -eq 'Access token has expired.'){
                Stop-PSFFunction -Message "Access token has expired." -ErrorRecord $_
            }
            Else{
                Stop-PSFFunction -Message "Failed to invoke rest method from $url." -ErrorRecord $_
            }
        }
        Return $returnvalue
    }
}