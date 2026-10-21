BeforeAll {
	$manifest = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	Import-Module $manifest -Force
	$page = Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\docs\Printix\examples\user-id-codes-to-excel.mdx') -Raw
	$blocks = [regex]::Matches($page, '(?s)```powershell\r?\n(.*?)```')
	$exampleText = $blocks[1].Groups[1].Value
}

Describe 'Excel ID-code documentation example' {
	It 'contains syntactically valid PowerShell' {
		$tokens = $null
		$parseErrors = $null
		$null = [Management.Automation.Language.Parser]::ParseInput($exampleText, [ref]$tokens, [ref]$parseErrors)
		$parseErrors | Should -BeNullOrEmpty
	}

	Context 'Workbook behaviour' -Skip:(-not (Get-Module -ListAvailable ImportExcel)) {
		BeforeAll {
			Import-Module ImportExcel
		}
		BeforeEach {
			$outputFile = Join-Path $TestDrive "$([guid]::NewGuid().ToString('N')).xlsx"
			$scriptText = $exampleText.Replace("Join-Path `$HOME 'Printix-UserIdCodes.xlsx'", "'$($outputFile.Replace("'", "''"))'")
			$example = [scriptblock]::Create($scriptText)
			Mock Get-PrintixUsers {
				[pscustomobject]@{ id = 'u1'; fullName = '=1+1'; email = 'first@example.test'; role = 'USER' }
				[pscustomobject]@{ id = 'u2'; fullName = 'Second User'; email = 'second@example.test'; role = 'GUEST_USER' }
			}
			Mock New-PrintixUserIdCode { [pscustomobject]@{ success = $true; idCode = '001234' } }
			Mock Start-Sleep {}
		}

		It 'exports names, emails and text codes without spreadsheet formulas' {
			& $example
			$rows = @(Import-Excel -Path $outputFile -WorksheetName UserIdCodes)
			$rows.Count | Should -Be 2
			$rows[0].Email | Should -Be 'first@example.test'
			$rows[0].IdCode | Should -BeExactly '001234'
			$rows[0].FullName | Should -BeExactly "'=1+1"
			$package = Open-ExcelPackage -Path $outputFile
			try {
				$sheet = $package.Workbook.Worksheets['UserIdCodes']
				$sheet.Cells[2, 5].Value | Should -BeOfType ([string])
				@($sheet.Cells | Where-Object Formula).Count | Should -Be 0
			} finally {
				$package.Dispose()
			}
			Should -Invoke Get-PrintixUsers -Times 1 -ParameterFilter { $All -and $TenantId -eq 'your-tenant-id' }
		}

		It 'keeps the first saved row and stops when a later API call fails' {
			Mock New-PrintixUserIdCode { throw 'API failure' } -ParameterFilter { $UserId -eq 'u2' }
			{ & $example } | Should -Throw '*API failure*'
			@(Import-Excel -Path $outputFile -WorksheetName UserIdCodes).Count | Should -Be 1
		}

		It 'refuses to overwrite an existing workbook before changing codes' {
			Set-Content -LiteralPath $outputFile -Value 'existing'
			{ & $example } | Should -Throw '*already exists*'
			Should -Invoke New-PrintixUserIdCode -Times 0
		}

		It 'stops at a failed save rather than generating another code' {
			Mock Export-Excel {}
			Mock Export-Excel { throw 'disk failure' } -ParameterFilter { $WorksheetName -eq 'UserIdCodes' }
			{ & $example } | Should -Throw '*Workbook save failed for user u1*'
			Should -Invoke New-PrintixUserIdCode -Times 1
		}
	}
}
