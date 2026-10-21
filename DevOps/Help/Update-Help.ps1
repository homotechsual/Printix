#Requires -Version 7.0
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Import-Module platyPS -RequiredVersion 0.14.2 -ErrorAction Stop
Import-Module (Join-Path $repoRoot 'Source\Printix.psd1') -Force -ErrorAction Stop
$outputFolder = Join-Path $repoRoot 'docs\Printix\commandlets'
$stagingFolder = Join-Path $repoRoot '.artifacts\HelpMarkdown'
New-MarkdownHelp -Module Printix -OutputFolder $stagingFolder -Force -ErrorAction Stop | Out-Null
foreach ($file in Get-ChildItem -LiteralPath $stagingFolder -Filter '*.md' -File) {
	$content = Get-Content -LiteralPath $file.FullName -Raw
	# platyPS 0.14 predates the ProgressAction common parameter.
	$content = $content.Replace('{{ Fill ProgressAction Description }}', 'Controls progress-record handling. Available in PowerShell 7.4 and later.')
	if ($content -match '\{\{') { throw "Unresolved help placeholder in $($file.Name)." }
	$content = $content -replace '(?s)\A---\r?\n.*?\r?\n---\r?\n', ''
	$content = $content -replace '\A\s*# [^\r\n]+\r?\n', ''
	$frontMatter = @(
		'---'
		"title: $($file.BaseName)"
		'hide_title: false'
		'hide_table_of_contents: false'
		'---'
		''
		':::powershell[Generated Cmdlet Help]'
		'This page is generated from the Printix module. Edit the corresponding PowerShell source to update it.'
		':::'
		''
	) -join "`n"
	$inFence = $false
	$lines = foreach ($line in ($content -split '\r?\n')) {
		if ($line -match '^```') {
			$inFence = -not $inFence
			if ($inFence -and $line -eq '```') { $line = '```powershell' }
			$line
		} elseif ($inFence) {
			$line
		} else {
			# Escape JSX delimiters in prose, but preserve inline code.
			$segments = [regex]::Split($line, '(`[^`]*`)')
			for ($index = 0; $index -lt $segments.Length; $index += 2) {
				$segments[$index] = $segments[$index].Replace('{', '&#123;').Replace('}', '&#125;').Replace('<', '&lt;').Replace('>', '&gt;')
			}
			$segments -join ''
		}
	}
	$category = (Get-ChildItem -LiteralPath (Join-Path $repoRoot 'Source\Public') -Recurse -Filter "$($file.BaseName).ps1" -File).Directory.Name
	if (-not $category) { throw "No public source found for $($file.BaseName)." }
	$destination = Join-Path $outputFolder $category
	$null = New-Item -Path $destination -ItemType Directory -Force
	$mdxPath = Join-Path $destination "$($file.BaseName).mdx"
	[IO.File]::WriteAllText($mdxPath, $frontMatter + ($lines -join "`n"), [Text.UTF8Encoding]::new($false))
	$legacyPath = Join-Path $outputFolder $file.Name
	if (Test-Path -LiteralPath $legacyPath) {
		Remove-Item -LiteralPath $legacyPath -ErrorAction Stop
	}
	Remove-Item -LiteralPath $file.FullName -ErrorAction Stop
}
