function Set-PSMsTeamsTeam {
    <#
.SYNOPSIS
    Updates the specified properties of a Microsoft Teams team.

.DESCRIPTION
    Updates modifiable properties of a Microsoft Teams team via Microsoft Graph API PATCH /teams/{id}.
    Some properties must be updated in separate PATCH calls (see parameter sets).
    Supports pipeline (InputObject), batch processing, identity lookup, and full error handling.

.PARAMETER InputObject
    Team object(s).

.PARAMETER Identity
    Team Id or GroupId.

.PARAMETER DisplayName
    New display name (can be PATCHed with Description, Classification, Visibility).

.PARAMETER Description
    New description (can be PATCHed with DisplayName, Classification, Visibility).

.PARAMETER Classification
    New classification (can be PATCHed with DisplayName, Description, Visibility).

.PARAMETER Visibility
    New visibility (Public, Private, HiddenMembership; can be PATCHed with other basic props).

.PARAMETER FunSettings
    FunSettings hashtable/object (must be PATCHed in a separate call).

.PARAMETER MemberSettings
    MemberSettings hashtable/object (must be PATCHed in a separate call).

.PARAMETER GuestSettings
    GuestSettings hashtable/object (must be PATCHed in a separate call).

.PARAMETER MessagingSettings
    MessagingSettings hashtable/object (must be PATCHed in a separate call).

.PARAMETER EnableException
    If set, cmdlet throws on failure. Otherwise, issues warnings.

.PARAMETER Force
    Suppresses confirmation prompts.

.EXAMPLE
    Get-PSMsTeamsTeam -Id $id | Set-PSMsTeamsTeam -DisplayName "New Name"

.EXAMPLE
    Set-PSMsTeamsTeam -Identity $id -FunSettings @{ allowGiphy = $false }
#>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'InputObjectUpdateCommon')]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObjectFunSettings')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObjectMemberSettings')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObjectGuestSettings')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'InputObjectMessagingSettings')]
        [PSMicrosoftTeams.Teams.Team[]] $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityFunSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityMemberSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityGuestSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityMessagingSettings')]
        [Alias("Id", "GroupId", "TeamId")]
        [string[]] $Identity,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [string] $DisplayName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [string] $Classification,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [ValidateSet('Public', 'Private', 'HiddenMembership')]
        [string] $Visibility,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectFunSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityFunSettings')]
        [hashtable] $FunSettings,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectMemberSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityMemberSettings')]
        [hashtable] $MemberSettings,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectGuestSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityGuestSettings')]
        [hashtable] $GuestSettings,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'InputObjectMessagingSettings')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityMessagingSettings')]
        [hashtable] $MessagingSettings,

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
        $cmdLetConfirm = if ($Force.IsPresent) { $false } else { $true }
        $cmdLetVerbose = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')
    }

    process {
        [hashtable] $body = @{}
        switch -Regex ($PSCmdlet.ParameterSetName) {
            '\wUpdateCommon' {
                foreach ($param in $PSBoundParameters.Keys) {
                    switch ($param) {
                        'DisplayName' { $body['displayName'] = $DisplayName }
                        'Description' { $body['description'] = $Description }
                        'Classification' { $body['classification'] = $Classification }
                        'Visibility' { $body['visibility'] = $Visibility }
                    }
                }
            }
            '\wFunSettings' { $body['funSettings'] = $FunSettings }
            '\wMemberSettings' { $body['memberSettings'] = $MemberSettings }
            '\wGuestSettings' { $body['guestSettings'] = $GuestSettings }
            '\wMessagingSettings' { $body['messagingSettings'] = $MessagingSettings }
        }

        switch -Regex  ($PSCmdlet.ParameterSetName) {
            '^InputObject\w' {
                foreach ($itemInputObject in $InputObject) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Set' -ActionStringValues $itemInputObject.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        [string] $path = ("teams/{0}" -f $itemInputObject.Id)
                        [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Patch -Verbose:$cmdLetVerbose -ErrorAction Stop)
                    } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue
                    if (Test-PSFFunctionInterrupt) { return }
                }
            }
            '^Identity\w' {
                foreach ($teamId in $Identity) {
                    Invoke-PSFProtectedCommand -ActionString 'Team.Set' -ActionStringValues $teamId -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                        $teamObj = Get-PSMsTeamsTeam -Identity $teamId
                        if ($null -ne $teamObj -and $teamObj.Id) {
                            [string] $path = ("teams/{0}" -f $teamObj.Id)
                            [void](Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method Patch -Verbose:$cmdLetVerbose -ErrorAction Stop)
                        }
                        else {
                            if ($EnableException.IsPresent) {
                                Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Set.Failed) -f $teamId)
                            }
                            if (Test-PSFFunctionInterrupt) { return }
                        } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }
            }
        }
    }
    end {}
}
