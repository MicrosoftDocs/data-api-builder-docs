---
title: Swagger and OpenAPI metadata for REST endpoints
description: Manage OpenAPI description and Swagger UI hosting for Data API builder's REST API endpoints feature.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to use the Data API Builder, so that I can host OpenAPI/Swagger metadata.
---

# Data API builder REST API documentation with Swagger / OpenAPI

The OpenAPI specification is a programming language-agnostic standard for documenting HTTP APIs. Data API builder supports the OpenAPI standard with its ability to:

- Generate information about all runtime configuration defined entities that are REST enabled.
- Compile the information into a format that matches the OpenAPI schema.
- Exposes the generated OpenAPI schema via a visual UI (Swagger) or a serialized file.

## OpenAPI description document

Data API builder generates an OpenAPI description document using the provided runtime configuration and the database object metadata for each REST enabled entity defined.
The schema file is generated using functionality provided by the [OpenAPI.NET SDK](https://github.com/microsoft/OpenAPI.NET). Currently, the schema file is generated in adherence to [OpenAPI Specification v3.0.1](https://spec.openapis.org/oas/v3.0.1.html) formatted as JSON.

The OpenAPI description document can be fetched from Data API builder from the path:

```https
GET /{rest-path}/openapi 
```

> [!NOTE]
> By default, the `rest-path` value is `api` and is configurable. For more information, see [REST configuration](../reference-configuration.md#rest-runtime)

## SwaggerUI

[Swagger UI](https://swagger.io/swagger-ui) offers a web-based UI that provides information about the service, using the generated OpenAPI specification.

In `Development` mode, Data API builder enables viewing the generated OpenAPI description document from a dedicated endpoint:

```https
GET /swagger
```

The "Swagger" endpoint isn't nested under the `rest-path` in order to avoid naming conflicts with runtime configured entities.

## Related content

- [REST configuration reference](../reference-configuration.md#rest-runtime)
- [REST endpoints](rest.md)
