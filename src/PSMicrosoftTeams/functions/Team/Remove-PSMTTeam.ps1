function Remove-PSMTTeam
{
<#
    .SYNOPSIS
        Removed Team (Office 365 unified group).
              
    .DESCRIPTION
        This cmdlet removes tam (Office 365 unified group).
              
    .PARAMETER TeamId
        Id of Team (unified group)

    .PARAMETER Status
        Switch response header or result

#>
	[CmdletBinding()]
	param(
	    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
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
        [switch]
        $Status
    )

	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
            $authorizationToken = Receive-PSMTAuthorizationToken
            #$property = Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.Group
		} 
		catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
	}
	
	process
	{
        if (Test-PSFFunctionInterrupt) { return }
	    try {
            $graphApiParameters=@{
                Method = 'Delete'
                AuthorizationToken = "Bearer $authorizationToken"
                Uri = Join-UriPath -Uri $url -ChildPath "$TeamId"
            }
            
            If($Status.IsPresent){
                $graphApiParameters['Status'] = $true
            }
            $deleteTeamResult = Invoke-GraphApiQuery @graphApiParameters
            $deleteTeamResult
        }
        catch {
            Stop-PSFFunction -String 'FailedRemoveTeam' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Continue -ErrorRecord $_ -Tag GraphApi,Delete
          }
          Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Delete -Data $graphApiParameters
	}
	
	end
	{
	
	}
}