function Get-PrintixJob {
	<#
	.SYNOPSIS
		Retrieves a print job.
	.DESCRIPTION
		Retrieves a print job. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER JobId
		The JobId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixJob -TenantId $tenantId -JobId $jobId
	.LINK
		https://printix.github.io/#_retrieve_a_single_job
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$JobId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/jobs/{JobId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.ResponseProperty = 'jobs'
	Invoke-PrintixRequest @request
}
