function Get-PSMTAuthorizationToken
{
    [CmdletBinding(DefaultParametersetName="Token")]    
    param()
 
    process
    {
        return (Get-PSFConfig -Module PSMicrosoftTeams -Name 'Settings.AuthorizationToken' -force).Value
    }
}