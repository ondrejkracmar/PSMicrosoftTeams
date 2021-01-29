﻿function Get-PSMTTeamUser
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
	    [string]
	    $TeamId,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
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
		} 
		catch {
            Stop-PSFFunction -String 'FailedGetUsers' -StringValues $graphApiParameters['Uri'] -ErrorRecord $_
        }
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {
            $graphApiParameters=@{
                Method = 'Get'
                AuthorizationToken = "Bearer $authorizationToken"
            }

            if(Test-PSFParameterBinding -Parameter Role) {
                if($Role -eq 'Members') {
                    $urlUser = Join-UriPath -Uri $url -ChildPath "$($TeamId)/members"
                    $graphApiParameters['Uri'] = $urlUser
                    $graphApiParameters['Filter'] = "(roles/Any(x:x ne 'owner'))"
                }
                if($Role -eq 'Owners') {
                    $urlUser = Join-UriPath -Uri $url -ChildPath "$($TeamId)/members"
                    $graphApiParameters['Uri'] = $urlUser
                    $graphApiParameters['Filter'] = "(roles/Any(x:x eq 'owner'))"
                }
                #$graphApiParameters['Select'] = $property -join ","
                #$graphApiParameters['Expand'] = 'roles'
            }
            
            if(Test-PSFParameterBinding -Parameter All) {
                $graphApiParameters['All'] = $true
            }

            if(Test-PSFParameterBinding -Parameter PageSize)
            {
                $graphApiParameters['Top'] = $PageSize
            }
            $userResult = Invoke-GraphApiQuery @graphApiParameters
            $userResult
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