BeforeAll {
	$manifestPath = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	Import-Module $manifestPath -Force -ErrorAction Stop
}

Describe 'Partner authentication and connection isolation' {
	BeforeEach {
		InModuleScope Printix {
			$Script:PrintixConnection = $null
			$Script:PrintixPartnerConnection = $null
			$Script:TokenBodies = [System.Collections.Generic.List[object]]::new()
			Mock Invoke-RestMethod {
				$Script:TokenBodies.Add($Body.Clone())
				[pscustomobject]@{ access_token = 'test-partner-token'; refresh_token = 'test-partner-refresh'; expires_in = 599 }
			}
		}
	}

	It 'requests partner tokens using client credentials and retains the partner ID' {
		InModuleScope Printix {
			Connect-PrintixPartner -ClientId partner-client -ClientSecret (ConvertTo-SecureString 'test-secret' -AsPlainText -Force) -PartnerId p
			$Script:TokenBodies[0].grant_type | Should -BeExactly 'client_credentials'
			$Script:TokenBodies[0].client_id | Should -BeExactly 'partner-client'
			$Script:TokenBodies[0].client_secret | Should -BeExactly 'test-secret'
			$Script:PrintixPartnerConnection.PartnerId | Should -BeExactly 'p'
			$Script:PrintixPartnerConnection.AccessToken | Should -BeOfType [securestring]
			$Script:PrintixPartnerConnection.RefreshToken | Should -BeOfType [securestring]
			$Script:PrintixConnection | Should -BeNullOrEmpty
			Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -eq 'https://auth.printix.net/oauth/token' -and $MaximumRedirection -eq 0 }
		}
	}

	It 'renews using and rotates the returned refresh token without sending the client secret' {
		InModuleScope Printix {
			Connect-PrintixPartner -ClientId partner-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force) -PartnerId p
			$Script:PrintixPartnerConnection.ExpiresAt = [DateTimeOffset]::UtcNow
			Mock Invoke-RestMethod {
				$Script:TokenBodies.Add($Body.Clone())
				[pscustomobject]@{ access_token = 'new-token'; refresh_token = 'rotated-refresh'; expires_in = 599 }
			}
			Get-PrintixAccessToken -Partner | Should -BeExactly 'new-token'
			$Script:TokenBodies[1].grant_type | Should -BeExactly 'refresh_token'
			$Script:TokenBodies[1].refresh_token | Should -BeExactly 'test-partner-refresh'
			$Script:TokenBodies[1].ContainsKey('client_secret') | Should -BeFalse
			([pscredential]::new('test', $Script:PrintixPartnerConnection.RefreshToken)).GetNetworkCredential().Password | Should -BeExactly 'rotated-refresh'
		}
	}

	It 'renews using client credentials when the service supplies no refresh token' {
		InModuleScope Printix {
			Mock Invoke-RestMethod {
				$Script:TokenBodies.Add($Body.Clone())
				[pscustomobject]@{ access_token = 'token'; expires_in = 599 }
			}
			Connect-PrintixPartner -ClientId partner-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force) -PartnerId p
			$Script:PrintixPartnerConnection.ExpiresAt = [DateTimeOffset]::UtcNow
			$null = Get-PrintixAccessToken -Partner
			$Script:TokenBodies[1].grant_type | Should -BeExactly 'client_credentials'
		}
	}

	It 'does not replace or disconnect the other API connection' {
		InModuleScope Printix {
			$secret = ConvertTo-SecureString 'secret' -AsPlainText -Force
			Connect-Printix -ClientId cloud-client -ClientSecret $secret -TenantId t
			$cloud = $Script:PrintixConnection
			Connect-PrintixPartner -ClientId partner-client -ClientSecret $secret -PartnerId p
			[object]::ReferenceEquals($cloud, $Script:PrintixConnection) | Should -BeTrue
			Disconnect-PrintixPartner
			$Script:PrintixPartnerConnection | Should -BeNullOrEmpty
			$Script:PrintixConnection.ClientId | Should -BeExactly 'cloud-client'
			Connect-PrintixPartner -ClientId partner-client -ClientSecret $secret -PartnerId p
			Disconnect-Printix
			$Script:PrintixPartnerConnection.ClientId | Should -BeExactly 'partner-client'
		}
	}

	It 'surfaces refresh errors without silently falling back to client credentials' {
		InModuleScope Printix {
			Connect-PrintixPartner -ClientId partner-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force) -PartnerId p
			$Script:PrintixPartnerConnection.ExpiresAt = [DateTimeOffset]::UtcNow
			Mock Invoke-RestMethod {
				$Script:FailedRefreshBody = $Body.Clone()
				throw 'Partner refresh rejected'
			}
			{ Get-PrintixAccessToken -Partner } | Should -Throw '*refresh rejected*'
			$Script:FailedRefreshBody.grant_type | Should -BeExactly 'refresh_token'
			Should -Invoke Invoke-RestMethod -Times 2 -Exactly
		}
	}

	It 'clears only a failed partner connection and surfaces OAuth failures' {
		InModuleScope Printix {
			$Script:PrintixConnection = @{ TenantId = 'preserved' }
			Mock Invoke-RestMethod { throw 'Partner credentials rejected' }
			{ Connect-PrintixPartner -ClientId partner-client -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force) -PartnerId p } | Should -Throw '*rejected*'
			$Script:PrintixPartnerConnection | Should -BeNullOrEmpty
			$Script:PrintixConnection.TenantId | Should -BeExactly 'preserved'
		}
	}
}

Describe 'Partner endpoint and transport contracts' {
	BeforeEach {
		InModuleScope Printix {
			$Script:PrintixConnection = @{
				TenantId = 'cloud-tenant'
				AccessToken = ConvertTo-SecureString 'cloud-token' -AsPlainText -Force
				ExpiresAt = [DateTimeOffset]::UtcNow.AddHours(1)
			}
			$Script:PrintixPartnerConnection = @{
				PartnerId = 'p'
				AccessToken = ConvertTo-SecureString 'partner-token' -AsPlainText -Force
				ExpiresAt = [DateTimeOffset]::UtcNow.AddHours(1)
			}
			$Script:PartnerCalls = [System.Collections.Generic.List[object]]::new()
			Mock Invoke-RestMethod {
				$Script:PartnerCalls.Add(@{ Uri = $Uri; Method = $Method; Headers = $Headers; Body = $Body; MaximumRedirection = $MaximumRedirection })
				[pscustomobject]@{
					tenants = @([pscustomobject]@{ tenant_name = 'Acme'; tenant_domain = 'acme.printix.net' })
					tenant_name = 'Acme'
					_embedded = @{ billing_info = @{ current_billing_period = @{ active_users = 5 } } }
					current_billing_period = @{ active_users = 5 }
					current_user_licenses = 10
					_links = @{ self = @{ href = 'https://api.printix.net/public/partners/p/tenants/t' } }
				}
			}
			Mock Start-Sleep {}
		}
	}

	It 'lists active tenants by default using the partner token and HAL accept header' {
		InModuleScope Printix {
			$result = Get-PrintixPartnerTenants
			$result.tenant_name | Should -BeExactly 'Acme'
			$call = $Script:PartnerCalls[0]
			$call.Uri.AbsoluteUri | Should -BeExactly 'https://api.printix.net/public/partners/p/tenants?include-inactive=false'
			$call.Method | Should -Be 'GET'
			$call.Headers.Accept | Should -BeExactly 'application/hal+json'
			$call.Headers.Authorization | Should -BeExactly 'Bearer partner-token'
			$call.MaximumRedirection | Should -Be 0
		}
	}

	It 'supports inactive tenants, partner overrides, encoded identifiers and Raw output' {
		InModuleScope Printix {
			$result = Get-PrintixPartnerTenants -PartnerId 'other/id' -IncludeInactive -Raw
			$result._links.self.href | Should -Not -BeNullOrEmpty
			$result.tenants.Count | Should -Be 1
			$Script:PartnerCalls[0].Uri.AbsoluteUri | Should -BeExactly 'https://api.printix.net/public/partners/other%2Fid/tenants?include-inactive=true'
		}
	}

	It 'gets a single tenant and embeds billing information when requested' {
		InModuleScope Printix {
			$result = Get-PrintixPartnerTenant -TenantId t -EmbedBillingInfo
			$result._embedded.billing_info.current_billing_period.active_users | Should -Be 5
			$Script:PartnerCalls[0].Uri.AbsoluteUri | Should -BeExactly 'https://api.printix.net/public/partners/p/tenants/t?embed=billing-info'
			$null = Get-PrintixPartnerTenant -TenantId t
			$Script:PartnerCalls[1].Uri.Query | Should -BeNullOrEmpty
		}
	}

	It 'gets the billing resource without discarding license or HAL fields' {
		InModuleScope Printix {
			$result = Get-PrintixPartnerTenantBillingInfo -TenantId t
			$result.current_billing_period.active_users | Should -Be 5
			$result.current_user_licenses | Should -Be 10
			$result._links.self.href | Should -Not -BeNullOrEmpty
			$Script:PartnerCalls[0].Uri.AbsolutePath | Should -BeExactly '/public/partners/p/tenants/t/billing-info'
			$Script:PartnerCalls[0].Method | Should -Be 'GET'
		}
	}

	It 'creates a tenant with only the documented required body fields' {
		InModuleScope Printix {
			$result = New-PrintixPartnerTenant -TenantName 'Acme Co.' -TenantDomain acme
			$call = $Script:PartnerCalls[0]
			$call.Uri.AbsolutePath | Should -BeExactly '/public/partners/p/tenants'
			$call.Method | Should -Be 'POST'
			$body = $call.Body | ConvertFrom-Json -AsHashtable
			$body.Count | Should -Be 2
			$body.tenant_name | Should -BeExactly 'Acme Co.'
			$body.tenant_domain | Should -BeExactly 'acme'
			$result._embedded.billing_info | Should -Not -BeNullOrEmpty
		}
	}

	It 'creates the initial user with an explicit false or true admin flag' {
		InModuleScope Printix {
			$null = New-PrintixPartnerTenant -TenantName Acme -TenantDomain acme -InitialUserEmail admin@acme.example -InitialUserName 'Alex Admin'
			$body = $Script:PartnerCalls[0].Body | ConvertFrom-Json
			$body.initial_user.email | Should -BeExactly 'admin@acme.example'
			$body.initial_user.name | Should -BeExactly 'Alex Admin'
			$body.initial_user.create_as_admin | Should -BeFalse
			$null = New-PrintixPartnerTenant -TenantName Acme -TenantDomain acme -InitialUserEmail admin@acme.example -InitialUserName 'Alex Admin' -CreateInitialUserAsAdmin
			($Script:PartnerCalls[1].Body | ConvertFrom-Json).initial_user.create_as_admin | Should -BeTrue
		}
	}

	It 'validates exact tenant-name length and lowercase subdomain requirements' {
		{ New-PrintixPartnerTenant -TenantName ('a' * 101) -TenantDomain acme } | Should -Throw
		foreach ($domain in @('Acme', 'acme.printix.net', 'acme_test', 'acme test', '')) {
			{ New-PrintixPartnerTenant -TenantName Acme -TenantDomain $domain } | Should -Throw
		}
		InModuleScope Printix {
			$null = New-PrintixPartnerTenant -TenantName ('a' * 100) -TenantDomain acme-123
			Should -Invoke Invoke-RestMethod -Times 1 -Exactly
		}
	}

	It 'does not create a tenant with WhatIf' {
		InModuleScope Printix {
			New-PrintixPartnerTenant -TenantName Acme -TenantDomain acme -WhatIf
			Should -Invoke Invoke-RestMethod -Times 0 -Exactly
		}
	}

	It 'requires a partner ID and never silently uses a Cloud Print token' {
		InModuleScope Printix {
			$Script:PrintixPartnerConnection = $null
			{ Get-PrintixPartnerTenants } | Should -Throw '*PartnerId*'
			{ Get-PrintixPartnerTenants -PartnerId p } | Should -Throw '*Connect-PrintixPartner*'
			Should -Invoke Invoke-RestMethod -Times 0 -Exactly
		}
	}

	It 'isolates API paths and rejects off-origin links before sending credentials' {
		InModuleScope Printix {
			foreach ($url in @('https://api.printix.net/cloudprint/tenants/t/users',
				'https://untrusted.example/public/partners/p/tenants',
				'http://api.printix.net/public/partners/p/tenants',
				'https://api.printix.net:444/public/partners/p/tenants',
				'https://user@api.printix.net/public/partners/p/tenants',
				'https://api.printix.net/public/partners-extra/p/tenants')) {
				{ Invoke-PrintixPartnerRequest -Resource $url } | Should -Throw
			}
			{ Invoke-PrintixRequest -Resource 'https://api.printix.net/public/partners/p/tenants' } | Should -Throw
			Should -Invoke Invoke-RestMethod -Times 0 -Exactly
		}
	}

	It 'follows a partner billing HAL link with the partner connection' {
		InModuleScope Printix {
			$null = Invoke-PrintixPartnerRequest -Resource 'https://api.printix.net/public/partners/p/tenants/t/billing-info'
			$Script:PartnerCalls[0].Headers.Authorization | Should -BeExactly 'Bearer partner-token'
		}
	}

	It 'returns an empty tenant collection without inventing paging parameters' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { [pscustomobject]@{ tenants = @(); _links = @{} } }
			@(Get-PrintixPartnerTenants).Count | Should -Be 0
			(Get-Command Get-PrintixPartnerTenants).Parameters.ContainsKey('All') | Should -BeFalse
		}
	}

	It 'surfaces partner errors without retrying a failed mutation' {
		InModuleScope Printix {
			Mock Invoke-RestMethod { throw 'Partner denied tenant creation' }
			{ New-PrintixPartnerTenant -TenantName Acme -TenantDomain acme } | Should -Throw '*denied*'
			Should -Invoke Invoke-RestMethod -Times 1 -Exactly
		}
	}

	It 'honours standard Retry-After on partner throttling' {
		InModuleScope Printix {
			$Script:PartnerAttempt = 0
			Mock Invoke-RestMethod {
				$Script:PartnerAttempt++
				if ($Script:PartnerAttempt -eq 1) {
					$http = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
					$http.Headers.Add('Retry-After', '4')
					throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Throttled', $http)
				}
				[pscustomobject]@{ tenants = @() }
			}
			$null = Get-PrintixPartnerTenants
			Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -ge 4 -and $Seconds -lt 5 }
			Should -Invoke Invoke-RestMethod -Times 2 -Exactly
		}
	}

	It 'uses bounded backoff when partner throttling has no delay header' {
		InModuleScope Printix {
			Mock Invoke-RestMethod {
				$http = [System.Net.Http.HttpResponseMessage]::new([System.Net.HttpStatusCode]::TooManyRequests)
				throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Throttled', $http)
			}
			{ Invoke-PrintixPartnerRequest -Resource 'p/tenants' -MaxRetryCount 1 } | Should -Throw '*Throttled*'
			Should -Invoke Invoke-RestMethod -Times 2 -Exactly
			Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -ge 1 -and $Seconds -lt 2 }
		}
	}
}
