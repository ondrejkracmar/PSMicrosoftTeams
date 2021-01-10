function Get-PSMTUser
{
    <#
    .SYNOPSIS
        Get the properties of the specified user.
                
    .DESCRIPTION
        Get the properties of the specified user.
                
    .PARAMETER UserPrincipalName
        UserPrincipalName of user
#>
    [CmdletBinding(DefaultParameterSetName = 'User',
        SupportsShouldProcess = $false,
        PositionalBinding = $true,
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0,
            ParameterSetName = 'User')]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName
    )
              
    begin
    {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $NUMBER_OF_RETRIES = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryCount)
            $RETRY_TIME_SEC = (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodRetryTimeSec)
	    } catch {
	        throw
        }
    }
    
    process
    {
        Try
        {
            #-ResponseHeadersVariable status -StatusCodeVariable stauscode
            $urlUser = Join-UriPath -Uri $url -ChildPath $UserPrincipalName
            $userResult = Invoke-RestMethod -Uri $urlUser-Headers @{Authorization = "Bearer $authorizationToken"} -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
            return $$userResult
        }
        catch
        {
                $PSCmdlet.ThrowTerminatingError($PSItem) 
        }
        }
}