function Get-PSMTTeam {
    [CmdletBinding(DefaultParameterSetName = 'TeadmId',
        SupportsShouldProcess = $false,
        PositionalBinding = $true,
        ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0,
            ParameterSetName = 'TeamId')]
        [ValidateScript( {
                try {
                    [System.Guid]::Parse($_) | Out-Null
                    $true
                }
                catch {
                    $false
                }
            })]
        [Alias("Id")]
        [string]
        $TeamId,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0,
            ParameterSetName = 'DisplayName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DisplayName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0,
            ParameterSetName = 'MailNickName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailNickName,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 1,
            ParameterSetName = 'MailNickName')]
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 1,
            ParameterSetName = 'DisplayName')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Public", "Private")]
        [string]
        $Visibility,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'DisplayName')]
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'MailNickName')]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'DisplayName')]
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'MailNickName')]
        [switch]$All,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'DisplayName')]
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'MailNickName')]
        [ValidateRange(5, 1000)]
        [int]$PageSize
    )

    begin {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
            $authorizationToken = Get-PSMTAuthorizationToken
            $property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
            $graphApiParameters = @{
                Method             = 'Get'
                AuthorizationToken = "Bearer $authorizationToken"
                Select = $property -join ","
            }
        } 
        catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
    }
	
    process {
        if (Test-PSFFunctionInterrupt) { return }
        
        $graphApiParameters['Uri'] = $url
        $graphApiParameters['Filter'] = "(resourceProvisioningOptions/Any(x:x eq 'Team'))"
        
        if (Test-PSFParameterBinding -Parameter TeamId) {
            $graphApiParameters['Uri'] = $url
            $graphApiParameters['Filter'] = '{0} {1}' -f $graphApiParameters['Filter'], ("and id eq '{0}'" -f $TeamId)
        }
        
			
        if (Test-PSFParameterBinding -Parameter MailNickName) {
            $graphApiParameters['Filter'] = '{0} {1}' -f $graphApiParameters['Filter'], ("and startswith(mailNickName,'{0}')" -f $MailNickName)
        }
			
        if (Test-PSFParameterBinding -Parameter DisplayName) {
            $graphApiParameters['Filter'] = '{0} {1}' -f $graphApiParameters['Filter'], ("and startswith(displayName,'{0}')" -f $DisplayName)
        }

        if (Test-PSFParameterBinding -Parameter Filter) {
            $graphApiParameters['Filter'] = $Filter
        }

        if (Test-PSFParameterBinding -Parameter All) {
            $graphApiParameters['All'] = $true
        }

        if (Test-PSFParameterBinding -Parameter PageSize) {
            $graphApiParameters['Top'] = $PageSize
        }
        $teamResult = Invoke-GraphApiQuery @graphApiParameters

        if (Test-PSFParameterBinding -Parameter Visibility) {
            $teamResult | Where-Object { $_.Visibility -eq $Visibility } | Select-PSFObject -Property $property -ExcludeProperty '@odata*' -TypeName 'PSMicrosoftTeams.Team'
        }
        else {
            $teamResult | Select-PSFObject -Property $property -ExcludeProperty '@odata*' -TypeName 'PSMicrosoftTeams.Team'	
        }
    }
    end {
    }
}