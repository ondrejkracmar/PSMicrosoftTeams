function Connect-PSMTMicrosoftTeams {
    [CmdletBinding(DefaultParametersetName = "Token")]    
    param(
        [Parameter(ParameterSetName = "AuthorizationToken", Mandatory = $true)]
        [string]$AuthorizationToken,
        [Parameter(ParameterSetName = 'Application', Mandatory = $true)]
        [string]$TenantName,
        [Parameter(ParameterSetName = 'Application', Mandatory = $true)]
        [string]$TenantId,
        [Parameter(ParameterSetName = 'Application', Mandatory = $true)]
        [string]$ClientId,
        [Parameter(ParameterSetName = 'Application', Mandatory = $true)]
        [string]$ClientSecret)
    
    process {
        Switch ($PSCmdlet.ParameterSetName) {
            'AuthorizationTokenAuthorizationToken' {                               
                $accessToken = $AuthorizationToken
            }
            'Application' {
                try{
                    $accessToken = Request-PSMTAuthorizationToken -TenantName $TenantName -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
                   #test1
                   #test2
                   #test3
                }
                catch{
                    $PSCmdlet.ThrowTerminatingError((New-Object System.Management.Automation.ErrorRecord ([Exception]'some-error'), $null, 0, $null))
                }
            }
        }
        Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.AuthorizationToken' -Value $accessToken -Hidden
    }
}       
