---
title: SQL MCP Server Overview
description: Enable and configure SQL MCP Server over a SQL data source. 
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 12/03/2026
# Customer Intent: As a developer, I want to create and configure a SQL MCP Server over a SQL data source. 
---

## Overview

## What is MCP?

MCP (Model Context Protocol) is a standard that defines how AI agents discover and call external tools. A tool is a single operation such as creating a record or reading data. Each tool describes its inputs, outputs, and behavior. MCP provides a predictable way for agents to discover and use capabilities.

## What is the SQL MCP Server?

SQL MCP Server is Microsoft's dynamic, open source engine for agentic apps. You configure it with a JSON file that defines how to connect to your database and which tables, views, or stored procedures should be exposed, along with the permissions that apply to each. SQL MCP Server is included as part of Data API builder (DAB) starting in version 1.7. It exposes SQL operations as a small [family of MCP tools](#the-dml-tools) so agents can interact with database entities through a controlled contract. The server is self hosted but, for developers, it can also run locally through the [DAB command-line](../../command-line/index.yml).

> [!TIP]
> Data API builder is open source and free to use.

### Typical use cases

* Allow copilots or chatbots to perform safe CRUD operations
* Build internal automations without writing SQL
* Add agent capabilities without exposing the database directly

## Securing the schema

Data API builder uses a well-defined entity abstraction layer that lists all tables, views, and stored procedures exposed through the API in the configuration. This layer lets you alias names and columns, describe objects and parameters, and limit which fields are available to different roles.

> [!IMPORTANT]
> Data API builder (DAB) is role-aware and only exposes the entities and operations the current role is permitted to access.

Because the SQL MCP Server is a feature of Data API builder, it also uses this abstraction layer. This prevents the internal schema from being exposed to external consumers and allows you to define complex, and even cross-datasource, families of objects and relationships at the API layer.

## Solving NL2SQL 

SQL MCP Server takes [a different approach](#the-dml-tools) from many of the short-sighted database MCP servers available today. A key example is that **we intentionally do not support NL2SQL**.

Why? Models are not deterministic, and complex queries are the most likely to produce subtle errors. These complex queries are often the ones users hope AI can generate, yet they are also the ones that require the most scrutiny when produced in a non-deterministic way.

> [!NOTE]
> Deterministic means the same input always produces the same output. There is no randomness or variation across calls, which makes results predictable, testable, and safe to automate.

Instead, SQL MCP Server supports what might be called an NL2DAB model. This approach uses the secure Data API builder entity abstraction layer and the built-in DAB Query Builder. Together, they produce accurate, well-formed TSQL in a fully deterministic way. This removes the risk, overhead, and nuisance associated with NL2SQL while preserving safety and reliability for agent-generated queries.

## Support for DML

DDL is the Data Definition Language databases use to create and alter objects such as tables and views. SQL MCP Server is built around DML, the Data Manipulation Language used to create, read, update, and delete data in existing tables and views. DML also covers the execution of stored procedures. As a result, SQL MCP Server is designed to work with data, not schema. This aligns with production MCP use cases where AI agents interact with mission critical or business sensitive systems.

> [!TIP]
> To modify schema during local development, engineers can use the MSSQL extension in VS Code, which provides comprehensive DDL support.

## Support for RBAC

SQL MCP Server benefits from the same proven role-based access control (RBAC) system used throughout Data API builder. Each entity in your configuration defines which roles may read, create, update, or delete data, as well as which fields are included or excluded for those roles. These rules apply automatically to every MCP tool, ensuring security remains consistent across REST, GraphQL, and MCP with no additional configuration required.

> [!IMPORTANT]
> Role-based constraints apply at every step of agent interaction.

## Support for caching

SQL MCP Server automatically caches results from the `read_records` tool. [Caching in Data API builder](../cache/level-1.md) is enabled globally, and you can configure it per entity. Both level 1 and level 2 caching help reduce database load, prevent request stampedes, and support warm-start scenarios in horizontally scaled environments.

## Support for monitoring

SQL MCP Server emits logs and telemetry that let enterprises monitor and validate activity from a single pane of glass. This includes Azure Log Analytics, [Application Insights](../monitor/application-insights.md), and local file logs inside a container.

### Telemetry

SQL MCP Server is fully instrumented with OTEL spans and activities. Each operation is traced so developers can correlate behavior across distributed systems. Learn more about Data API builder's native [Open Telemetry](../monitor/open-telemetry.md) support.

### Health checks

SQL MCP Server provides detailed health and entity checks across REST, GraphQL, and MCP endpoints. [Data API builder Health](../monitor/health-checks.md) lets developers define performance expectations, set thresholds, and verify that each endpoint is functioning as expected.


## How to configure SQL MCP Server?

MCP is configured in your DAB configuration file. If you already have a working Data API builder config, upgrading to version 1.7 or later automatically gives you a working SQL MCP Server with no extra steps required.

### Configuration

You can enable MCP globally or at the entity level. This lets you choose which entities surface MCP tools and which remain inaccessible to agents. MCP follows the same rules used for REST and GraphQL, so your configuration remains the single source of truth for permissions, projections, and policies.

When MCP is enabled, SQL MCP Server generates its tool surface automatically based on your configuration. You do not define MCP tools manually. The built-in `dml-tools` system discovers and exposes entities procedurally, which scales well from small schemas to very large databases.

> [!NOTE]
> In the upcoming 1.7 release, you will be able to elevate stored procedures as custom tools. This allows you to host an MCP Server dedicated to a specific set of operations. While this is already possible through the `dml-tools` system, developers who want to define custom tools directly will have a new, simpler option.

### Get started

Getting started means creating the `dab-config.json` to control the engine. You can do this manually, or you can use the [Data API builder (DAB) CLI](../../command-line/index.yml). The CLI simplifies the task, letting you initialize the file with a single command. Configuration property values can use literal strings, [environment variables](../config/env-function.md), or [Azure Key Vault](../config/akv-function.md) secrets. 

```sh
dab init --database-type mssql --connection-string "<todo>" --config dab-config.json --host-mode development
```

You can specify each table, view or stored procedure you want the SQL MCP Server to expose by adding them to the configuration. The CLI lets you easily add them, assign aliases, configure their permissions, and map columns if you want. Most importantly, with the `description` property, you can include semantic details to help language models better understand your data. 

```sh
dab add {entity-name} \                          # object alias (Employees)
  --source {table-or-view-name} \                # database object (dbo.Employees)
  --source.type {table|view|stored-procedure} \  # object type (table)
  --permissions "{role:actions}" \               # role and allowed actions (anonymous:*)
  --description "{text}"                         # semantic description (Company employee records)
```

### Runtime settings

The SQL MCP Server is enabled by default in the Data API builder configuration. In most cases, you do not need to add any settings. The server automatically follows the same permissions and security rules as your API and database. Configure MCP only when you want to narrow or restrict what agents can do.

```json
"runtime": {
  "mcp": {
    "enabled": true,              // default: true
    "path": "/mcp",               // default: /mcp
    "dml-tools": {
      "describe-entities": true,  // default: true
      "create-record": true,      // default: true
      "read-records": true,       // default: true
      "update-record": true,      // default: true
      "delete-record": true,      // default: true
      "execute-entity": true      // default: true
    }
  }
}
```

The CLI also lets you set every property individually or programmatically through scripting. 

```sh
dab configure runtime mcp --enabled true
dab configure runtime mcp --path "/mcp"
dab configure runtime mcp --describe-entities true
dab configure runtime mcp --create-record true
dab configure runtime mcp --read-records true
dab configure runtime mcp --update-record true
dab configure runtime mcp --delete-record true
dab configure runtime mcp --execute-entity true
```

**Why disable individual tools?**
Developers may want to restrict specific actions even when roles or entity permissions allow them. Disabling a tool at the runtime level ensures it never appears to agents. For example, turning off `delete_record` hides delete capability completely, regardless of configuration elsewhere. This scenario is uncommon but useful when strict operational boundaries are required.

### Entity settings

You also do not need to enable MCP on each entity. Entities participate automatically unless you choose to restrict them. The `dml-tools` property exists so you can exclude an entity from MCP or narrow its capabilities, but you do not need to set anything for normal use. The defaults handle everything.

```json
"entities": {
  "products": {
    "mcp": {
      "dml-tools": true
    }
  }
}
```

## The DML tools

When DML tools are enabled globally and for an entity, SQL MCP Server exposes the following tools to agents. These tools form a typed CRUD surface that always reflects your configuration.

#### list_tools response

```json
{
  "tools": [
    { "name": "describe_entities" },
    { "name": "create_record" },
    { "name": "read_records" },
    { "name": "update_record" },
    { "name": "delete_record" },
    { "name": "execute_entity" }
  ]
}
```

**describe_entities** returns the entities available to the current role. Each entry includes field names, data types, primary keys, and allowed operations. This tool does not query the database. Instead, it reads from the in-memory configuration of the endpoint, which is built from the provided configuration file or files.

#### Example response

```json
{
  "entities": [
    {
      "name": "Products",
      "fields": [
        {
          "name": "ProductId",
          "type": "int",
          "isKey": true
        },
        {
          "name": "ProductName",
          "type": "string"
        }
      ],
      "operations": [
        "read_records",
        "update_record"
      ]
    }
  ]
}
```

> [!NOTE]
> The entity options used by any of the CRUD and execute DML tools come directly from `describe_entities`. This two-step flow is enforced by the internal semantic description attached to each tool.

**create_record** creates a new row.

**read_records** queries a table or view.

**update_record** modifies an existing row.

**delete_record** removes an existing row.

**execute_record** runs a stored procedure.

## Conclusion

SQL MCP Server gives developers a simple, predictable, and secure way to bring AI agents into their data workflows without exposing the database or relying on fragile natural language parsing. By building on Data API builder’s entity abstraction, RBAC, caching, and telemetry, it delivers a production-ready surface that works the same across REST, GraphQL, and MCP. You configure it once, and the engine handles the rest.

As MCP adoption grows, this approach keeps agents safe, keeps queries deterministic, and keeps developers in control. With each release, the tooling becomes more capable, but the core idea stays the same: secure defaults, clear contracts, and a fast on-ramp for agentic apps that work anywhere SQL does.
