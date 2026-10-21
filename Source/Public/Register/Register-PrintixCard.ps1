function Register-PrintixCard {
	<#
	.SYNOPSIS
		Registers a converted, base64-encoded card number for a user.
	.DESCRIPTION
		Registers a converted, base64-encoded card number for a user. Uses the documented Printix Cloud Print API.
		Required application type: Card manager.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER UserId
		The UserId path identifier.
	.PARAMETER Secret
		The Secret value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		Register-PrintixCard -TenantId $tenantId -UserId $userId -Secret $secret
	.LINK
		https://printix.github.io/#_register_card
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$UserId,
		[Parameter(Mandatory)]
		[securestring]$Secret,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/users/{UserId}/cards' -Parameters $PSBoundParameters
	$cardSecret = ([pscredential]::new('Printix', $Secret)).GetNetworkCredential().Password
	try { $null = [Convert]::FromBase64String($cardSecret) }
	catch [FormatException] { throw 'Secret must be a base64-encoded card number.' }
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Secret = 'secret' }
	if ($PSCmdlet.ShouldProcess($resource, 'Register-PrintixCard')) {
		Invoke-PrintixRequest @request
	}
}
