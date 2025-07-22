---
title: Use Azure Application Insights in Data API builder
description: Enable and configure Azure Application Insights for monitoring Data API builder applications.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 07/21/2025
# Customer Intent: As a developer, I want to enable telemetry using Application Insights so I can monitor and troubleshoot my Data API builder apps.
---

# Use Azure Application Insights in Data API builder

![Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Monitor' location is currently highlighted.](media/application-insights/map.svg)

Azure Application Insights is a monitoring service that captures telemetry such as request details, performance counters, logs, and exceptions. Integrating it with Data API builder (DAB) helps you diagnose issues and monitor runtime behavior in production.

> **Warning**
> Application Insights isn't supported when DAB is hosted using Azure App Service web apps.

## Configuration

To configure Application Insights in your DAB config:

### CLI example

```sh
dab add-telemetry \
  --app-insights-enabled true \
  --app-insights-conn-string "@env('app-insights-connection-string')"
```

### JSON example

```json
"runtime": {
  ...
  "telemetry": {
    "application-insights": {
      "enabled": true,
      "connection-string": "@env('app-insights-connection-string')"
    }
  }
  ...
}
```

This assumes `app-insights-connection-string` is set as an environment variable. You can use an `.env` file to define it.

## What gets captured

| Type                 | Description                     |
| -------------------- | ------------------------------- |
| Request telemetry    | URL, status code, response time |
| Trace telemetry      | Console logs from DAB           |
| Exception telemetry  | Errors and stack traces         |
| Performance counters | CPU, memory, network metrics    |

## View in Azure

1. Go to your Application Insights resource in the Azure portal: [https://portal.azure.com](https://portal.azure.com)
2. Review logs using this query:

```kusto
traces
| order by timestamp
```

LogLevel mapping:

| LogLevel    | Severity    | Value |
| ----------- | ----------- | ----- |
| Trace       | Verbose     | 0     |
| Debug       | Verbose     | 0     |
| Information | Information | 1     |
| Warning     | Warning     | 2     |
| Error       | Error       | 3     |
| Critical    | Critical    | 4     |

3. Check **Live Metrics**

![Screenshot of the live metrics page for Data API builder data in Application Insights.](media/application-insights/live-metrics.png)

4. Run this query for requests:

```kusto
requests
| order by timestamp
```

![Screenshot of the results of a query for Data API builder application requests in Application Insights.](media/application-insights/requests-results.png)

5. Run this query for exceptions:

```kusto
exceptions
| order by timestamp
```

![Screenshot of the results of a query for Data API builder exceptions in Application Insights.](media/application-insights/exceptions-results.png)

