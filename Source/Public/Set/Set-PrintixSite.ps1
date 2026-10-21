function Set-PrintixSite {
	<#
	.SYNOPSIS
		Updates a Site resource.
	.DESCRIPTION
		Updates a Site resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER SiteId
		The SiteId path identifier.
	.PARAMETER Name
		The Name value sent to Printix.
	.PARAMETER Path
		The Path value sent to Printix.
	.PARAMETER AdminGroupIds
		The AdminGroupIds value sent to Printix.
	.PARAMETER NetworkIds
		The NetworkIds value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Set-PrintixSite -TenantId $tenantId -SiteId $siteId -Name 'Updated name'
	.LINK
		https://printix.github.io/#_update_site
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SiteId,
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[ValidateNotNullOrEmpty()]
		[string]$Path,
		[string[]]$AdminGroupIds,
		[string[]]$NetworkIds,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/sites/{SiteId}' -Parameters $PSBoundParameters
	if (-not @('Name', 'Path', 'AdminGroupIds', 'NetworkIds' | Where-Object { $PSBoundParameters.ContainsKey($_) }).Count) {
		throw 'Specify at least one field to update.'
	}
	$request = @{ Resource = $resource; Method = 'PUT'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Name = 'name'; Path = 'path'; AdminGroupIds = 'adminGroupIds'; NetworkIds = 'networkIds' }
	if ($PSCmdlet.ShouldProcess($resource, 'Set-PrintixSite')) {
		Invoke-PrintixRequest @request
	}
}
