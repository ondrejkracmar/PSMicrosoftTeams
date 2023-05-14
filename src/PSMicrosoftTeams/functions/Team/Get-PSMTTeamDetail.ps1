<#[Parameter(ParameterSetName='Identity', Mandatory=$true)]
[string]
${TeamId},
#

<#if(Test-PSFParameterBinding -Parameter TeamId)
            {
				$format = "?`$format=json"
				$url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams/$($TeamId)$format" 
			}#>