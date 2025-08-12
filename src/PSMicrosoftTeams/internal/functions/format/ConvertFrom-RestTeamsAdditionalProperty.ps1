function ConvertFrom-RestTeamAdditionalProperty {
    <#
	.SYNOPSIS
		Converts additional group properties objects to look nice.

	.DESCRIPTION
		Converts additional group properties objects to look nice.

	.PARAMETER InputObject
		The rest response representing a additional group properties

	.EXAMPLE
		PS C:\> Invoke-RestRequest -Service 'graph' -Path teams -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeamAdditionalProperty

		Retrieves the specified additional group properties and converts it into something userfriendly

	#>
	param (
		$InputObject
	)

	if (-not $InputObject) { return }
	$jsonString = $InputObject | ConvertTo-Json -Depth 4

	$type = if ($InputObject -is [array]) {
		[PSMicrosoftTeams.Teams.TeamAdditionalProperty[]]
	}
	else {
		[PSMicrosoftTeams.Teams.TeamAdditionalProperty]
	}

	$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonString)
	$stream = [System.IO.MemoryStream]::new($byteArray)
	$serializer = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($type)
	return $serializer.ReadObject($stream)
}