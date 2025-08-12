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
        This parameters disables user-friendly warnings and enables the throwing of exceptions. This is less user frien
        dly, but allows catching exceptions in calling scripts.

    .PARAMETER WhatIf
        Enables the function to simulate what it will do instead of actually executing.

    .PARAMETER Force
        The Force switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Force switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .PARAMETER Confirm
        The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
        The command then prompts you to acknowledge each action before it continues.
        When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
        This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
        A confirmation prompt is displayed for each object before the Shell modifies the object.

    .PARAMETER PassThru
        When specified, the cmdlet will not execute the disable license action but will instead
        return a `PSMicrosoftEntraID.Batch.Request` object for batch processing.

    .EXAMPLE
        Get-PSMsTeamsTeam -Id $id | Set-PSMsTeamsTeam -DisplayName "New Name"

    .EXAMPLE
        PS C:\> Set-PSMsTeamsTeam -Identity $id -FunSettings @{ allowGiphy = $false }

        Updates the FunSettings of the specified team. If the team is not found, an error is thrown (when -EnableException is used).
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
        [Parameter(ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [string] $DisplayName,
        [Parameter(ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [string] $Description,
        [Parameter( ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [string] $Classification,
        [Parameter(ParameterSetName = 'InputObjectUpdateCommon')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityUpdateCommon')]
        [ValidateSet('Public', 'Private', 'HiddenMembership')]
        [string] $Visibility,
        [Parameter( ParameterSetName = 'InputObjectFunSettings')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityFunSettings')]
        [hashtable] $FunSettings,
        [Parameter(ParameterSetName = 'InputObjectMemberSettings')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityMemberSettings')]
        [hashtable] $MemberSettings,
        [Parameter(ParameterSetName = 'InputObjectGuestSettings')]
        [Parameter( ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityGuestSettings')]
        [hashtable] $GuestSettings,
        [Parameter(ParameterSetName = 'InputObjectMessagingSettings')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'IdentityMessagingSettings')]
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
        $path = 'teams'
        $header = @{ 'Content-Type' = 'application/json' }
        $method = 'PATCH'
        if ($Force.IsPresent -and (-not $Confirm.IsPresent)) {
            [bool] $cmdLetConfirm = $false
        }
        else {
            [bool] $cmdLetConfirm = $true
        }
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
                    [string] $path = ("teams/{0}" -f $itemInputObject.Id)
                    if ($PassThru.IsPresent) {
                        [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                    }
                    else {
                        Invoke-PSFProtectedCommand -ActionString 'Team.Set' -ActionStringValues $itemInputObject.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                            [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method $method -ErrorAction Stop)
                        } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                        if (Test-PSFFunctionInterrupt) { return }
                    }
                }
            }
            '^Identity\w' {
                foreach ($itemIdentity in $Identity) {
                    [PSMicrosoftTeams.Teams.Team] $team = Get-PSMsTeamsTeam -Identity $itemIdentity
                    if (-not ([object]::Equals($team, $null))) {
                        [string] $path = ("teams/{0}" -f $team.Id)
                        if ($PassThru.IsPresent) {
                            [PSMicrosoftEntraID.Batch.Request] @{ Method = $method; Url = ('/{0}' -f $path); Body = $body; Headers = $header }
                        }
                        else {
                            Invoke-PSFProtectedCommand -ActionString 'Team.Set' -ActionStringValues $team.DisplayName -Target (Get-PSFLocalizedString -Module $script:ModuleName -Name Identity.Platform) -ScriptBlock {
                                [void] (Invoke-EntraRequest -Service $service -Path $path -Header $header -Body $body -Method $method -ErrorAction Stop)
                            } -EnableException:$EnableException -Confirm:$cmdLetConfirm -PSCmdlet $PSCmdlet -Continue -RetryCount $commandRetryCount -RetryWait $commandRetryWait
                            if (Test-PSFFunctionInterrupt) { return }
                        }
                    }
                    else {
                        if ($EnableException.IsPresent) {
                            Invoke-TerminatingException -Cmdlet $PSCmdlet -Message ((Get-PSFLocalizedString -Module $script:ModuleName -Name Team.Set.Failed) -f $teamId)
                        }
                    }
                }
            }
        }
    }
    end {}
}
