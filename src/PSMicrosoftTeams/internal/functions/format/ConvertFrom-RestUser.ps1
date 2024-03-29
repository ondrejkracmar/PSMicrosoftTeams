function ConvertFrom-RestUser {
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
			PSTypeName        = 'PSMicrosoftEntraID.User'
			Id                = $InputObject.id
			UserPrincipalName = $InputObject.userPrincipalName
			CreatedDateTime   = $InputObject.createdDateTime
			Mail              = $InputObject.mail
			MailNickname      = $InputObject.mailNickname
			ProxyAddresses    = $InputObject.proxyAddresses
			UserType          = $InputObject.userType
			AccountEnabled    = $InputObject.accountEnabled
			GivenName         = $InputObject.givenName
			Surname           = $InputObject.surname
			DisplayName       = $InputObject.displayName
			EmployeeId        = $InputObject.employeeId
			JobTitle          = $InputObject.jobTitle
			Department        = $InputObject.department
			OfficeLocation    = $InputObject.officeLocation
			CompanyName       = $InputObject.companyName
			City              = $InputObject.city
			PostalCode        = $InputObject.postalCode
			Country           = $InputObject.Country
			UsageLocation     = $InputObject.usageLocation
			MobilePhone       = $InputObject.mobilePhone
			BusinessPhones    = $InputObject.businessPhones
			FaxNumber         = $InputObject.faxNumber
		}
	}
}