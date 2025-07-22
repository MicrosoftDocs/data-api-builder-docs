---
title: Use Filtered Log Levels
description: Use Filtered Log Levels
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to customize and filter the verbosity of logs, so that I can better debug my endpoints. 
---

# Use Filtered Log Levels

Data API builder (DAB) supports customizable, filtered log levels to help you control the verbosity and focus of logs. This allows you to get detailed diagnostics on specific components while keeping other areas quieter, improving your debugging and monitoring experience.

Logging settings are configured in the [`runtime.telemetry.log-level` section](../../configuration/runtime.md#telemetry-runtime) of your configuration. You can specify log levels globally or target specific namespaces or classes for fine-grained control.

## Log level priorities

* The most specific namespace or class name takes precedence.
* The `default` key sets the base level for all other components not explicitly listed.
* If omitted, DAB uses default levels based on the host mode:

  * `development` mode defaults to `Debug` (verbose)
  * `production` mode defaults to `Error` (less verbose)

## Supported log levels

* `Trace`: Capture the most detailed and fine-grained information, usually only useful for deep troubleshooting or understanding every step in a process.
* `Debug`: Provide detailed information intended for diagnosing problems and understanding the flow during development.
* `Information`: Record general, high-level events that describe normal operations and milestones.
* `Warning`: Indicate unexpected situations or minor issues that do not stop processing but might require attention.
* `Error`: Log failures that prevent an operation from completing successfully but do not crash the system.
* `Critical`: Report severe issues that cause system or major feature failure and require immediate intervention.
* `None`: Disable logging to suppress all messages for the targeted category or component.

Partial matches of namespace names are supported but must end at a `.` separator. For example:

* `Azure.DataApiBuilder.Core.Configurations.RuntimeConfigValidator`
* `Azure.DataApiBuilder.Core`
* `default`

## Example configuration

```json
{
  "runtime": {
    "telemetry": {
      "log-level": {
        "Azure.DataApiBuilder.Core.Configurations.RuntimeConfigValidator": "Debug",
        "Azure.DataApiBuilder.Core": "Information",
        "default": "Warning"
      }
    }
  }
}
```

In this example:

* Logs from `RuntimeConfigValidator` class are shown at `Debug` level.
* Other classes under `Azure.DataApiBuilder.Core` use `Information` level.
* All other logs default to `Warning` level.

## Hot-reload support

You can update log levels dynamically (hot-reload) in both development and production modes without restarting the application. This helps adjust logging on-the-fly to troubleshoot issues.

## Important namespaces for filtering

Some common namespaces/classes you may want to filter:

* `Azure.DataApiBuilder.Core.Configurations.RuntimeConfigValidator`
* `Azure.DataApiBuilder.Core.Resolvers.SqlQueryEngine`
* `Azure.DataApiBuilder.Core.Resolvers.IQueryExecutor`
* `Azure.DataApiBuilder.Service.HealthCheck.ComprehensiveHealthReportResponseWriter`
* `Azure.DataApiBuilder.Service.Controllers.RestController`
* `Azure.DataApiBuilder.Auth.IAuthorizationResolver`
* `Microsoft.AspNetCore.Authorization.IAuthorizationHandler`
* `default`
