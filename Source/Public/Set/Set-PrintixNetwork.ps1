function Set-PrintixNetwork {
	<#
	.SYNOPSIS
		Updates a Network resource.
	.DESCRIPTION
		Updates a Network resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER NetworkId
		The NetworkId path identifier.
	.PARAMETER Name
		The Name value sent to Printix.
	.PARAMETER HomeOffice
		The HomeOffice value sent to Printix.
	.PARAMETER ClientMigratePrintQueues
		The ClientMigratePrintQueues value sent to Printix.
	.PARAMETER AirPrint
		The AirPrint value sent to Printix.
	.PARAMETER Gateways
		Gateway objects containing mac and ip fields.
	.PARAMETER SiteId
		The SiteId value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Set-PrintixNetwork -TenantId $tenantId -NetworkId $networkId -Name 'Updated name'
	.LINK
		https://printix.github.io/#_update_network
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$NetworkId,
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[bool]$HomeOffice,
		[ValidateSet('GLOBAL_SETTING', 'YES', 'NO')]
		[string]$ClientMigratePrintQueues,
		[bool]$AirPrint,
		[hashtable[]]$Gateways,
		[ValidateNotNullOrEmpty()]
		[string]$SiteId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/networks/{NetworkId}' -Parameters $PSBoundParameters
	if (-not @('Name', 'HomeOffice', 'ClientMigratePrintQueues', 'AirPrint', 'Gateways', 'SiteId' | Where-Object { $PSBoundParameters.ContainsKey($_) }).Count) {
		throw 'Specify at least one field to update.'
	}
	$request = @{ Resource = $resource; Method = 'PUT'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Name = 'name'; HomeOffice = 'homeOffice'; ClientMigratePrintQueues = 'clientMigratePrintQueues'; AirPrint = 'airPrint'; Gateways = 'gateways'; SiteId = 'siteId' }
	if ($PSCmdlet.ShouldProcess($resource, 'Set-PrintixNetwork')) {
		Invoke-PrintixRequest @request
	}
}
