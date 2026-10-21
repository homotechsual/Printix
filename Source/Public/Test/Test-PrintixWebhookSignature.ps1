function Test-PrintixWebhookSignature {
	<#
	.SYNOPSIS
		Verifies a Printix webhook signature and emitted timestamp.
	.DESCRIPTION
		Computes HMAC-SHA512 over the exact UTF-8 request body using each shared secret.
		Returns false for a signature mismatch or expired event, and throws on malformed input.
		Uses constant-time comparison. Does not host an HTTP endpoint.
	.PARAMETER Body
		The unmodified UTF-8 request body bytes.
	.PARAMETER Signature
		A hexadecimal X-Printix-Signature-1 or X-Printix-Signature-2 header value.
	.PARAMETER SharedSecret
		One or both webhook shared secrets, interpreted as UTF-8 text.
	.PARAMETER Now
		The comparison time. Defaults to UTC now.
	.EXAMPLE
		Test-PrintixWebhookSignature -Body $bodyBytes -Signature $signatureHeader -SharedSecret $secret
	.LINK
		https://printix.github.io/#_webhooks
	#>
	[CmdletBinding()]
	[OutputType([bool])]
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[byte[]]$Body,
		[Parameter(Mandatory)]
		[ValidatePattern('^[0-9a-fA-F]{128}$')]
		[string]$Signature,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[securestring[]]$SharedSecret,
		[DateTimeOffset]$Now = [DateTimeOffset]::UtcNow
	)

	$signatureBytes = [byte[]]::new(64)
	for ($index = 0; $index -lt 64; $index++) {
		$signatureBytes[$index] = [Convert]::ToByte($Signature.Substring($index * 2, 2), 16)
	}
	$matched = $false
	foreach ($secret in $SharedSecret) {
		$key = [Text.Encoding]::UTF8.GetBytes(([pscredential]::new('Printix', $secret)).GetNetworkCredential().Password)
		$hmac = [Security.Cryptography.HMACSHA512]::new($key)
		try {
			$hash = $hmac.ComputeHash($Body)
			if ([Printix.Cryptography]::FixedTimeEquals($hash, $signatureBytes)) {
				$matched = $true
			}
		} finally {
			$hmac.Dispose()
			[Array]::Clear($key, 0, $key.Length)
		}
	}
	if (-not $matched) { return $false }
	$document = [Text.UTF8Encoding]::new($false, $true).GetString($Body) | ConvertFrom-Json -ErrorAction Stop
	if ($null -eq $document -or -not $document.PSObject.Properties['emitted'] -or
		$document.emitted -is [bool] -or $document.emitted -isnot [ValueType]) {
		throw 'Webhook body must contain a numeric emitted timestamp.'
	}
	$emitted = [double]$document.emitted
	if ([double]::IsNaN($emitted) -or [double]::IsInfinity($emitted)) {
		throw 'Webhook emitted timestamp must be finite.'
	}
	$nowSeconds = ($Now - [DateTimeOffset]::FromUnixTimeSeconds(0)).TotalSeconds
	[Math]::Abs($nowSeconds - $emitted) -le 900
}
