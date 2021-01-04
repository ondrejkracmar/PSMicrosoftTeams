function Get-PSMTUser
{
    <#
    .SYNOPSIS
        Get the properties of the specified user.
                
    .DESCRIPTION
        Get the properties of the specified user.

    .PARAMETER Token
        Access Token for Graph Api
                
    .PARAMETER UserPrincipalName
        UserPrincipalName of user
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
        [string]$UserPrincipalName
    )
              
    begin
    {
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl), '/', (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion)
        {
            'v1.0'
            {
                $url = -join ($graphApiUrl, "/", "users")
            }
            'beta'
            {
                $url = -join ($graphApiUrl, "/", "users")
            }
            Default
            {
                $url = -join ($graphApiUrl, "/", "users")
            }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }
    
    process
    {
        Try
        {
            #-ResponseHeadersVariable status -StatusCodeVariable stauscode
            $user = Invoke-RestMethod -Uri "$url/$UserPrincipalName"-Headers @{Authorization = "Bearer $Token"} -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
            $user
            }
            catch
            {
                $PSCmdlet.ThrowTerminatingError($PSItem) #Get-ParseErrorForResponseBody($_)
            }
        }
    }