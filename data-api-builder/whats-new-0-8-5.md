---
title: Release notes for Data API builder 0.8.5
description: Release notes for Data API builder 0.8.5 are available here.
author: jerrynixon
ms.author: jerrynixon
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 09/18/2023
---

## Version 0.8.51

### What's New
- Added support for .env file [#1497](https://github.com/Azure/data-api-builder/pull/1497)

Environment variables shield secrets from plain text exposure and allow for value swapping in different settings. However, these variables must be set either in the user or computer scope, which can lead to cross-project variable "bleeding" if variable names are duplicated. The better alternative? ENV files.[Related Blog](https://devblogs.microsoft.com/azure-sql/dab-envfiles)

- Added support for base-route in Runtime [#1506](https://github.com/Azure/data-api-builder/pull/1506)

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
- Fixed merge config file not available issue [#1493](https://github.com/Azure/data-api-builder/pull/1493)
- Fixed broken links in Markdown Contributing & Readme files [#1498](https://github.com/Azure/data-api-builder/pull/1498)
- Fixed issue when graphql is true & include permission is WILDCARD [#1501](https://github.com/Azure/data-api-builder/pull/1501)
- Fixed linting issues with markdown files [#1514](https://github.com/Azure/data-api-builder/pull/1514)
- Fixed unintended update to GraphQL operation when updating REST methods [#1555](https://github.com/Azure/data-api-builder/pull/1555)
- Fixed bug with only __typename in the selection set [#1525](https://github.com/Azure/data-api-builder/pull/1525)
- Fixed REST behavior for Stored Procedures when methods property is absent in the config file [#1548](https://github.com/Azure/data-api-builder/pull/1548)
- Fixed init command with environment variable [#1541](https://github.com/Azure/data-api-builder/pull/1541)
- Fixed handle configs which have missing options for MsSql [#1580](https://github.com/Azure/data-api-builder/pull/1580)
- Fixed log warning when REST Methods are configured for tables/views [#1646](https://github.com/Azure/data-api-builder/pull/1646)
- Fixed OpenAPI document resolves custom configured REST path [#1658](https://github.com/Azure/data-api-builder/pull/1658)
- Fixed guid filter in GraphQL [#1659](https://github.com/Azure/data-api-builder/pull/1659)
- Fixed indentation in the generated configuration [#1668](https://github.com/Azure/data-api-builder/pull/1668)
- Fixed redundant logging of found config file [#1670](https://github.com/Azure/data-api-builder/pull/1670)