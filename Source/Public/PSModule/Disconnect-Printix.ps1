function Disconnect-Printix {
	<#
	.SYNOPSIS
		Clears the current Printix connection from module memory.
	.DESCRIPTION
		Discards locally held credentials and tokens. Does not revoke the server-side token.
		Does not change the separate Partner API connection.
	.EXAMPLE
		Disconnect-Printix
	#>
	[CmdletBinding()]
	[OutputType([void])]
	param()
	$Script:PrintixConnection = $null
}
