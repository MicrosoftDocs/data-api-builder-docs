---
title: What's New in Data API builder 
description: Release notes summary for the latest version of Data API builder is available here.  
author: yorek 
ms.author: damauri
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 02/22/2023
---

# What's New in Data API builder

- [Version 0.8.5](#version-085)
- [Version 0.7.6](#version-076)
- [Version 0.6.14](#version-0614)
- [Version 0.6.13](#version-0613)
- [Version 0.5.35](#version-0535)
- [Version 0.5.34](#version-0534)
- [Version 0.5.32](#version-0532)
- [Version 0.5.0](#version-050)
- [Version 0.4.11](#version-0411)
- [Version 0.3.7](#version-037)

## Version 0.8.5

Certainly! Here's the revised list with the GitHub URL prefix added to all the issue references:

**What's New**
 - Added support for .env files ([#1497](https://github.com/Azure/data-api-builder/issues/1497))
 - Added support for adding base-route for Runtime ([#1506](https://github.com/Azure/data-api-builder/issues/1506))

**What's Changed**
 - Improved null handling in generated config ([#1529](https://github.com/Azure/data-api-builder/issues/1529))
 - Improved JSON schema definition ([#1565](https://github.com/Azure/data-api-builder/issues/1565))
 - Improved resolving JSON data types in OpenAPI ([#1568](https://github.com/Azure/data-api-builder/issues/1568))
 - Improved config validation for REST entities ([#1496](https://github.com/Azure/data-api-builder/issues/1496))
 - Improved stored procedure parameter handling ([#1551](https://github.com/Azure/data-api-builder/issues/1551))
 - Improved order by and filter tests for GQL/SQL Types ([#1557](https://github.com/Azure/data-api-builder/issues/1557))

**Bug Fixes**
 - Fixed the issue with merge config file not being available ([#1493](https://github.com/Azure/data-api-builder/issues/1493))
 - Fixed broken links in Markdown Contributing and Readme files ([#1498](https://github.com/Azure/data-api-builder/issues/1498))
 - Fixed the issue when GraphQL is true and include permission is WILDCARD ([#1501](https://github.com/Azure/data-api-builder/issues/1501))
 - Fixed linting issues with markdown files ([#1514](https://github.com/Azure/data-api-builder/issues/1514))
 - Fixed unintended update to GraphQL operation when updating REST methods ([#1555](https://github.com/Azure/data-api-builder/issues/1555))
 - Fixed a bug with only __typename in the selection set ([#1525](https://github.com/Azure/data-api-builder/issues/1525))
 - Fixed REST behavior for Stored Procedures when methods property is absent in the config file ([#1548](https://github.com/Azure/data-api-builder/issues/1548))
 - Fixed init command with environment variable ([#1541](https://github.com/Azure/data-api-builder/issues/1541))
 - Fixed configs missing options for MsSql ([#1580](https://github.com/Azure/data-api-builder/issues/1580))
 - Fixed OpenAPI document with custom REST path ([#1658](https://github.com/Azure/data-api-builder/issues/1658))
 - Fixed the guid filter issue in GraphQL ([#1659](https://github.com/Azure/data-api-builder/issues/1659))
 - Fixed indentation in the generated configuration ([#1663](https://github.com/Azure/data-api-builder/issues/1663))

**Bug Fixes**

## Version 0.7.6

A summary of the most relevant changes done in this version is available in the following list:


- [Initial Support for OpenAPI v3.0.1 description document creation](./whats-new-0-7-6.md#initial-support-for-openapi-v3-0-1-description-document-creation)
- [Allowing merger of configuration files](./whats-new-0-7-6.md#allowing-merger-of-configuration-files)
- [Executing GraphQL and REST Mutations in a transaction](./whats-new-0-7-6.md#executing-graphql-and-rest-mutations-in-a-transaction)
- [Bug Fixes](./whats-new-0-7-6.md#bug-fixes)

The full list of release notes for this version is available here: [version 0.7.6 release notes](https://github.com/Azure/data-api-builder/releases/tag/v0.7.6)


## Version 0.6.14

A summary of the most relevant changes done in this version is available in the following list:

- [Bug Fixes](./whats-new-0-6-14.md#bug-fixes)

## Version 0.6.13

A summary of the most relevant changes done in this version is available in the following list:

- [New CLI command to export GraphQL schema](./whats-new-0-6-13.md#new-cli-command-to-export-graphql-schema)
- [Database policy support for create action for MsSql](./whats-new-0-6-13.md#database-policy-support-for-create-action-for-mssql)
- [Ability to configure GraphQL path and disable REST and GraphQL endpoints globally via CLI](./whats-new-0-6-13.md#ability-to-configure-graphql-path-and-disable-rest-and-graphql-endpoints-globally-via-cli)
- [Key fields mandatory for adding/updating views in CLI](./whats-new-0-6-13.md#key-fields-mandatory-for-adding-and-updating-views-in-cli)

## Version 0.5.35

- Force `Allow User Variables=true` for MySql connections fixing PUT/PATCH requests
- Improve mapped column handling for REST pagination and NextLink creation fixes

## Version 0.5.34

A summary of the most relevant changes done in this version is available in the following list:

- [Honor REST and GraphQL enabled flag at runtime level](./whats-new-0-5-34.md#honor-rest-and-graphql-enabled-flag-at-runtime-level)
- [Add Correlation ID to request logs](./whats-new-0-5-34.md#add-correlation-id-to-request-logs)
- [Wildcard Operation Support for Stored Procedures in Engine and CLI](./whats-new-0-5-34.md#wildcard-operation-support-for-stored-procedures-in-engine-and-cli)

## Version 0.5.32

A summary of the most relevant changes done in this version is available in the following list:

- [Ability to customize rest path via CLI](./whats-new-0-5-32.md#ability-to-customize-rest-path-via-cli)
- [Data API builder container image in MAR](./whats-new-0-5-32.md#data-api-builder-container-image-in-mar)
- [Support for GraphQL fragments](./whats-new-0-5-32.md#support-for-graphql-fragments)
- Generate NOTICE.txt in the pipeline for distribution and include LICENSE, README, NOTICE in zip, NuGet, docker image
- [Turn on BinSkim and fix Policheck alerts](./whats-new-0-5-32.md#turn-on-binskim-and-fix-policheck-alerts)

## Version 0.5.0

A summary of the most relevant changes done in this version is available in the following list:

- [Public Microsoft.DataApiBuilder NuGet](./whats-new-0-5-0.md#public-microsoftdataapibuilder-nuget)
- [Public JSON Schema](./whats-new-0-5-0.md#public-json-schema)
- [New `execute` action for stored procedures in Azure SQL](./whats-new-0-5-0.md#new-execute-action-for-stored-procedures-in-azure-sql)
- [New `mappings` section for column renames of tables in Azure SQL](./whats-new-0-5-0.md#new-mappings-section)
- [Set session context to add JWT claims as name/value pairs for Azure SQL connections](./whats-new-0-5-0.md#support-for-session-context-in-azure-sql)
- [Support for filter on nested objects within a document in PostgreSQL](./whats-new-0-5-0.md#support-for-filter-on-nested-objects-within-a-document-in-postgresql)
- [Support for list of scalars for Cosmos DB NoSQL](./whats-new-0-5-0.md#support-scalar-list-in-cosmos-db-nosql)
- [Enhanced logging support using `LogLevel`](./whats-new-0-5-0.md#enhanced-logging-support-using-loglevel)
- [Updated DAB CLI to support new features](./whats-new-0-5-0.md#updated-cli)

## Version 0.4.11

A summary of the most relevant changes done in this version is available in the following list:

- [Public JSON Schema](./whats-new-0-4-11.md#public-json-schema)
- [Updated JSON schema for `data-source` section](./whats-new-0-4-11.md#updated-json-schema-for-data-source-section)
- [Support for filter on nested objects within a document in Azure SQL and SQL Server](./whats-new-0-4-11.md#support-for-filter-on-nested-objects-within-a-document-in-azure-sql-and-sql-server)
- [Improved Stored Procedure support](./whats-new-0-4-11.md#improved-stored-procedure-support)
- [`database-type` value renamed for Cosmos DB](./whats-new-0-4-11.md#database-type-value-renamed-for-cosmos-db)
- [Renaming CLI properties for `cosmosdb_nosql`](./whats-new-0-4-11.md#renaming-cli-properties-for-cosmosdb_nosql)
- [Managed Identity now supported with Postgres](./whats-new-0-4-11.md#managed-identity-now-supported-with-postgres)
- [Support Azure AD User authentication for Azure MySQL Service](./whats-new-0-4-11.md#support-azure-ad-user-authentication-for-azure-mysql-service)

## Version 0.3.7

A summary of the most relevant changes done in this version is available in the following list:

- [Public JSON Schema](./whats-new-0-3-7.md#public-json-schema)
- [View Support](./whats-new-0-3-7.md#view-support)
- [Stored Procedures Support](./whats-new-0-3-7.md#stored-procedures-support)
- [Azure Active Directory Authentication](./whats-new-0-3-7.md#azure-active-directory-authentication)
- [New "Simulator" Authentication Provider for local authentication](./whats-new-0-3-7.md#new-simulator-authentication-provider-for-local-authentication)
- [Support for filter on nested objects within a document in Cosmos DB](./whats-new-0-3-7.md#support-for-filter-on-nested-objects-within-a-document-in-cosmos-db)
