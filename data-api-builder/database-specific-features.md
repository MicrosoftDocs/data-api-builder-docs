---
title: Database-specific features for Data API builder
description: This document lists the database specific features.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: database-specific-features
ms.date: 04/06/2023
---

# Database-specific features

Data API builder allows each database to have its own specific features. This page lists the features that are supported for each database.

### Azure SQL and SQL Server

#### SESSION_CONTEXT and row level security

Azure SQL and SQL Server support the use of the SESSION_CONTEXT function to access the current user's identity. This is useful when you want to leverage the native support for row level security (RLS) available in Azure SQL and SQL Server. For more information, see [Azure SQL session context and RLS](./azure-sql-session-context-rls.md).
