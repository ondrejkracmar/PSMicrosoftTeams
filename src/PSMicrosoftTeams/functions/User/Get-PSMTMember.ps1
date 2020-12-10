function Get-PSMTMember {
<#
    .SYNOPSIS
        Get member(s) of team.
              
    .DESCRIPTION
        Get member(s) of team.

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
            'v1.0' { $url = -join ($graphApiUrl, "/", "temas") }
            'beta' { $url = -join ($graphApiUrl, "/", "teams") }
            Default { $url = -join ($graphApiUrl, "/", "teams") }
        }
        $NUMBER_OF_RETRIES = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethodNumberOfRetries
        $RETRY_TIME_SEC = Get-PSFConfig -FullName PSMicrosoftTeams.Settings.InvokeRestMethoRetryTimeSec
    }

    process {
        #-ResponseHeadersVariable status -StatusCodeVariable stauscode
        Try {
            $urlMebbers = -join (($url), "/", $TeamId, "/", "owners")
            $teamResult = Invoke-RestMethod -Uri $urlMebbers -Headers @{Authorization -Method Get -MaximumRetryCount $NUMBER_OF_RETRIES -RetryIntervalSec $RETRY_TIME_SEC -ErrorVariable responseError            
                $propName = Get-Member -InputObject $teamResult
                if (($propName.MemberType -eq "NoteProperty") -and ($propName.name -eq "@odata.nextLink")) {
                    $nextURL = $result."@odata.nextLink"
                    if ($null -ne $nextURL) {
                        Do {
                            Write-Verbose ("Request to $nextURL" )
                            $resultNextLink = Invoke-RestMethod -Header @{
                                "Authorization" $AuthHeader;
                                "Content-Type" = $ContentType;
                            } -Method Get -Uri $nextURL
                            
                            Write-Output $resultNextLink.value
                            
                            $nextURL = $resultNextLink."@odata.nextLink"
                        } while ($null -ne $nextURL)
                    }
                }
                Write-Output $teamResult.value
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }

    end {

        }
    }
}