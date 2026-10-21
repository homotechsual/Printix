function Invoke-PrintixApiRequest {
	<#
	.SYNOPSIS
		Sends an authenticated request to the Printix Cloud Print API.
	.DESCRIPTION
		Accepts relative resources or API HAL links, serializes JSON, renews expiring tokens,
		and retries HTTP 429 responses only. Other HTTP and API failures terminate.
		Use All with a collection ResponseProperty to follow HAL next links.
		The required application type depends on the endpoint being called.
		Application types are mutually exclusive, not OAuth scopes; reconnect with the
		appropriate application's credentials when switching between endpoint requirements.
	.PARAMETER Resource
		An API resource relative to cloudprint, or an absolute Printix API link.
	.PARAMETER Method
		The HTTP method. Defaults to GET.
	.PARAMETER Query
		Query fields. Arrays become comma-separated values; false and zero are preserved.
	.PARAMETER Body
		An object to serialize as JSON, or JSON text.
	.PARAMETER Headers
		Additional API headers, for example version. Authorization cannot be overridden.
	.PARAMETER ResponseProperty
		The response property to emit. Without this, returns the complete HAL document.
	.PARAMETER All
		Follows next links, emitting each page's resources (or documents with Raw).
	.PARAMETER Raw
		Returns complete response documents rather than extracting ResponseProperty.
	.PARAMETER MaxRetryCount
		Maximum retries after HTTP 429. Other failures are not retried.
	.EXAMPLE
		Invoke-PrintixRequest -Resource 'tenants/tenant-id/users' -ResponseProperty users -All
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
		[int]$MaxRetryCount = 5,
		[switch]$Partner
	)

	if ($All -and $Method -ne 'GET') {
		throw '-All is only supported for GET requests.'
	}
	if ($Headers.ContainsKey('Authorization')) {
		throw 'Authorization is managed by the Printix connection.'
	}
	$uri = Resolve-PrintixUri -Resource $Resource -Partner:$Partner
	if ($Query.Count) {
		$builder = [UriBuilder]::new($uri)
		$pairs = foreach ($key in ($Query.Keys | Sort-Object)) {
			$value = $Query[$key]
			if ($null -eq $value) { continue }
			if ($value -is [bool]) { $value = $value.ToString().ToLowerInvariant() }
			elseif ($value -is [array]) { $value = $value -join ',' }
			'{0}={1}' -f [uri]::EscapeDataString($key), [uri]::EscapeDataString([string]$value)
		}
		$builder.Query = (@($builder.Query.TrimStart('?'), ($pairs -join '&')) | Where-Object { $_ }) -join '&'
		$uri = $builder.Uri
	}
	$visited = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
	do {
		if (-not $visited.Add($uri.AbsoluteUri)) {
			throw 'Printix returned a pagination cycle.'
		}
		for ($attempt = 0; ; $attempt++) {
			$requestHeaders = @{
				Accept = $(if ($Partner) { 'application/hal+json' } else { 'application/json' })
				Authorization = 'Bearer ' + (Get-PrintixAccessToken -Partner:$Partner)
			}
			foreach ($key in $Headers.Keys) { $requestHeaders[$key] = $Headers[$key] }
			$request = @{
				Uri = $uri
				Method = $Method
				Headers = $requestHeaders
				MaximumRedirection = 0
				ErrorAction = 'Stop'
				ResponseHeadersVariable = 'responseHeaders'
			}
			if ($PSBoundParameters.ContainsKey('Body')) {
				$request.Body = if ($Body -is [string]) { $Body } else { ConvertTo-Json -InputObject $Body -Depth 30 -Compress }
				$request.ContentType = 'application/json; charset=utf-8'
			}
			try {
				$response = Invoke-RestMethod @request
				break
			} catch {
				$httpResponse = $_.Exception.PSObject.Properties['Response']
				if (-not $httpResponse -or [int]$httpResponse.Value.StatusCode -ne 429 -or $attempt -ge $MaxRetryCount) {
					$PSCmdlet.ThrowTerminatingError($_)
				}
				$retryValues = $null
				$hasRetryHeader = $httpResponse.Value.Headers.TryGetValues('X-Rate-Limit-Retry-After-Seconds', [ref]$retryValues)
				$retrySeconds = 0.0
				if (-not $hasRetryHeader -and $Partner) {
					$retryAfter = $httpResponse.Value.Headers.RetryAfter
					if ($null -ne $retryAfter -and $null -ne $retryAfter.Delta) {
						$retrySeconds = $retryAfter.Delta.TotalSeconds
					} elseif ($null -ne $retryAfter -and $null -ne $retryAfter.Date) {
						$retrySeconds = [Math]::Max(0, ($retryAfter.Date - [DateTimeOffset]::UtcNow).TotalSeconds)
					} else {
						$retrySeconds = [Math]::Pow(2, $attempt)
					}
				} elseif (-not $hasRetryHeader -or -not [double]::TryParse([string](@($retryValues)[0]), [Globalization.NumberStyles]::Float,
						[Globalization.CultureInfo]::InvariantCulture, [ref]$retrySeconds) -or $retrySeconds -lt 0 -or
					[double]::IsInfinity($retrySeconds) -or [double]::IsNaN($retrySeconds)) {
					throw 'Printix returned HTTP 429 without a valid X-Rate-Limit-Retry-After-Seconds header.'
				}
				$delay = [Math]::Max($retrySeconds, [Math]::Pow(2, $attempt)) + (Get-Random -Minimum 0 -Maximum 1000) / 1000.0
				Write-Verbose "Printix rate limit reached. Retrying in $delay seconds."
				Start-Sleep -Seconds $delay
			}
		}
		if ($null -ne $response -and $response.PSObject.Properties['success'] -and $response.success -eq $false) {
			throw ('Printix API request failed: {0}' -f (ConvertTo-Json -InputObject $response -Depth 30 -Compress))
		}
		if ($Raw -or -not $ResponseProperty) {
			$response
		} elseif ($null -ne $response -and $response.PSObject.Properties[$ResponseProperty]) {
			$response.$ResponseProperty
		} else {
			throw "Printix response did not contain '$ResponseProperty'. Use -Raw to inspect the document."
		}
		$next = $null
		if ($All -and $null -ne $response -and $response.PSObject.Properties['_links'] -and
			$response._links.PSObject.Properties['next']) {
			$links = @($response._links.next)
			if ($links.Count -ne 1 -or -not $links[0].href) {
				throw 'Printix returned an invalid next-page link.'
			}
			$next = Resolve-PrintixUri -Resource $links[0].href -RelativeTo $uri -Partner:$Partner
		}
		$uri = $next
	} while ($null -ne $uri)
}
