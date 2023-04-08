---
title: Known issues in Data API builder
description: This document lists the known issues in Data API builder
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: known-issues
ms.date: 04/06/2023
---

# Known Issues and Limitations

## General

- Mutations aren't correctly created for many-to-many relationship. [Issue #479](https://github.com/Azure/data-api-builder/issues/479)

## Azure SQL and SQL Server

- Table with triggers error out on UPDATE. [Issue #452](https://github.com/Azure/data-api-builder/issues/452)
- JSON data is escaped in the response. [Issue #444](https://github.com/Azure/data-api-builder/issues/444)
- Database policies for insert via PUT/PATCH operations in REST aren't supported yet. [Issue #1370](https://github.com/Azure/data-api-builder/issues/1370)

## MySQL

- Update fails on tables with Computed columns. [Issue #1001](https://github.com/Azure/data-api-builder/issues/1001)
- Update fails on views. [Issue #938](https://github.com/Azure/data-api-builder/issues/938)
- Support for CREATE/UPDATE actions on view is missing. [Issue #894](https://github.com/Azure/data-api-builder/issues/894)
- Nested Filtering in GraphQL isn't supported yet. [Issue #1019](https://github.com/Azure/data-api-builder/issues/1019)
- Entities backed by Stored Procedures aren't supported yet. [Issue #1024](https://github.com/Azure/data-api-builder/issues/1024)
- Database policies for PUT/PATCH/POST operations in REST aren't supported yet. [Issue #1267](https://github.com/Azure/data-api-builder/issues/1267), [Issue #1329](https://github.com/Azure/data-api-builder/issues/1329), [Issue #1371](https://github.com/Azure/data-api-builder/issues/1371)

## PostgreSQL

- Entities backed by Stored Procedures aren't supported yet. [Issue #1023](https://github.com/Azure/data-api-builder/issues/1023)
- Database policies for insert via PUT/PATCH/POST operations in REST aren't supported yet. [Issue #1372](https://github.com/Azure/data-api-builder/issues/1372), [Issue #1334](https://github.com/Azure/data-api-builder/issues/1334)
