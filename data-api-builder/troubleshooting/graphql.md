---
title: GraphQL API troubleshooting - Data API builder
description: Troubleshoot common GraphQL schema, mutation, introspection, and relationship issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# GraphQL API troubleshooting

> [!div class="checklist"]
> Solutions for common GraphQL schema generation, authorization, introspection, and relationship issues in Data API builder.

## Common questions

### What is the GraphQL API in DAB?

Data API builder automatically generates a GraphQL API for each entity configured in `dab-config.json`. DAB creates query and mutation types based on the entity definitions and translates GraphQL requests into database queries at runtime. No schema authoring is required for relational databases; Cosmos DB requires a GraphQL schema file.

### Where is the GraphQL endpoint?

The GraphQL endpoint is available at `/<graphql-path>`, which defaults to `/graphql`. The path can be customized using the `--graphql.path` option in `dab init` or by editing `dab-config.json`. The GraphQL IDE (Banana Cake Pop) is available at the same path when DAB runs in development mode.

### Does DAB support GraphQL subscriptions?

No. Data API builder does not currently support GraphQL subscriptions. Only queries and mutations are supported. If your application requires real-time updates, consider polling the query endpoint or using a separate eventing service alongside DAB.

## Common issues

### GraphQL schema not generated

**Symptom:** The GraphQL endpoint returns no types for an entity, or the entity is missing from the schema.

**Cause:** The entity is not enabled for GraphQL, or the entity configuration contains an error that prevents schema generation.

**Resolution:** Open `dab-config.json` and confirm the entity has `"graphql": { "enabled": true }` or that `graphql` is not explicitly set to `false`. Check DAB startup logs for schema generation errors. Ensure the entity's `source` table exists in the database and the database user has sufficient privileges to read its metadata.

### Mutation returns authorization error

**Symptom:** A `create`, `update`, or `delete` mutation returns an authorization or permission denied error.

**Cause:** The role used in the request does not have the required permission configured for the mutation operation on the entity.

**Resolution:** Check the `permissions` array for the entity in `dab-config.json`. Ensure the role (for example, `authenticated`) has `create`, `update`, or `delete` listed in its `actions`. Use `dab update` to add the permission, then restart DAB.

### Introspection disabled in production

**Symptom:** GraphQL clients or tooling receive an error such as `Introspection is not allowed` when querying the schema.

**Cause:** DAB disables GraphQL introspection when running in production mode. This is the expected behavior and is a security default to avoid exposing the schema to unauthorized clients.

**Resolution:** This behavior is by design. To enable introspection during development, run DAB with `--no-https-redirect` or confirm `host.mode` is set to `development` in `dab-config.json`. Do not enable introspection in production deployments.

### Relationship field returns null

**Symptom:** A query on an entity returns `null` for a related entity field even though the related data exists in the database.

**Cause:** The relationship between the two entities is not configured in `dab-config.json`, or the linking fields are mapped incorrectly.

**Resolution:** Use `dab update` to add the relationship, specifying `--relationship`, `--cardinality`, `--target.entity`, and the appropriate linking fields. Verify the foreign key column names in `--relationship.fields` and `--target.fields` match the actual column names in the database. Check DAB logs for join generation errors.
