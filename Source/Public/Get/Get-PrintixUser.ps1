function Get-PrintixUser {
	<#
	.SYNOPSIS
		Retrieves a user by ID.
	.DESCRIPTION
		Retrieves a user by ID. Uses the documented Printix Cloud Print API.
		Required application type: Card registration (API terminology). Requires Printix Premium.
		User manager is not listed for this endpoint, even though it can list users.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER UserId
		The UserId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixUser -TenantId $tenantId -UserId $userId
	.LINK
		https://printix.github.io/#_find_user_by_id
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$UserId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/users/{UserId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.ResponseProperty = 'user'
	Invoke-PrintixRequest @request
}
