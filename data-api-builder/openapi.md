---
title: Data API builder REST API documentation with Swagger / OpenAPI
description: This document describes how to access the REST endpoint's OpenAPI description document with Swagger.
author: seantleonard
ms.author: seleonar
ms.service: data-api-builder
ms.topic: openapi
ms.date: 06/08/2023
---

# Data API builder REST API documentation with Swagger / OpenAPI

The OpenAPI specification is a programming language-agnostic standard for documenting HTTP APIs. Data API builder supports the OpenAPI standard with its ability to:

- Generate information about all runtime config defined entities that are REST enabled.
- Compile the information into a format that matches the OpenAPI schema.
- Exposes the generated OpenAPI schema via a visual UI (Swagger) or a serialized file.

## OpenAPI Description Document

Data API builder generates an OpenAPI description document (also referred to as a schema file) using the developer provided runtime config file and the database object metadata for each REST enabled entity defined in the runtime config file.
The schema file is generated using functionality provided by the [OpenAPI.NET SDK](https://github.com/microsoft/OpenAPI.NET). Currently, the schema file is  generated in adherence to [OpenAPI Specification v3.0.1](https://spec.openapis.org/oas/v3.0.1.html) formatted as JSON.

The OpenAPI description document can be fetched from Data API builder from the path:

```https
GET /{rest-path}/openapi 
```

> [!NOTE]
> By default, the `rest-path` value is `api` and is configurable. For more details, see [Configuration file - REST Settings](./configuration-file.md#rest)

## SwaggerUI

[Swagger UI](https://swagger.io/swagger-ui/) offers a web-based UI that provides information about the service, using the generated OpenAPI specification.

In `Development` mode, Data API builder enables viewing the generated OpenAPI description document from a dedicated endpoint:

```https
GET /swagger
```

The "Swagger" endpoint is not nested under the `rest-path` in order to avoid naming conflicts with runtime configured entities.
