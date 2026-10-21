#Requires -Version 7.0
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'Initialisation.ps1')
foreach ($directory in @('Private', 'Public')) {
	foreach ($file in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot $directory) -Filter '*.ps1' -Recurse | Sort-Object FullName) {
		. $file.FullName
	}
}
$publicFunctions = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -Recurse
Export-ModuleMember -Function $publicFunctions.BaseName
