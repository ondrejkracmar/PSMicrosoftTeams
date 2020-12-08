function Remove-PSMTOwner
{
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
        Try
        {
            $ref='$ref'
            $teamOwnerResult = Invoke-RestMethod -Uri "$($url)/$($TeamId)/owners/$($UserId)/$($ref)" -Headers @{Authorization = "Bearer $Token"} -ContentType "application/json"  -Method Delete -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError                
            Write-Output $teamOwnerResult
        }
        catch  {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    end
    {

    }
}