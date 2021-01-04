<#
Add all things you want to run before importing the main function code.

WARNING: ONLY provide paths to files!

After building the module, this file will be completely ignored, adding anything but paths to files ...
- Will not work after publishing
- Could break the build process
#>

$moduleRoot = Split-Path (Split-Path $PSScriptRoot)

# Add all things you want to run before importing the main code

# Load the initial settings of module
"$($moduleRoot)\internal\scripts\initialize.ps1"

# Load the strings used in messages
"$($moduleRoot)\internal\scripts\strings.ps1"

# Load Variables needed during import
"$($moduleRoot)\internal\scripts\variables.ps1"


# Load Configurations
<#
Usually configuration is imported after most of the module has been imported.
This module is an exception to this, as some of its tasks are performed on import.
#>
(Get-ChildItem "$moduleRoot\internal\configurations\*.ps1" -ErrorAction Ignore).FullName

# Load additional resources needed during import
#"$($moduleRoot)\internal\scripts\initialize.ps1"