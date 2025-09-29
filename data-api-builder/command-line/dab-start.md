---
title: Start the runtime with the DAB CLI
description: Use the Data API builder (DAB) CLI to start the runtime and serve APIs based on your configuration.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to start the Data API builder runtime, so that my APIs become available for requests.
---

# `start` command

Start the Data API builder runtime with an existing configuration file.

## Syntax

```sh
dab start [options]
```

### Quick glance

| Option                                        | Summary                                                                                            |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| [`-c, --config`](#-c---config)                | Use a specific config file (defaults to `dab-config.json` or environment-specific file if present) |
| [`--LogLevel <level>`](#--loglevel-level)     | Sets log level explicitly (name or number 0–6)                                                     |
| [`--no-https-redirect`](#--no-https-redirect) | Disables automatic HTTP→HTTPS redirection                                                          |
| [`--verbose`](#--verbose)                     | Sets log level to Information                                                                      |

## `-c, --config`

Path to the configuration file. Defaults to `dab-config.json`. If an environment-specific file `dab-config.<DAB_ENVIRONMENT>.json` exists, that file is used instead (`DAB_ENVIRONMENT` is read from the environment variable).

**Behavior**

* If both the base and environment-specific file exist, the environment-specific file is chosen.
* No mutation of config happens, `start` only consumes.

> [!Note]
> Providing `--config` (or `-c`) overrides the environment-variable–based selection logic. If you pass a path explicitly, the `DAB_ENVIRONMENT` variable is ignored and only the specified file is used. This means environment-specific layering is bypassed. If you want automatic environment resolution, omit `--config` and rely on `DAB_ENVIRONMENT` plus the matching file naming convention.

**Example**

```sh
dab start --config ./settings/dab-config.json
```

## `--LogLevel <level>`

Sets the minimum log level explicitly. Accepts names (`Trace`, `Debug`, `Information`, `Warning`, `Error`, `Critical`, `None`) or numeric values `0–6`. Case-insensitive.

**Behavior**

* Cannot be combined with `--verbose`.
* Invalid values outside `0–6` cause startup to fail.
* If neither `--verbose` nor `--LogLevel` is set, defaults are:

  * Development host mode: `Debug`
  * Production host mode: `Error`

**Examples**

```sh
dab start --LogLevel Warning
dab start --LogLevel 1   # Debug
```

For more about levels, see [.NET log levels](/dotnet/api/microsoft.extensions.logging.loglevel).

> [!Note]
> `--LogLevel` and `--verbose` always override any log level settings in the configuration file. Even if you do not supply a logging flag, the CLI injects a baseline log level when launching the runtime. As a result, per-namespace or fine-grained logger filters defined in configuration are not applied when using `dab start`.

## `--no-https-redirect`

Disables automatic HTTP→HTTPS redirection.

**Behavior**

* Default is secure redirection enabled.
* Supplying this flag disables redirection.

> [!Note]
> This flag only controls whether HTTP traffic is redirected to HTTPS. It does not create or remove endpoints. Endpoints are determined by `ASPNETCORE_URLS` (or Kestrel defaults).
>
> * If only HTTP is configured, the flag changes nothing because there is no HTTPS endpoint to redirect to.
> * If only HTTPS is configured, the flag changes nothing because there is no HTTP traffic to upgrade.
> * If both HTTP and HTTPS are configured, the flag suppresses the automatic redirect, allowing both endpoints to serve requests directly.

**Example**

```sh
dab start --no-https-redirect
```

## `--verbose`

Sets the minimum log level to `Information`.

**Behavior**

* Cannot be combined with `--LogLevel`.
* Overrides host mode defaults.

> [!Note]
> Equivalent to using `--LogLevel Information`. The parser prevents both `--verbose` and `--LogLevel` from being provided together, so there is no conflict path.

**Example**

```sh
dab start --verbose
```
