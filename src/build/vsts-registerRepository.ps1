param (
    [string]$OrganizationName,
    [string]$RepositoryName,
    [string]$ArtifactRepositoryName,
    [string]$ArtifactFeedName,
    [string]$FeedUsername,
    [string]$PersonalAccessToken
)

# Variables
$packageSourceUrl = "https://$($OrganizationName).pkgs.visualstudio.com/$RepositoryName/_packaging/$ArtifactFeedName/nuget/v3/index.json" # NOTE: v2 Feed


# This is downloaded during Step 3, but could also be "C:\Users\USERNAME\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"
# if not running script as Administrator.
$nugetPath = (Get-Command NuGet.exe).Source
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
& $nugetPath Sources Add -Name $ArtifactFeedName -Source $packageSourceUrl -Username $FeedUsername -Password $PersonalAccessToken 

# Check new NuGet Source is registered
& $nugetPath Sources List


# Step 4
# Register feed
$registerParams = @{
    Name                      = $ArtifactRepositoryName
    SourceLocation            = $packageSourceUrl
    PublishLocation           = $packageSourceUrl
    InstallationPolicy        = 'Trusted'
    PackageManagementProvider = 'Nuget'
    Credential                = $credential
    Verbose                   = $true
}
Register-PSRepository @registerParams

# Check new PowerShell Repository is registered
Get-PSRepository -Name $ArtifactRepositoryName
