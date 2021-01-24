function Get-PSMTTeamUser
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
[CmdletBinding(DefaultParameterSetName = 'All',
SupportsShouldProcess = $false,
PositionalBinding = $true,
ConfirmImpact = 'Medium')]
	param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
			ParameterSetName = 'Filters')]
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
            ParameterSetName = 'Role')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName = 'All')]
	    [ValidateSet('Member','Owner')]
	    [string]
        $Role
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
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams/$($TeamId)/members"
            if(Test-PSFPowerShell -Edition Core){    
                $getUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"}  -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            else {
                $getUserTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $authorizationToken"}  -Method Get #-MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError -ResponseHeadersVariable responseHeaders
            }
            if((Test-PSFParameterBinding -ParameterName Role) -or $Role -eq 'member')
            {
                return $getUserTeamResult #| Where-Object
            }
            else {
                return $getUserTeamResult #| Where-Object
            }
        }
        catch {
            Stop-PSFFunction -Message "Failed to get data from $urlUser." -ErrorRecord $_
        }
    }
	
	end
	{
	
	}
	
	
}