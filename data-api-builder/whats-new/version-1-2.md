---
title: What's new for version 1.2
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.2.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 08/21/2024
---

# What's new in Data API builder version 1.2

Release notes and information about the updates and enhancements in Data API builder (DAB) version 1.2. [Release 1.2.10: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v1.2.10) 

> [!IMPORTANT]
> This is our first significant release since general availability (GA) in May.

## Introducing: Maximum Page Size

Data API builder [automatically paginates](https://learn.microsoft.com/en-us/azure/data-api-builder/reference-configuration#pagination-runtime) query results in both REST and GraphQL endpoints, ensuring queries against large tables return manageable results and protects both the database and Data API builder from overwhelmingly large result sets. In Data API builder, pages default to `100` records, but this value can be customized in DAB's configuration file using the [`max-page-size` property](https://learn.microsoft.com/en-us/azure/data-api-builder/reference-configuration#default-page-size-pagination-runtime). This feature isn't new. User may bypass page size limits with the [`$first` keyword](https://learn.microsoft.com/en-us/azure/data-api-builder/rest#first-and-after) to specify a custom desired result size. Though results are still paginated, the default page size is ignored, and the custom value of `$first` is applied. To prevent abuse and to allow developers to ensure the performance and reliability of their endpoints, Data API builder now supports `max-page-size`, which limits the maximum value that users can specify with `$first`. This new capability is a nice compromise, allowing customizable result sets with guardrails that ensure overall quality.

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

When users request large result sets, it can strain the database and Data API builder, potentially impacting performance, and reliability. Version 1.1.2 introduces the `max-response-size-mb` property, which allows developers to set a limit on the maximum response size, measured in megabytes, as the data streams from the data source. This limit is based on the overall data size, not the number of rows, which is crucial since columns can vary significantly in size. For instance, a few columns with data types like text, binary, XML, or JSON can hold up to 2 GB each, making each row potentially large. This setting helps developers protect their endpoints by capping response sizes, preventing system overloads while maintaining flexibility in handling different types of data.

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

GraphQL’s ability to handle nested queries based on relationship definitions is an incredible feature, enabling users to fetch complex, related data in a single query. However, as users continue to add nested queries, the complexity of the query increases, which can eventually compromise the performance and reliability of both the database and the API endpoint. So, the `graphql/depth-limit` property sets the maximum allowed depth of a GraphQL query (and mutation). This property allows developers to strike a balance, enabling users to enjoy the benefits of nested queries while placing limits to prevent scenarios that could jeopardize the performance and quality of the system.

```json
{
  "runtime": {
    "graphql": {
      "depth-limit": 2
    }
  }
}
```

## Miscellaneous improvements

1. **OpenAPI changes**. Data API builder now better integrates with tools like Infragistics AppBuilder by ensuring our OpenAPI endpoint emits the necessary details for improved compatibility. [Read more](https://github.com/Azure/data-api-builder/issues/2212).

2. **Postgres Telemetry**. In a previous release, we instrumented DAB for SQL Server with login telemetry, specifically by adding a custom value in the connection string's `application_name` attribute. Version 1.1.2 enables instrumentation to Postgres in the same way. [Read more](https://github.com/Azure/data-api-builder/pull/2208).

3. **Updated retry policy**. In a previous release, we added resiliency to Data API builder by enabling a retry policy should a data source fail to respond. Retry policies are a good practice, helping address intermittent network issues. Version 1.1.2 amends our built-in policy from five attempts to three, based on MS Learn guidance. [Read more](https://github.com/Azure/data-api-builder/pull/2285).

4. **Cultural Invariant Conversion**. Version 1.1.2 addresses an issue where float fields were being saved based on local Windows Regional format settings, leading to inconsistencies. This update ensures that all data type conversions during mutations are now handled using `CultureInfo.InvariantCulture`, providing consistent data handling regardless of regional settings. [Read more](https://github.com/Azure/data-api-builder/pull/2316).

5. **Environment Variable Resolution in Schema Validation**. Version 1.1.2 resolves an issue around resolving environment variables during configuration schema validation, causing validation failures. This update ensures that environment variables, such as those used for database types or connection strings, are properly resolved before validation, allowing for accurate and error-free schema validation. [Read more](https://github.com/Azure/data-api-builder/pull/2316).