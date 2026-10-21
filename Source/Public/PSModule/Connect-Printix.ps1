function Connect-Printix {
	<#
	.SYNOPSIS
		Connects to the Printix Cloud Print API using OAuth client credentials.
	.DESCRIPTION
		Obtains an access token and retains credentials in module memory for renewal.
		A new connection replaces the previous connection. Credentials are never written to disk.
		Printix application types are mutually exclusive, not combinable OAuth scopes.
		Each application has one type; use separate applications and credentials for operations
		that require different types. Reconnect to switch the active Cloud Print connection.
		The Partner API uses a separate connection managed by Connect-PrintixPartner.
		Successful authentication does not authorize every endpoint.
	.PARAMETER ClientId
		The application client ID from Printix Administrator.
	.PARAMETER ClientSecret
		The application secret as a SecureString.
	.PARAMETER TenantId
		Optional default tenant ID for subsequent commands.
	.EXAMPLE
		Connect-Printix -ClientId $clientId -ClientSecret (Read-Host 'Client secret' -AsSecureString) -TenantId $tenantId
	.LINK
		https://printix.github.io/#_authentication
	#>
	[CmdletBinding()]
	[OutputType([void])]
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$ClientId,
		[Parameter(Mandatory)]
		[securestring]$ClientSecret,
		[ValidateNotNullOrEmpty()]
		[string]$TenantId
	)

	$Script:PrintixConnection = @{
		ClientId = $ClientId
		ClientSecret = $ClientSecret
		TenantId = $TenantId
		AccessToken = $null
		ExpiresAt = [DateTimeOffset]::MinValue
	}
	try {
		$null = Get-PrintixAccessToken
	} catch {
		$Script:PrintixConnection = $null
		$PSCmdlet.ThrowTerminatingError($_)
	}
}
