Register-PSFConfigValidation -Name "PSMicrosoftTeams.apiversion"  -ScriptBlock {
	Param (
		$Value
	)
	
	$Result = New-Object PSOBject -Property @{
		Success = $True
		Value = $null
		Message = ""
	}
	$stringValue = $Value -as [string]
    try
    {
        if(($stringValue -in @('v1.0','beta')) -eq $false)
        {
            $Result.Message = "Not an graphapiversion: $Value"
		    $Result.Success = $False
        }
    }
	catch
	{
		$Result.Message = "Not an graphapiversion: $Value"
		$Result.Success = $False
		return $Result
	}
	$Result.Value = $Value
	return $Result
}