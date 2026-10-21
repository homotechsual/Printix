@{
	Severity = @('Error', 'Warning')
	IncludeDefaultRules = $true
	ExcludeRules = @(
		# Match the reference modules' distinct singular/detail and plural/list command names.
		'PSUseSingularNouns'
	)
}
