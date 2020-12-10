function Add-PSMTOwner
{
<#
    .SYNOPSIS
        Add owner to specified team.
              
    .DESCRIPTION
        Add owner to specified team.

    .PARAMETER Token
        Access Token for Graph Api .
              
    .PARAMETER TeamId
        Id of Team

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
              
    begin {
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl), '/', (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion) {
            'v1.0' {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
                $urlUsers = -join ($graphApiUrl, "/", "users('$($UserId)')")
            }
            'beta' {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
                $urlUsers = -join ($graphApiUrl, "/", "users('$($UserId)')")
            }
            Default {
                $url = -join ($graphApiUrl, "/teams/$($TeamId)/", "members")
                $urlUsers = -join ($graphApiUrl, "/", "users('$($UserId)')")
            }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }
    
    process {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        Try {
            $ownerBody = @{
                "@odata.type"     = "#microsoft.graph.aadUserConversationMember"
                "roles"           = @('owner')
                "user@odata.bind" = "$urlUsers"
            }
            $jsonOwnerBody = $ownerBody | ConvertTo-Json
            $teamOwnerResult = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $Token"} -Body $jsonOwnerBody -ContentType "application/json"  -Method Post -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
            $teamOwnerResult
        }
        catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
        }     
    }
}
