function Get-PrintixPrinter {
	<#
	.SYNOPSIS
		Retrieves printer properties for a print queue.
	.DESCRIPTION
		Retrieves printer properties for a print queue. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER PrinterId
		The PrinterId path identifier.
	.PARAMETER QueueId
		The QueueId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixPrinter -TenantId $tenantId -PrinterId $printerId -QueueId $queueId
	.LINK
		https://printix.github.io/#_get_printer_properties
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$PrinterId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$QueueId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/printers/{PrinterId}/queues/{QueueId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.ResponseProperty = 'printers'
	Invoke-PrintixRequest @request
}
