# Printix - A [PowerShell](https://microsoft.com/powershell) module for [Printix](https://printix.net/)

[![Homotechsual Discord](https://img.shields.io/discord/1075421628424523816?style=for-the-badge&logo=discord&logoColor=white&label=Homotechsual%20Discord)](https://discord.gg/NrCjh5ht7K)
[![GitHub contributors](https://img.shields.io/github/contributors/homotechsual/Printix?style=for-the-badge&logo=github)](https://github.com/homotechsual/Printix/)
[![Build and Publish](https://img.shields.io/github/actions/workflow/status/homotechsual/Printix/publish.yml?style=for-the-badge&label=Build%20and%20Publish)](https://github.com/homotechsual/Printix/actions/workflows/publish.yml)
[![CI](https://img.shields.io/github/actions/workflow/status/homotechsual/Printix/ci.yml?branch=develop&style=for-the-badge&label=CI)](https://github.com/homotechsual/Printix/actions/workflows/ci.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Printix?style=for-the-badge)](https://www.powershellgallery.com/packages/Printix/)
[![License](https://img.shields.io/github/license/homotechsual/Printix?style=for-the-badge)](LICENSE.md)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/homotechsual?style=for-the-badge)](https://github.com/sponsors/homotechsual/)
[![Stable Release](https://img.shields.io/powershellgallery/v/Printix?label=Stable+Release&style=for-the-badge)](https://www.powershellgallery.com/packages/Printix/)

A PowerShell wrapper for the [Printix Cloud Print API](https://printix.github.io/)
and [Printix Partner API](https://printix.github.io/partner-api/).
Requires **PowerShell 7.0 or later**, with no runtime module dependencies.
This is an independent MIT-licensed module, not an official Printix or Tungsten Automation product.

## Where's the content?

Use the [docs website](https://docs.homotechsual.dev/modules/printix) for getting
started, application permissions, Partner API guidance and a full automatically
generated cmdlet reference.

Printix application types are **mutually exclusive, not combinable OAuth scopes**.
See the [application permissions matrix](https://docs.homotechsual.dev/modules/printix/api-coverage#application-permissions)
before creating your credentials.

## Installation

Install from PowerShell Gallery using PowerShell 7 or later:

```powershell
Install-Module -Name Printix -Repository PSGallery -Scope CurrentUser
Import-Module Printix
```

Update with `Update-Module -Name Printix`, then start a new PowerShell session,
import the module and reconnect.
For development from this checkout, use `Import-Module .\Source\Printix.psd1`.

## Tooling locations

Common dev and build tooling lives under DevOps:

- Build: [build.ps1](DevOps/Build/build.ps1), [bootstrap.ps1](DevOps/Build/bootstrap.ps1)
- Quality: [run-pssa.ps1](DevOps/Quality/run-pssa.ps1), [test.ps1](DevOps/Quality/test.ps1)
- Help generation: [Update-Help.ps1](DevOps/Help/Update-Help.ps1)
- Documentation sync: [Sync-Docs.ps1](DevOps/Help/Sync-Docs.ps1)

See the [development and publishing guide](docs/Printix/development/index.mdx)
for local validation, GitHub Actions, required secrets and release instructions.
