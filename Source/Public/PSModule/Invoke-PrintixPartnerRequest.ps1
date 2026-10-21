function Invoke-PrintixPartnerRequest {
	<#
	.SYNOPSIS
		Sends an authenticated request to the production Partner API.
	.DESCRIPTION
		Required application type: partner API credentials issued by Printix.
		Uses the separate partner connection and application/hal+json responses.
		Only HTTPS links under api.printix.net/public/partners are accepted.
		HTTP 429 retries respect Retry-After when supplied, otherwise use backoff.
	.PARAMETER Resource
		A path relative to public/partners, or an absolute Partner API HAL link.
	.PARAMETER Method
		The HTTP method, defaulting to GET.
	.PARAMETER Query
		Query parameters, including the documented include-inactive or embed fields.
	.PARAMETER Body
		An object to serialize as JSON, or JSON text.
	.PARAMETER Headers
		Additional headers. Authorization cannot be overridden.
	.PARAMETER ResponseProperty
		The response field to emit. Defaults to returning the complete document.
	.PARAMETER Raw
		Return the complete response even when ResponseProperty is specified.
	.PARAMETER MaxRetryCount
		The maximum number of HTTP 429 retries. Other failures terminate.
	.EXAMPLE
		Invoke-PrintixPartnerRequest -Resource $tenant._links.'px:billing-info'.href
	.LINK
		https://printix.github.io/partner-api/
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
		[switch]$Raw,
		[ValidateRange(0, 10)]
		[int]$MaxRetryCount = 5
	)
	Invoke-PrintixApiRequest @PSBoundParameters -Partner
}
