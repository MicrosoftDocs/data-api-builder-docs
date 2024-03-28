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

Logs can now be streamed to Application Insights for a better monitoring and debugging experience, especially when Data API builder is deployed in Azure. A new `telemetry` section can be added to the configuration file to enable and configure integration with Application Insights:

```json
"telemetry": {
    "application-insights": {
    "enabled": true,    // To enable/disable application insights telemetry
    "connection-string": "{APP_INSIGHTS_CONNECTION_STRING}" // Application Insights connection string to send telemetry
    }
}
```

Read all the details in the [Use Application Insights](./use-application-insights.md) documentation page.


## Support for ignoring extraneous fields in rest request body

With the new `request-body-strict` option, you can now decide if having extra field in the REST payload generates an error (default behavior, backward compatible) or the extra fields is just silently ignored. 

```json
"runtime": {
    "rest": {
      "enabled": true,
      "path": "/api",
      "request-body-strict": true
    },
    ...
}
```

By setting the `request-body-strict` option to `false`, fields that don't have a mapping to the related database object are ignored without generating any error.

## Adding Application Name for `mssql` connections 

Data API builder now injects in the connection string, for `mssql` database types only, the value `dab-<version>` as the `Application Name` property, making easier to identify the connections in the database server. If `Application Name` is already present in the connection string, Data API builder version is appended to it.

## Support `time` data type in `mssql`

`time` data type is now supported in `mssql` databases.

## Mutations on table with triggers for `mssql`

Mutations are now fully supported on tables with triggers for `mssql` databases.

### Preventing update/insert of read-only fields in a table by user 

Automatically detect read-only fields the database and prevent update/insert of those fields by user.  

## Complete list of fixes:

Take a look at [0.9.7 GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.9.7) for a comprehensive list of all the changes and improvements.

