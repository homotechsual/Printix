function Get-PrintixAccessToken {
	[CmdletBinding()]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'OAuth returns a plaintext token; protect it in module memory after receipt.')]
	[OutputType([string])]
	param([switch]$Partner)

	$connection = if ($Partner) { $Script:PrintixPartnerConnection } else { $Script:PrintixConnection }
	if ($null -eq $connection) {
		$connectCommand = if ($Partner) { 'Connect-PrintixPartner' } else { 'Connect-Printix' }
		throw "Not connected to Printix. Run $connectCommand first."
	}
	if ($connection.ExpiresAt -le [DateTimeOffset]::UtcNow.AddSeconds(30)) {
		$credential = [pscredential]::new($connection.ClientId, $connection.ClientSecret)
		$body = @{
			grant_type = 'client_credentials'
			client_id = $credential.UserName
			client_secret = $credential.GetNetworkCredential().Password
		}
		if ($Partner -and $connection.RefreshToken) {
			$body = @{
				grant_type = 'refresh_token'
				client_id = $connection.ClientId
				refresh_token = ([pscredential]::new('Printix', $connection.RefreshToken)).GetNetworkCredential().Password
			}
		}
		try {
			$token = Invoke-RestMethod -Uri 'https://auth.printix.net/oauth/token' -Method Post -Body $body -ContentType 'application/x-www-form-urlencoded' -MaximumRedirection 0 -ErrorAction Stop
		} finally {
			$body.Clear()
		}
		if ($null -eq $token -or -not $token.PSObject.Properties['access_token'] -or -not $token.PSObject.Properties['expires_in'] -or
			-not $token.access_token -or [double]$token.expires_in -le 0) {
			throw 'Printix returned an invalid token response (access_token and positive expires_in are required).'
		}
		$connection.AccessToken = ConvertTo-SecureString -String $token.access_token -AsPlainText -Force
		$connection.ExpiresAt = [DateTimeOffset]::UtcNow.AddSeconds([double]$token.expires_in)
		if ($Partner -and $token.PSObject.Properties['refresh_token'] -and $token.refresh_token) {
			$connection.RefreshToken = ConvertTo-SecureString -String $token.refresh_token -AsPlainText -Force
		}
	}
	([pscredential]::new('Printix', $connection.AccessToken)).GetNetworkCredential().Password
}
