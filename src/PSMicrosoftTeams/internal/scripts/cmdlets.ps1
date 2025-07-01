<#
Registers the cmdlets published by this module.
Necessary for full hybrid module support.
#>
$commonParam = @{
	Module = $ExecutionContext.SessionState.Module
}

Import-PSFCmdlet @commonParam -Name New-PSMsTeamsBatchRequest -Type ([PSMicrosoftTeams.Commands.NewPSMsTeamsBatchRequest])

#Set-Alias -Name Sort-PSFObject -Value Set-PSFObjectOrder -Force -ErrorAction SilentlyContinue