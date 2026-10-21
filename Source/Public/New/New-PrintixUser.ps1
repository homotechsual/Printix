function New-PrintixUser {
	<#
	.SYNOPSIS
		Creates a normal or guest user.
	.DESCRIPTION
		Creates a normal or guest user. Uses the documented Printix Cloud Print API.
		Required application type: User manager for role USER; User manager, Cloud Print API,
		or Card registration (API terminology) for role GUEST_USER. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Email
		The Email value sent to Printix.
	.PARAMETER FullName
		The FullName value sent to Printix.
	.PARAMETER Role
		The Role value sent to Printix.
	.PARAMETER Pin
		The Pin value sent to Printix.
	.PARAMETER Password
		The Password value sent to Printix.
	.PARAMETER ExpirationTimestamp
		The ExpirationTimestamp value sent to Printix.
	.PARAMETER SendWelcomeEmail
		The SendWelcomeEmail value sent to Printix.
	.PARAMETER SendExpirationEmail
		The SendExpirationEmail value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		New-PrintixUser -TenantId $tenantId -Email $email -FullName $fullName -Role $role
	.LINK
		https://printix.github.io/#_create_user
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Email,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(Mandatory)]
		[ValidateSet('GUEST_USER', 'USER')]
		[string]$Role,
		[securestring]$Pin,
		[securestring]$Password,
		[ValidatePattern('^\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}$')]
		[string]$ExpirationTimestamp,
		[bool]$SendWelcomeEmail,
		[bool]$SendExpirationEmail,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/users/create' -Parameters $PSBoundParameters
	if ($PSBoundParameters.ContainsKey('ExpirationTimestamp') -and $Role -ne 'GUEST_USER') {
		throw 'ExpirationTimestamp is only supported for GUEST_USER.'
	}
	if ($PSBoundParameters.ContainsKey('Pin')) {
		$pinText = ([pscredential]::new('Printix', $Pin)).GetNetworkCredential().Password
		if ($pinText -notmatch '^\d{4}$') { throw 'Pin must contain exactly four digits.' }
	}
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Email = 'email'; FullName = 'fullName'; Role = 'role'; Pin = 'pin'; Password = 'password'; ExpirationTimestamp = 'expirationTimestamp'; SendWelcomeEmail = 'sendWelcomeEmail'; SendExpirationEmail = 'sendExpirationEmail' }
	if ($PSCmdlet.ShouldProcess($resource, 'New-PrintixUser')) {
		Invoke-PrintixRequest @request
	}
}
