# Changelog

## Unreleased

- Complete CI/CD scaffolding with verified MDX artifacts, cross-repository docs sync, stable tag validation and GitHub release archives.
- Document Gallery first publication, required secrets and environments.

- Add all four documented production Partner API operations with the `PrintixPartner` prefix.
- Keep independent partner credentials, access tokens and refresh-token renewal alongside the Cloud Print connection.

- Document mutually exclusive application types and per-command requirements.
- Publish documentation as MDX with a module overview and application permissions matrix.

- Request both normal and guest users by default in `Get-PrintixUsers`; explicit `-Role` filtering remains supported.

## 0.1.0

- Initial module scaffold following the HaloAPI / NinjaOne conventions.
- OAuth client credentials, in-memory token renewal, HAL pagination and rate-limit retries.
- Complete documented Cloud Print API endpoint coverage, including both submission versions.
- Unauthenticated cloud-storage upload and webhook signature verification.
- Offline tests, static analysis, ModuleBuilder packaging, help generation and CI.
