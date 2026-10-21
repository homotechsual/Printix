#Requires -Version 7.0
[CmdletBinding()]
param(
	[switch]$UseBuiltModule,
	[switch]$SkipScriptAnalyzer
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Import-Module Pester -RequiredVersion 6.2.0 -ErrorAction Stop
if (-not $SkipScriptAnalyzer) {
	& (Join-Path $PSScriptRoot 'run-pssa.ps1')
}
$manifest = Join-Path $repoRoot 'Source\Printix.psd1'
if ($UseBuiltModule) {
	$version = (Import-PowerShellDataFile -LiteralPath $manifest).ModuleVersion
	$manifest = Join-Path $repoRoot "Output\Printix\$version\Printix.psd1"
	if (-not (Test-Path -LiteralPath $manifest)) { throw 'Build the module before using -UseBuiltModule.' }
}
$previousManifest = $env:PRINTIX_MODULE_MANIFEST
try {
	Get-Module -Name Printix -All | Remove-Module -Force -ErrorAction Stop
	$env:PRINTIX_MODULE_MANIFEST = $manifest
	$config = New-PesterConfiguration
	$config.Run.Path = Join-Path $repoRoot 'Tests'
	$config.Run.PassThru = $true
	$config.Output.Verbosity = 'Detailed'
	$config.TestResult.Enabled = $true
	$config.TestResult.OutputPath = Join-Path $repoRoot '.artifacts\TestResults.xml'
	$result = Invoke-Pester -Configuration $config
	if ($result.FailedCount -gt 0 -or $result.TotalCount -eq 0 -or $result.Result -ne 'Passed') {
		throw "Pester failed: $($result.Result); $($result.FailedCount) failures out of $($result.TotalCount) tests."
	}
} finally {
	$env:PRINTIX_MODULE_MANIFEST = $previousManifest
}
