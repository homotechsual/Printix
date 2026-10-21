BeforeAll {
	$manifestPath = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	Import-Module $manifestPath -Force -ErrorAction Stop
	function New-TestWebhook {
		param([double]$Emitted = 1792562400)
		$bytes = [Text.Encoding]::UTF8.GetBytes('{"emitted":' + $Emitted.ToString([Globalization.CultureInfo]::InvariantCulture) + ',"events":[]}')
		$hmac = [Security.Cryptography.HMACSHA512]::new([Text.Encoding]::UTF8.GetBytes('offline-shared-secret'))
		try { $signature = [BitConverter]::ToString($hmac.ComputeHash($bytes)).Replace('-', '').ToLowerInvariant() }
		finally { $hmac.Dispose() }
		@{ Body = $bytes; Signature = $signature }
	}
}

Describe 'Webhook validation' {
	It 'accepts a valid signature and supports shared-secret rotation' {
		$hook = New-TestWebhook
		$secrets = @(
			ConvertTo-SecureString 'old-secret' -AsPlainText -Force
			ConvertTo-SecureString 'offline-shared-secret' -AsPlainText -Force
		)
		Test-PrintixWebhookSignature @hook -SharedSecret $secrets -Now ([DateTimeOffset]::FromUnixTimeSeconds(1792562400)) | Should -BeTrue
	}

	It 'rejects an altered body or signature' {
		$hook = New-TestWebhook
		$secret = ConvertTo-SecureString 'offline-shared-secret' -AsPlainText -Force
		$hook.Body[0] = 32
		Test-PrintixWebhookSignature @hook -SharedSecret $secret | Should -BeFalse
		$hook = New-TestWebhook
		$hook.Signature = '0' * 128
		Test-PrintixWebhookSignature @hook -SharedSecret $secret | Should -BeFalse
	}

	It 'accepts exactly 15 minutes of clock skew but rejects older or future events outside that window' {
		$secret = ConvertTo-SecureString 'offline-shared-secret' -AsPlainText -Force
		$now = [DateTimeOffset]::FromUnixTimeSeconds(1792562400)
		foreach ($offset in @(-900, 900)) {
			$hook = New-TestWebhook -Emitted (1792562400 + $offset)
			Test-PrintixWebhookSignature @hook -SharedSecret $secret -Now $now | Should -BeTrue
		}
		foreach ($offset in @(-900.001, 900.001)) {
			$hook = New-TestWebhook -Emitted (1792562400 + $offset)
			Test-PrintixWebhookSignature @hook -SharedSecret $secret -Now $now | Should -BeFalse
		}
	}

	It 'rejects malformed hexadecimal signatures' {
		$secret = ConvertTo-SecureString 'offline-shared-secret' -AsPlainText -Force
		{ Test-PrintixWebhookSignature -Body ([byte[]]@(1)) -Signature 'not-a-signature' -SharedSecret $secret } | Should -Throw
	}
}
