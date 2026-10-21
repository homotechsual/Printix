function Get-PrintixGroup {
	<#
	.SYNOPSIS
		Retrieves a group.
	.DESCRIPTION
		Retrieves a group. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER GroupId
		The GroupId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixGroup -TenantId $tenantId -GroupId $groupId
	.LINK
		https://printix.github.io/#_fetch_group_details
	#>
	[CmdletBinding()]
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
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.ResponseProperty = 'group'
	Invoke-PrintixRequest @request
}
