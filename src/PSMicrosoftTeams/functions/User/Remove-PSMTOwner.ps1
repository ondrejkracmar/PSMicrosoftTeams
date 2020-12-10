function Remove-PSMTOwner {
<#
	.SYNOPSIS
		Json string of template new team.
	
	.DESCRIPTION
        Json string of template new team.

	.PARAMETER Token
		Access Token for Graph Api .
	
	.PARAMETER TeamId
        Id of Team

    .PARAMETER UserId
        Id of User

#>
    [CmdletBinding(DefaultParameterSetName = 'Token',
        SupportsShouldProcess = $false,
        PositionalBinding = $true,
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 0,
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$Token,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 1,
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 2,
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$UserId
    )
	
    begin {
        
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl), '/', (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion) {
            'v1.0' {
                $url = -join ($graphApiUrl, "/", "groups")
           
            }
            'beta' {
                $url = -join ($graphApiUrl, "/", "groups")
            }
            Default {
                $url = -join ($graphApiUrl, "/", "groups")
            }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }
    
    process {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        Try {
            $ref = '$ref'
            $teamOwnerResult = Invoke-RestMethod -Uri "$($url)$($TeamId)$($UserId)$($ref)$Token"-ContentType "application/json" -Method Delete -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError                
            Write-Output $teamOwnerResult
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}