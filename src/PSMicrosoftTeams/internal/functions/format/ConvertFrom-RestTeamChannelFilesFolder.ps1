function ConvertFrom-RestTeamChannelFilesFolder {
	<#
	.SYNOPSIS
		Converts a REST API response object representing a team channel files folder into a more user-friendly format.
	
	.DESCRIPTION
		Converts a REST API response object representing a team channel files folder (DriveItem) into a more user-friendly format.

	.PARAMETER InputObject
		The REST API response object that represents a team channel files folder.

	.DESCRIPTION
		This function takes a REST API response object that represents a team channel files folder and converts it into a more user-friendly format. This can be useful for displaying files folder information in a more readable way or for further processing.

	.EXAMPLE
		PS C:\> Invoke-RestRequest -Service 'graph' -Path 'teams/{id}/channels/{id}/filesFolder' -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeamChannelFilesFolder

		Retrieves the specified team channel files folder and converts it into something userfriendly
	#>
	param (
		$InputObject
	)
	
	if (-not $InputObject) { return }
	$jsonString = $InputObject | ConvertTo-Json -Depth 4

	$type = if ($InputObject -is [array]) {
		[PSMicrosoftTeams.Channels.FileFolder.ChannelFileFolder[]]
	}
	else {
		[PSMicrosoftTeams.Channels.FileFolder.ChannelFileFolder]
	}
	
	$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonString)
	$stream = [System.IO.MemoryStream]::new($byteArray)
	$serializer = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($type)
	return $serializer.ReadObject($stream)
}