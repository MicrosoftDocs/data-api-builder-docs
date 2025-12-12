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
| [`--LogLevel <level>`](#--loglevel-level)     | Specifies logging level as provided value.                                                         |
| [`--no-https-redirect`](#--no-https-redirect) | Disables automatic HTTP→HTTPS redirection                                                          |
| [`--verbose`](#--verbose)                     | Sets log level to Information                                                                      |
| [`--help`](#--help)                           | Display the help screen.                                                                           |
| [`--version`](#--version)                     | Display version information.                                                                       |

## `-c, --config`

Path to config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --config ./settings/dab-config.json
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --config .\settings\dab-config.json
```

---

## `--LogLevel <level>`

Specifies logging level as provided value. For possible values, see: https://go.microsoft.com/fwlink/?linkid=2263106

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --LogLevel Warning
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --LogLevel Warning
```

---

## `--no-https-redirect`

Disables automatic HTTP→HTTPS redirection.

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --no-https-redirect
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --no-https-redirect
```

---

## `--verbose`

Sets the minimum log level to `Information`.

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --verbose
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --verbose
```

---

## `--help`

Display the help screen.

### Example

#### [Bash](#tab/bash)

```bash
dab start --help
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start --help
```

---

## `--version`

Display version information.

### Example

#### [Bash](#tab/bash)

```bash
dab start --version
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start --version
```

---
