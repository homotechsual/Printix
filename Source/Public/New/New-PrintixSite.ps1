function New-PrintixSite {
	<#
	.SYNOPSIS
		Creates a Site resource.
	.DESCRIPTION
		Creates a Site resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
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
		New-PrintixSite -TenantId $tenantId -Name $name
	.LINK
		https://printix.github.io/#_create_site
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[ValidateNotNullOrEmpty()]
		[string]$Path,
		[string[]]$AdminGroupIds,
		[string[]]$NetworkIds,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/sites' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Name = 'name'; Path = 'path'; AdminGroupIds = 'adminGroupIds'; NetworkIds = 'networkIds' }
	if ($PSCmdlet.ShouldProcess($resource, 'New-PrintixSite')) {
		Invoke-PrintixRequest @request
	}
}
