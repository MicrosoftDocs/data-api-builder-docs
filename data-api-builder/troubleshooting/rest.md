---
title: REST API troubleshooting - Data API builder
description: Troubleshoot common REST API endpoint, HTTP method, filtering, and CORS issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# REST API troubleshooting

> [!div class="checklist"]
> Solutions for common REST endpoint availability, HTTP method, OData filter, and CORS issues in Data API builder.

## Common questions

### What is the REST API in DAB?

Data API builder automatically generates a REST API for each entity configured in `dab-config.json`. The API follows OData conventions and supports standard HTTP methods for reading and writing data. No additional code is required; DAB translates HTTP requests into database queries at runtime.

### What HTTP methods does DAB support?

DAB supports `GET`, `POST`, `PUT`, `PATCH`, and `DELETE` for REST entities. Each method maps to a database operation: `GET` reads, `POST` inserts, `PUT` replaces, `PATCH` updates, and `DELETE` removes records. You can restrict allowed methods per entity using the `rest.methods` field in the entity configuration.

### How are REST endpoints structured?

REST endpoints follow the pattern `/<rest-path>/<entity-name>`, where `<rest-path>` defaults to `api` and `<entity-name>` is the entity key in `dab-config.json`. For example, an entity named `Products` is accessible at `/api/Products`. The REST path can be customized using the `--rest.path` option in `dab init` or by editing `dab-config.json`.

## Common issues

### 404 on REST endpoint

**Symptom:** Requests to `/api/EntityName` return `404 Not Found`.

**Cause:** The entity is not enabled for REST, the entity name in the URL does not match the configuration, or the REST path has been customized.

**Resolution:** Open `dab-config.json` and confirm the entity has `"rest": { "enabled": true }` or that `rest` is not explicitly set to `false`. Verify the URL uses the exact entity name (case-sensitive). If the REST path was customized with `--rest.path`, update the URL accordingly.

### 405 Method Not Allowed

**Symptom:** A `POST`, `PUT`, `PATCH`, or `DELETE` request returns `405 Method Not Allowed`.

**Cause:** The HTTP method is not included in the entity's `rest.methods` allow list.

**Resolution:** Check the `rest.methods` array for the entity in `dab-config.json`. Add the required method, for example `"methods": ["GET", "POST", "PATCH", "DELETE"]`. Re-run `dab start` to apply the change.

### $filter query returns unexpected results

**Symptom:** An OData `$filter` expression returns no results or an error such as `Invalid filter expression`.

**Cause:** The OData filter syntax is incorrect, the field name does not match the entity's exposed column name, or the value format does not match the column type.

**Resolution:** Verify the filter syntax against the OData specification. String values must be enclosed in single quotes (for example, `$filter=Name eq 'Alice'`). If field mappings are configured in the entity, use the mapped name rather than the database column name. Check DAB logs for the generated SQL to diagnose unexpected result sets.

### CORS error calling REST endpoint from browser

**Symptom:** Browser requests to the DAB REST API fail with a CORS policy error.

**Cause:** The DAB host configuration does not include the caller's origin in the allowed origins list.

**Resolution:** Update the `host.cors.origins` array in `dab-config.json` to include the front-end origin, for example `["https://myapp.example.com"]`. To allow all origins during local development, set `"origins": ["*"]`. Restart DAB after updating the configuration. Avoid using `*` in production environments.
