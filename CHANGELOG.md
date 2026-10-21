# Changelog

## 0.1.0 - 2026-10-21

- Document PowerShell Gallery installation and updates as the primary getting-started path.
- Add a separate development documentation sync workflow, including the module overview while preserving released command help.
- Complete CI/CD scaffolding with verified MDX artifacts, cross-repository docs sync, stable tag validation and GitHub release archives.
- Document Gallery first publication, required secrets and environments.
- Add contributor guides and vault-backed connection examples with secret-management recommendations.

- Add all four documented production Partner API operations with the `PrintixPartner` prefix.
- Keep independent partner credentials, access tokens and refresh-token renewal alongside the Cloud Print connection.

- Document mutually exclusive application types and per-command requirements.
- Publish documentation as MDX with a module overview and application permissions matrix.

- Request both normal and guest users by default in `Get-PrintixUsers`; explicit `-Role` filtering remains supported.

- Initial module scaffold following the HaloAPI / NinjaOne conventions.
- OAuth client credentials, in-memory token renewal, HAL pagination and rate-limit retries.
- Complete documented Cloud Print API endpoint coverage, including both submission versions.
- Unauthenticated cloud-storage upload and webhook signature verification.
- Offline tests, static analysis, ModuleBuilder packaging, help generation and CI.
