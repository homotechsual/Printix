function Remove-PrintixJob {
	<#
	.SYNOPSIS
		Deletes a print job.
	.DESCRIPTION
		Deletes a print job. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER JobId
		The JobId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixJob -TenantId $tenantId -JobId $jobId
	.LINK
		https://printix.github.io/#_delete_a_single_job
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$JobId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/jobs/{JobId}/delete' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixJob')) {
		Invoke-PrintixRequest @request
	}
}
