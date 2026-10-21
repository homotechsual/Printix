function New-PrintixPartnerTenant {
	<#
	.SYNOPSIS
		Creates a partner-managed Printix tenant.
	.DESCRIPTION
		Required application type: partner API credentials issued by Printix.
		Returns the full created tenant resource and embedded billing information.
		Without an initial user, no users are created and the partner must invite them.
		Initial users who have never signed in may need to reset their password.
	.PARAMETER PartnerId
		The partner ID, defaulting to the partner connection's ID.
	.PARAMETER TenantName
		The display name, up to 100 characters.
	.PARAMETER TenantDomain
		The subdomain prefix, using only lowercase ASCII letters, digits and dashes.
		For acme.printix.net, supply acme, not the full domain.
	.PARAMETER InitialUserEmail
		The initial user's email and login name. Requires InitialUserName.
	.PARAMETER InitialUserName
		The initial user's name. Requires InitialUserEmail.
	.PARAMETER CreateInitialUserAsAdmin
		Create the initial user as an administrator. Defaults to false.
	.EXAMPLE
		New-PrintixPartnerTenant -TenantName 'Acme Co.' -TenantDomain acme
	.EXAMPLE
		New-PrintixPartnerTenant -TenantName 'Acme Co.' -TenantDomain acme -InitialUserEmail admin@acme.example -InitialUserName 'Alex Admin' -CreateInitialUserAsAdmin
	.LINK
		https://printix.github.io/partner-api/#_create_new_tenant
	#>
	[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'NoInitialUser')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$PartnerId,
		[Parameter(Mandatory)]
		[ValidateLength(1, 100)]
		[ValidateNotNullOrEmpty()]
		[string]$TenantName,
		[Parameter(Mandatory)]
		[ValidatePattern('^[a-z0-9-]+$', Options = [System.Text.RegularExpressions.RegexOptions]::None)]
		[string]$TenantDomain,
		[Parameter(Mandatory, ParameterSetName = 'InitialUser')]
		[ValidateNotNullOrEmpty()]
		[string]$InitialUserEmail,
		[Parameter(Mandatory, ParameterSetName = 'InitialUser')]
		[ValidateNotNullOrEmpty()]
		[string]$InitialUserName,
		[Parameter(ParameterSetName = 'InitialUser')]
		[switch]$CreateInitialUserAsAdmin
	)
	$resource = New-PrintixResource -Template '{PartnerId}/tenants' -Parameters $PSBoundParameters -Partner
	$body = @{ tenant_name = $TenantName; tenant_domain = $TenantDomain }
	if ($PSCmdlet.ParameterSetName -eq 'InitialUser') {
		$body.initial_user = @{
			email = $InitialUserEmail
			name = $InitialUserName
			create_as_admin = [bool]$CreateInitialUserAsAdmin
		}
	}
	if ($PSCmdlet.ShouldProcess("$TenantName ($TenantDomain)", 'Create partner-managed Printix tenant')) {
		Invoke-PrintixPartnerRequest -Resource $resource -Method POST -Body $body
	}
}
