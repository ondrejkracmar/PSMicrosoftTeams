function New-PSMsTeamsTeamChannel {
<#
.SYNOPSIS
    Create a new channel in a Microsoft Teams team (standard, private, or shared).

.DESCRIPTION
    Creates a new Microsoft Teams channel of the specified type via Microsoft Graph API POST /teams/{team-id}/channels.

.PARAMETER Identity
    Team Id, GroupId, MailNickname, or any unique team identifier.

.PARAMETER DisplayName
    Name of the new channel.

.PARAMETER Description
    Description of the channel.

.PARAMETER MembershipType
    Channel type: standard (default), private, shared.

.PARAMETER Owner
    (For private/shared channels) Array of UPNs/IDs for owners/members to be added during creation.

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.EXAMPLE
    New-PSMsTeamsTeamChannel -Identity team1 -DisplayName "IT Only" -MembershipType private -Owner "user1@contoso.com"
#>
    [OutputType('PSMicrosoftTeams.Channel')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Id", "GroupId", "TeamId", "MailNickname")]
        [ValidateGroupIdentity()]
        [string] $Identity,

        [Parameter(Mandatory = $true)]
        [string] $DisplayName,

        [Parameter(Mandatory = $false)]
        [string] $Description,

        [Parameter(Mandatory = $false)]
        [ValidateSet('standard', 'private', 'shared')]
        [string] $MembershipType = 'standard',

        [Parameter(Mandatory = $false)]
        [string[]] $Owner,

        [Parameter()]
        [switch] $EnableException,

        [Parameter()]
        [switch] $Force
    )
    begin {
        [string] $service = Get-PSFConfigValue -FullName ('{0}.Settings.DefaultService' -f $script:ModuleName)
        Assert-EntraConnection -Service $service -Cmdlet $PSCmdlet
        [int] $commandRetryCount = Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryCount' -f $script:ModuleName)
        [System.TimeSpan] $commandRetryWait = New-TimeSpan -Seconds (Get-PSFConfigValue -FullName ('{0}.Settings.Command.RetryWaitInSeconds' -f $script:ModuleName))
        [hashtable] $header = @{ 'Content-Type' = 'application/json' }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')) {
            [boolean] $cmdLetVerbose = $true
        } else {
            [boolean] $cmdLetVerbose = $false
        }
        $teamObj = Get-PSMsTeamsTeam -Identity $Identity -EnableException:$EnableException
        if ([object]::Equals($teamObj, $null) -or -not $teamObj.Id) {
            $msg = "Team '$Identity' not found or missing Id. Skipping."
            if ($EnableException.IsPresent) {
                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Get.Failed) -f $Identity)
            } else {
                Write-Warning $msg
            }
            throw $msg
        }
        $teamId = $teamObj.Id
        $path = "teams/$teamId/channels"
        $serviceUrl = (Get-EntraService -Name $service).ServiceUrl
    }
    process {
        $body = @{
            displayName    = $DisplayName
            membershipType = $MembershipType
        }
        if ($Description) { $body['description'] = $Description }

        if ($MembershipType -in @('private', 'shared') -and $Owner) {
            $owners = @()
            foreach ($own in $Owner) {
                $userObj = Get-PSMsTeamsUser -Identity $own
                if ([object]::Equals($userObj, $null) -or -not $userObj.Id) {
                    $msg = "Owner '$own' not found or missing Id. Skipping."
                    if ($EnableException.IsPresent) {
                        Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name User.Get.Failed) -f $own)
                    } else {
                        Write-Warning $msg
                    }
                    continue
                }
                $owners += @{
                    '@odata.type'     = "microsoft.graph.aadUserConversationMember"
                    'roles'           = @('owner')
                    'user@odata.bind' = ('{0}/users/{1}' -f $serviceUrl, $userObj.Id)
                }
            }
            if ($owners.Count -gt 0) {
                $body['members'] = $owners
            }
        }
        if ($PSCmdlet.ShouldProcess("$DisplayName", "Create channel in team $teamId")) {
            $result = Invoke-PSFProtectedCommand -ActionString 'TeamChannel.New' -ActionStringValues $DisplayName -Target $teamId -ScriptBlock {
                Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Post -Verbose:$cmdLetVerbose -ErrorAction Stop | ConvertFrom-RestTeamChannel
            } -EnableException:$EnableException -Confirm:$Force -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
            $result
            if (Test-PSFFunctionInterrupt) { return }
        }
    }
    end {}
}
