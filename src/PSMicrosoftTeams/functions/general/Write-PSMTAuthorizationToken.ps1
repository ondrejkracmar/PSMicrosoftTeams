function Write-PSMTAuthorizationToken
{
    [CmdletBinding(DefaultParametersetName="Token")]    
    param(
        [Parameter(ParameterSetName="Token", Mandatory=$false, Position=0)]
        [string]$AuthorizationToken)
    
    begin {
        try{
            $jwtToken = $AuthorizationToken | Get-JWTDetails     
            Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.AuthorizationToken' -Value $jwtToken.AccessToken
            return $jwtToken
        }
        catch{
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}