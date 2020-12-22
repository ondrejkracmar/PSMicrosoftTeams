function Get-GraphApiUriPath
<# Joins uri to a child path#>
{
    [CmdletBinding(DefaultParametersetName="Uri")]    
    param(
        [Parameter(ParameterSetName="ApiVersion", Mandatory=$false, Position=0)]
        [uri]$GraphApiVersion)
    
    if($PSBoundParameters.ContainsKey('GraphApiVersion'))
    {
        return Join-UriPath -Uri (Get-PSFConfig -FullNamePSMicrosoftTeams.Settings.GraphApiUrl) -ChildPath $GraphApiVersion
    }
    else 
    {
        return Join-UriPath -Uri (Get-PSFConfig -FullNamePSMicrosoftTeams.Settings.GraphApiUrl) -ChildPath (Get-PSFConfig -FullName PSMicrosoftTeams.Settings.GraphApiVersion)
    }
}