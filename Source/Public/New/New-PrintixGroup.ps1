function New-PrintixGroup {
	<#
	.SYNOPSIS
		Creates an externally identified group.
	.DESCRIPTION
		Creates an externally identified group. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Name
		The Name value sent to Printix.
	.PARAMETER ExternalId
		The ExternalId value sent to Printix.
	.PARAMETER IdentityProvider
		The IdentityProvider value sent to Printix.
	.PARAMETER Description
		The Description value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		New-PrintixGroup -TenantId $tenantId -Name $name -ExternalId $externalId
	.LINK
		https://printix.github.io/#_create_group
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$ExternalId,
		[ValidateNotNullOrEmpty()]
		[string]$IdentityProvider,
		[ValidateNotNullOrEmpty()]
		[string]$Description,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/groups' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Name = 'name'; ExternalId = 'externalId'; IdentityProvider = 'identityProvider'; Description = 'description' }
	if ($PSCmdlet.ShouldProcess($resource, 'New-PrintixGroup')) {
		Invoke-PrintixRequest @request
	}
}
