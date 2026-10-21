BeforeAll {
	$manifestPath = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	Import-Module $manifestPath -Force -ErrorAction Stop
}

Describe 'Authentication' {
	BeforeEach {
		InModuleScope Printix {
			$Script:PrintixConnection = $null
			Mock Invoke-RestMethod {
				$Script:TokenBody = $Body.Clone()
				[pscustomobject]@{ access_token = 'offline-test-token'; expires_in = 3600 }
			}
		}
	}

	It 'uses the documented client credentials form and stores secrets securely' {
		InModuleScope Printix {
			$secret = ConvertTo-SecureString 'offline-client-secret' -AsPlainText -Force
			$result = Connect-Printix -ClientId test-client -ClientSecret $secret -TenantId t
			$result | Should -BeNullOrEmpty
			$Script:PrintixConnection.AccessToken | Should -BeOfType [securestring]
			$Script:PrintixConnection.ClientSecret | Should -BeOfType [securestring]
			$Script:TokenBody.grant_type | Should -BeExactly 'client_credentials'
			$Script:TokenBody.client_id | Should -BeExactly 'test-client'
			$Script:TokenBody.client_secret | Should -BeExactly 'offline-client-secret'
			Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
				$Uri -eq 'https://auth.printix.net/oauth/token' -and $Method -eq 'Post' -and
				$ContentType -eq 'application/x-www-form-urlencoded' -and
				$MaximumRedirection -eq 0
			}
		}
	}

	It 'reuses a valid token and renews it before expiration' {
		InModuleScope Printix {
			Connect-Printix -ClientId test-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force)
			Get-PrintixAccessToken | Should -BeExactly 'offline-test-token'
			Should -Invoke Invoke-RestMethod -Times 1 -Exactly
			$Script:PrintixConnection.ExpiresAt = [DateTimeOffset]::UtcNow.AddSeconds(10)
			Get-PrintixAccessToken | Should -BeExactly 'offline-test-token'
			Should -Invoke Invoke-RestMethod -Times 2 -Exactly
		}
	}

	It 'clears failed connections and surfaces authentication failures' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { throw 'OAuth rejected credentials' }
			{ Connect-Printix -ClientId test-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force) } | Should -Throw '*rejected*'
			$Script:PrintixConnection | Should -BeNullOrEmpty
		}
	}

	It 'rejects malformed token responses' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { [pscustomobject]@{ expires_in = 3600 } }
			{ Connect-Printix -ClientId test-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force) } | Should -Throw '*invalid token*'
		}
	}

	It 'disconnects and requires authentication for subsequent API calls' {
		InModuleScope Printix {
			Connect-Printix -ClientId test-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force)
			Disconnect-Printix
			{ Invoke-PrintixRequest -Resource 'tenants/t/users' } | Should -Throw '*Connect-Printix*'
		}
	}
}

Describe 'Request transport and HAL pagination' {
	BeforeEach {
		InModuleScope Printix {
			$Script:PrintixConnection = @{
				ClientId = 'test-client'
				ClientSecret = ConvertTo-SecureString 'secret' -AsPlainText -Force
				TenantId = 't'
				AccessToken = ConvertTo-SecureString 'offline-test-token' -AsPlainText -Force
				ExpiresAt = [DateTimeOffset]::UtcNow.AddHours(1)
			}
			$Script:Calls = [System.Collections.Generic.List[object]]::new()
			Mock Invoke-RestMethod {
				$Script:Calls.Add(@{ Uri = $Uri; Method = $Method; Body = $Body; Headers = $Headers; ContentType = $ContentType; MaximumRedirection = $MaximumRedirection })
				[pscustomobject]@{ success = $true; users = @([pscustomobject]@{ id = 'u1' }); _links = [pscustomobject]@{} }
			}
			Mock Start-Sleep {}
		}
	}

	It 'encodes query values without losing false, zero, role lists or UTF-8 text' {
		InModuleScope Printix {
			$null = Invoke-PrintixRequest -Resource 'tenants/t/users?existing=yes' -Query @{
				page = 0; enabled = $false; role = @('USER', 'GUEST_USER'); query = 'a+b & caf' + [char]0xE9; absent = $null
			}
			$uri = $Script:Calls[0].Uri.AbsoluteUri
			$uri | Should -Match 'existing=yes'
			$uri | Should -Match 'page=0'
			$uri | Should -Match 'enabled=false'
			$uri | Should -Match 'role=USER%2CGUEST_USER'
			$uri | Should -Match 'query=a%2Bb%20%26%20caf%C3%A9'
			$uri | Should -Not -Match 'absent='
			$Script:Calls[0].Headers.Authorization | Should -BeExactly 'Bearer offline-test-token'
			$Script:Calls[0].MaximumRedirection | Should -Be 0
		}
	}

	It 'sends both roles by default and only the selected role when explicitly filtered' {
		InModuleScope Printix {
			$null = Get-PrintixUsers
			$Script:Calls[0].Uri.Query | Should -BeExactly '?role=USER%2CGUEST_USER'
			$null = Get-PrintixUsers -Role USER
			$Script:Calls[1].Uri.Query | Should -BeExactly '?role=USER'
			$null = Get-PrintixUsers -Role GUEST_USER
			$Script:Calls[2].Uri.Query | Should -BeExactly '?role=GUEST_USER'
		}
	}

	It 'serializes nested bodies and preserves JSON boolean values' {
		InModuleScope Printix {
			$null = Invoke-PrintixRequest -Resource 'tenants/t/networks' -Method POST -Body @{
				homeOffice = $false; gateways = @(@{ mac = '00:11:22:33:44:55'; ip = '192.0.2.1' })
			}
			$body = $Script:Calls[0].Body | ConvertFrom-Json
			$body.homeOffice | Should -BeFalse
			$body.gateways[0].ip | Should -Be '192.0.2.1'
			$Script:Calls[0].ContentType | Should -Be 'application/json; charset=utf-8'
		}
	}

	It 'follows relative next links represented as an array and strips optional templates' {
		InModuleScope Printix {
			Mock Invoke-RestMethod {
				if ($Uri.Query -eq '?page=1') {
					[pscustomobject]@{ users = @([pscustomobject]@{ id = 'u2' }); _links = [pscustomobject]@{} }
				} else {
					[pscustomobject]@{ users = @([pscustomobject]@{ id = 'u1' }); _links = [pscustomobject]@{
						next = @([pscustomobject]@{ href = '?page=1{&query}'; templated = $true })
					} }
				}
			}
			$result = @(Get-PrintixUsers -All)
			$result.id | Should -Be @('u1', 'u2')
			Should -Invoke Invoke-RestMethod -Times 2 -Exactly
		}
	}

	It 'does not paginate by default and returns complete documents with Raw' {
		InModuleScope Printix {
			Mock Invoke-RestMethod {
				[pscustomobject]@{ users = @([pscustomobject]@{ id = 'u1' }); page = @{ number = 0 }; _links = @{
					next = @{ href = 'https://api.printix.net/cloudprint/tenants/t/users?page=1' }
				} }
			}
			$result = Get-PrintixUsers -Raw
			$result.page.number | Should -Be 0
			Should -Invoke Invoke-RestMethod -Times 1 -Exactly
		}
	}

	It 'emits no resources for an empty collection' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { [pscustomobject]@{ users = @(); _links = @{} } }
			@(Get-PrintixUsers -All).Count | Should -Be 0
		}
	}

	It 'extracts the single job from the documented jobs array' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { [pscustomobject]@{ jobs = @([pscustomobject]@{ id = 'j1' }); success = $true } }
			(Get-PrintixJob -JobId j1).id | Should -BeExactly 'j1'
		}
	}

	It 'retains submit upload links and other mutation response data' {
		InModuleScope Printix {
			Mock Invoke-RestMethod {
				[pscustomobject]@{ job = @{ id = 'j1' }; uploadLinks = @(@{ url = 'https://storage.example.test/file' }); _links = @{ uploadCompleted = @{ href = 'https://api.printix.net/cloudprint/tenants/t/jobs/j1/completeUpload' } } }
			}
			$result = New-PrintixJob -PrinterId p -QueueId q -Title Report
			$result.job.id | Should -Be 'j1'
			$result.uploadLinks.Count | Should -Be 1
			$result._links.uploadCompleted.href | Should -Match '/completeUpload$'
		}
	}

	It 'rejects off-origin, insecure, wrong-path and unresolved links before sending tokens' {
		InModuleScope Printix {
			foreach ($url in @('https://untrusted.example/cloudprint', 'http://api.printix.net/cloudprint',
				'https://api.printix.net/oauth', 'https://api.printix.net:444/cloudprint', 'https://user@api.printix.net/cloudprint',
				'tenants/{TenantId}/users')) {
				{ Invoke-PrintixRequest -Resource $url } | Should -Throw
			}
			Should -Invoke Invoke-RestMethod -Times 0 -Exactly
		}
	}

	It 'rejects attempts to override Authorization or paginate mutations' {
		{ Invoke-PrintixRequest -Resource 'tenants/t/users' -Headers @{ authorization = 'other' } } | Should -Throw '*Authorization*'
		{ Invoke-PrintixRequest -Resource 'tenants/t/users' -Method POST -All } | Should -Throw '*GET*'
	}

	It 'rejects cycles and untrusted next links' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { [pscustomobject]@{ users = @(); _links = [pscustomobject]@{ next = [pscustomobject]@{ href = 'https://api.printix.net/cloudprint/tenants/t/users' } } } }
			{ Get-PrintixUsers -All } | Should -Throw '*cycle*'
			Mock Invoke-RestMethod { [pscustomobject]@{ users = @(); _links = [pscustomobject]@{ next = [pscustomobject]@{ href = 'https://untrusted.example/users' } } } }
			{ Get-PrintixUsers -All } | Should -Throw '*Authenticated requests*'
		}
	}

	It 'surfaces service-level failures and missing expected collection fields' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { [pscustomobject]@{ success = $false; message = 'Denied'; internalErrorId = 'error-id' } }
			{ Get-PrintixUsers } | Should -Throw '*Denied*error-id*'
			Mock Invoke-RestMethod { [pscustomobject]@{ success = $true } }
			{ Get-PrintixUsers } | Should -Throw "*did not contain 'users'*"
		}
	}

	It 'does not retry non-429 HTTP errors' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { throw [System.Net.Http.HttpRequestException]::new('Service failed') }
			{ Invoke-PrintixRequest -Resource 'tenants/t/users' } | Should -Throw '*Service failed*'
			Should -Invoke Invoke-RestMethod -Times 1 -Exactly
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}
	}

	It 'retries only 429 responses and waits at least the server delay' {
		InModuleScope Printix {
			$Script:Attempt = 0
			Mock Invoke-RestMethod {
				$Script:Attempt++
				if ($Script:Attempt -eq 1) {
					$http = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
					$http.Headers.Add('X-Rate-Limit-Retry-After-Seconds', '4')
					throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Throttled', $http)
				}
				[pscustomobject]@{ users = @([pscustomobject]@{ id = 'u1' }) }
			}
			(Get-PrintixUsers).id | Should -Be 'u1'
			Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -ge 4 -and $Seconds -lt 5 }
			Should -Invoke Invoke-RestMethod -Times 2 -Exactly
		}
	}

	It 'bounds throttling retries and does not sleep after the final failure' {
		InModuleScope Printix {
			Mock Invoke-RestMethod {
				$http = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
				$http.Headers.Add('X-Rate-Limit-Retry-After-Seconds', '0')
				throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Throttled', $http)
			}
			{ Invoke-PrintixRequest -Resource 'tenants/t/users' -MaxRetryCount 2 } | Should -Throw '*Throttled*'
			Should -Invoke Invoke-RestMethod -Times 3 -Exactly
			Should -Invoke Start-Sleep -Times 2 -Exactly
		}
	}

	It 'rejects missing, negative and non-finite retry delays without sleeping' {
		InModuleScope Printix {
			foreach ($delay in @($null, '-1', 'NaN', 'Infinity', 'not-a-number')) {
				$Script:RetryDelay = $delay
				Mock Invoke-RestMethod {
					$http = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
					if ($null -ne $Script:RetryDelay) {
						$http.Headers.Add('X-Rate-Limit-Retry-After-Seconds', $Script:RetryDelay)
					}
					throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Throttled', $http)
				}
				{ Invoke-PrintixRequest -Resource 'tenants/t/users' } | Should -Throw '*valid X-Rate-Limit-Retry-After-Seconds*'
			}
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}
	}
}
