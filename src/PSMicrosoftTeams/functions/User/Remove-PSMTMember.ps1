function Remove-PSMTMember
{
<#
.SYNOPSIS
    Remove member from team.
	
.DESCRIPTION
    Remove member from team.

.PARAMETER Token
    Access Token for Graph Api
	
.PARAMETER TeamId
    Id of team
    
.PARAMETER UserId
    Id of User

#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl), '/', (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion)
        {   
            'v1.0'
            {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
            }
            'beta'
            {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
            }
            Default
            {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
            }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }
    process
    {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        Try
        {
            #$UserID vs $MembershipId
            $urlMemberShipId = -join ($url, "/", "$UserId")
            $teamUsersResult = Invoke-RestMethod -Uri $urlMemberShipId -Headers @{Authorization = "Bearer $Token" } -ContentType "application/json"  -Method Delete -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
            $teamUsersResult
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}