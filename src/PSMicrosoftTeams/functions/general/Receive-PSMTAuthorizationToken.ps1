function Receive-PSMTAuthorizationToken
{
    [CmdletBinding(DefaultParametersetName="Token")]    
    param(
        )
 
    begin
    {
        try{
            $jwtToken = $AuthorizationToken | (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.AuthorizationToken)     
            return $jwtToken
        }
        catch{
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}