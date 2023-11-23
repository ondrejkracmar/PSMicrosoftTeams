﻿function Remove-PSMTTeam {
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
        [Alias("Id")]
        [string]
        $TeamId,
        [switch]
        $Status
    )

    begin {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "groups"
            $authorizationToken = Get-PSMTAuthorizationToken
        } 
        catch {
            Stop-PSFFunction -String 'StringAssemblyError' -StringValues $url -ErrorRecord $_
        }
    }
	
    process {
        if (Test-PSFFunctionInterrupt) { return }

        $graphApiParameters = @{
            Method             = 'Delete'
            AuthorizationToken = "Bearer $authorizationToken"
            Uri                = Join-UriPath -Uri $url -ChildPath "$TeamId"
        }
            
        If ($Status.IsPresent) {
            $graphApiParameters['Status'] = $true
        }
        Invoke-GraphApiQuery @graphApiParameters
    }

	
    end {
	
    }
}