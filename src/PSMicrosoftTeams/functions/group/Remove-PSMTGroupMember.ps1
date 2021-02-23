﻿function Remove-PSMTGroupMember
{
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
	    $GroupId,
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
	    $UserId,
        [switch]
        $Status
    )

	begin
	{
	    try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $graphApiParameters=@{
                Method = 'Delete'
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
                $urlMembers = Join-UriPath -Uri $url -ChildPath "$($GroupId)/members/$($UserId)" 
                $graphApiParameters['Uri'] = Join-UriPath -Uri $urlMembers -ChildPath '$ref'
                If($Status.IsPresent){
                    $graphApiParameters['Status'] = $true
                }
                Invoke-GraphApiQuery @graphApiParameters
            }
        catch {
            Stop-PSFFunction -String 'FailedRemoveMember' -StringValues $UserId,$GroupId -Target $graphApiParameters['Uri'] -Continue -ErrorRecord $_ -Tag GraphApi,Delete
        }
        Write-PSFMessage -Level InternalComment -String 'QueryCommandOutput' -StringValues $graphApiParameters['Uri'] -Target $graphApiParameters['Uri'] -Tag GraphApi,Delete -Data $graphApiParameters

	}
	
	end
	{
	
	}
}