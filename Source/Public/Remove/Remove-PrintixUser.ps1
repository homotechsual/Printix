function Remove-PrintixUser {
	<#
	.SYNOPSIS
		Deletes a guest user.
	.DESCRIPTION
		Deletes a guest user. Uses the documented Printix Cloud Print API.
		Required application type: User manager, Cloud Print API, or Card registration (API terminology).
		Requires Printix Premium. The documented operation deletes guest users.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER UserId
		The UserId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixUser -TenantId $tenantId -UserId $userId
	.LINK
		https://printix.github.io/#_delete_user
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$UserId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/users/{UserId}/delete' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixUser')) {
		Invoke-PrintixRequest @request
	}
}
