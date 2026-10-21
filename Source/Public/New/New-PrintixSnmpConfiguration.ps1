function New-PrintixSnmpConfiguration {
	<#
	.SYNOPSIS
		Creates a SnmpConfiguration resource.
	.DESCRIPTION
		Creates a SnmpConfiguration resource. Uses the documented Printix Cloud Print API.
		Required application type: Cloud Print API. Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID. Defaults to the tenant selected by Connect-Printix.
	.PARAMETER Name
		The Name value sent to Printix.
	.PARAMETER GetCommunityName
		The GetCommunityName value sent to Printix.
	.PARAMETER SetCommunityName
		The SetCommunityName value sent to Printix.
	.PARAMETER TenantDefault
		The TenantDefault value sent to Printix.
	.PARAMETER SecurityLevel
		The SecurityLevel value sent to Printix.
	.PARAMETER Version
		The Version value sent to Printix.
	.PARAMETER Username
		The Username value sent to Printix.
	.PARAMETER ContextName
		The ContextName value sent to Printix.
	.PARAMETER Authentication
		The Authentication value sent to Printix.
	.PARAMETER AuthenticationKey
		The AuthenticationKey value sent to Printix.
	.PARAMETER Privacy
		The Privacy value sent to Printix.
	.PARAMETER PrivacyKey
		The PrivacyKey value sent to Printix.
	.PARAMETER NetworkIds
		The NetworkIds value sent to Printix.
	.PARAMETER Raw
		Return the complete HAL document, including links and metadata.
	.EXAMPLE
		New-PrintixSnmpConfiguration -TenantId $tenantId -Name $name
	.LINK
		https://printix.github.io/#_create_snmp_configuration
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[securestring]$GetCommunityName,
		[securestring]$SetCommunityName,
		[bool]$TenantDefault,
		[ValidateSet('NO_AUTH_NO_PRIVACY', 'AUTH_NO_PRIVACY', 'AUTH_PRIVACY')]
		[string]$SecurityLevel,
		[ValidateSet('V1', 'V3')]
		[string]$Version,
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[ValidateNotNullOrEmpty()]
		[string]$ContextName,
		[ValidateSet('NONE', 'MD5', 'SHA', 'SHA256', 'SHA384', 'SHA512')]
		[string]$Authentication,
		[securestring]$AuthenticationKey,
		[ValidateSet('NONE', 'DES', 'AES', 'AES192', 'ASE256')]
		[string]$Privacy,
		[securestring]$PrivacyKey,
		[string[]]$NetworkIds,
		[switch]$Raw
	)

	$resource = New-PrintixResource -Template 'tenants/{TenantId}/snmp' -Parameters $PSBoundParameters
	$request = @{ Resource = $resource; Method = 'POST'; Raw = $Raw }
	$request.Body = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Name = 'name'; GetCommunityName = 'getCommunityName'; SetCommunityName = 'setCommunityName'; TenantDefault = 'tenantDefault'; SecurityLevel = 'securityLevel'; Version = 'version'; Username = 'username'; ContextName = 'contextName'; Authentication = 'authentication'; AuthenticationKey = 'authenticationKey'; Privacy = 'privacy'; PrivacyKey = 'privacyKey'; NetworkIds = 'networkIds' }
	if ($PSCmdlet.ShouldProcess($resource, 'New-PrintixSnmpConfiguration')) {
		Invoke-PrintixRequest @request
	}
}
