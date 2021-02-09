function Lock-PSMTTeamMember
{
<#
    .SYNOPSIS
        Archive the specified team.
              
    .DESCRIPTION
        Archive the specified team.
        hen a team is archived, users can no longer send or like messages on any channel in the team, edit the team's name, description, or other settings, or in general make most changes to the team.
        Membership changes to the team continue to be allowed.
              
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
        [string]
        [Alias("Id")]
	    $TeamId,
        [switch]
        $Status
    )

	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $graphApiParameters=@{
                Method = 'Post'
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
            $graphApiParameters['Uri'] = Join-UriPath -Uri $url -ChildPath "$($TeamId)/archive"
            
            If($Status.IsPresent){
                $graphApiParameters['Status'] = $true
            }
            $archiveTeamResult = Invoke-GraphApiQuery @graphApiParameters
            $archiveTeamResult
        }
        catch {
            Stop-PSFFunction -String 'FailedRemoveMember' -StringValues $UserId,$TeamId -Target $graphApiParameters['Uri'] -Continue -ErrorRecord $_ -Tag GraphApi,Delete
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Delete -Data $graphApiParameters

	}
	
	end
	{
	
	}
}