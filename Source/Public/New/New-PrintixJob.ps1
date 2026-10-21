function New-PrintixJob {
	<#
	.SYNOPSIS
		Creates a print job using either documented submission version.
	.DESCRIPTION
		Returns the complete submission response, including uploadLinks and uploadCompleted.
		Creation alone does not upload or print a document. Version 1.1 is the default.
		Required application type: Cloud Print API or Card registration (API terminology).
		Requires Printix Premium.
	.PARAMETER TenantId
		The tenant ID, or the connection default.
	.PARAMETER PrinterId
		The physical printer ID from the queue's HAL link.
	.PARAMETER QueueId
		The print queue ID from the queue's HAL link.
	.PARAMETER Title
		The title of the job.
	.PARAMETER User
		The redirector username. Cannot be combined with user mapping.
	.PARAMETER PDL
		The document language for non-PDF files.
	.PARAMETER ReleaseImmediately
		Whether to print after upload completion. Defaults to the service setting (true).
	.PARAMETER Color
		Whether to print in color. Defaults to false.
	.PARAMETER Duplex
		The duplex setting. Defaults to NONE.
	.PARAMETER PageOrientation
		The page orientation. Defaults to AUTO.
	.PARAMETER Copies
		The number of copies. Defaults to one.
	.PARAMETER MediaSize
		A documented paper size. Defaults to A4.
	.PARAMETER Scaling
		The scaling setting. Defaults to NOSCALE.
	.PARAMETER UserMappingKey
		The user attribute used to assign ownership. Requires UserMappingValue.
	.PARAMETER UserMappingValue
		The value to match for UserMappingKey.
	.PARAMETER LegacyTicket
		An original-version printer ticket object. Mutually exclusive with modern settings.
	.EXAMPLE
		New-PrintixJob -PrinterId $printerId -QueueId $queueId -Title 'Monthly report' -Duplex LONG_EDGE -ReleaseImmediately $false
	.EXAMPLE
		New-PrintixJob -PrinterId $printerId -QueueId $queueId -Title 'Legacy document' -LegacyTicket $ticket
	.LINK
		https://printix.github.io/#_new_submit_method
	#>
	[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Modern')]
	[OutputType([object])]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TenantId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$PrinterId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$QueueId,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Title,
		[string]$User,
		[ValidateSet('PCL5', 'PCLXL', 'POSTSCRIPT', 'UFRII', 'TEXT', 'XPS')]
		[string]$PDL,
		[Parameter(ParameterSetName = 'Modern')]
		[bool]$ReleaseImmediately,
		[Parameter(ParameterSetName = 'Modern')]
		[bool]$Color = $false,
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateSet('NONE', 'SHORT_EDGE', 'LONG_EDGE')]
		[string]$Duplex = 'NONE',
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateSet('PORTRAIT', 'LANDSCAPE', 'AUTO')]
		[string]$PageOrientation = 'AUTO',
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateRange(1, [int]::MaxValue)]
		[int]$Copies = 1,
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateSet('A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'B4', 'B5', 'ISOA0', 'ISOA1', 'ISOA2', 'ISOA3',
			'ISOA4', 'ISOA5', 'ISOB4', 'ISOB5', 'LETTER', 'LEGAL', 'EXECUTIVE', 'EXEC', 'COM10', 'MONARCH', 'DL',
			'ANSIC', 'ANSID', 'ANSIE', 'ARCHC', 'ARCHD', 'ARCHE', 'TABLOID', 'JISB5', 'JISB4', 'STATEMENT')]
		[string]$MediaSize = 'A4',
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateSet('NOSCALE', 'SHRINK', 'FIT')]
		[string]$Scaling = 'NOSCALE',
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateSet('AzureObjectId', 'AzureUPN', 'SAMAccountName', 'OnPremImmutableId', 'OnPremUpn', 'Email')]
		[string]$UserMappingKey,
		[Parameter(ParameterSetName = 'Modern')]
		[ValidateNotNullOrEmpty()]
		[string]$UserMappingValue,
		[Parameter(Mandatory, ParameterSetName = 'Legacy')]
		[ValidateNotNullOrEmpty()]
		[hashtable]$LegacyTicket
	)

	if ($PSBoundParameters.ContainsKey('UserMappingKey') -xor $PSBoundParameters.ContainsKey('UserMappingValue')) {
		throw 'Specify both UserMappingKey and UserMappingValue.'
	}
	if ($PSBoundParameters.ContainsKey('User') -and $PSBoundParameters.ContainsKey('UserMappingKey')) {
		throw 'User and user mapping cannot be specified together.'
	}
	$resource = New-PrintixResource -Template 'tenants/{TenantId}/printers/{PrinterId}/queues/{QueueId}/submit' -Parameters $PSBoundParameters
	$query = ConvertTo-PrintixFields -Parameters $PSBoundParameters -Map @{ Title = 'title'; User = 'user'; PDL = 'PDL'; ReleaseImmediately = 'releaseImmediately' }
	$headers = @{}
	if ($PSCmdlet.ParameterSetName -eq 'Legacy') {
		$body = $LegacyTicket
	} else {
		$headers.version = '1.1'
		$body = @{
			color = $Color
			duplex = $Duplex
			page_orientation = $PageOrientation
			copies = $Copies
			media_size = $MediaSize
			scaling = $Scaling
		}
		if ($UserMappingKey) {
			$body.userMapping = @{ key = $UserMappingKey; value = $UserMappingValue }
		}
	}
	if ($PSCmdlet.ShouldProcess($resource, "Create print job '$Title'")) {
		Invoke-PrintixRequest -Resource $resource -Method POST -Query $query -Body $body -Headers $headers
	}
}
