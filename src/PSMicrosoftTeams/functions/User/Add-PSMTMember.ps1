function Add-PSMTMember {
<#
    .SYNOPSIS
        Add meber to specified team.
              
    .DESCRIPTION
        Add meber to specified team.

    .PARAMETER Token
        Access Token for Graph Api
              
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
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
                $urlUsers = -join ($graphApiUrl, "/", "users")
            }
            'beta' {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
                $urlUsers = -join ($graphApiUrl, "/", "users")
            }
            default {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
                $urlUsers = -join ($graphApiUrl, "/", "users")
            }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }
    
    process {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        Try {
            $memberBody = @{
                "@odata.type"     = "#microsoft.graph.aadUserConversationMember"
                "roles"           = @('member')
                "user@odata.bind" = "$($urlUsers)('$UserID')"
            }
            $jsonMemberBody = $memberBody | ConvertTo-Json
            $teamOwnerResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $Token"} -Body $jsonMemberBody -ContentType "application/json"  -Method Post -Verbose -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
                Write-Output $teamOwnerResult
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
}