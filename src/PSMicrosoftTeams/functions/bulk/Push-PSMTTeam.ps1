<#if(Test-PSFParameterBinding -Parameter Batch){
    $batchGraphApiParameters=@{
        AuthorizationToken = $graphApiParameters['AuthorizationToken']
        Request = @{
            Uri = $graphApiParameters['Uri']
            Method = $graphApiParameters['Method']
            Body = $bodyParameters
        }
        Batch=$Batch
    }
    $batchGraphApiParameters
    $newTeamResult = Invoke-GraphApiQueryBatch @batchGraphApiParameters
    $newTeamResult
}

if(Test-PSFParameterBinding -Parameter Batch){
            Write-PSFMessage -Level InternalComment -String 'QueryBatchCommandOutput' -StringValues $batchGraphApiParameters'Uri'] -Target $batchGraphApiParameters['Uri'] -Tag GraphApi,Post,Batch -Data $batchGraphApiParameters
        }
#>