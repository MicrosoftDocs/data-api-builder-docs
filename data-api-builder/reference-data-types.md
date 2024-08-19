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

# Data API builder not supported data types

### SQL Server database

| **Not Supported**       | **Description**                                                |
|---------------------|----------------------------------------------------------------|
| `geography`         | Geospatial data representing Earth's surface.                  |
| `geometry`          | Planar spatial data using Cartesian coordinates.               |
| `hierarchyid`       | Hierarchical data management.                                  |
| `json`              | JSON formatted data (currently in preview).                                           |
| `rowversion`        | Row versioning for concurrency control.                        |
| `sql_variant`       | Values of various SQL Server-supported data types.             |
| `vector`               | Vector data (currently in preview).                                            |
| `xml`               | XML formatted data.                                            |

### PostgreSQL database

| **Not Supported**       | **Description**                                                |
|---------------------|----------------------------------------------------------------|
| `bytea`             | Binary string storage.                                         |
| `date`              | Calendar dates (year, month, day).                             |
| `smalldatetime`     | Less precise date and time storage.                            |
| `datetime2`         | Not native; typically handled by `timestamp`.                  |
| `timestamptz`       | Dates and times with time zone.                                |
| `time`              | Time of day without date.                                      |
| `localtime`         | Current time based on system clock.                            |

### MySQL database

| **Not Supported**       | **Description**                                                |
|---------------------|----------------------------------------------------------------|
| `UUID`              | Universally Unique Identifiers.                                |
| `DATE`              | Calendar dates.                                                |
| `SMALLDATETIME`     | Less precise date and time storage.                            |
| `DATETIME2`         | Not native; typically handled by `datetime`.                   |
| `DATETIMEOFFSET`    | Dates and times with time zone.                                |
| `TIME`              | Time of day without date.                                      |
| `LOCALTIME`         | Current time based on system clock.                            |

### Azure Cosmos DB for NoSQL

_Data type support is not yet listed._