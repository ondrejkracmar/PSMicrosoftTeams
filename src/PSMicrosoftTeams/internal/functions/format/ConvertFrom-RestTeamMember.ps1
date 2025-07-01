
function ConvertFrom-RestTeamMember {
	<#
	.SYNOPSIS
		Converts user objects to look nice.

	.DESCRIPTION
		Converts user objects to look nice.

	.PARAMETER InputObject
		The rest response representing a user

	.EXAMPLE
		PS C:\> Invoke-RestRequest -Service 'graph' -Path users -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestUser

		Retrieves the specified user and converts it into something userfriendly

	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	begin {

	}
	process {
		if ((-not $InputObject) -or ([string]::IsNullOrEmpty($InputObject.id)) ) { return }


		[PSCustomObject]@{
			PSTypeName   = 'PSMicrosoftEntraID.User'
			Id           = $InputObject.UserId
			DisplayName  = $InputObject.displayName
			Mail         = $InputObject.email
			MembershipId = $InputObject.Id
			Roles        = $InputObject.roles
		}
	}
}