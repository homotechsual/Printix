function Remove-PrintixCard {
	<#
	.SYNOPSIS
		Deletes a card by ID or converted base64 card number.
	.DESCRIPTION
		Deletes a card by ID or converted base64 card number. Uses the documented Printix Cloud Print API.
		Required application type: Card manager.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER CardId
		The CardId path identifier.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Remove-PrintixCard -TenantId $tenantId -CardId $cardId
	.LINK
		https://printix.github.io/#_delete_card
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
	$request = @{ Resource = $resource; Method = 'DELETE'; Raw = $Raw }
	if ($PSCmdlet.ShouldProcess($resource, 'Remove-PrintixCard')) {
		Invoke-PrintixRequest @request
	}
}
