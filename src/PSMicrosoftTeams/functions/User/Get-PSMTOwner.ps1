function Get-PSMTOwner {
    <#
.SYNOPSIS
    Get owner(s) of team.
              
.DESCRIPTION
    Get owner(s) of team.

.PARAMETER Token
    Access Token for Graph Api
              
.PARAMETER TeamId
    Id of Team
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
        [string]$TeamId
    )
              
    begin {
        $graphApiUrl = -join ((Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl), '/', (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion))
        switch (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion) {
            'v1.0' { $url = -join ($graphApiUrl, "/", "groups") }
            'beta' { $url = -join ($graphApiUrl, "/", "groups") }
            Default { $url = -join ($graphApiUrl, "/", "groups") }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }

    process {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        Try {
            $teamResult = Invoke-RestMethod -Uri "$($url)/$($TeamId)/owners" -Headers @{Authorization = "Bearer $Token"} -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError
            $propName = Get-Member -InputObject $teamResult
            if (($propName.MemberType -eq "NoteProperty") -and ($propName.name -eq "@odata.nextLink")) {
                $nextURL = $result."@odata.nextLink"
                if ($null -ne $nextURL) {
                    Do {
                        $resultNextLink = Invoke-RestMethod  -Header @{
                            "Authorization" = $AuthHeader;
                            "Content-Type"  = $ContentType;
                        } -Method Get -Uri $nextURL                            
                        $resultNextLink.value
                        $nextURL = $resultNextLink."@odata.nextLink"
                    } while ($null -ne $nextURL)
                }
            }
            $teamResult.value
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}