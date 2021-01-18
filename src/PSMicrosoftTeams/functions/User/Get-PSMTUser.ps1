function Get-PSMTUser
{
<#
    .SYNOPSIS
        Get the properties of the specified user.
                
    .DESCRIPTION
        Get the properties of the specified user.
                
    .PARAMETER UserPrincipalName
        UserPrincipalName
#>
    [CmdletBinding(DefaultParameterSetName = 'FilterByName',
        SupportsShouldProcess = $false,
        PositionalBinding = $true,
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'FilterByUserPrincipalName')]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'FilterByName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'Filter')]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'All')]
        [switch]$All,
        [Parameter(Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        ValueFromRemainingArguments = $false)]
        [ValidateRange(5, 100)]
        [int]$PageSize
    )
     
    begin
    {
        try {
            $url = Join-UriPath -Uri (Get-GraphApiUriPath) -ChildPath "users"
            $authorizationToken = Receive-PSMTAuthorizationToken
            $select = (Get-PSFConfigValue -FullName PSMicrosoftTeams.Settings.GraphApiQuery.Select.User) -join ","
	    } catch {
            Stop-PSFFunction -Message "Failed to receive uri $url." -ErrorRecord $_
        }
    }
    
    process
    {
        if (Test-PSFFunctionInterrupt) { return }
        Try
        {
            $graphApiParameters=@{
                Method = 'Get'
                AuthorizationToken = "Bearer $authorizationToken"
                Select = $select
            }

            if(Test-PSFParameterBinding -Parameter UserPrincipalName) {
                $urlUser = Join-UriPath -Uri $url -ChildPath $UserPrincipalName
                $graphApiParameters['Uri'] = $urlUser
            }

            if(Test-PSFParameterBinding -Parameter Name) {
                $graphApiParameters['Uri'] = $url
                $graphApiParameters['Filter'] = ("startswith(displayName,'{0}') or startswith(givenName,'{0}') or startswith(surname,'{0}') or startswith(mail,'{0}') or startswith(userPrincipalName,'{0}')" -f $Name)
            }

            if(Test-PSFParameterBinding -Parameter Filter)
            {
                $graphApiParameters['Uri'] = $url
                $graphApiParameters['Filter'] = $Filter
            }

            if(Test-PSFParameterBinding -Parameter All)
            {
                $graphApiParameters['Uri'] = $url
                $graphApiParameters['All'] = $true
            }

            if(Test-PSFParameterBinding -Parameter All PageSize)
            {
                $graphApiParameters['Top'] = $PageSize
            }

            $userResult = Invoke-GraphApiQuery @graphApiParameters
            return $userResult | Select-PSFObject -Property * -ExcludeProperty '@odata*' -TypeName 'PSMicrosoftTeams.User'
        }
        catch
        {
           Write-PSFMessage -Level Warning -String 'FailedGetUser' -StringValues $UserPrincipalName  -ErrorRecord $_
        }
    }
}