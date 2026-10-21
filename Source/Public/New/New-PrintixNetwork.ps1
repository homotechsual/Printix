function New-PrintixNetwork {
	<#
	.SYNOPSIS
		Creates a Network resource.
	.DESCRIPTION
		Creates a Network resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
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
		New-PrintixNetwork -TenantId $tenantId -Name $name
	.LINK
		https://printix.github.io/#_create_network
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
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

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/networks' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Name = 'name'; HomeOffice = 'homeOffice'; ClientMigratePrintQueues = 'clientMigratePrintQueues'; AirPrint = 'airPrint'; Gateways = 'gateways'; SiteId = 'siteId' }
	if ($PSCmdlet.ShouldProcess($resource, 'New-PrintixNetwork')) {
		Invoke-PrintixRequest @request
	}
}
