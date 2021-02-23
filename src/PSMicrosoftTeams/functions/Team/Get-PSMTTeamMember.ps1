function Get-PSMTTeamMember
{
<#
    .SYNOPSIS
    Get an owner or member to the team, and to the unified group which backs the team.
              
    .DESCRIPTION
        This cmdlet get an owner or member of the team, and to the unified group which backs the team.
              
    .PARAMETER TeamId
        Id of Team (unified group)

    .PARAMETER Role
        Type of Teams user Owner or Member

#>
[CmdletBinding(DefaultParameterSetName = 'Default',
SupportsShouldProcess = $false,
PositionalBinding = $true,
ConfirmImpact = 'Medium')]
	param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'Default')]
	    [ValidateScript({
            try {
                [System.Guid]::Parse($_) | Out-Null
                $true
            } catch {
                $false
            }
        })]
        [Alias("Id")]
	    [string]
	    $TeamId,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'Default')]
        [ValidateNotNullOrEmpty()]
	    [ValidateSet('Members','Owners')]
	    [string]
        $Role,
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
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
            $graphApiParameters=@{
                Method = 'Get'
                AuthorizationToken = "Bearer $authorizationToken"
            }
        } 
		catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {
            
            $graphApiParameters['Uri'] = Join-UriPath -Uri $url -ChildPath "$($TeamId)/members"
            if(Test-PSFParameterBinding -Parameter Role) {
                if($Role -eq 'Owners') {
                    $graphApiParameters['Uri'] = Join-UriPath -Uri $url -ChildPath "$($TeamId)/owners"
                }
            }
            if(Test-PSFParameterBinding -Parameter All) {
                $graphApiParameters['All'] = $true
            }

            if(Test-PSFParameterBinding -Parameter PageSize)
            {
                $graphApiParameters['Top'] = $PageSize
            }
            Invoke-GraphApiQuery @graphApiParameters
        }
        catch {
            Stop-PSFFunction -String 'FailedGetUsers' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Continue -ErrorRecord $_ -Tag GraphApi,Get
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Get -Data $graphApiParameters
    }
	end
	{
	
	}
}