function ConvertTo-PrintixFields {
	[CmdletBinding()]
	[OutputType([hashtable])]
	param(
		[Parameter(Mandatory)]
		[System.Collections.IDictionary]$Parameters,
		[Parameter(Mandatory)]
		[hashtable]$Map
	)

	$fields = @{}
	foreach ($name in $Map.Keys) {
		if ($Parameters.Keys -contains $name) {
			$value = $Parameters[$name]
			if ($value -is [securestring]) {
				$value = ([pscredential]::new('Printix', $value)).GetNetworkCredential().Password
			}
			$fields[$Map[$name]] = $value
		}
	}
	$fields
}
