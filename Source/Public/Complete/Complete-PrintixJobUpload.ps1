function Complete-PrintixJobUpload {
	<#
	.SYNOPSIS
		Notifies Printix that a job file has been uploaded.
	.DESCRIPTION
		Notifies Printix that a job file has been uploaded. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER JobId
		The JobId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Complete-PrintixJobUpload -TenantId $tenantId -JobId $jobId
	.LINK
		https://printix.github.io/#_complete_upload
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$JobId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/jobs/{JobId}/completeUpload' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Complete-PrintixJobUpload')) {
		Invoke-PrintixRequest @request
	}
}
