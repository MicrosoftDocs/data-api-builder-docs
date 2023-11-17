---
title: Release notes for Data API builder 0.9
description: Release notes for Data API builder 0.9 are available here.
author: yorek
ms.author: damauri
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 11/16/2023
---

# What's new in Data API builder 0.9

Here's the details on the most relevant changes and improvement in Data API builder 0.9

## Enable Application Insights when self-hosting DAB

Logs can now be streamed to Application Insights for a better monitoring and debugging experience, especially when Data API builder is deployed in Azure. A new `telemetry` section can been added to the configuration file to enable and configure integration with Application Insights:

```
"telemetry": {
    "application-insights": {
    "enabled": true,    // To enable/disable application insights telemetry
    "connection-string": "{APP_INSIGHTS_CONNECTION_STRING}" // Application Insights connection string to send telemetry
    }
}
```

Read all the details in the [Use Application Insights](./use-application-insights.md) documentation page.


## Support for ignoring extraneous fields in rest request body

TBD


## Adding Application Name for `mssql` connections 

TBD

## Support `time` data type in `mssql`

TBD

## Mutations on table with triggers for `mssql`

TBD

## Adding support for positive boolean options in CLI 

TBD

### Preventing update/insert of read-only fields in a table by user 

TBD

## Structured logging compatibility 

TBD

## Complete list of fixes:

Please take a look at [0.9.7 GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.9.7) for a comprehensive list of all the changes and improvements.

