function Get-PrintixUsers {
	<#
	.SYNOPSIS
		Lists normal or guest users.
	.DESCRIPTION
		Lists both normal and guest users by default. Use Role to filter by user type.
		Uses the documented Printix Cloud Print API.
		Required application type: User manager, Cloud Print API, or Card registration (API terminology).
		Requires Printix Premium. Individual user lookup has a different application-type requirement.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Query
		The server-side search string.
	.PARAMETER Role
		The user types to retrieve. Defaults to USER and GUEST_USER, overriding the API's guest-only default.
	.PARAMETER Page
		The zero-based page number.
	.PARAMETER PageSize
		The number of resources per page.
	.PARAMETER All
		Follow HAL next links and return all pages, starting at Page if specified.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixUsers -TenantId $tenantId
	.LINK
		https://printix.github.io/#_list_users
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		[ValidateSet('USER', 'GUEST_USER')]
		[string[]]$Role = @('USER', 'GUEST_USER'),
		[ValidateRange(0, [int]::MaxValue)]
		[int]$Page,
		[ValidateRange(1, [int]::MaxValue)]
		[int]$PageSize,
		[switch]$All,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/users' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Query = 'query'; Role = 'role'; Page = 'page'; PageSize = 'pageSize' }
	$request.Query.role = $Role
	$request.ResponseProperty = 'users'
	$request.All = $All
	Invoke-PrintixRequest @request
}
