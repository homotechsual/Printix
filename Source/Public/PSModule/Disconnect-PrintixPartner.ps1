function Disconnect-PrintixPartner {
	<#
	.SYNOPSIS
		Clears the partner connection from module memory.
	.DESCRIPTION
		Discards local partner credentials and tokens without revoking server-side tokens.
		Does not change the separate Cloud Print connection.
	.EXAMPLE
		Disconnect-PrintixPartner
	#>
	[CmdletBinding()]
	[OutputType([void])]
	param()
	$Script:PrintixPartnerConnection = $null
}
