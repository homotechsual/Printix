#Requires -Version 7.0
[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[string]$RefName,
	[Parameter(Mandatory)]
	[string]$Commit
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$manifest = Import-PowerShellDataFile -LiteralPath (Join-Path $repoRoot 'Source\Printix.psd1')
if ($RefName -ne 'main' -and $RefName -cne "v$($manifest.ModuleVersion)") {
	throw "Publish from main or the matching stable tag v$($manifest.ModuleVersion). Prerelease tags are not currently supported."
}
& git -C $repoRoot merge-base --is-ancestor $Commit origin/main
if ($LASTEXITCODE -ne 0) { throw 'The release commit must be reachable from origin/main.' }
