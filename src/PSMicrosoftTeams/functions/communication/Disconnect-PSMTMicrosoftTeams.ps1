function Disconnect-PSMTMicrosoftTeams {
    [CmdletBinding(DefaultParametersetName = "Token")]    
    param()
    
    process {
        Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.AuthorizationToken' -Value 'None' -Hidden
    }
}       
