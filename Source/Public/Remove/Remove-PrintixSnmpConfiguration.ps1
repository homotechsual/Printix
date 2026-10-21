function Remove-PrintixSnmpConfiguration {
	<#
	.SYNOPSIS
		Deletes a SnmpConfiguration resource.
	.DESCRIPTION
		Deletes a SnmpConfiguration resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER SnmpId
		The SnmpId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixSnmpConfiguration -TenantId $tenantId -SnmpId $snmpId
	.LINK
		https://printix.github.io/#_delete_snmp_configuration
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SnmpId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/snmp/{SnmpId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'DELETE'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixSnmpConfiguration')) {
		Invoke-PrintixRequest @request
	}
}
