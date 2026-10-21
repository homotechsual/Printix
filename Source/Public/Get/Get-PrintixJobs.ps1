function Get-PrintixJobs {
	<#
	.SYNOPSIS
		Lists jobs owned by the API user.
	.DESCRIPTION
		Lists jobs owned by the API user. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER SortOrder
		The SortOrder value sent to Printix.
	.PARAMETER Page
		The zero-based page number.
	.PARAMETER PageSize
		The number of resources per page.
	.PARAMETER All
		Follow HAL next links and return all pages, starting at Page if specified.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixJobs -TenantId $tenantId
	.LINK
		https://printix.github.io/#_retrieve_jobs
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[ValidateSet('CREATE_TIME', 'CREATE_TIME_DESC', 'STATUS', 'STATUS_DESC', 'TITLE', 'TITLE_DESC')]
		[string]$SortOrder,
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Page,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$PageSize,
		[switch]$All,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/jobs' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ SortOrder = 'sortOrder'; Page = 'page'; PageSize = 'pageSize' }
	$request.ResponseProperty = 'jobs'
	$request.All = $All
	Invoke-PrintixRequest @request
}
