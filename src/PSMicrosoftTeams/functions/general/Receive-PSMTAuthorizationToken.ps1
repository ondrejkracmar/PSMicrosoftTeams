function Receive-PSMTAuthorizationToken
{
    [CmdletBinding(DefaultParametersetName="Token")]    
    param(
        )
 
    begin
    {
        try{
            $jwtToken = (Get-PSFConfig -FullName 'PSMicrosoftTeams.Settings.AuthorizationToken')  | Get-JWTDetails   
            return $jwtToken
        }
        catch{
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}