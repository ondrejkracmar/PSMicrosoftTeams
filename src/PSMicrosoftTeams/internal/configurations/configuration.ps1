﻿<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

#Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
#Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.GraphApiVersion' -Value "beta" -Initialize -Validation 'string' -Description "What version of Graph API module is useing."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.GraphApiUrl' -Value "https://graph.microsoft.com" -Initialize -Validation 'string' -Description "What url of Graph API module is useing."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.AuthUrl' -Value "https://login.microsoftonline.com" -Initialize -Validation 'string' -Description "What url authentication of Graph API module is useing."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.InvokeRestMethodRetryCount' -Value 10 -Initialize -Validation 'integer' -Description "Specifies how many times PowerShell retries a connection when a failure code between 400 and 599, inclusive or 304 is received."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.InvokeRestMethodRetryTimeSec' -Value 10 -Initialize -Validation 'integer' -Description "Specifies how many times PowerShell retries a connection when a failure code between 400 and 599, inclusive or 304 is received."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.PostConrtentType' -Value 'application/json' -Initialize -Validation 'string' -Description "Specifies post content type of rest method."
Set-PSFConfig -Module 'PSMicrosoftTeams' -Name 'Settings.AuthorizationToken' -Value '' -Initialize -Validation 'string' -Description "Specifies the last authorization token of GRAPH APU to Office 65 Teams."