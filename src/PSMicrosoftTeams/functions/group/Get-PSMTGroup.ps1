function Get-PSMTGroup
{
	[CmdletBinding(DefaultParameterSetName = 'Filters',
        SupportsShouldProcess = $false,
        PositionalBinding = $true,
        ConfirmImpact = 'Medium')]
	param(
	    [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
			ParameterSetName = 'Filters')]
		[Parameter(ParameterSetName = 'Displayname')]
		[ValidateNotNullOrEmpty()]
	    [string]
	    $DisplayName,
	    [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
			ParameterSetName = 'Filters')]
		[Parameter(ParameterSetName = 'MailNickName')]
        [ValidateNotNullOrEmpty()]
	    [string]
	    $MailNickName,
	    [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'Filters')]
        [ValidateNotNullOrEmpty()]
		[ValidateSet("Public", "Private")]
	    [string]
		$Visibility,
		[Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false)]
        [switch]$All,
        [Parameter(Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        ValueFromRemainingArguments = $false)]
        [ValidateRange(5, 1000)]
        [int]$PageSize
	)

	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
		} 
		catch {
            Stop-PSFFunction -String 'FailedGetUsers' -StringValues $graphApiParameters['Uri'] -ErrorRecord $_
        }
	}
	
	process
	{
		if (Test-PSFFunctionInterrupt) { return }
        Try
        {
            $graphApiParameters=@{
                Method = 'Get'
				AuthorizationToken = "Bearer $authorizationToken"
				Uri = $url
				#Filter = "(resourceProvisioningOptions/Any(x:x eq 'Team'))"
			}
			
            if(Test-PSFParameterBinding -Parameter MailNickName) {
                $graphApiParameters['Filter'] = '{0} {1}' -f $graphApiParameters['Filter'], ("and startswith(mailNickName,'{0}')" -f $MailNickName)
			}
			
			if(Test-PSFParameterBinding -Parameter DisplayName) {
                $graphApiParameters['Filter'] = '{0} {1}' -f $graphApiParameters['Filter'], ("and startswith(displayName,'{0}')" -f $DisplayName)
			}

            if(Test-PSFParameterBinding -Parameter Filter)
            {
                $graphApiParameters['Filter'] = $Filter
            }

            if(Test-PSFParameterBinding -Parameter All)
            {
                $graphApiParameters['All'] = $true
            }

            if(Test-PSFParameterBinding -Parameter PageSize)
            {
                $graphApiParameters['Top'] = $PageSize
            }
			$teamResult = Invoke-GraphApiQuery @graphApiParameters

			if(Test-PSFParameterBinding -Parameter Visibility) {
				$teamResult | Where-Object {$_.Visibility -eq $Visibility} | Select-PSFObject -Property $property -ExcludeProperty '@odata*' -TypeName 'PSMicrosoftTeams.Group'
			}
			else {
				$teamResult | Select-PSFObject -Property $property -ExcludeProperty '@odata*' -TypeName 'PSMicrosoftTeams.Group'	
			}
        }
        catch {
			Stop-PSFFunction -String 'FailedGetGroup' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Continue -ErrorRecord $_ -Tag GraphApi,Get
		}
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Get -Data $graphApiParameters
	}

	end
	{
    }
}