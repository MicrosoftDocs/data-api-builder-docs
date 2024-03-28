---
title: What's new for version 0.3.7
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.3.7.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 03/28/2024
---

# What's new in Data API builder version 0.3.7

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.3.7-alpha>.

## Public JSON schema

JSON schema is published here: <https://dataapibuilder.azureedge.net/schemas/v0.3.7-alpha/dab.draft.schema.json>.

This schema gives you support for "intellisense," if you're using an IDE like Visual Studio Code that supports JSON Schemas. The `basic-empty-dab-config.json` file in the `samples` folder has an example starting point when manually creating the `dab-config.json` file.

If you're using DAB CLI to create and manage the `dab-config.json` file, DAB CLI isn't yet creating the configuration file using the reference to the JSON schema file.

## View support

Views are now supported both in REST and GraphQL. If you have a view, for example [`dbo.vw_books_details`](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql#L115) it can be exposed using the following `dab` command:

```sh
dab add BookDetail --source dbo.vw_books_details --source.type View --source.key-fields "id" --permissions "anonymous:read"
```

The `source.key-fields` option is used to specify which fields from the view are used to uniquely identify an item, so that navigation by primary key can be implemented also for views. It's the responsibility of the developer configuring DAB to enable or disable actions (for example, the `create` action) depending on if the view is updatable or not.

## Stored procedures support

Stored procedures are now supported for REST requests. If you have a stored procedure, for example [`dbo.stp_get_all_cowritten_books_by_author`](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql#L141) it can be exposed using the following `dab` command:

```sh

dab add GetCowrittenBooksByAuthor --source dbo.stp_get_all_cowritten_books_by_author --source.type "stored-procedure" --permissions "anonymous:read" --rest true
```

The parameter can be passed in the URL query string when calling the REST endpoint:

```text
http://<dab-server>/api/GetCowrittenBooksByAuthor?author=isaac%20asimov
```

It's the responsibility of the developer configuring DAB to enable or disable actions (for example, the `create` action) to allow or deny specific HTTP verbs to be used when calling the stored procedure. For example, for the stored procedure used in the example, given that its purpose is to return some data, it would make sense to only allow the `read` action.

## Microsoft Entra ID Authentication

Microsoft Entra ID authentication is now fully working. For more information, see [authentication with Microsoft Entra ID](https://github.com/Azure/data-api-builder/blob/8c44bc882da718f86bbfba48756c0796ef24e058/docs/authentication-azure-ad.md).

## New simulator authentication provider for local authentication

To simplify testing of authenticated requests when developing locally, a new `simulator` authentication provider is available. The provider `simulator` is a configurable authentication provider, which instructs the Data API builder engine to treat all requests as authenticated. More details here: [Local Authentication](https://github.com/Azure/data-api-builder/blob/8c44bc882da718f86bbfba48756c0796ef24e058/docs/local-authentication.md)

## Support for filter on nested objects within a document in Azure Cosmos DB

With Azure Cosmos DB, You can use the object or array relationship defined in your schema, which enables to do filter operations on the nested objects.

```graphql
query {
  books(first: 1, filter : { author : { profile : { twitter : {eq : ""@founder""}}}})
    id
    name
  }
}
```
