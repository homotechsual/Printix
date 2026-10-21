function Get-PrintixPrintQueueJobs {
	<#
	.SYNOPSIS
		Lists jobs for a specific print queue.
	.DESCRIPTION
		Lists jobs for a specific print queue. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER PrinterId
		The PrinterId path identifier.
	.PARAMETER QueueId
		The QueueId path identifier.
	.PARAMETER Page
		The zero-based page number.
	.PARAMETER PageSize
		The number of resources per page.
	.PARAMETER All
		Follow HAL next links and return all pages, starting at Page if specified.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixPrintQueueJobs -TenantId $tenantId -PrinterId $printerId -QueueId $queueId
	.LINK
		https://printix.github.io/#_retrieve_jobs
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
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Page,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$PageSize,
		[switch]$All,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/printers/{PrinterId}/queues/{QueueId}/jobs' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Page = 'page'; PageSize = 'pageSize' }
	$request.ResponseProperty = 'jobs'
	$request.All = $All
	Invoke-PrintixRequest @request
}
