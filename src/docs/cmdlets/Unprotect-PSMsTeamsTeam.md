---
external help file: PSMicrosoftTeams-help.xml
Module Name: PSMicrosoftTeams
online version:
schema: 2.0.0
---

# Unprotect-PSMsTeamsTeam

## SYNOPSIS
Archive team

## SYNTAX

```
Unprotect-PSMsTeamsTeam -Identity <String[]> [-EnableException] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Unarchive MIcrosoft Teams team
      Restore an archived team.
This restores users' ability to send messages and edit the team, abiding by tenant and team settings..

## EXAMPLES

### EXAMPLE 1
```
Unprotect-PSMsTeamsTeam -Identity teamname@contoso.com
```

Unprotect team teamname@contoso.com from Microsoft Teams

## PARAMETERS

### -EnableException
Archive the specified team.
When a team is archived, users can no longer send or like messages on any channel in the team, edit the team's name, description, or other settings, or in general make most changes to the team.
Membership changes to the team continue to be allowed.

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

### -Identity
teamPrincipalName, Mail or Id of the team attribute populated in tenant/directory.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases: Id, TeamId, GroupId, MailNickname

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
