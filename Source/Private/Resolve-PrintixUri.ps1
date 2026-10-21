function Resolve-PrintixUri {
	[CmdletBinding()]
	[OutputType([uri])]
	param(
		[Parameter(Mandatory)]
		[string]$Resource,
		[uri]$RelativeTo,
		[switch]$Partner
	)

	$basePath = if ($Partner) { '/public/partners' } else { '/cloudprint' }
	if (-not $RelativeTo) { $RelativeTo = [uri]("https://api.printix.net$basePath/") }
	$resourceWithoutTemplate = $Resource -replace '\{[?&][^}]+\}', ''
	if ($resourceWithoutTemplate -match '[{}]') {
		throw 'The Printix link contains an unresolved URI template.'
	}
	$uri = [uri]::new($RelativeTo, $resourceWithoutTemplate)
	if ($uri.Scheme -ne 'https' -or $uri.Host -ne 'api.printix.net' -or $uri.Port -ne 443 -or $uri.UserInfo -or
		($uri.AbsolutePath -ne $basePath -and -not $uri.AbsolutePath.StartsWith("$basePath/", [StringComparison]::Ordinal))) {
		throw "Authenticated requests must target https://api.printix.net$basePath."
	}
	$uri
}
