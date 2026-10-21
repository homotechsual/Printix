function Set-PrintixJobOwner {
	<#
	.SYNOPSIS
		Assigns an API-created print job to a registered user.
	.DESCRIPTION
		Assigns an API-created print job to a registered user. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER JobId
		The JobId path identifier.
	.PARAMETER UserEmail
		The UserEmail value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Set-PrintixJobOwner -TenantId $tenantId -JobId $jobId -UserEmail $userEmail
	.LINK
		https://printix.github.io/#_change_owner
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$JobId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$UserEmail,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/jobs/{JobId}/changeOwner' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ UserEmail = 'userEmail' }
	if ($PSCmdlet.ShouldProcess($resource, 'Set-PrintixJobOwner')) {
		Invoke-PrintixRequest @request
	}
}
