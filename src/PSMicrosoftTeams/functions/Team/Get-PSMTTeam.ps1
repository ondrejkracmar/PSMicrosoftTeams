function Get-PSMTTeam
{
<#
	.SYNOPSIS
		Json string of template new team.
	
	.DESCRIPTION
        Json string of template new team.

	.PARAMETER Token
		Access Token for Graph Api .
	
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
	
	begin
	{
        $taSetting = Get-TeamsAutomationSettings
        $url = -join ($taSetting.GraphApiUrl,"/",$taSetting.GraphApiVersion, "/","groups")
        $NUMBER_OF_RETRIES = $taSetting.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = $taSetting.InvokeRestMethoRetryTimeSec
    }
    
	process
	{
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        $teamsDisplayName = -join ("'",$DisplayName,"'")
        Try
        {
            $teamResult = Invoke-RestMethod -Uri "$($url)?filter=displayname eq $($teamsDisplayName)" -Headers @{Authorization = "Bearer $Token"} -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError            
            Write-Output $teamResult.value
        }
        catch  {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end
    {

    }
}
