# Printix

A PowerShell module for the [Printix Cloud Print API](https://printix.github.io/)
and [Printix Partner API](https://printix.github.io/partner-api/).

Uses the `Source`, `Public` / `Private`, and `DevOps` layout of the HaloAPI and
NinjaOne modules. Requires **PowerShell 7.0 or later**; there are no runtime module dependencies.

## Getting started

Install from [PowerShell Gallery](https://www.powershellgallery.com/packages/Printix)
using PowerShell 7 or later:

```powershell
Install-Module -Name Printix -Repository PSGallery -Scope CurrentUser
Import-Module Printix

$secret = Read-Host 'Printix client secret' -AsSecureString
Connect-Printix -ClientId $clientId -ClientSecret $secret -TenantId $tenantId

# Discover accessible tenant links if the tenant ID is not yet known.
Get-PrintixRoot

Get-PrintixPrintQueues -All
Get-PrintixUsers -All

Disconnect-Printix
```

Update Gallery installations with `Update-Module -Name Printix`, then start a new
PowerShell session, import the module and reconnect.
For development from this checkout, use `Import-Module .\Source\Printix.psd1`
instead. See the [installation guide](docs/Printix/index.mdx#installing).

Generate client credentials in Printix Administrator. Different application types
authorize different operations; see the [overview](docs/Printix/index.mdx) and
[application permissions matrix](docs/Printix/api-coverage.mdx#application-permissions).
**Application types are mutually exclusive, not combinable OAuth scopes.**
Create separate applications and reconnect with the appropriate credentials when
switching between types. A Cloud Print API connection cannot also be a Workstation
monitoring or User manager connection.
Tokens renew automatically. Credentials and tokens are held in module memory only.
API user responses can contain sensitive credentials; do not log them indiscriminately.

## Print a document

Use printer and queue IDs from a queue's `_links.self.href`; the print queue's
`id` alone is not necessarily the physical printer ID.

```powershell
$submission = New-PrintixJob -PrinterId $printerId -QueueId $queueId `
    -Title 'Quarterly report' -Duplex LONG_EDGE -Copies 1

$submission.uploadLinks | Send-PrintixJobFile -Path '.\report.pdf'

# Follow the service's completion link; signed upload URLs are not API resources.
Invoke-PrintixRequest -Resource $submission._links.uploadCompleted.href -Method POST
```

Alternatively, use `Complete-PrintixJobUpload -JobId $submission.job.id`.
Version 1.1 print settings are the default. `-LegacyTicket` supports original
submission tickets. Use `-ReleaseImmediately $false` to defer printing; the service
defaults to immediate release otherwise. Submission and upload are intentionally
separate so failures cannot silently resubmit or print a document twice.

## Partner API

Partner credentials are issued directly by Printix, separately from tenant API
applications. The module keeps an independent partner connection:

```powershell
Connect-PrintixPartner -ClientId $partnerClientId `
    -ClientSecret (Read-Host 'Partner secret' -AsSecureString) -PartnerId $partnerId

Get-PrintixPartnerTenants
Get-PrintixPartnerTenant -TenantId $tenantId -EmbedBillingInfo
Get-PrintixPartnerTenantBillingInfo -TenantId $tenantId
New-PrintixPartnerTenant -TenantName 'Acme Co.' -TenantDomain acme -WhatIf

Disconnect-PrintixPartner
```

Connecting or disconnecting the Partner API does not replace your Cloud Print
connection. See the [Partner API guide](docs/Printix/partner-api.mdx) for credential
requirements, output shapes, refresh-token renewal and production-environment scope.

## Commands and behaviour

- Covers every documented API operation: print queues, jobs (both submission
  versions), file upload, user and ID-code management, groups, cards, sites,
  networks, SNMP configurations and workstation monitoring.
- Cloud Print collection commands return one page by default. Use `-All` for automatic HAL
  pagination, `-Page` / `-PageSize` for explicit paging, and `-Raw` for full HAL
  documents. Page numbers start at zero.
- `-TenantId` overrides the connection's default tenant per command.
- `Get-PrintixUsers` requests both normal and guest users by default. Use
  `-Role USER` or `-Role GUEST_USER` to filter to one type.
- `Invoke-PrintixRequest` accepts authenticated API HAL links and relative resources.
  Optional query templates are stripped; unresolved path templates are rejected.
- Cloud Print HTTP 429 responses honour `X-Rate-Limit-Retry-After-Seconds` with bounded retries
  and exponential backoff plus jitter. Other failures are surfaced, not retried.
  Printix shares a **100 requests/minute/user** budget across all endpoints.
- Authenticated requests are restricted to the Printix API origin. Cloud uploads
  use only storage-provided headers and never receive the Printix bearer token.
- All API mutations and file uploads support `-WhatIf` / `-Confirm`.
- `Test-PrintixWebhookSignature` checks signatures and emitted-time freshness.
  Webhook creation is performed in Printix Administrator, not an undocumented API.

Use `Get-Help <command> -Full` for parameter help and examples.
See the [endpoint coverage reference](docs/Printix/api-coverage.mdx) for method/path mappings.

## Development

```powershell
# Explicitly installs pinned development tools if missing.
.\DevOps\Build\bootstrap.ps1

# Analyze and run offline mocked tests.
.\DevOps\Quality\test.ps1

# Build Output\Printix\0.1.0.
.\DevOps\Build\build.ps1
.\DevOps\Quality\test.ps1 -UseBuiltModule -SkipScriptAnalyzer

# Generate command reference from comment-based help.
.\DevOps\Help\Update-Help.ps1
```

`DevOps\Build\build.ps1 -TaskNames publish -NuGetApiKey $key` publishes an already
built module. Publishing is never a default local build task. The GitHub Publish
workflow runs manually from main or on matching stable `v*` tags, validates and
builds before publishing, and creates a GitHub release for tags.

Configure `PSGALLERY_API_KEY` in the `PSGallery` environment and `DOCS_REPO_TOKEN`
in the `Documentation` environment (or at repository/organization level). Successful
releases sync MDX to `homotechsual/homotechsualdocs`; the separate Sync Development
Documentation workflow syncs the development guide and overview after develop CI.
See [CI/CD and Gallery setup](docs/Printix/development/index.mdx).

Source and built-module tests require no Printix credentials and make no live API
calls. Live permissions, tenant licensing and printer behaviour must be checked
against a real tenant before a release.

## License

[MIT](LICENSE.md). Not an official Printix or Tungsten Automation product.
