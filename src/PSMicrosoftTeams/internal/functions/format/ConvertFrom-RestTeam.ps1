function ConvertFrom-RestTeam {
    <#
	.SYNOPSIS
		Converts team objects to look nice.

	.DESCRIPTION
		Converts team objects to look nice.

	.PARAMETER InputObject
		The rest response representing a tea

	.EXAMPLE
		PS C:\> Invoke-RestRequest -Service 'graph' -Path users -Query $query -Method Get -ErrorAction Stop | ConvertFrom-RestTeam

		Retrieves the specified team and converts it into something userfriendly

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
            PSTypeName      = 'PSMicrosoftTeams.Team'
            Id              = $InputObject.id
            CreatedDateTime = $InputObject.createdDateTime
            MailNickname    = $InputObject.mailNickname
            Mail            = $InputObject.mail
            ProxyAddresses  = $InputObject.proxyAddresses
            MailEnabled     = $InputObject.mailEnabled
            Visibility      = $InputObject.visibility
            DisplayName     = $InputObject.displayName
            Description     = $InputObject.description
            GropupTypes     = $InputObject.groupTypes
        }

    }
}