function New-PSMTTeam
{
<#
	.SYNOPSIS
		Create new team using JSON template.
	
	.DESCRIPTION
		Create new team using JSON template
	
	.PARAMETER Token
		Access Token for Graph Api.
	
	.PARAMETER JsonTemplateString
		JSOn string with definition new team GRaph Api function.
	
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
		[string]$JsonTemplateString
	)
	
	begin
	{
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl),'/',(Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion)
        {
            'v1.0' {$url = -join ($graphApiUrl, "/","teams")}
            'beta' {$url = -join ($graphApiUrl, "/","teams")}
            Default {$url = -join ($graphApiUrl, "/","teams")}
        }
        $NUMBER_OF_RETRIES = $taSetting.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = $taSetting.InvokeRestMethoRetryTimeSec
	}
	process
	{
		Try
        {
            $newTeamResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $Token"} -Body $JsonTemplateString -Method Post -ContentType "application/json"  -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
			$newTeamResult
		}
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}