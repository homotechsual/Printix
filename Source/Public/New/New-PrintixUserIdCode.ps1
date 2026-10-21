function New-PrintixUserIdCode {
	<#
	.SYNOPSIS
		Generates or replaces a user's ID code.
	.DESCRIPTION
		Generates or replaces a user's ID code. Uses the documented Printix Cloud Print API.
		Required application type: Card registration (API terminology), not User manager.
		The API uses Card registration while the Administrator UI shown uses Card manager;
		confirm the matching application in your tenant rather than treating the labels as scopes.
		This operation replaces any existing ID code.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER UserId
		The UserId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		New-PrintixUserIdCode -TenantId $tenantId -UserId $userId
	.LINK
		https://printix.github.io/#_generate_id_code
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$UserId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/users/{UserId}/idCode' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'New-PrintixUserIdCode')) {
		Invoke-PrintixRequest @request
	}
}
