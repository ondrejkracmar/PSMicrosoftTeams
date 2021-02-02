Function Invoke-GraphApiQueryBatch{
<#
    
#>
    [CmdletBinding(DefaultParametersetname="Default")]
    Param(
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [HashTable[]]$RequestList,
        [Parameter(Mandatory=$true,ParameterSetName='Default')]
        [string]$AuthorizationToken,
        [string]$Accept = 'application/json',
        [string]$ContentType = 'application/json',
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [ValidateRange(2, 10)]
        [int]$Count
    )

    begin{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $urlBatch = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath '$batch'
        $numberOFRetries = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
        $retryTimeSec = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
        $authHeader = @{
            'Accept'= $Accept
            'Content-Type'= $ContentType
            'Authorization'= $AuthorizationToken
        }
        $queryParameters=@{
            Uri = $urlBatch
            Method = 'Post'
            Headers = $authHeader
            ContentType = $ContentType
        }
        $bacthRequests = @{ requests = @() }
        [int]$batchIterator = 0
        if(Test-PSFPowerShell -PSMinVersion '7.0.0'){
            $queryParameters['MaximumRetryCount'] = $numberOFRetries
            $queryParameters['RetryIntervalSec'] = $retryTimeSec
            $queryParameters['ErrorVariable'] = 'responseError'
            $queryParameters['ErrorAction'] = 'Stop'
            $queryParameters['ResponseHeadersVariable'] = 'responseHeaders'
        }
    }
    process
    {
        if (Test-PSFFunctionInterrupt) { return }

        Try{ 
            foreach($requestItem in $RequestList)
            {
                $batchIterator++
                If($Request['Body']) {
                    $bacthRequests.requests+= @{
                        id = $batchIterator
                        url = ($Request['uri']).Replace((Get-GraphApiUriPath),'')
                        method = $Request['Method']
                        body = $Request['Body']
                        headers = @{ "content-type" = "application/json" }
                    }
                }
                else {
                    $bacthRequests.requests+= @{
                        id = $batchIterator
                        url = ($Request['uri']).Replace((Get-GraphApiUriPath),'')
                        method = ($Request['Method'])
                        headers = @{ "content-type" = "application/json" }
                    }
                }   
                if ($bacthRequests.requests.Count -eq $Count) {
                    $queryParameters['Body'] = ConvertTo-Json $bacthRequests -Depth 4
                    $queryParameters
                    $bacthRequests.requests = @()
                    $response = Invoke-RestMethod @queryParameters 
                    $response
                }
            }
        }
        Catch{
            Stop-PSFFunction -String 'FailedInvokeRest' -Target $queryUri -StringValues $Method, $queryUri -ErrorRecord $_ -Continue -EnableException $True
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $queryUri -Target $queryUri -Tag GraphApi -Data $queryParameters
    }
    end{}
}


