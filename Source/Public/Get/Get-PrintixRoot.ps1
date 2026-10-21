function Get-PrintixRoot {
	<#
	.SYNOPSIS
		Retrieves the API entry point and accessible tenant links.
	.DESCRIPTION
		Retrieves the API entry point and accessible tenant links. Uses the documented Printix Cloud Print API.
		Required application type: any Printix application type.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixRoot
	.LINK
		https://printix.github.io/#_root_request
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[switch]$Raw
	)

	$resource = 'https://api.printix.net/cloudprint'
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	Invoke-PrintixRequest @request
}
