function Remove-PrintixGroup {
	<#
	.SYNOPSIS
		Deletes a group.
	.DESCRIPTION
		Deletes a group. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER GroupId
		The GroupId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixGroup -TenantId $tenantId -GroupId $groupId
	.LINK
		https://printix.github.io/#_delete_group
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$GroupId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/groups/{GroupId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'DELETE'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixGroup')) {
		Invoke-PrintixRequest @request
	}
}
