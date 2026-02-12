function ConvertFrom-RestObject {
	<#
	.SYNOPSIS
		Converts a REST API response object into a strongly-typed .NET object.

	.DESCRIPTION
		Generic deserialization function that converts REST API response objects
		into strongly-typed .NET objects using DataContractJsonSerializer.
		Replaces the individual ConvertFrom-Rest* functions with a single reusable implementation.

	.PARAMETER InputObject
		The REST API response object to convert.

	.PARAMETER Type
		The target .NET type to deserialize into.

	.EXAMPLE
		PS C:\> ConvertFrom-RestObject -InputObject $response -Type ([PSMicrosoftTeams.Teams.Team])

		Converts the REST response into a Team object.

	.EXAMPLE
		PS C:\> ConvertFrom-RestObject -InputObject $response -Type ([PSMicrosoftTeams.Members.ConversationMember])

		Converts the REST response into a ConversationMember object.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject,

		[Parameter(Mandatory = $true)]
		[Type]
		$Type
	)

	process {
		if (-not $InputObject) { return }

		$jsonString = $InputObject | ConvertTo-Json -Depth 4
		$targetType = if ($InputObject -is [array]) { $Type.MakeArrayType() } else { $Type }
		$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonString)
		$stream = [System.IO.MemoryStream]::new($byteArray)
		try {
			$serializer = [System.Runtime.Serialization.Json.DataContractJsonSerializer]::new($targetType)
			$serializer.ReadObject($stream)
		}
		finally {
			$stream.Dispose()
		}
	}
}
