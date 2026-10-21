function Remove-PrintixNetwork {
	<#
	.SYNOPSIS
		Deletes a Network resource.
	.DESCRIPTION
		Deletes a Network resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER NetworkId
		The NetworkId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixNetwork -TenantId $tenantId -NetworkId $networkId
	.LINK
		https://printix.github.io/#_delete_network
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
	$request = @{ Resource = $resource; Method = 'DELETE'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixNetwork')) {
		Invoke-PrintixRequest @request
	}
}
