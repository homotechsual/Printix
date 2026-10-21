function Connect-PrintixPartner {
	<#
	.SYNOPSIS
		Connects to the production Printix Partner API.
	.DESCRIPTION
		Required application type: partner API credentials issued out of band by Printix.
		These are separate from tenant applications created in Printix Administrator.
		Keeps a separate partner connection without replacing the Cloud Print connection.
		Access and refresh tokens are retained in memory only. Renewal uses the returned
		refresh token, or client credentials if no refresh token was supplied.
	.PARAMETER ClientId
		The production partner client ID provided by Printix.
	.PARAMETER ClientSecret
		The production partner client secret as a SecureString.
	.PARAMETER PartnerId
		The default partner ID provided by Printix.
	.EXAMPLE
		Connect-PrintixPartner -ClientId $clientId -ClientSecret (Read-Host 'Partner secret' -AsSecureString) -PartnerId $partnerId
	.LINK
		https://printix.github.io/partner-api/#_authentication
	#>
	[CmdletBinding()]
	[OutputType([void])]
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$ClientId,
		[Parameter(Mandatory)]
		[securestring]$ClientSecret,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$PartnerId
	)
	$Script:PrintixPartnerConnection = @{
		ClientId = $ClientId
		ClientSecret = $ClientSecret
		PartnerId = $PartnerId
		AccessToken = $null
		RefreshToken = $null
		ExpiresAt = [DateTimeOffset]::MinValue
	}
	try {
		$null = Get-PrintixAccessToken -Partner
	} catch {
		$Script:PrintixPartnerConnection = $null
		$PSCmdlet.ThrowTerminatingError($_)
	}
}
