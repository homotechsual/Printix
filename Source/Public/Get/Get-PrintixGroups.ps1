function Get-PrintixGroups {
	<#
	.SYNOPSIS
		Lists or searches groups.
	.DESCRIPTION
		Lists or searches groups. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Query
		The server-side search string.
	.PARAMETER Page
		The zero-based page number.
	.PARAMETER PageSize
		The number of resources per page.
	.PARAMETER All
		Follow HAL next links and return all pages, starting at Page if specified.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixGroups -TenantId $tenantId
	.LINK
		https://printix.github.io/#_listing_and_searching_groups
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Page,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$PageSize,
		[switch]$All,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/groups' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Query = 'query'; Page = 'page'; PageSize = 'pageSize' }
	$request.ResponseProperty = 'groups'
	$request.All = $All
	Invoke-PrintixRequest @request
}
