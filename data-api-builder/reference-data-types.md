---
title: Supported data types
description: Lists all of the data types by database platform and whether they're supported or not in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 05/15/2024
---

# Data API builder supported data types

These tables list database data types and indicates whether they're supported or not in Data API builder (DAB) for Azure databases.

## Data types support by database

| | MSSQL | MySQL | PostgreSQL |
| --- | --- | --- | --- |
| **`boolean`** | ✅ Yes | Yes | ✅ Yes |
| **`byte`** | ✅ Yes | Yes | ✖️ No |
| **`bytearray`** | ✅ Yes | Yes | ✅ Yes |
| **`date`** | ✅ Yes | ✖️ No | ✖️ No |
| **`datetime`** | ✅ Yes | Yes | ✅ Yes |
| **`datetime2`** | ✅ Yes | ✖️ No | ✖️ No |
| **`datetimeoffset`** | ✅ Yes | ✖️ No | ✖️ No |
| **`decimal`** | ✅ Yes | Yes | ✅ Yes |
| **`float`** | ✅ Yes | Yes | ✅ Yes |
| **`guid`** | ✅ Yes | ✖️ No | ✅ Yes |
| **`int`** | ✅ Yes | Yes | ✅ Yes |
| **`long`** | ✅ Yes | Yes | ✅ Yes |
| **`short`** | ✅ Yes | Yes | ✅ Yes |
| **`single`** | ✅ Yes | Yes | ✅ Yes |
| **`smalldatetime`** | ✅ Yes | ✖️ No | ✖️ No |
| **`string`** | ✅ Yes | Yes | ✅ Yes |
| **`time`** | ✅ Yes | ✖️ No | ✖️ No |

> [!NOTE]
> Data type support for Azure Cosmos DB for NoSQL is not yet listed.

## Data types reference

| | Description |
| --- | --- |
| **`boolean`** | Represents true or false values |
| **`byte`** | A tiny integer, usually ranging from 0 to 255 |
| **`bytearray`** | Holds variable-length binary data |
| **`date`** | Stores date values without the time component |
| **`datetime`** | Stores date & time down to milliseconds |
| **`datetime2`** | Extended form of `datetime` that supports more extensive date ranges |
| **`datetimeoffset`** | Similar to `datetime` but includes timezone offset |
| **`decimal`** | Fixed-point number with a specific number of digits to the right of the decimal point |
| **`float`** | Floating-point number that can hold large or small numbers with decimal points |
| **`guid`** | A 128-bit unique identifier |
| **`int`** | Integer data type that typically ranges from `-2,147,483,648` to `2,147,483,647` |
| **`long`** | A 64-bit integer |
| **`short`** | A 16-bit integer |
| **`single`** | Similar to `float`, but less precise |
| **`smalldatetime`** | Date & time data type with smaller range & precision |
| **`string`** | Variable-length character string |
| **`time`** | Stores time values down to nanoseconds |

## Related content

- [Command-line interface (CLI) reference](reference-command-line-interface.md)
- [Configuration reference](reference-configuration.md)
- [Database-specific features reference](reference-database-specific-features.md)
- [Functions reference](reference-functions.md)
- [Policies reference](reference-policies.md)
