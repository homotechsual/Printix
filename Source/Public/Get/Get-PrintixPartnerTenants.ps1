function Get-PrintixPartnerTenants {
	<#
	.SYNOPSIS
		Lists tenants managed by a Printix partner.
	.DESCRIPTION
		Required application type: partner API credentials issued by Printix.
		Returns active tenants unless IncludeInactive is supplied.
		The Partner API documents no pagination parameters for this operation.
	.PARAMETER PartnerId
		The partner ID. Defaults to the partner selected by Connect-PrintixPartner.
	.PARAMETER IncludeInactive
		Include deactivated and deleted tenants.
	.PARAMETER Raw
		Return the full HAL document rather than its tenants array.
	.EXAMPLE
		Get-PrintixPartnerTenants -IncludeInactive
	.LINK
		https://printix.github.io/partner-api/#_list_tenants
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$PartnerId,
		[switch]$IncludeInactive,
		[switch]$Raw
	)
	$resource = New-PrintixResource -Template '{PartnerId}/tenants' -Parameters $PSBoundParameters -Partner
	Invoke-PrintixPartnerRequest -Resource $resource -Query @{ 'include-inactive' = [bool]$IncludeInactive } -ResponseProperty tenants -Raw:$Raw
}
