---
external help file: PSMicrosoftTeams-help.xml
Module Name: PSMicrosoftTeams
online version:
schema: 2.0.0
---

# New-PSMsTeamsTeam

## SYNOPSIS
Create new  Microsoft Teams team.

## SYNTAX

### Team (Default)
```
New-PSMsTeamsTeam -DisplayName <String> [-Description <String>] [-MailNickName <String>]
 [-MailEnabled <Boolean>] [-Classification <String>] [-Visibility <String>] [-Template <String>]
 -Owners <String[]> [-Members <String[]>] [-AllowGiphy <Boolean>] [-GiphyContentRating <String>]
 [-AllowStickersAndMemes <Boolean>] [-AllowCustomMemes <Boolean>] [-AllowGuestCreateUpdateChannels <Boolean>]
 [-AllowGuestDeleteChannels <Boolean>] [-AllowCreateUpdateChannels <Boolean>] [-AllowDeleteChannels <Boolean>]
 [-AllowAddRemoveApps <Boolean>] [-AllowCreateUpdateRemoveTabs <Boolean>]
 [-AllowCreateUpdateRemoveConnectors <Boolean>] [-AllowUserEditMessages <Boolean>]
 [-AllowUserDeleteMessages <Boolean>] [-AllowOwnerDeleteMessages <Boolean>] [-AllowTeamMentions <Boolean>]
 [-AllowChannelMentions <Boolean>] [-ShowInTeamsSearchAndSuggestions <Boolean>] [-EnableException]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Identity
```
New-PSMsTeamsTeam -Identity <String> [-Template <String>] [-AllowGiphy <Boolean>]
 [-GiphyContentRating <String>] [-AllowStickersAndMemes <Boolean>] [-AllowCustomMemes <Boolean>]
 [-AllowGuestCreateUpdateChannels <Boolean>] [-AllowGuestDeleteChannels <Boolean>]
 [-AllowCreateUpdateChannels <Boolean>] [-AllowDeleteChannels <Boolean>] [-AllowAddRemoveApps <Boolean>]
 [-AllowCreateUpdateRemoveTabs <Boolean>] [-AllowCreateUpdateRemoveConnectors <Boolean>]
 [-AllowUserEditMessages <Boolean>] [-AllowUserDeleteMessages <Boolean>] [-AllowOwnerDeleteMessages <Boolean>]
 [-AllowTeamMentions <Boolean>] [-AllowChannelMentions <Boolean>] [-ShowInTeamsSearchAndSuggestions <Boolean>]
 [-EnableException] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create new  Microsoft Teams team.

## EXAMPLES

### EXAMPLE 1
```
New-PSMsTeamsTeam -DisplayName 'New Team' -Description 'Description of new team'
```

Create new Microsoft Teams team

## PARAMETERS

### -AllowAddRemoveApps
Boolean value that determines whether or not members (not only owners) are allowed to add apps to the team.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowChannelMentions
Boolean value that determines whether or not channels in the team can be @ mentioned so that all users who follow the channel are notified.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowCreateUpdateChannels
Setting that determines whether or not members (and not just owners) are allowed to create channels.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowCreateUpdateRemoveConnectors
Setting that determines whether or not members (and not only owners) can manage connectors in the team.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowCreateUpdateRemoveTabs
Setting that determines whether or not members (and not only owners) can manage tabs in channels.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowCustomMemes
Allow custom memes.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowDeleteChannels
Setting that determines whether or not members (and not only owners) can delete channels in the team.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowGiphy
Eable giphy for team.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowGuestCreateUpdateChannels
Setting that determines whether or not guests can create channels in the team.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowGuestDeleteChannels
Setting that determines whether or not guests can delete in the team.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowOwnerDeleteMessages
Setting that determines whether or not owners can delete messages that they or other members of the team have posted.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowStickersAndMemes
Enable Stickers and memes.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowTeamMentions
Setting that determines whether the entire team can be @ mentioned (which means that all users will be notified).

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowUserDeleteMessages
Setting that determines whether or not members can delete messages that they have posted.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowUserEditMessages
Setting that determines whether or not users can edit messages that they have posted.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Classification
Describes a classification for the team.

```yaml
Type: System.String
Parameter Sets: Team
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Description
The description for the team.

```yaml
Type: System.String
Parameter Sets: Team
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DisplayName
The display name for the team.

```yaml
Type: System.String
Parameter Sets: Team
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EnableException
This parameters disables user-friendly warnings and enables the throwing of exceptions.
This is less user frien
dly, but allows catching exceptions in calling scripts.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GiphyContentRating
Rating for giphy.
Can be "Strict" or "Moderate".

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity
MailnicName, Mail.

```yaml
Type: System.String
Parameter Sets: Identity
Aliases: Id, GroupId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MailEnabled
Specifies whether the group is mail-enabled.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: Team
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MailNickName
The mail alias for the team, unique for Microsoft 365 groups in the organization.
Maximum length is 64 characters.

```yaml
Type: System.String
Parameter Sets: Team
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Members
List of mwmwbrs of new team.

```yaml
Type: System.String[]
Parameter Sets: Team
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Owners
List of owners of new team.

```yaml
Type: System.String[]
Parameter Sets: Team
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: System.Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowInTeamsSearchAndSuggestions
The parameter has been deprecated.

```yaml
Type: System.Nullable`1[System.Boolean]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Template
Specifies team template.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Visibility
Specifies the team join policy and team content visibility for groups.
Possible values are: Private, Public, or HiddenMembership.

```yaml
Type: System.String
Parameter Sets: Team
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Confirm
The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
The command then prompts you to acknowledge each action before it continues.
When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.
This functionality is useful when you apply changes to many objects and want precise control over the operation of the Shell.
A confirmation prompt is displayed for each object before the Shell modifies the object.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Enables the function to simulate what it will do instead of actually executing.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
