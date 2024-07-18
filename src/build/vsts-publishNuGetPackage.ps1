[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param (
    $WorkingDirectory,
    [string]$OrganizationName,
    [string]$ArtifactRepositoryName,
    [string]$ArtifactFeedName,
    [string]$FeedUsername,
    [string]$PersonalAccessToken,
    [string]$ModuleName,
    [string]$ModuleVersion,
    [string]$PreRelease
)

# Variables
$packageSourceUrl = "https://pkgs.dev.azure.com/$($OrganizationName)/$ArtifactRepositoryName/_packaging/$ArtifactFeedName/nuget/v3/index.json" # NOTE: v2 Feed


# This is downloaded during Step 3, but could also be "C:\Users\USERNAME\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"
# if not running script as Administrator.
$nugetPath = (Get-Command NuGet).Source
if (-not (Test-Path -Path $nugetPath)) {
    # $nugetPath = 'C:\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe'
    $nugetPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe'
}

# Create credential
$password = ConvertTo-SecureString -String $PersonalAccessToken -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($FeedUsername, $password)


# Step 1 - "Install NuGet" Agent job task now handles this
# Upgrade PowerShellGet
# Install-Module PowerShellGet -RequiredVersion $powershellGetVersion -Force
# Remove-Module PowerShellGet -Force
# Import-Module PowerShellGet -RequiredVersion $powershellGetVersion -Force

# Step 2
# Check NuGet is listed
Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Format-List *

# Step 3
# Register NuGet Package Source
& $nugetPath source add -Name $ArtifactFeedName -Source $packageSourceUrl -Username $FeedUsername -Password $PersonalAccessToken

# Step 4
# Upload NuGet Package
if (-not ([string]::IsNullOrEmpty($PreRelease))) {
    & $nugetPath source push -Source $ArtifactFeedName -ApiKey ((New-Guid).Guid)  '$(moduleName).$(ModuleVersion).nupkg' -SkipDuplicate
}
else{
    & $nugetPath source push -Source $ArtifactFeedName -ApiKey ((New-Guid).Guid)  '$(moduleName).$(ModuleVersion)-$($PreRelease).nupkg' -SkipDuplicate
}
