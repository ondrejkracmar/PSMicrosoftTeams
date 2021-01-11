@{
	# Script module or binary module file associated with this manifest
	RootModule = 'PSMicrosoftTeams.psm1'
	
	# Version number of this module.
	ModuleVersion = '1.0.0'
	
	# ID used to uniquely identify this module
	GUID = '68aff6a6-275a-40e9-adc0-f2ff32ce35b5'
	
	# Author of this module
	Author = 'KracmarOndrej'
	
	# Company or vendor of this module
	CompanyName = 'MyCompany'
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2020 KracmarOndrej'
	
	# Description of the functionality provided by this module
	Description = 'Powershell module for managing Microsoft Teams'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.4.150' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\PSMicrosoftTeams.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\PSMicrosoftTeams.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\PSMicrosoftTeams.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Add-PSMTTeamUser',
		'Get-PSMTTeam',
		'Get-PSMTTeamUser',
		'New-PSMTTeam',
		'Get-PSMTUser',
		'Remove-PSMTTeam',
		'Remove-PSMTTeamUser',
		"Get-PSMTRequestStatus",
		'Receive-PSMTAuthorizationToken',
		'Write-PSMTAuthorizationToken',
		'Get-PSMTUser'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}