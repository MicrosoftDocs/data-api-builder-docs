---
title: Usage and behavior of transactions created by Data API builder
description: This document aims to outline details about the transactions created by Data API builder.
author: severussundar
ms.author: shyamsundarj
ms.service: data-api-builder
ms.topic: transactions
ms.date: 05/18/2023
---

# Transactions

Data API builder creates database transactions to execute certain types of GraphQL and REST requests. This document aims to outline the details on 
 - GraphQL and REST request types for which transactions are created.
 - Isolation levels with which the transactions are created for each database type.
 - Behavior of concurrent long running transactions. 

## GraphQL Mutations in Data API builder

 Refer to [GraphQL Mutations in Data API builder](.\graphql.md#mutations) to learn about GraphQL mutations supported by Data API builder.

Consider a typical GraphQL mutation

```graphql
mutation updateNotebook($id: Int!, $item: UpdateNotebookInput!) {
        updateNotebook(id: $id, item: $item) {
          id
          color
        }
      }

``` 

To process such a graphQL request, Data API builder constructs two database queries. The first database query is for performing the update action that is associated with the mutation. 
The second database query is for fetching the data requested in the selection set. 

Data API builder executes both these database queries in a transaction. 

## REST requests

Refer to the [REST in Data API builder](.\rest.md) page to read about the REST features supported by Data API builder.

Data API builder executes the database queries associated with `POST,DELETE,PUT and PATCH` requests in a transaction.

## Transaction Isolation level for each database type

The below table lists the isolation levels with which the transactions are created for each database type.

|**Database Type**|**Isolation Level**
:-----:|:-----:
Azure SQL (or) SQL Server|Read Committed
MySQL|Repeatable Read
PostgreSQL|Read Committed

## Behavior exhibited by concurrent transactions

This section details the behavior expected when there are two concurrent running transactions operating on the same item. The nature of concurrent transactions is as follows.

a) Long running write transaction and a read transaction

b) Long running read transaction and a write transaction

Here, a read transaction implies that the transaction performs only read operations. A write transaction implies that the transaction performs both read and write operations.

### Long running write transaction and a read transaction

A read transaction arrives when a long running write transaction is in flight.

|**Database Type**|**Does the read transaction block?**
:-----:|:-----:
Azure SQL (or) SQL Server| Yes
MySQL| No
PostgreSQL| No

For Azure SQL or SQL Server, the read transaction waits for the write transaction to complete. For MySQL and PostgreSQL database types, the read transaction doesn't wait until the completion of the write transaction.

### Long running read transaction and a write transaction

A write transaction arrives when a long running read transaction is in flight.

|**Database Type**|**Does the write transaction block?**
:-----:|:-----:
Azure SQL (or) SQL Server| No
MySQL| No
PostgreSQL| No

For all the SQL database types, the write transaction doesn't wait for the read transaction to complete.
