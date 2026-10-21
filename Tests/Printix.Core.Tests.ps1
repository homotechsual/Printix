BeforeAll {
	$manifestPath = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	$module = Import-Module $manifestPath -Force -PassThru -ErrorAction Stop
}

Describe 'Module scaffold' {
	It 'has a valid manifest and explicit exports' {
		$manifest = Test-ModuleManifest -Path $module.Path.Replace('.psm1', '.psd1') -ErrorAction Stop
		$manifest.Version.ToString() | Should -Be '0.1.0'
		$manifest.ExportedFunctions.Count | Should -Be 51
		$manifest.ExportedAliases.Count | Should -Be 0
		Get-Command Get-PrintixAccessToken -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
	}

	It 'exports exactly one function per public source file' {
		$sourceNames = Get-ChildItem (Join-Path $PSScriptRoot '..\Source\Public') -Recurse -Filter '*.ps1' | Select-Object -ExpandProperty BaseName
		Compare-Object ($sourceNames | Sort-Object) ($module.ExportedFunctions.Keys | Sort-Object) | Should -BeNullOrEmpty
	}

	It 'provides a synopsis, parameter help and an example for every public command' {
		foreach ($command in $module.ExportedFunctions.Keys) {
			$help = Get-Help $command -Full
			$help.Synopsis | Should -Not -BeNullOrEmpty -Because $command
			@($help.Examples.Example).Count | Should -BeGreaterThan 0 -Because $command
			$helpNames = @($help.Parameters.Parameter.Name)
			$parameters = (Get-Command $command).Parameters.Values | Where-Object { $_.Attributes -is [System.Management.Automation.ParameterAttribute] -and $_.Name -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and $_.Name -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters }
			foreach ($parameter in $parameters) {
				$helpNames | Should -Contain $parameter.Name -Because "$command parameter $($parameter.Name)"
			}
		}
	}

	It 'supports ShouldProcess on every remote mutation and file upload' {
		$commands = Get-Command -Module Printix | Where-Object { $_.Verb -in @('New', 'Set', 'Remove', 'Register', 'Complete', 'Send') }
		foreach ($command in $commands) {
			$command.Parameters.Keys | Should -Contain 'WhatIf' -Because $command.Name
		}
	}

	It 'has an endpoint reference and generated help without unresolved placeholders' {
		$docsRoot = Join-Path $PSScriptRoot '..\docs\Printix'
		Test-Path -LiteralPath (Join-Path $docsRoot 'api-coverage.mdx') | Should -BeTrue
		Test-Path -LiteralPath (Join-Path $docsRoot 'index.mdx') | Should -BeTrue
		Get-ChildItem -LiteralPath $docsRoot -Recurse -Filter '*.md' -File | Should -BeNullOrEmpty
		foreach ($command in $module.ExportedFunctions.Keys) {
			$source = Get-ChildItem (Join-Path $PSScriptRoot '..\Source\Public') -Recurse -Filter "$command.ps1" -File
			$path = Join-Path $docsRoot "commandlets\$($source.Directory.Name)\$command.mdx"
			Test-Path -LiteralPath $path | Should -BeTrue -Because $command
			Get-Content -LiteralPath $path -Raw | Should -Not -Match '\{\{' -Because $command
		}
	}

	It 'documents the required application type for every endpoint command' {
		foreach ($command in $module.ExportedFunctions.Keys | Where-Object { $_ -notin @('Connect-Printix', 'Disconnect-Printix', 'Disconnect-PrintixPartner', 'Invoke-PrintixRequest', 'Test-PrintixWebhookSignature') }) {
			$help = Get-Help $command -Full
			$help.Description.Text -join ' ' | Should -Match 'Required application type:' -Because $command
		}
		(Get-Help New-PrintixUserIdCode -Full).Description.Text -join ' ' | Should -Match 'not User manager'
		(Get-Help Get-PrintixWorkstations -Full).Description.Text -join ' ' | Should -Match 'Workstation monitoring'
		(Get-Help Connect-Printix -Full).Description.Text -join ' ' | Should -Match 'mutually exclusive'
	}
}
