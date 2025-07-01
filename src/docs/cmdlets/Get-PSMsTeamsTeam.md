---
external help file: PSMicrosoftTeams-help.xml
Module Name: PSMicrosoftTeams
online version:
schema: 2.0.0
---

# Get-PSMsTeamsTeam

## SYNOPSIS
Get the properties of the specified team.

## SYNTAX

### Identity (Default)
```
Get-PSMsTeamsTeam -Identity <String[]> [-EnableException] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### DisplayName
```
Get-PSMsTeamsTeam -DisplayName <String[]> [-EnableException] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Filter
```
Get-PSMsTeamsTeam -Filter <String> [-AdvancedFilter] [-EnableException] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### All
```
Get-PSMsTeamsTeam [-All] [-EnableException] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get the properties of the specified team.

## EXAMPLES

### EXAMPLE 1
```
Get-PSMsTeamsTeam -Identity team1
```

Get properties of Microsoft Teams team1

## PARAMETERS

### -AdvancedFilter
Switch advanced filter for filtering accounts in tenant/directory.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Return all accounts in tenant/directory.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
DIsplayName of the group attribute populated in tenant/directory.

```yaml
Type: System.String[]
Parameter Sets: DisplayName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableException
This parameters disables user-friendly warnings and enables the throwing of exceptions.
This is less user friendly,
but allows catching exceptions in calling scripts.

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

### -Filter
Filter expressions of accounts in tenant/directory.

```yaml
Type: System.String
Parameter Sets: Filter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity
MailnicName, Mail or Id of the team attribute populated in tenant/directory.

```yaml
Type: System.String[]
Parameter Sets: Identity
Aliases: Id, GroupId, TeamId, MailNickName

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSMicrosoftTeams.Team
## NOTES

## RELATED LINKS
