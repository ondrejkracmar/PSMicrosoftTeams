Function Invoke-GraphApiQuery{
    <#

    #>
    [CmdletBinding(DefaultParametersetname="Default")]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Default')]
        [Parameter(Mandatory=$true,ParameterSetName='Refresh')]
        [string]$URI,
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [Parameter(Mandatory=$false,ParameterSetName='Refresh')]
        [string]$Body,
        [Parameter(Mandatory=$true,ParameterSetName='Default')]
        [Parameter(Mandatory=$true,ParameterSetName='Refresh')]
        [string]$token,
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [Parameter(Mandatory=$false,ParameterSetName='Refresh')]
        [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
        [string]$method = "GET",
        [Parameter(Mandatory=$false,ParameterSetName='Default')]
        [Parameter(Mandatory=$false,ParameterSetName='Refresh')]
        [switch]$recursive
    )
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $authHeader = @{
            'Accept'= 'application/json'
            'Content-Type'= 'application/json'
            'Authorization'= $Token
        }
        [array]$returnvalue = $()
        Try{
            If($body){
                $Response = Invoke-RestMethod -Uri $URI –Headers $authHeader -Body $Body –Method $method -ErrorAction Stop
            }
            Else{
                $Response = Invoke-RestMethod -Uri $URI –Headers $authHeader –Method $method -ErrorAction Stop
            }
        }
        Catch{
            If(($Error[0].ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue).error.Message -eq 'Access token has expired.' -and $tokenrefresh){
                $token =  Get-MSGraphAuthToken -credential $credential -tenantID $TenantID
                $authHeader = @{
                    'Content-Type'='application\json'
                    'Authorization'=$Token
                }
                $returnvalue = $()
                If($body){
                    $Response = Invoke-RestMethod -Uri $URI –Headers $authHeader -Body $Body –Method $method -ErrorAction Stop
                }
                Else{
                    $Response = Invoke-RestMethod -Uri $uri –Headers $authHeader –Method $method
                }
            }
            Else{
                Throw $_
            }
        }
        $returnvalue += $Response
        If(-not $recursive -and $Response.'@odata.nextLink'){
            Write-Warning "Query contains more data, use recursive to get all!"
            Start-Sleep 1
        }
        ElseIf($recursive){
            If($PSCmdlet.ParameterSetName -eq 'default'){
                If($body){
                    $returnvalue += Invoke-MSGraphQuery -URI $Response.'@odata.nextLink' -token $token -body $body -method $method -recursive -ErrorAction SilentlyContinue
                }
                Else{
                    $returnvalue += Invoke-MSGraphQuery -URI $Response.'@odata.nextLink' -token $token -method $method -recursive -ErrorAction SilentlyContinue
                }
            }
            Else{
                If($body){
                    $returnvalue += Invoke-MSGraphQuery -URI $Response.'@odata.nextLink' -token $token -body $body -method $method -recursive -tokenrefresh -credential $credential -tenantID $TenantID -ErrorAction SilentlyContinue
                }
                Else{
                    $returnvalue += Invoke-MSGraphQuery -URI $Response.'@odata.nextLink' -token $token -method $method -recursive -tokenrefresh -credential $credential -tenantID $TenantID -ErrorAction SilentlyContinue
                }
            }
        }
        Return $returnvalue
    }