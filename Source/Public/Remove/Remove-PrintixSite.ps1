function Remove-PrintixSite {
	<#
	.SYNOPSIS
		Deletes a Site resource.
	.DESCRIPTION
		Deletes a Site resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER SiteId
		The SiteId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixSite -TenantId $tenantId -SiteId $siteId
	.LINK
		https://printix.github.io/#_delete_site
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SiteId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/sites/{SiteId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'DELETE'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixSite')) {
		Invoke-PrintixRequest @request
	}
}
