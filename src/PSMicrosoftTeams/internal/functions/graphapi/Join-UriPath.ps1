function Join-UriPath
<# Joins uri to a child path#>
{
    [CmdletBinding(DefaultParametersetName="Uri")]    
    param(
        [Parameter(ParameterSetName="Uri", Mandatory=$true, Position=0)]
        [uri]$Uri, 
        [Parameter(ParameterSetName="Uri", Mandatory=$true, Position=1)]
        [string]$ChildPath)
    $combinedPath = [System.Uri]::new($Uri, $ChildPath)
    return New-Object uri $combinedPath
}