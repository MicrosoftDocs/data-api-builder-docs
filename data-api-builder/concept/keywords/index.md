---
title: Data API builder keywords and arguments
description: Learn about Data API builder keywords (REST) and arguments (GraphQL) for shaping, filtering, ordering, and paging results.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/09/2025
# Customer Intent: As a developer, I want to quickly find and understand how to shape, filter, and page results using REST or GraphQL.
---

# API keywords and arguments

Data API builder (DAB) exposes a consistent query model across REST and GraphQL.  
Each feature appears as a **keyword** in REST and an **argument** in GraphQL.

| Concept | REST | GraphQL | Purpose |
|----------|---------------|------------------|----------|
| Projection | [$select](./select-rest.md) | [items](./select-graphql.md) | Choose which fields to return |
| Filtering | [$filter](./filter-rest.md) | [filter](./filter-graphql.md) | Restrict rows by condition |
| Sorting | [$orderby](./orderby-rest.md) | [orderBy](./orderby-graphql.md) | Define the sort order |
| Page size | [$first](./first-rest.md) | [first](./first-graphql.md) | Limit the items per page |
| Continuation | [$after](./after-rest.md) | [after](./after-graphql.md) | Continue from the last page |

> [!NOTE]
> REST keywords begin with `$`, following OData conventions. 

All keywords and arguments can be combined.  

