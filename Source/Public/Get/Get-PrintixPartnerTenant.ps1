function Get-PrintixPartnerTenant {
	<#
	.SYNOPSIS
		Retrieves a partner-managed tenant.
	.DESCRIPTION
		Required application type: partner API credentials issued by Printix.
		Returns the tenant HAL resource, optionally including _embedded.billing_info.
	.PARAMETER PartnerId
		The partner ID, defaulting to the partner connection's ID.
	.PARAMETER TenantId
		The managed tenant ID. Not taken from the Cloud Print connection.
	.PARAMETER EmbedBillingInfo
		Request embed=billing-info to include billing information in the tenant response.
	.EXAMPLE
		Get-PrintixPartnerTenant -TenantId $tenantId -EmbedBillingInfo
	.LINK
		https://printix.github.io/partner-api/#_interacting_with_a_single_tenant
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$PartnerId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[switch]$EmbedBillingInfo
	)
	$resource = New-PrintixResource -Template '{PartnerId}/tenants/{TenantId}' -Parameters $PSBoundParameters -Partner
	$query = @{}
	if ($EmbedBillingInfo) { $query.embed = 'billing-info' }
	Invoke-PrintixPartnerRequest -Resource $resource -Query $query
}
