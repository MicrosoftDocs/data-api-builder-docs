---
title: Use Azure Application Insights in Data API builder
description: Enable and configure Azure Application Insights for monitoring Data API builder applications.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 01/27/2026
# Customer Intent: As a developer, I want to enable telemetry using Application Insights so I can monitor and troubleshoot my Data API builder apps.
---

# Use Azure Application Insights in Data API builder

Azure Application Insights is an Application Performance Monitoring (APM) service that automatically captures requests, traces, exceptions, and performance metrics. Integrating it with Data API builder (DAB) helps you monitor runtime behavior, diagnose issues, and optimize performance in production.

![Diagram showing the Application Insights telemetry flow.](media/application-insights/application-insights-flow.svg)

> [!WARNING]
> Application Insights integration with DAB may have limitations when hosted on Azure App Service web apps due to double instrumentation. Application Insights works best with DAB when you self-host it in containers, Azure Container Apps, or Azure Kubernetes Service (AKS). If you must use App Service, test thoroughly or consider alternative monitoring approaches.

## Prerequisites

- Existing DAB configuration file.
- Azure Application Insights resource.
- Application Insights connection string.
- Data API builder CLI. [Install the CLI](../../command-line/install.md)

## Get connection string

Before configuring DAB, obtain the Application Insights connection string from Azure.

### Azure portal

1. Navigate to your Application Insights resource in the Azure portal.
1. Go to **Overview** or **Properties**.
1. Copy the **Connection String** (not the Instrumentation Key).

### Azure CLI

#### [Bash](#tab/bash-cli)

```bash
az monitor app-insights component show \
  --app my-app-insights \
  --resource-group my-rg \
  --query connectionString -o tsv
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
az monitor app-insights component show ^
  --app my-app-insights ^
  --resource-group my-rg ^
  --query connectionString -o tsv
```

---

### Connection string format

```text
InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://<region>.in.applicationinsights.azure.com/;LiveEndpoint=https://<region>.livediagnostics.monitor.azure.com/
```

> [!NOTE]
> Use the full connection string (not just the instrumentation key) for region-specific endpoints and better performance.

## Configure Application Insights

Add an `application-insights` section under `runtime.telemetry` in your config file.

```json
{
  "runtime": {
    "telemetry": {
      "application-insights": {
        "enabled": true,
        "connection-string": "@env('app-insights-connection-string')"
      }
    }
  }
}
```

This configuration uses an environment variable for the connection string. Define it in an `.env` file:

```bash
app-insights-connection-string="InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=..."
```

> [!WARNING]
> Never commit connection strings to source control. Always use environment variables or Azure Key Vault.

## Command-line

Configure Application Insights via `dab add-telemetry`.

| Option | Description |
| ------ | ----------- |
| `--app-insights-enabled` | Enable or disable Application Insights (`true` or `false`). |
| `--app-insights-conn-string` | Connection string for Application Insights. |

### Enable Application Insights

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --app-insights-enabled true \
  --app-insights-conn-string "@env('app-insights-connection-string')"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --app-insights-enabled true ^
  --app-insights-conn-string "@env('app-insights-connection-string')"
```

---

### Disable Application Insights

#### [Bash](#tab/bash-cli)

```bash
dab add-telemetry \
  --app-insights-enabled false
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add-telemetry ^
  --app-insights-enabled false
```

---

> [!NOTE]
> Application Insights settings use `dab add-telemetry`, not `dab configure`.

## Run DAB

Start DAB with your configuration file:

```dotnetcli
dab start
```

Check startup logs for confirmation:

```text
Application Insights telemetry is enabled with connection string from config.
```

## How it works

When Application Insights is enabled, DAB:

1. Registers the Application Insights SDK using `AddApplicationInsightsTelemetry()`.
1. Registers a custom telemetry initializer to enrich all telemetry with DAB-specific properties.
1. Configures `TelemetryClient` with the connection string from config.
1. Integrates with ASP.NET Core logging to capture console logs as traces.

### Data flow

```text
DAB Application
    ↓
ILogger (ASP.NET Core)
    ↓
ApplicationInsightsLoggerProvider
    ↓
AppInsightsTelemetryInitializer (adds custom properties)
    ↓
TelemetryClient
    ↓
Application Insights (Azure)
```

## What gets captured

| Telemetry type | Source | Examples |
| -------------- | ------ | -------- |
| Requests | ASP.NET Core middleware | REST/GraphQL requests, response times, status codes |
| Traces | `ILogger` calls in DAB | Startup logs, query execution logs, warnings |
| Exceptions | Unhandled exceptions | Runtime errors, configuration errors, database errors |
| Dependencies | Database calls | SQL queries, Azure Cosmos DB operations, duration |
| Performance counters | Runtime | CPU usage, memory consumption, request rate |

## Telemetry enrichment

DAB automatically enriches all Application Insights telemetry with custom properties:

| Property | Description | Example value |
| -------- | ----------- | ------------- |
| `ProductName` | DAB user agent identifier | `dab-1.2.3` |
| `UserAgent` | Full DAB user agent string | `data-api-builder/1.2.3` |
| `Cloud.RoleName` | DAB cloud role name | `DataApiBuilder` |
| `Component.Version` | DAB version | `1.2.3` |
| `Session.Id` | Unique session identifier | `guid` |

These properties help filter and correlate DAB-specific telemetry in Application Insights.

## Query telemetry in Azure

### Traces (logs)

```kusto
traces
| where customDimensions["ProductName"] startswith "dab-"
| order by timestamp desc
| project timestamp, message, severityLevel
```

**LogLevel mapping:**

| LogLevel | Severity | Value |
| -------- | -------- | ----- |
| Trace / Debug | Verbose | 0 |
| Information | Information | 1 |
| Warning | Warning | 2 |
| Error | Error | 3 |
| Critical | Critical | 4 |

### Requests

```kusto
requests
| where customDimensions["ProductName"] startswith "dab-"
| order by timestamp desc
| project timestamp, name, duration, resultCode, success
```

![Screenshot of the results of a query for Data API builder application requests in Application Insights.](media/application-insights/requests-results.png)

### Exceptions

```kusto
exceptions
| where customDimensions["ProductName"] startswith "dab-"
| order by timestamp desc
| project timestamp, type, outerMessage, details
```

![Screenshot of the results of a query for Data API builder exceptions in Application Insights.](media/application-insights/exceptions-results.png)

### Filter by DAB version

```kusto
traces
| where customDimensions["Component.Version"] == "1.2.3"
| project timestamp, message, severityLevel
```

### Find slow GraphQL queries

```kusto
requests
| where name contains "/graphql"
| where duration > 1000
| project timestamp, name, duration, resultCode
| order by duration desc
```

### Request success rate

```kusto
requests
| where customDimensions["ProductName"] startswith "dab-"
| summarize 
    Total = count(),
    Success = countif(success == true),
    Failed = countif(success == false)
| extend SuccessRate = (Success * 100.0) / Total
```

### Top slow database operations

```kusto
dependencies
| where type == "SQL" or type == "Azure Cosmos DB"
| top 10 by duration desc
| project timestamp, name, duration, target, data
```

## Live Metrics

Live Metrics provides real-time monitoring with <1 second latency. It's automatically enabled when Application Insights is configured.

### Access Live Metrics

1. Open your Application Insights resource in the Azure portal.
1. Navigate to **Live Metrics** in the left menu.
1. Start your DAB application.
1. Within seconds, real-time data appears.

![Screenshot of the live metrics page for Data API builder data in Application Insights.](media/application-insights/live-metrics.png)

### What you see

| Metric | Description |
| ------ | ----------- |
| Incoming Requests | REST/GraphQL requests per second |
| Outgoing Requests | Database calls per second |
| Overall Health | Success rate, failures per second |
| Memory / CPU | Resource consumption |
| Exception Rate | Exceptions per second |

> [!TIP]
> Use Live Metrics during development to see immediate feedback on API requests and database operations.

## Sampling and data retention

### Adaptive sampling

The Application Insights SDK automatically samples telemetry when volume is high to reduce costs and stay within rate limits. Sampling rate is shown in the Application Insights UI.

**Default behavior:**

- Low traffic: All telemetry sent (100%)
- High traffic: Sampling automatically reduces volume
- Representative data maintained

### Data retention

| Plan | Default retention | Maximum retention |
| ---- | ----------------- | ----------------- |
| Free tier | 90 days | 90 days |
| Pay-as-you-go | 90 days | 730 days (2 years) |

Configure retention: Application Insights → **Usage and estimated costs** → **Data Retention**.

## Performance considerations

### Telemetry overhead

Application Insights adds minimal overhead:

- **Memory**: ~10-50 MB depending on traffic
- **CPU**: <1% under normal load
- **Latency**: <1ms per request (async)

### Best practices

- Use environment variables for connection strings.
- Disable in local development if not needed.
- Monitor sampling rate in production.
- Set appropriate data retention to manage costs.

### Disable in development

```json
{
  "runtime": {
    "telemetry": {
      "application-insights": {
        "enabled": false
      }
    }
  }
}
```

## Export and visualization

Telemetry is exported via the Application Insights SDK. The SDK batches and sends data periodically.

> [!NOTE]
> The SDK controls export timing. Default behavior sends telemetry in batches every few seconds.

> [!WARNING]
> Ephemeral containers that shut down quickly may exit before exports complete. Configure graceful shutdown windows and avoid aggressive termination to ensure pending telemetry flushes.

## Connection string vs. instrumentation key

### Use connection strings (recommended)

```json
{
  "connection-string": "InstrumentationKey=...;IngestionEndpoint=https://eastus.in.applicationinsights.azure.com/"
}
```

**Benefits:**

- Region-specific endpoints (lower latency)
- Supports sovereign clouds
- Future-proof (Microsoft's recommended approach)

### Legacy instrumentation key

While still supported, Microsoft recommends connection strings for new implementations.

```json
{
  "connection-string": "InstrumentationKey=00000000-0000-0000-0000-000000000000"
}
```

> [!NOTE]
> If you only provide an instrumentation key, Application Insights uses the global ingestion endpoint, which may have higher latency.

## Troubleshooting

### Error: "Application Insights connection string cannot be null or empty if enabled"

**Cause**: `enabled` is set to `true` but `connection-string` is missing or empty.

**Solution**: Provide a valid connection string when enabling Application Insights, or set `enabled` to `false`.

```json
{
  "runtime": {
    "telemetry": {
      "application-insights": {
        "enabled": true,
        "connection-string": "@env('app-insights-connection-string')"
      }
    }
  }
}
```

### DAB starts but no telemetry appears

Check startup logs for these messages:

#### [Bash](#tab/bash-cli)

```bash
dab start --LogLevel Information
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab start --LogLevel Information
```

---

**Success message:**

```text
Application Insights telemetry is enabled with connection string from config.
```

**Warning messages:**

```text
Logs won't be sent to Application Insights because an Application Insights connection string is not available in the runtime config.
```

```text
Application Insights are disabled.
```

**Error message:**

```text
Telemetry client is not initialized.
```

### Verify environment variable

#### [Bash](#tab/bash-cli)

```bash
echo $app-insights-connection-string
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
echo %app-insights-connection-string%
```

---

### Test with direct connection string

Temporarily use a direct connection string (not environment variable) to verify the string is valid:

```json
{
  "connection-string": "InstrumentationKey=...;IngestionEndpoint=..."
}
```

If this works, the issue is with environment variable loading.

## Related content

- [Use Azure Log Analytics](log-analytics.md)
- [Use OpenTelemetry](open-telemetry.md)
- [Customize log verbosity](log-levels.md)
- [Application Insights overview](/azure/azure-monitor/app/app-insights-overview)
- [Application Insights for ASP.NET Core](/azure/azure-monitor/app/asp-net-core)

