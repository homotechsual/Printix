function Get-PrintixPrintQueues {
	<#
	.SYNOPSIS
		Lists print queues and their printer capabilities.
	.DESCRIPTION
		Lists print queues and their printer capabilities. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Query
		The server-side search string.
	.PARAMETER Network
		The Network value sent to Printix.
	.PARAMETER Site
		The Site value sent to Printix.
	.PARAMETER Page
		The zero-based page number.
	.PARAMETER PageSize
		The number of resources per page.
	.PARAMETER All
		Follow HAL next links and return all pages, starting at Page if specified.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixPrintQueues -TenantId $tenantId
	.LINK
		https://printix.github.io/#_list_print_queues
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		[ValidateNotNullOrEmpty()]
		[string]$Network,
		[ValidateNotNullOrEmpty()]
		[string]$Site,
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Page,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$PageSize,
		[switch]$All,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/printers' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Query = 'query'; Network = 'network'; Site = 'site'; Page = 'page'; PageSize = 'pageSize' }
	$request.ResponseProperty = 'printers'
	$request.All = $All
	Invoke-PrintixRequest @request
}
