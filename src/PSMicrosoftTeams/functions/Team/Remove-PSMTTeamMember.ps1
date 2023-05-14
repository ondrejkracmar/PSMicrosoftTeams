function Remove-PSMTTeamMember {
    <#
    .SYNOPSIS
        Remove an owner or member from the team, and to the unified group which backs the team.
              
    .DESCRIPTION
        This cmdlet removes an owner or member from the team, and to the unified group which backs the team.
              
    .PARAMETER TeamId
        Id of Team (unified group)

    .PARAMETER UserId
        Id of User

    .PARAMETER Status
        Switch response header or result

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                try {
                    [System.Guid]::Parse($_) | Out-Null
                    $true
                }
                catch {
                    $false
                }
            })]
        [string]
        $TeamId,
        [Alias("Id")]
        [string]
        $MembershipId,
        [switch]
        $Status
    )

    begin {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "teams"
            $authorizationToken = Get-PSMTAuthorizationToken
            $graphApiParameters = @{
                Method             = 'Delete'
                AuthorizationToken = "Bearer $authorizationToken"
            }
        } 
        catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
    }
	
    process {
        if (Test-PSFFunctionInterrupt) { return }
        $graphApiParameters['Uri'] = Join-UriPath -Uri $url -ChildPath "$($TeamId)/members/$($MembershipId)"
            
        If ($Status.IsPresent) {
            $graphApiParameters['Status'] = $true
        }
        Invoke-GraphApiQuery @graphApiParameters
    }
	
    end {
	
    }
}