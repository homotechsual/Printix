function New-PrintixResource {
	[CmdletBinding()]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Formats a resource path without changing state.')]
	[OutputType([string])]
	param(
		[Parameter(Mandatory)]
		[string]$Template,
		[Parameter(Mandatory)]
		[System.Collections.IDictionary]$Parameters,
		[switch]$Partner
	)

	$resource = $Template
	foreach ($match in [regex]::Matches($Template, '\{(\w+)\}')) {
		$name = $match.Groups[1].Value
		$value = $Parameters[$name]
		if (-not $value -and $name -eq 'PartnerId' -and $Partner -and $null -ne $Script:PrintixPartnerConnection) {
			$value = $Script:PrintixPartnerConnection.PartnerId
		}
		if (-not $value -and $name -eq 'TenantId' -and -not $Partner -and $null -ne $Script:PrintixConnection) {
			$value = $Script:PrintixConnection.TenantId
		}
		if ([string]::IsNullOrWhiteSpace([string]$value)) {
			throw "Specify -$name$(if ($name -eq 'TenantId') { ' or set -TenantId when connecting' })."
		}
		if ([string]$value -in @('.', '..')) {
			throw "Invalid path identifier for $name."
		}
		$resource = $resource.Replace($match.Value, [uri]::EscapeDataString([string]$value))
	}
	$resource
}
