#Requires -Version 7.0
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Import-Module PSScriptAnalyzer -MinimumVersion 1.25.0 -ErrorAction Stop
$settings = Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'
$results = @(
	foreach ($directory in @('Source', 'DevOps')) {
		Invoke-ScriptAnalyzer -Path (Join-Path $repoRoot $directory) -Recurse -Settings $settings
	}
)
if ($results.Count) {
	$results | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize | Out-Host
	throw "PSScriptAnalyzer reported $($results.Count) issue(s)."
}
