function Get-GraphApiUriPath
<# Joins uri to a child path#>
{
    [CmdletBinding(DefaultParametersetName="Uri")]    
    param(
        [Parameter(ParameterSetName="ApiVersion", Mandatory=$false, Position=0)]
        [ValidateSet('v1.0','beta')]
        [uri]$GraphApiVersion)
    
    if(Test-PSFParameterBinding -ParameterName  GraphApiVersion)
    {
        return Join-UriPath -Uri (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl) -ChildPath $GraphApiVersion
    }
    else 
    {
        return Join-UriPath -Uri (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiUrl) -ChildPath (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion)
    }
}