BeforeAll {
	$syncScript = Join-Path $PSScriptRoot '..\DevOps\Help\Sync-Docs.ps1'
}

Describe 'Release gates' {
	BeforeAll {
		$releaseScript = Join-Path $PSScriptRoot '..\DevOps\Build\Test-Release.ps1'
		$version = (Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\Source\Printix.psd1')).ModuleVersion
	}

	BeforeEach {
		Mock git { $global:LASTEXITCODE = 0 }
	}

	It 'accepts main or the exact stable manifest version and verifies main ancestry' {
		& $releaseScript -RefName main -Commit test-commit
		& $releaseScript -RefName "v$version" -Commit test-commit
		Should -Invoke git -Times 2 -Exactly
	}

	It 'rejects mismatched versions, branches and prerelease tags before invoking git' {
		foreach ($ref in @('develop', 'v999.0.0', "v$version-beta1")) {
			{ & $releaseScript -RefName $ref -Commit test-commit } | Should -Throw '*matching stable tag*'
		}
		Should -Invoke git -Times 0 -Exactly
	}

	It 'rejects a commit that is not reachable from main' {
		Mock git { $global:LASTEXITCODE = 1 }
		{ & $releaseScript -RefName "v$version" -Commit test-commit } | Should -Throw '*reachable*'
	}
}

Describe 'Scoped documentation synchronization' {
	BeforeEach {
		$testRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
		$source = Join-Path $testRoot 'source'
		$destination = Join-Path $testRoot 'site'
		$null = New-Item -Path $source, $destination -ItemType Directory -Force
	}

	It 'copies MDX and removes stale Printix documents without touching other modules or assets' {
		$null = New-Item -Path "$destination\docs\printix", "$destination\docs\ninjaone" -ItemType Directory -Force
		Set-Content -LiteralPath "$source\index.mdx" -Value '# New overview'
		Set-Content -LiteralPath "$destination\docs\printix\stale.mdx" -Value '# Obsolete'
		Set-Content -LiteralPath "$destination\docs\printix\index.md" -Value '# Old format'
		Set-Content -LiteralPath "$destination\docs\printix\image.png" -Value 'preserved asset'
		Set-Content -LiteralPath "$destination\docs\ninjaone\index.mdx" -Value '# Other module'
		& $syncScript -SourcePath $source -DocsRepositoryPath $destination
		Get-Content -LiteralPath "$destination\docs\printix\index.mdx" | Should -Be '# New overview'
		Test-Path -LiteralPath "$destination\docs\printix\stale.mdx" | Should -BeFalse
		Test-Path -LiteralPath "$destination\docs\printix\index.md" | Should -BeFalse
		Get-Content -LiteralPath "$destination\docs\printix\image.png" | Should -Be 'preserved asset'
		Get-Content -LiteralPath "$destination\docs\ninjaone\index.mdx" | Should -Be '# Other module'
	}

	It 'syncs the development guide and overview without changing released command help' {
		$null = New-Item -Path "$source\development", "$destination\docs\printix\development", "$destination\docs\printix\commandlets" -ItemType Directory -Force
		Set-Content -LiteralPath "$source\index.mdx" -Value '# Updated overview'
		Set-Content -LiteralPath "$source\development\index.mdx" -Value '# Development'
		Set-Content -LiteralPath "$destination\docs\printix\index.mdx" -Value '# Released overview'
		Set-Content -LiteralPath "$destination\docs\printix\index.md" -Value '# Legacy overview'
		Set-Content -LiteralPath "$destination\docs\printix\commandlets\Get-PrintixUsers.mdx" -Value '# Released command'
		Set-Content -LiteralPath "$destination\docs\printix\development\stale.mdx" -Value '# Stale'
		& $syncScript -SourcePath $source -DocsRepositoryPath $destination -DevelopmentOnly
		Get-Content -LiteralPath "$destination\docs\printix\development\index.mdx" | Should -Be '# Development'
		Get-Content -LiteralPath "$destination\docs\printix\index.mdx" | Should -Be '# Updated overview'
		Get-Content -LiteralPath "$destination\docs\printix\commandlets\Get-PrintixUsers.mdx" | Should -Be '# Released command'
		Test-Path -LiteralPath "$destination\docs\printix\index.md" | Should -BeFalse
		Test-Path -LiteralPath "$destination\docs\printix\development\stale.mdx" | Should -BeFalse
	}

	It 'rejects incomplete artifacts and legacy Markdown before modifying the destination' {
		{ & $syncScript -SourcePath $source -DocsRepositoryPath $destination } | Should -Throw '*index.mdx*'
		Set-Content -LiteralPath "$source\index.mdx" -Value '# Overview'
		Set-Content -LiteralPath "$source\legacy.md" -Value '# Legacy'
		{ & $syncScript -SourcePath $source -DocsRepositoryPath $destination } | Should -Throw '*MDX documents only*'
		Test-Path -LiteralPath "$destination\docs\printix" | Should -BeFalse
	}
}
