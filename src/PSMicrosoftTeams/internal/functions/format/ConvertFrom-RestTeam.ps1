function ConvertFrom-RestTeam {
	<#
	.SYNOPSIS
		Converts a REST API response object representing a group into a more user-friendly format.
	
	.DESCRIPTION
		Converts a REST API response object representing a group into a more user-friendly format.

	.PARAMETER InputObject
		The REST API response object that represents a group.

	.DESCRIPTION
		This function takes a REST API response object that represents a group and converts it into a more user-friendly format. This can be useful for displaying group information in a more readable way or for further processing.

	.EXAMPLE
		PS C:\> Invoke-RestRequest -Service 'graph' -Path users -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeam

		Retrieves the specified user and converts it into something userfriendly
	#>
	param (
		$InputObject
	)
	
	if (-not $InputObject) { return }
	$jsonString = $InputObject | ConvertTo-Json -Depth 4

	$type = if ($InputObject -is [array]) {
		[PSMicrosoftTeams.Teams.Team[]]
	}
	else {
		[PSMicrosoftTeams.Teams.Team]
	}
	
	$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonString)
	$stream = [System.IO.MemoryStream]::new($byteArray)
	$serializer = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($type)
	return $serializer.ReadObject($stream)
}