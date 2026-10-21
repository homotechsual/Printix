$endpointCases = @(
	@{ Command = 'Get-PrintixRoot'; Method = 'GET'; Expected = 'https://api.printix.net/cloudprint'; Arguments = @{}; Property = '' }
	@{ Command = 'Get-PrintixPrintQueues'; Method = 'GET'; Expected = 'tenants/t/printers'; Arguments = @{}; Property = 'printers' }
	@{ Command = 'Get-PrintixPrinter'; Method = 'GET'; Expected = 'tenants/t/printers/p/queues/q'; Arguments = @{ PrinterId = 'p'; QueueId = 'q' }; Property = 'printers' }
	@{ Command = 'Get-PrintixJobs'; Method = 'GET'; Expected = 'tenants/t/jobs'; Arguments = @{}; Property = 'jobs' }
	@{ Command = 'Get-PrintixPrintQueueJobs'; Method = 'GET'; Expected = 'tenants/t/printers/p/queues/q/jobs'; Arguments = @{ PrinterId = 'p'; QueueId = 'q' }; Property = 'jobs' }
	@{ Command = 'Get-PrintixJob'; Method = 'GET'; Expected = 'tenants/t/jobs/j'; Arguments = @{ JobId = 'j' }; Property = 'jobs' }
	@{ Command = 'Remove-PrintixJob'; Method = 'POST'; Expected = 'tenants/t/jobs/j/delete'; Arguments = @{ JobId = 'j' }; Property = '' }
	@{ Command = 'Complete-PrintixJobUpload'; Method = 'POST'; Expected = 'tenants/t/jobs/j/completeUpload'; Arguments = @{ JobId = 'j' }; Property = '' }
	@{ Command = 'Set-PrintixJobOwner'; Method = 'POST'; Expected = 'tenants/t/jobs/j/changeOwner'; Arguments = @{ JobId = 'j'; UserEmail = 'person@example.test' }; Property = '' }
	@{ Command = 'New-PrintixUser'; Method = 'POST'; Expected = 'tenants/t/users/create'; Arguments = @{ Email = 'person@example.test'; FullName = 'A Person'; Role = 'USER' }; Property = '' }
	@{ Command = 'Get-PrintixUsers'; Method = 'GET'; Expected = 'tenants/t/users'; Arguments = @{}; Property = 'users' }
	@{ Command = 'Get-PrintixUser'; Method = 'GET'; Expected = 'tenants/t/users/u'; Arguments = @{ UserId = 'u' }; Property = 'user' }
	@{ Command = 'Remove-PrintixUser'; Method = 'POST'; Expected = 'tenants/t/users/u/delete'; Arguments = @{ UserId = 'u' }; Property = '' }
	@{ Command = 'New-PrintixUserIdCode'; Method = 'POST'; Expected = 'tenants/t/users/u/idCode'; Arguments = @{ UserId = 'u' }; Property = '' }
	@{ Command = 'New-PrintixGroup'; Method = 'POST'; Expected = 'tenants/t/groups'; Arguments = @{ Name = 'Group'; ExternalId = 'external' }; Property = '' }
	@{ Command = 'Get-PrintixGroups'; Method = 'GET'; Expected = 'tenants/t/groups'; Arguments = @{}; Property = 'groups' }
	@{ Command = 'Get-PrintixGroup'; Method = 'GET'; Expected = 'tenants/t/groups/g'; Arguments = @{ GroupId = 'g' }; Property = 'group' }
	@{ Command = 'Remove-PrintixGroup'; Method = 'DELETE'; Expected = 'tenants/t/groups/g'; Arguments = @{ GroupId = 'g' }; Property = '' }
	@{ Command = 'Register-PrintixCard'; Method = 'POST'; Expected = 'tenants/t/users/u/cards'; Arguments = @{ UserId = 'u'; Secret = (ConvertTo-SecureString 'AQID' -AsPlainText -Force) }; Property = '' }
	@{ Command = 'Get-PrintixCard'; Method = 'GET'; Expected = 'tenants/t/cards/c'; Arguments = @{ CardId = 'c' }; Property = 'card' }
	@{ Command = 'Remove-PrintixCard'; Method = 'DELETE'; Expected = 'tenants/t/cards/c'; Arguments = @{ CardId = 'c' }; Property = '' }
	@{ Command = 'New-PrintixSite'; Method = 'POST'; Expected = 'tenants/t/sites'; Arguments = @{ Name = 'Site' }; Property = '' }
	@{ Command = 'Get-PrintixSite'; Method = 'GET'; Expected = 'tenants/t/sites/s'; Arguments = @{ SiteId = 's' }; Property = '' }
	@{ Command = 'Set-PrintixSite'; Method = 'PUT'; Expected = 'tenants/t/sites/s'; Arguments = @{ SiteId = 's'; Name = 'Site' }; Property = '' }
	@{ Command = 'Remove-PrintixSite'; Method = 'DELETE'; Expected = 'tenants/t/sites/s'; Arguments = @{ SiteId = 's' }; Property = '' }
	@{ Command = 'Get-PrintixSites'; Method = 'GET'; Expected = 'tenants/t/sites'; Arguments = @{}; Property = 'sites' }
	@{ Command = 'New-PrintixNetwork'; Method = 'POST'; Expected = 'tenants/t/networks'; Arguments = @{ Name = 'Network' }; Property = '' }
	@{ Command = 'Get-PrintixNetwork'; Method = 'GET'; Expected = 'tenants/t/networks/n'; Arguments = @{ NetworkId = 'n' }; Property = '' }
	@{ Command = 'Set-PrintixNetwork'; Method = 'PUT'; Expected = 'tenants/t/networks/n'; Arguments = @{ NetworkId = 'n'; Name = 'Network' }; Property = '' }
	@{ Command = 'Remove-PrintixNetwork'; Method = 'DELETE'; Expected = 'tenants/t/networks/n'; Arguments = @{ NetworkId = 'n' }; Property = '' }
	@{ Command = 'Get-PrintixNetworks'; Method = 'GET'; Expected = 'tenants/t/networks'; Arguments = @{}; Property = 'networks' }
	@{ Command = 'New-PrintixSnmpConfiguration'; Method = 'POST'; Expected = 'tenants/t/snmp'; Arguments = @{ Name = 'SNMP' }; Property = '' }
	@{ Command = 'Get-PrintixSnmpConfiguration'; Method = 'GET'; Expected = 'tenants/t/snmp/x'; Arguments = @{ SnmpId = 'x' }; Property = '' }
	@{ Command = 'Set-PrintixSnmpConfiguration'; Method = 'PUT'; Expected = 'tenants/t/snmp/x'; Arguments = @{ SnmpId = 'x'; Name = 'SNMP' }; Property = '' }
	@{ Command = 'Remove-PrintixSnmpConfiguration'; Method = 'DELETE'; Expected = 'tenants/t/snmp/x'; Arguments = @{ SnmpId = 'x' }; Property = '' }
	@{ Command = 'Get-PrintixSnmpConfigurations'; Method = 'GET'; Expected = 'tenants/t/snmp'; Arguments = @{}; Property = 'snmpConfigurations' }
	@{ Command = 'Get-PrintixWorkstation'; Method = 'GET'; Expected = 'tenants/t/workstations/w'; Arguments = @{ WorkstationId = 'w' }; Property = '' }
	@{ Command = 'Get-PrintixWorkstations'; Method = 'GET'; Expected = 'tenants/t/workstations'; Arguments = @{}; Property = 'workstations' }
)

BeforeAll {
	$manifestPath = if ($env:PRINTIX_MODULE_MANIFEST) { $env:PRINTIX_MODULE_MANIFEST } else { Join-Path $PSScriptRoot '..\Source\Printix.psd1' }
	Import-Module $manifestPath -Force -ErrorAction Stop
}

Describe 'Documented endpoint contracts' {
	It '<Case.Command> uses the documented method, path and response envelope' -ForEach @($endpointCases | ForEach-Object { @{ Case = $_ } }) {
		InModuleScope Printix -Parameters @{ Case = $Case } {
			$Script:PrintixConnection = @{ TenantId = 't' }
			Mock Invoke-PrintixRequest {
				[pscustomobject]@{
					Resource = $Resource
					Method = $Method
					Property = $ResponseProperty
				}
			}
			$arguments = $Case.Arguments.Clone()
			if ($Case.Method -ne 'GET') { $arguments.Confirm = $false }
			$result = & $Case.Command @arguments
			$result.Resource | Should -BeExactly $Case.Expected
			$result.Method | Should -BeExactly $Case.Method
			$result.Property | Should -BeExactly $Case.Property
			Should -Invoke Invoke-PrintixRequest -Times 1 -Exactly
		}
	}

	It '<Case.Command> does not send a request with WhatIf' -ForEach @($endpointCases | Where-Object Method -NE 'GET' | ForEach-Object { @{ Case = $_ } }) {
		InModuleScope Printix -Parameters @{ Case = $Case } {
			$Script:PrintixConnection = @{ TenantId = 't' }
			Mock Invoke-PrintixRequest {}
			$arguments = $Case.Arguments.Clone()
			& $Case.Command @arguments -WhatIf
			Should -Invoke Invoke-PrintixRequest -Times 0 -Exactly
		}
	}
}

Describe 'Endpoint parameter serialization' {
	BeforeEach {
		InModuleScope Printix {
			$Script:PrintixConnection = @{ TenantId = 't' }
			Mock Invoke-PrintixRequest {
				[pscustomobject]@{ Resource = $Resource; Query = $Query; Body = $Body; Headers = $Headers; All = $All; Raw = $Raw }
			}
		}
	}

	It 'honours explicit tenant overrides and preserves encoded card path segments' {
		$result = Get-PrintixCard -TenantId other -CardId 'ab+/='
		$result.Resource | Should -BeExactly 'tenants/other/cards/ab%2B%2F%3D'
	}

	It 'requires a tenant when no default exists' {
		InModuleScope Printix { $Script:PrintixConnection = $null }
		{ Get-PrintixUsers } | Should -Throw '*TenantId*'
	}

	It 'requests both user types when Role is omitted' {
		$result = Get-PrintixUsers
		$result.Query.role | Should -Be @('USER', 'GUEST_USER')
	}

	It 'preserves an explicit single-role filter' -ForEach @('USER', 'GUEST_USER') {
		$result = Get-PrintixUsers -Role $_
		@($result.Query.role).Count | Should -Be 1
		$result.Query.role | Should -Be @($_)
	}

	It 'passes zero-based pages, role lists, search and All/Raw switches' {
		$result = Get-PrintixUsers -Role USER,GUEST_USER -Query 'a+b & c' -Page 0 -PageSize 50 -All -Raw
		$result.Query.page | Should -Be 0
		$result.Query.pageSize | Should -Be 50
		$result.Query.query | Should -BeExactly 'a+b & c'
		$result.Query.role | Should -Be @('USER', 'GUEST_USER')
		$result.All | Should -BeTrue
		$result.Raw | Should -BeTrue
	}

	It 'maps workstation filtering to the documented workstations query field' {
		$result = Get-PrintixWorkstations -WorkstationIds one,two
		$result.Query.workstations | Should -Be @('one', 'two')
	}

	It 'keeps false values, gateway objects and empty arrays in network bodies' {
		$result = Set-PrintixNetwork -NetworkId n -HomeOffice $false -AirPrint $false -Gateways @() -Confirm:$false
		$result.Body.homeOffice | Should -BeFalse
		$result.Body.airPrint | Should -BeFalse
		$result.Body.ContainsKey('gateways') | Should -BeTrue
		$result.Body.gateways.Count | Should -Be 0
		$result.Body.ContainsKey('name') | Should -BeFalse
		$result = New-PrintixNetwork -Name Office -Gateways @{ mac = '00:11:22:33:44:55'; ip = '192.0.2.1' }
		$result.Body.gateways[0].ip | Should -Be '192.0.2.1'
	}

	It 'rejects empty updates' {
		{ Set-PrintixSite -SiteId s } | Should -Throw '*at least one*'
		{ Set-PrintixNetwork -NetworkId n } | Should -Throw '*at least one*'
		{ Set-PrintixSnmpConfiguration -SnmpId x } | Should -Throw '*at least one*'
	}

	It 'serializes every SNMP field including secret fields' {
		$secret = ConvertTo-SecureString 'sensitive' -AsPlainText -Force
		$result = New-PrintixSnmpConfiguration -Name SNMP -GetCommunityName $secret -SetCommunityName $secret `
			-TenantDefault $false -SecurityLevel AUTH_PRIVACY -Version V3 -Username monitor -ContextName context `
			-Authentication SHA512 -AuthenticationKey $secret -Privacy ASE256 -PrivacyKey $secret -NetworkIds n1,n2
		$result.Body.Count | Should -Be 13
		$result.Body.tenantDefault | Should -BeFalse
		$result.Body.authenticationKey | Should -BeExactly 'sensitive'
		$result.Body.privacyKey | Should -BeExactly 'sensitive'
		$result.Body.networkIds | Should -Be @('n1', 'n2')
	}

	It 'creates normal users without expiration and guest users with expiration' {
		$result = New-PrintixUser -Email person@example.test -FullName Person -Role USER -SendWelcomeEmail $false
		$result.Body.role | Should -Be 'USER'
		$result.Body.sendWelcomeEmail | Should -BeFalse
		$result.Body.ContainsKey('expirationTimestamp') | Should -BeFalse
		$result = New-PrintixUser -Email person@example.test -FullName Person -Role GUEST_USER -ExpirationTimestamp '2026.12.01 12:00'
		$result.Body.expirationTimestamp | Should -Be '2026.12.01 12:00'
		{ New-PrintixUser -Email person@example.test -FullName Person -Role USER -ExpirationTimestamp '2026.12.01 12:00' } | Should -Throw '*GUEST_USER*'
	}

	It 'validates card secrets and four-digit PINs' {
		$badSecret = ConvertTo-SecureString 'not base64!' -AsPlainText -Force
		{ Register-PrintixCard -UserId u -Secret $badSecret } | Should -Throw '*base64*'
		$badPin = ConvertTo-SecureString '12345' -AsPlainText -Force
		{ New-PrintixUser -Email person@example.test -FullName Person -Role USER -Pin $badPin } | Should -Throw '*four digits*'
		$pin = ConvertTo-SecureString '0123' -AsPlainText -Force
		$result = New-PrintixUser -Email person@example.test -FullName Person -Role GUEST_USER -Pin $pin
		$result.Body.pin | Should -BeExactly '0123'
	}

	It 'uses version 1.1 and the documented print-setting wire names' {
		$result = New-PrintixJob -PrinterId p -QueueId q -Title Report -ReleaseImmediately $false -Color $true `
			-Duplex LONG_EDGE -PageOrientation LANDSCAPE -Copies 2 -MediaSize LETTER -Scaling FIT -UserMappingKey Email -UserMappingValue person@example.test
		$result.Headers.version | Should -BeExactly '1.1'
		$result.Resource | Should -BeExactly 'tenants/t/printers/p/queues/q/submit'
		$result.Query.releaseImmediately | Should -BeFalse
		$result.Body.color | Should -BeTrue
		$result.Body.page_orientation | Should -BeExactly 'LANDSCAPE'
		$result.Body.media_size | Should -BeExactly 'LETTER'
		$result.Body.copies | Should -Be 2
		$result.Body.userMapping.key | Should -BeExactly 'Email'
		$result.Body.userMapping.value | Should -BeExactly 'person@example.test'
	}

	It 'supports the original ticket schema without a version header' {
		$ticket = @{ color = @{ type = 'STANDARD_COLOR' }; copies = @{ copies = 1 } }
		$result = New-PrintixJob -PrinterId p -QueueId q -Title Legacy -LegacyTicket $ticket -PDL POSTSCRIPT -User Redirector
		$result.Headers.Count | Should -Be 0
		$result.Body | Should -Be $ticket
		$result.Query.PDL | Should -BeExactly 'POSTSCRIPT'
		$result.Query.user | Should -BeExactly 'Redirector'
	}

	It 'rejects incompatible user mapping and invalid print settings' {
		{ New-PrintixJob -PrinterId p -QueueId q -Title Bad -UserMappingKey Email } | Should -Throw '*both*'
		{ New-PrintixJob -PrinterId p -QueueId q -Title Bad -UserMappingKey Email -UserMappingValue person@example.test -User redirect } | Should -Throw '*cannot*'
		{ New-PrintixJob -PrinterId p -QueueId q -Title Bad -Copies 0 } | Should -Throw
		{ New-PrintixJob -PrinterId p -QueueId q -Title Bad -LegacyTicket @{} -Color $true } | Should -Throw
	}

	It 'does not create a job with WhatIf' {
		InModuleScope Printix {
			Mock Invoke-PrintixRequest {}
			New-PrintixJob -PrinterId p -QueueId q -Title Preview -WhatIf
			Should -Invoke Invoke-PrintixRequest -Times 0 -Exactly
		}
	}
}
