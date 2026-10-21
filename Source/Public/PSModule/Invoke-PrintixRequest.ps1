function Invoke-PrintixRequest {
	<#
	.SYNOPSIS
		Sends an authenticated request to the Printix Cloud Print API.
	.DESCRIPTION
		Serializes JSON, renews tokens, follows HAL next links when requested and retries HTTP 429 only.
		The required application type depends on the endpoint. Types are mutually exclusive, not scopes.
		Partner API requests use Invoke-PrintixPartnerRequest and a separate partner connection.
	.PARAMETER Resource
		An API resource relative to cloudprint, or an absolute Cloud Print API HAL link.
	.PARAMETER Method
		The HTTP method, defaulting to GET.
	.PARAMETER Query
		Query fields. Arrays become comma-separated values; false and zero are preserved.
	.PARAMETER Body
		An object to serialize as JSON, or JSON text.
	.PARAMETER Headers
		Additional headers. Authorization cannot be overridden.
	.PARAMETER ResponseProperty
		The response property to emit. Omit to return the complete document.
	.PARAMETER All
		Follow HAL next links for GET requests.
	.PARAMETER Raw
		Return complete response documents instead of extracting ResponseProperty.
	.PARAMETER MaxRetryCount
		Maximum retries after HTTP 429, defaulting to five.
	.EXAMPLE
		Invoke-PrintixRequest -Resource 'tenants/tenant-id/users' -Query @{ role = 'USER' } -ResponseProperty users -All
	.LINK
		https://printix.github.io/#_api_conventions
	#>
	[CmdletBinding()]
	[OutputType([object])]
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Resource,
		[ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
		[string]$Method = 'GET',
		[hashtable]$Query = @{},
		[object]$Body,
		[hashtable]$Headers = @{},
		[string]$ResponseProperty,
		[switch]$All,
		[switch]$Raw,
		[ValidateRange(0, 10)]
		[int]$MaxRetryCount = 5
	)
	Invoke-PrintixApiRequest @PSBoundParameters
}
