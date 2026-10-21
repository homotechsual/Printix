BeforeAll {
	$manifestPath = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	Import-Module $manifestPath -Force -ErrorAction Stop
}

Describe 'Cloud storage uploads' {
	BeforeEach {
		$file = Join-Path $TestDrive 'print.pdf'
		[IO.File]::WriteAllBytes($file, [byte[]]@(0, 1, 2, 3, 255))
		Mock Invoke-WebRequest -ModuleName Printix { [pscustomobject]@{ StatusCode = 201 } }
	}

	It 'uploads binary data with provider headers and no Printix authentication' {
		$link = [pscustomobject]@{ url = 'https://storage.example.test/document?signature=example'; headers = [pscustomobject]@{ 'x-ms-blob-type' = 'BlockBlob' } }
		$link | Send-PrintixJobFile -Path $file
		Should -Invoke Invoke-WebRequest -ModuleName Printix -Times 1 -Exactly -ParameterFilter {
			$Method -eq 'Put' -and $Headers['x-ms-blob-type'] -eq 'BlockBlob' -and -not $Headers.ContainsKey('Authorization') -and
			$InFile -like '*print.pdf' -and $ContentType -eq 'application/pdf' -and $MaximumRedirection -eq 0
		}
	}

	It 'uploads every link and respects provider content types' {
		@(
			@{ url = 'https://storage.example.test/one'; headers = @{ 'Content-Type' = 'application/octet-stream' } }
			@{ url = 'https://storage.example.test/two'; headers = @{ 'Content-Type' = 'application/octet-stream' } }
		) | Send-PrintixJobFile -Path $file
		Should -Invoke Invoke-WebRequest -ModuleName Printix -Times 2 -Exactly -ParameterFilter { $ContentType -eq 'application/octet-stream' }
	}

	It 'rejects missing files, insecure URLs and unexpected authorization headers' {
		{ Send-PrintixJobFile -Path (Join-Path $TestDrive 'missing.pdf') -UploadLink @{ url = 'https://storage.example.test/file' } } | Should -Throw
		{ Send-PrintixJobFile -Path $file -UploadLink @{ url = 'http://storage.example.test/file' } } | Should -Throw '*HTTPS*'
		{ Send-PrintixJobFile -Path $file -UploadLink @{ url = 'https://storage.example.test/file'; headers = @{ Authorization = 'Bearer accidental' } } } | Should -Throw '*Authorization*'
		Should -Invoke Invoke-WebRequest -ModuleName Printix -Times 0 -Exactly
	}

	It 'does not upload with WhatIf' {
		Send-PrintixJobFile -Path $file -UploadLink @{ url = 'https://storage.example.test/file' } -WhatIf
		Should -Invoke Invoke-WebRequest -ModuleName Printix -Times 0 -Exactly
	}

	It 'surfaces storage failures and unexpected success statuses' {
		Mock Invoke-WebRequest -ModuleName Printix { throw 'Storage rejected file' }
		{ Send-PrintixJobFile -Path $file -UploadLink @{ url = 'https://storage.example.test/file' } } | Should -Throw '*Storage rejected*'
		Mock Invoke-WebRequest -ModuleName Printix { [pscustomobject]@{ StatusCode = 202 } }
		{ Send-PrintixJobFile -Path $file -UploadLink @{ url = 'https://storage.example.test/file' } } | Should -Throw '*202*'
	}
}
