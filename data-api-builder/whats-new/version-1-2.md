---
title: What's new for version 1.2
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.2.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 06/11/2025
---

# What's new in Data API builder version 1.2 (August 2024)

Release notes and information about the updates and enhancements in Data API builder (DAB) version 1.2.  
[Release 1.2.10: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v1.2.10)

> [!IMPORTANT]  
> This update is our first significant release since general availability (GA) in May.

## Introducing: Maximum Page Size

Data API builder [automatically paginates](../configuration/runtime.md#pagination-settings) query results in REST and GraphQL endpoints. Pagination ensures queries against large tables return manageable results and protects both the database and DAB from overly large responses. 

By default, DAB uses a page size of `100` records, configurable through the [`default-page-size`](../configuration/runtime.md#max-page-size-supported-values) setting. Users can request more records using the [`$first` keyword](../concept/api/rest.md#first-and-after), bypassing the default.

To prevent abuse and help maintain endpoint performance, DAB now supports the `max-page-size` setting, which caps the maximum number of records a user can request. This option gives developers control and flexibility while adding important safeguards.

```json
{
  "runtime": {
    "pagination": {
      "max-page-size": 1000,
      "default-page-size": 100
    }
  }
}
```

## Introducing: Maximum Response Size

Large result sets can overwhelm both DAB and the database. Version 1.2 introduces `max-response-size-mb`, a setting that limits response size in megabytes. This cap applies to the actual payload, not the row count—important because wide columns (text, binary, XML, JSON) can hold up to 2 GB per value.

This setting helps ensure performance and system reliability by enforcing a ceiling on output size while maintaining flexibility for varied data types.

```json
{
  "runtime": {
    "host": {
      "max-response-size-mb": 158
    }
  }
}
```

## Introducing: GraphQL Query Depth Limit

GraphQL supports deep nested queries through relationships, which simplifies complex data retrieval. However, deep nesting increases query complexity and may degrade performance.

The new `graphql/depth-limit` setting restricts the maximum query depth, striking a balance between functionality and reliability.

```json
{
  "runtime": {
    "graphql": {
      "depth-limit": 2
    }
  }
}
```

## Miscellaneous Improvements

- **OpenAPI enhancements**: Improved OpenAPI compatibility for tools like Infragistics AppBuilder by including more metadata in the generated OpenAPI document.  
  [Details](https://github.com/Azure/data-api-builder/issues/2212)

- **Postgres telemetry support**: The `application_name` is now set for Postgres connections, as previously done for SQL Server.  
  [Details](https://github.com/Azure/data-api-builder/pull/2208)

- **Retry policy adjustment**: The default retry count was reduced from 5 to 3 to follow Microsoft Learn best practices.  
  [Details](https://github.com/Azure/data-api-builder/pull/2285)

- **Cultural invariant data conversion**: Data mutations now use `CultureInfo.InvariantCulture` to avoid locale-based inconsistencies when handling float values.  
  [Details](https://github.com/Azure/data-api-builder/pull/2316)

- **Environment variable resolution during schema validation**: Environment variables used in configuration (for example, for connection strings) are now resolved correctly before schema validation.  
  [Details](https://github.com/Azure/data-api-builder/pull/2316)