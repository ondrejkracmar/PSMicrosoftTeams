function Get-PSMTTeamTemplate {
<#
	.SYNOPSIS
		Json string of template new team.
	
	.DESCRIPTION
        Json string of template new team.

	.PARAMETER Token
		Access Token for Graph Api .
	
	.PARAMETER JsonTemplate
        Json string with template of new team for GRaph Api function.

    .PARAMETER DisplayName
        DispalyName of new team
        
    .PARAMETER Description
        Description of new team

    .PARAMETER Owners
        Teams Owners
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
        [string]$JsonTemplate,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 2,
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 3,
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            Position = 4,
            ParameterSetName = 'Token')]
        [array]$Owners
    )
	
    begin {
        $taSetting = Get-TeamsAutomationSettings
        $url = -join ($taSetting.GraphApiUrl, "/", $taSetting.GraphApiVersion, "/", "users")        
    }
    
    process {
        Try {
            [array]$ownerList = @()
            if ($PSBoundParameters.ContainsKey('Owners')) {
                foreach ($owner in $Owners) {
                    $userResult = Get-User -Token $token -UserPrincipalName $owner
                    if ($userResult.PSobject.Properties.name -eq "Id") {
                        if (-not $ownerList.Contains("$url/$($userResult.Id)")) {
                            #$ownerList.Add("$url/$($userResult.Id)")
                            $ownerList += "$url/$($userResult.Id)"
                        } 
                    }    
                }
            }
                
            $teamsTemplate = $JsonTemplate | ConvertFrom-Json | ConvertTo-Hashtable
            $teamsTemplate['DisplayName'] = $DisplayName
            $teamsTemplate['Description'] = $Description
            if ($ownerList.count -gt 0) {
                $teamsTemplate['owners@odata.bind'] = [array]$ownerList
            }
            [string]$jsonTeamsTemplate = $teamsTemplate | ConvertTo-Json | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) } 
            Write-Output $jsonTeamsTemplate
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
         
    }
    end {

    }
}
