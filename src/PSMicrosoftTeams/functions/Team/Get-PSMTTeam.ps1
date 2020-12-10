function Get-PSMTTeam 
{
<#
    .SYNOPSIS
        Get the properties of the specified team.
	
    .DESCRIPTION
        Get the properties of the specified team.

    .PARAMETER Token
	    Access Token for Graph Api
	
    .PARAMETER TeamDisplayName
        DisplayName of Team

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
        [string]$DisplayName
    )
	
    begin {
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl), '/', (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion) {
            'v1.0' { $url = -join ($graphApiUrl, "/", "groups") }
            'beta' { $url = -join ($graphApiUrl, "/", "groups") }
            Default { $url = -join ($graphApiUrl, "/", "groups") }
        }
        $NUMBER_OF_RETRIES = $taSetting.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = $taSetting.InvokeRestMethoRetryTimeSec
    }
    
    process {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        $teamsDisplayName = -join ("'", $DisplayName, "'")
        Try {
            $teamResult = Invoke-RestMethod -Uri "$($url)?filter=displayname eq $($teamsDisplayName)" -Headers @{Authorization = "Bearer $Token"} -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
            $teamResult.value
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}