function Receive-PSMTAuthorizationToken
{
    [CmdletBinding(DefaultParametersetName="Token")]    
    param(

            [switch]
            $AuthorizationTokenDetail
        )
 
    process
    {
        try{
            if(Test-PSFParameterBinding -ParameterName AuthorizationTokenDetail)
            {
                $jwtToken = (Get-PSFConfigValue -FullName 'PSMicrosoftTeams.Settings.AuthorizationToken')  | Get-JWTDetails
                return  $jwtToken                
            }
            else {
                return (Get-PSFConfigValue -FullName 'PSMicrosoftTeams.Settings.AuthorizationToken')
            }
        }
        catch{
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}