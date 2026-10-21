function Send-PrintixJobFile {
	<#
	.SYNOPSIS
		Uploads a document to a cloud storage link returned by Printix.
	.DESCRIPTION
		Uses the upload link's URL and provider headers without a Printix bearer token.
		Does not complete the job; call Complete-PrintixJobUpload after all uploads succeed.
		Required application type: none for this storage request. Uses a signed upload link
		from an authorized submission; never send a Printix access token to cloud storage.
	.PARAMETER UploadLink
		An entry from the submission response's uploadLinks array.
	.PARAMETER Path
		The local file to upload.
	.PARAMETER ContentType
		The document MIME type. Defaults to application/pdf unless supplied by the upload link.
	.EXAMPLE
		$job.uploadLinks | Send-PrintixJobFile -Path '.\report.pdf'
	.LINK
		https://printix.github.io/#_upload_a_file
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType([void])]
	param(
		[Parameter(Mandatory, ValueFromPipeline)]
		[ValidateNotNull()]
		[object]$UploadLink,
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,
		[ValidateNotNullOrEmpty()]
		[string]$ContentType = 'application/pdf'
	)

	process {
		$urlValue = if ($UploadLink -is [System.Collections.IDictionary]) { $UploadLink['url'] } else { $UploadLink.PSObject.Properties['url'].Value }
		$url = $null
		if (-not [uri]::TryCreate([string]$urlValue, [UriKind]::Absolute, [ref]$url) -or
			$url.Scheme -ne 'https' -or $url.UserInfo -or $url.IsLoopback) {
			throw 'UploadLink must contain an absolute HTTPS storage URL without user information.'
		}
		$file = Get-Item -LiteralPath $Path -ErrorAction Stop
		if ($file -isnot [System.IO.FileInfo]) { throw 'Path must identify a file.' }
		$headers = @{}
		$providerHeaders = if ($UploadLink -is [System.Collections.IDictionary]) {
			$UploadLink['headers']
		} elseif ($UploadLink.PSObject.Properties['headers']) {
			$UploadLink.headers
		}
		if ($providerHeaders -is [System.Collections.IDictionary]) {
			foreach ($key in $providerHeaders.Keys) { $headers[$key] = $providerHeaders[$key] }
		} elseif ($null -ne $providerHeaders) {
			foreach ($property in $providerHeaders.PSObject.Properties) { $headers[$property.Name] = $property.Value }
		}
		if ($headers.ContainsKey('Authorization')) {
			throw 'Storage uploads must not contain an Authorization header.'
		}
		$uploadContentType = $ContentType
		if ($headers.ContainsKey('Content-Type')) {
			$uploadContentType = $headers['Content-Type']
			$headers.Remove('Content-Type')
		}
		if ($PSCmdlet.ShouldProcess($file.FullName, 'Upload print document to cloud storage')) {
			$response = Invoke-WebRequest -Uri $url -Method Put -Headers $headers -InFile $file.FullName -ContentType $uploadContentType -MaximumRedirection 0 -ErrorAction Stop
			if ([int]$response.StatusCode -notin @(200, 201)) {
				throw "Unexpected storage upload status: $($response.StatusCode)."
			}
		}
	}
}
