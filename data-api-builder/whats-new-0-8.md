---
title: Release notes for Data API builder 0.8
description: Release notes for Data API builder 0.8 are available here.
author: jerrynixon
ms.author: jnixon
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 09/18/2023
---

# What's new in Data API builder

## Version 0.8

### What's New
- Added support for .env file [#1497](https://github.com/Azure/data-api-builder/pull/1497)

[Environment variables](/azure/data-api-builder/configuration-file#setting-environment-variables) shield secrets from plain text exposure and allow for value swapping in different settings. However, these variables must be set either in the user or computer scope, which can lead to cross-project variable "bleeding" if variable names are duplicated. The better alternative? ENV files. [Related Blog](https://devblogs.microsoft.com/azure-sql/dab-envfiles)

### Source & Refactoring
- Updated FileSystemRuntimeConfigLoader [#1587](https://github.com/Azure/data-api-builder/pull/1587)
- Updated config system [#1402](https://github.com/Azure/data-api-builder/pull/1402)
- Updated pipelines to support -rc for dab versions [#1558](https://github.com/Azure/data-api-builder/pull/1558)
- Updated Nugetization of DataApiBuilder [#1539](https://github.com/Azure/data-api-builder/pull/1539)
- Updated generated config to exclude null values [#1529](https://github.com/Azure/data-api-builder/pull/1529)
- Updated missing properties from the schema [#1565](https://github.com/Azure/data-api-builder/pull/1565)
- Updated OpenAPI - resolving db types to json data types [#1568](https://github.com/Azure/data-api-builder/pull/1568)
- Updated OpenAPI - distinguish proc parameters & result set columns [#1551](https://github.com/Azure/data-api-builder/pull/1551)

### Bug Fixes
- Fixed broken links in Markdown Contributing & Readme files [#1498](https://github.com/Azure/data-api-builder/pull/1498)
- Fixed issue when graphql is true & include permission is WILDCARD [#1501](https://github.com/Azure/data-api-builder/pull/1501)
- Fixed unintended update to GraphQL operation when updating REST methods [#1555](https://github.com/Azure/data-api-builder/pull/1555)
- Fixed bug with only __typename in the selection set [#1525](https://github.com/Azure/data-api-builder/pull/1525)
- Fixed REST behavior for Stored Procedures when methods property is absent in the config file [#1548](https://github.com/Azure/data-api-builder/pull/1548)
- Fixed init command with environment variable [#1541](https://github.com/Azure/data-api-builder/pull/1541)
- Fixed handle configs which have missing options for MsSql [#1580](https://github.com/Azure/data-api-builder/pull/1580)
- Fixed OpenAPI document resolves custom configured REST path [#1658](https://github.com/Azure/data-api-builder/pull/1658)
- Fixed guid filter in GraphQL [#1659](https://github.com/Azure/data-api-builder/pull/1659)
