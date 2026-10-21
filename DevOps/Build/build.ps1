#Requires -Version 7.0
[CmdletBinding()]
param(
	[ValidateSet('build', 'test', 'updateHelp', 'publish')]
	[string[]]$TaskNames = @('build'),
	[string]$NuGetApiKey
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$config = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'build.config.psd1')
$source = Join-Path $repoRoot 'Source'
$sourceManifest = Join-Path $source $config.ModuleManifest
$manifest = Import-PowerShellDataFile -LiteralPath $sourceManifest
$output = Join-Path $repoRoot $config.OutputDirectory
$builtManifest = Join-Path (Join-Path (Join-Path $output 'Printix') $manifest.ModuleVersion) 'Printix.psd1'

foreach ($task in $TaskNames) {
	switch ($task) {
		'build' {
			Import-Module ModuleBuilder -MinimumVersion 3.2.18 -ErrorAction Stop
			Build-Module -SourcePath $sourceManifest -OutputDirectory $output -VersionedOutputDirectory -PublicFilter $config.PublicFilter -Prefix $config.Prefix
			$null = Test-ModuleManifest -Path $builtManifest -ErrorAction Stop
			Copy-Item -LiteralPath (Join-Path $repoRoot 'LICENSE.md'), (Join-Path $repoRoot 'README.md'), (Join-Path $repoRoot 'CHANGELOG.md') -Destination (Split-Path $builtManifest -Parent) -Force
			Write-Output "Built $builtManifest"
		}
		'test' {
			& (Join-Path $repoRoot 'DevOps\Quality\test.ps1') -UseBuiltModule
		}
		'updateHelp' {
			& (Join-Path $repoRoot 'DevOps\Help\Update-Help.ps1')
		}
		'publish' {
			if ([string]::IsNullOrWhiteSpace($NuGetApiKey)) { throw 'Publishing requires -NuGetApiKey.' }
			if (-not (Test-Path -LiteralPath $builtManifest)) { throw 'Build and test the module before publishing.' }
			Publish-Module -Path (Split-Path $builtManifest -Parent) -Repository PSGallery -NuGetApiKey $NuGetApiKey -ErrorAction Stop
		}
	}
}
