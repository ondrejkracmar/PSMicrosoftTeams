try {
    $alreadyLoaded = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {
        $_.GetName().Name -eq 'PSMicrosoftEntraID'
    }
    if (-not $alreadyLoaded) {
        Add-Type -Path "$script:ModuleRoot\bin\PSMicrosoftEntraID.dll" -ErrorAction Stop
    }
    Add-Type -Path "$script:ModuleRoot\bin\PSMicrosoftTeams.dll" -ErrorAction Stop
}
catch {
    Write-Warning "Failed to load PSMicrosoftEntraID Assembly! Unable to import module."
    throw
}
try {
    Update-TypeData -AppendPath "$script:ModuleRoot\types\PSMicrosoftTeams.ps1xml" -ErrorAction Stop
}
catch {
    Write-Warning "Failed to load PSMicrosoftEntraID type extensions! Unable to import module."
    throw
}