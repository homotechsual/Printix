#Requires -Version 7.0
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$requirements = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RequiredModules.psd1')
foreach ($name in $requirements.Keys) {
	$version = $requirements[$name]
	if (-not (Get-Module -ListAvailable -Name $name | Where-Object Version -EQ ([version]$version))) {
		Install-Module -Name $name -RequiredVersion $version -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
	}
}
