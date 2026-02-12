[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param (
	$TestGeneral = $true,
	
	$TestFunctions = $false,
	
	[ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
	[Alias('Show')]
	$Output = "None",
	
	$Include = "*",
	
	$Exclude = ""
)

Write-PSFMessage -Level Important -Message "Starting Tests"

Write-PSFMessage -Level Important -Message "Importing Module"

$global:testroot = $PSScriptRoot
$global:__pester_data = @{ }

Remove-Module PSMicrosoftTeams -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\PSMicrosoftTeams\PSMicrosoftTeams.psd1"
Import-Module "$PSScriptRoot\..\PSMicrosoftTeams\PSMicrosoftTeams.psm1" -Force

# Register global EntraToken C# stub so Pester mocks can resolve [EntraToken] type
# across session state boundaries (e.g. when called through compiled PSFramework cmdlets)
if (-not ('EntraToken' -as [type])) {
    Add-Type -TypeDefinition @'
public class EntraToken {
    public string AccessToken { get; set; }
    public System.DateTime ValidAfter { get; set; }
    public System.DateTime ValidUntil { get; set; }
    public string[] Scopes { get; set; }
    public string RefreshToken { get; set; }
    public string Audience { get; set; }
    public string Issuer { get; set; }
    public object TokenData { get; set; }
    public string Service { get; set; }
    public string Type { get; set; }
    public string ClientID { get; set; }
    public string TenantID { get; set; }
    public string ServiceUrl { get; set; }
    public string AuthenticationUrl { get; set; }
    public System.Collections.Hashtable Header { get; set; }
    public System.Collections.Hashtable Query { get; set; }
    public bool RawOnly { get; set; }
    public EntraToken() {
        Header = new System.Collections.Hashtable();
        Query = new System.Collections.Hashtable();
    }
    public System.Collections.Hashtable GetHeader() {
        var h = Header != null ? new System.Collections.Hashtable(Header) : new System.Collections.Hashtable();
        h["Authorization"] = "Bearer " + (AccessToken ?? "");
        return h;
    }
}
'@
}

# Need to import explicitly so we can use the configuration class
Import-Module Pester

Write-PSFMessage -Level Important -Message "Creating test result folder"
$null = New-Item -Path "$PSScriptRoot\..\.." -Name TestResults -ItemType Directory -Force

$totalFailed = 0
$totalRun = 0

$testresults = @()
$config = [PesterConfiguration]::Default
$config.TestResult.Enabled = $true

#region Run General Tests
if ($TestGeneral)
{
	Write-PSFMessage -Level Important -Message "Modules imported, proceeding with general tests"
	foreach ($file in (Get-ChildItem "$PSScriptRoot\general" | Where-Object Name -like "*.Tests.ps1"))
	{
		if ($file.Name -notlike $Include) { continue }
		if ($file.Name -like $Exclude) { continue }

		Write-PSFMessage -Level Significant -Message "  Executing <c='em'>$($file.Name)</c>"
		$config.TestResult.OutputPath = Join-Path "$PSScriptRoot\..\..\TestResults" "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
    	$results = Invoke-Pester -Configuration $config
		foreach ($result in $results)
		{
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block    = $_.Block
					Name	 = "It $($_.Name)"
					Result   = $_.Result
					Message  = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Run General Tests
$global:__pester_data.ScriptAnalyzer | Out-Host

#region Test Commands
if ($TestFunctions)
{
	Write-PSFMessage -Level Important -Message "Proceeding with individual tests"
	foreach ($file in (Get-ChildItem "$PSScriptRoot\functions" -Recurse -File | Where-Object Name -like "*Tests.ps1"))
	{
		if ($file.Name -notlike $Include) { continue }
		if ($file.Name -like $Exclude) { continue }
		
		Write-PSFMessage -Level Significant -Message "  Executing $($file.Name)"
		$config.TestResult.OutputPath = Join-Path "$PSScriptRoot\..\..\TestResults" "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
    	$results = Invoke-Pester -Configuration $config
		foreach ($result in $results)
		{
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block    = $_.Block
					Name	 = "It $($_.Name)"
					Result   = $_.Result
					Message  = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Test Commands

$testresults | Sort-Object Describe, Context, Name, Result, Message | Format-List

if ($totalFailed -eq 0) { Write-PSFMessage -Level Critical -Message "All <c='em'>$totalRun</c> tests executed without a single failure!" }
else { Write-PSFMessage -Level Critical -Message "<c='em'>$totalFailed tests</c> out of <c='sub'>$totalRun</c> tests failed!" }

if ($totalFailed -gt 0)
{
	throw "$totalFailed / $totalRun tests failed!"
}