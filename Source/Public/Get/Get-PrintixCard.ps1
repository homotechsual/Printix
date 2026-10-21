function Get-PrintixCard {
	<#
	.SYNOPSIS
		Finds a card by ID or converted base64 card number.
	.DESCRIPTION
		Finds a card by ID or converted base64 card number. Uses the documented Printix Cloud Print API.
		Required application type: Card registration (API terminology).
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER CardId
		The CardId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Get-PrintixCard -TenantId $tenantId -CardId $cardId
	.LINK
		https://printix.github.io/#_search_for_card
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$CardId,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/cards/{CardId}' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'GET'; Raw = $Raw }
	$request.ResponseProperty = 'card'
	Invoke-PrintixRequest @request
}
