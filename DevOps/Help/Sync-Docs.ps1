#Requires -Version 7.0
[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[string]$SourcePath,
	[Parameter(Mandatory)]
	[string]$DocsRepositoryPath,
	[switch]$DevelopmentOnly
)

$ErrorActionPreference = 'Stop'
$sourceRoot = (Resolve-Path -LiteralPath $SourcePath).Path
$repositoryRoot = (Resolve-Path -LiteralPath $DocsRepositoryPath).Path
$targetRoot = Join-Path $repositoryRoot 'docs\printix'
if ($DevelopmentOnly) {
	$sourceRoot = Join-Path $sourceRoot 'development'
	$targetRoot = Join-Path $targetRoot 'development'
}
if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot 'index.mdx') -PathType Leaf)) {
	throw 'Documentation source must contain index.mdx.'
}
$files = @(Get-ChildItem -LiteralPath $sourceRoot -Recurse -File)
if ($files | Where-Object { $_.Extension -ne '.mdx' }) {
	throw 'The documentation artifact must contain MDX documents only.'
}
if (Get-ChildItem -LiteralPath $sourceRoot -Recurse -Attributes ReparsePoint) {
	throw 'Documentation source must not contain symbolic links or junctions.'
}
$ancestors = @($repositoryRoot, (Join-Path $repositoryRoot 'docs'), (Join-Path $repositoryRoot 'docs\printix'), $targetRoot) | Select-Object -Unique
foreach ($directory in $ancestors) {
	if ((Test-Path -LiteralPath $directory) -and ((Get-Item -LiteralPath $directory).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
		throw 'Documentation destination must not contain symbolic links or junctions.'
	}
}
if ((Test-Path -LiteralPath $targetRoot) -and (Get-ChildItem -LiteralPath $targetRoot -Recurse -Attributes ReparsePoint)) {
	throw 'Documentation destination must not contain symbolic links or junctions.'
}
$null = New-Item -Path $targetRoot -ItemType Directory -Force
$relativePaths = @($files | ForEach-Object { [IO.Path]::GetRelativePath($sourceRoot, $_.FullName) })
foreach ($file in $files) {
	$relativePath = [IO.Path]::GetRelativePath($sourceRoot, $file.FullName)
	$destination = Join-Path $targetRoot $relativePath
	$null = New-Item -Path (Split-Path $destination -Parent) -ItemType Directory -Force
	Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
}
foreach ($existing in Get-ChildItem -LiteralPath $targetRoot -Recurse -File | Where-Object Extension -In @('.md', '.mdx')) {
	if ([IO.Path]::GetRelativePath($targetRoot, $existing.FullName) -notin $relativePaths) {
		Remove-Item -LiteralPath $existing.FullName -ErrorAction Stop
	}
}
