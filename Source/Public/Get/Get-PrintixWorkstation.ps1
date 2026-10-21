function Get-PrintixWorkstation {
	<#
	.SYNOPSIS
		Retrieves workstation monitoring information.
	.DESCRIPTION
		Retrieves workstation monitoring information. Uses the documented Printix Cloud Print API.
		Required application type: Workstation monitoring, not Cloud Print API or User manager.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER WorkstationId
		The WorkstationId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixWorkstation -TenantId $tenantId -WorkstationId $workstationId
	.LINK
		https://printix.github.io/#_retrieve_workstation
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$WorkstationId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/workstations/{WorkstationId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	Invoke-PrintixRequest @request
}
