<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration

#>


$script:ModuleName = 'PSMicrosoftTeams'

Set-PSFConfig -Module $script:ModuleName -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module $script:ModuleName -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.Command.RetryWaitInSeconds' -Value 0 -Initialize -Validation 'integer' -Description "Value of parameter RetryWait in the Invoke-PSFProtectedCommand."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.Command.RetryCount' -Value 0 -Initialize -Validation 'integer' -Description "Value of parameter RetryCount in the Invoke-PSFProtectedCommand."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.DefaultService' -Value $script:_DefaultService -Initialize -Validation 'string' -Description "What service name of Microsoft EntraID."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Format' -Value 'json' -Initialize -Validation 'string' -Description "Specifies the media format of the items returned from Microsoft Graph Api."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Query.Level' -Value 'Default' -Initialize -Validation 'string' -Description "Query capabilities level (Default/Advanced). Default value is Default."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Query.AdvancedQueryCapabilities.ConsistencyLevel ' -Value 'eventual' -Initialize -Validation 'string' -Description "Advanced query capabilities ConsistencyLevel settings."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.PageSize' -Value 100 -Initialize -Validation 'integer' -Description "Value of parameter PageSize invoke rest query."

Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.Team' -Value @('id', 'displayName', 'description') -Initialize -Validation 'stringarray' -Description "Specifies uery parameter to return a set of properties that are different than the default set for an individual resource or a collection of resources."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.TeamAdditionalProperty' -Value @('id', 'classification', 'classSettings', 'createdDateTime', 'description', 'displayName', 'firstChannelName', 'funSettings', 'guestSettings', 'internalId', 'isArchived', 'memberSettings', 'messagingSettings', 'specialization', 'summary', 'tenantId', 'visibility', 'webUrl') -Initialize -Validation 'stringarray' -Description "Specifies uery parameter to return a set of properties that are different than the default set for an individual resource or a collection of resources."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.ConversationMember' -Value @('id', 'displayName', 'email', 'userId', 'roles', 'tenantId') -Initialize  -Validation 'stringarray' -Description "Specifies filter select parameter to return a set of properties for a conversation member resource from Microsoft Graph API, including mail address if available."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.Channel' -Value @('id','displayName','description','email','createdDateTime','isArchived','isFavoriteByDefault','membershipType','tenantId','webUrl','summary') -Initialize  -Validation 'stringarray' -Description "Specifies filter select parameter to return a set of properties for a conversation member resource from Microsoft Graph API, including mail address if available."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.Channel.FileFolder' -Value @('id','name','webUrl','createdDateTime','lastModifiedDateTime','size','parentReference','folder') -Initialize -Validation 'stringarray' -Description "Specifies filter select parameter to return a set of properties for a channel files folder (DriveItem) resource from Microsoft Graph API."
Set-PSFConfig -Module $script:ModuleName -Name 'Settings.GraphApiQuery.Select.User' -Value @('id', 'createdDateTime', 'userPrincipalName', 'mail', 'mailNickname', 'proxyAddresses', 'userType', 'accountEnabled', 'givenName', 'surname', 'displayName', 'employeeId', 'jobTitle', 'department', 'officeLocation', 'companyName', 'city', 'postalCode', 'country', 'usageLocation', 'mobilePhone', 'businessPhones', 'faxNumber', 'assignedLicenses') -Initialize -Validation 'stringarray' -Description "Specifies filter select parameter to return a set of properties that are different than the default set for an individual resource or a collection of resources."