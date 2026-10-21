function Get-PrintixNetwork {
	<#
	.SYNOPSIS
		Retrieves a Network resource.
	.DESCRIPTION
		Retrieves a Network resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER NetworkId
		The NetworkId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixNetwork -TenantId $tenantId -NetworkId $networkId
	.LINK
		https://printix.github.io/#_retrieve_network
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$NetworkId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/networks/{NetworkId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	Invoke-PrintixRequest @request
}
