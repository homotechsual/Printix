function Get-PrintixPartnerTenantBillingInfo {
	<#
	.SYNOPSIS
		Retrieves billing information for a partner-managed tenant.
	.DESCRIPTION
		Required application type: partner API credentials issued by Printix.
		Returns the billing resource with current and previous billing periods,
		HAL links and current_user_licenses when supplied by the service.
	.PARAMETER PartnerId
		The partner ID, defaulting to the partner connection's ID.
	.PARAMETER TenantId
		The managed tenant ID.
	.EXAMPLE
		Get-PrintixPartnerTenantBillingInfo -TenantId $tenantId
	.LINK
		https://printix.github.io/partner-api/#_billing_information
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$PartnerId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$TenantId
	)
	$resource = New-PrintixResource -Template '{PartnerId}/tenants/{TenantId}/billing-info' -Parameters $PSBoundParameters -Partner
	Invoke-PrintixPartnerRequest -Resource $resource
}
