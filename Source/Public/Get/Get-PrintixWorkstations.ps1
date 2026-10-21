function Get-PrintixWorkstations {
	<#
	.SYNOPSIS
		Lists or searches monitored workstations.
	.DESCRIPTION
		Lists or searches monitored workstations. Uses the documented Printix Cloud Print API.
		Required application type: Workstation monitoring, not Cloud Print API or User manager.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Query
		The server-side search string.
	.PARAMETER WorkstationIds
		The WorkstationIds value sent to Printix.
	.PARAMETER Page
		The zero-based page number.
	.PARAMETER PageSize
		The number of resources per page.
	.PARAMETER All
		Follow HAL next links and return all pages, starting at Page if specified.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixWorkstations -TenantId $tenantId
	.LINK
		https://printix.github.io/#_query_workstations
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		[string[]]$WorkstationIds,
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Page,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$PageSize,
		[switch]$All,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/workstations' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Query = 'query'; WorkstationIds = 'workstations'; Page = 'page'; PageSize = 'pageSize' }
	$request.ResponseProperty = 'workstations'
	$request.All = $All
	Invoke-PrintixRequest @request
}
