---
title: Add telemetry settings with the DAB CLI
description: Use the Data API builder (DAB) CLI add-telemetry command to configure OpenTelemetry and Azure Application Insights settings in your configuration file.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/26/2026
# Customer Intent: As a developer, I want to configure telemetry settings in Data API builder from the CLI so I can enable distributed tracing and monitoring without editing JSON directly.
---

# `add-telemetry` command

Add or update OpenTelemetry and Azure Application Insights settings in an existing Data API builder configuration file. If the `runtime.telemetry` section doesn't exist, it gets created. Unspecified options leave existing values unchanged.

> [!NOTE]
> Telemetry settings aren't configurable with `dab configure`. Use `dab add-telemetry` for all `runtime.telemetry` changes.

For conceptual guidance and end-to-end walkthroughs, see [Use OpenTelemetry and activity traces](../concept/monitor/open-telemetry.md) and [Use Azure Application Insights](../concept/monitor/application-insights.md).

## Syntax

```sh
dab add-telemetry [options]
```

## Quick glance

| Option | Summary |
| --- | --- |
| [`-c, --config`](#-c---config) | Config file path. Default `dab-config.json`. |

### OpenTelemetry section

| Option | Summary |
| --- | --- |
| [`--otel-enabled`](#--otel-enabled) | Enable or disable OpenTelemetry. |
| [`--otel-endpoint`](#--otel-endpoint) | OpenTelemetry collector endpoint URL. |
| [`--otel-protocol`](#--otel-protocol) | Export protocol. Allowed values: `grpc`, `http`. |
| [`--otel-service-name`](#--otel-service-name) | Service name tag on all telemetry. |
| [`--otel-headers`](#--otel-headers) | Extra headers to send to the OpenTelemetry collector. |

### Azure Application Insights section

| Option | Summary |
| --- | --- |
| [`--app-insights-enabled`](#--app-insights-enabled) | Enable or disable Azure Application Insights. |
| [`--app-insights-conn-string`](#--app-insights-conn-string) | Application Insights connection string. |

## `-c, --config`

Path to the configuration file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --config ./my-config.json \
  --otel-enabled true
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --config ./my-config.json ^
  --otel-enabled true
```

---

## `--otel-enabled`

Enable or disable the OpenTelemetry exporter. Accepted values: `true`, `false`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --otel-enabled true
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --otel-enabled true
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": true
      }
    }
  }
}
```

## `--otel-endpoint`

URL of your OpenTelemetry collector or back end. For gRPC, use `http://<host>:<port>`. For HTTP, include the full path, for example `http://<host>:<port>/v1/traces`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --otel-enabled true \
  --otel-endpoint "http://localhost:4317"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --otel-enabled true ^
  --otel-endpoint "http://localhost:4317"
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": true,
        "endpoint": "http://localhost:4317"
      }
    }
  }
}
```

## `--otel-protocol`

Export protocol for the OpenTelemetry exporter. Allowed values: `grpc`, `http`. Defaults to `grpc`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --otel-enabled true \
  --otel-endpoint "http://localhost:4318" \
  --otel-protocol "http"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --otel-enabled true ^
  --otel-endpoint "http://localhost:4318" ^
  --otel-protocol "http"
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": true,
        "endpoint": "http://localhost:4318",
        "exporter-protocol": "http"
      }
    }
  }
}
```

## `--otel-service-name`

Service name tag attached to all traces and metrics. Appears as the service identifier in your telemetry back end. Defaults to `dab`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --otel-enabled true \
  --otel-service-name "my-dab-api"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --otel-enabled true ^
  --otel-service-name "my-dab-api"
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": true,
        "service-name": "my-dab-api"
      }
    }
  }
}
```

## `--otel-headers`

Extra HTTP headers to include when exporting telemetry to the collector. Use a comma-separated `key=value` list. Use this option for authenticated collector endpoints that require an API key or authorization header.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --otel-enabled true \
  --otel-endpoint "https://collector.example.com:4317" \
  --otel-headers "api-key=my-secret-key"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --otel-enabled true ^
  --otel-endpoint "https://collector.example.com:4317" ^
  --otel-headers "api-key=my-secret-key"
```

---

## `--app-insights-enabled`

Enable or disable Azure Application Insights telemetry. Accepted values: `true`, `false`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --app-insights-enabled true
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --app-insights-enabled true
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "application-insights": {
        "enabled": true
      }
    }
  }
}
```

## `--app-insights-conn-string`

Connection string for your Azure Application Insights resource. Use an environment variable reference to avoid committing secrets to source control.

> [!WARNING]
> Never hard-code the connection string directly in your configuration file. Use `@env('<variable-name>')` or a secret manager.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --app-insights-enabled true \
  --app-insights-conn-string "@env('APP_INSIGHTS_CONN_STRING')"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --app-insights-enabled true ^
  --app-insights-conn-string "@env('APP_INSIGHTS_CONN_STRING')"
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "application-insights": {
        "enabled": true,
        "connection-string": "@env('APP_INSIGHTS_CONN_STRING')"
      }
    }
  }
}
```

## Full example: OpenTelemetry and Application Insights

The following example enables both OpenTelemetry and Application Insights in a single command.

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --otel-enabled true \
  --otel-endpoint "http://localhost:4317" \
  --otel-protocol "grpc" \
  --otel-service-name "my-dab-api" \
  --app-insights-enabled true \
  --app-insights-conn-string "@env('APP_INSIGHTS_CONN_STRING')"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --otel-enabled true ^
  --otel-endpoint "http://localhost:4317" ^
  --otel-protocol "grpc" ^
  --otel-service-name "my-dab-api" ^
  --app-insights-enabled true ^
  --app-insights-conn-string "@env('APP_INSIGHTS_CONN_STRING')"
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": true,
        "endpoint": "http://localhost:4317",
        "service-name": "my-dab-api",
        "exporter-protocol": "grpc"
      },
      "application-insights": {
        "enabled": true,
        "connection-string": "@env('APP_INSIGHTS_CONN_STRING')"
      }
    }
  }
}
```

## Related content

- [Use OpenTelemetry and activity traces](../concept/monitor/open-telemetry.md)
- [Use Azure Application Insights](../concept/monitor/application-insights.md)
- [Runtime configuration reference](../configuration/runtime.md)
- [`dab configure` command](dab-configure.md)
