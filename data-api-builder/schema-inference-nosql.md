---
title: Schema Generation for Azure Cosmos DB for NOSQL
description: Feature that allows for automatic schema generation from Azure Cosmos DB collections
author: sajeetharan
ms.author: sasinnat
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 05/13/2025
show_latex: true
---

# Azure Cosmos DB for NoSQL schema generation

Schema generation allows for automatic schema generation from Azure Cosmos DB collections. Previously, users manually generated the required `schema.gql` schema file. With schema generation, users can generate this schema automatically by sampling their existing data.

## Usage

 - Ensure your Azure Cosmos DB NOSQL collections are populated with representative data.
 - Configure DAB to connect to your Azure Cosmos DB NOSQL instance.
 - Omit the schema.gql file from your setup.
 - After initialization, use the `export` CLI command. 
 
## CLI Syntax

```sh
./Microsoft.DataApiBuilder export --graphql -o <output-path> --generate true \
  --database-type cosmosdb \
  --sampling-mode <sampling-mode> \
  --sampling-count <N> \
  --sampling-partitionKeyPath <partition-key> \
  --sampling-days <days> \
  --sampling-group-count <group-count> \
  --config <dab-config-file>
```

> [!NOTE]
> This command connects to Cosmos DB using the information in config file.

### CLI options

| Option                    | Data Type | Values / Default                        | Description |
|---------------------------|-----------|-----------------------------------------|-------------|
| `--generate`              | boolean   | `true` / `false`                        | Enable schema generation. |
| `--database-type`         | string    | `cosmosdb`                              | Only `cosmosdb` is supported. |
| `--sampling-mode`         | string    | `TopNSampling`, `PartitionBasedSampling`, `TimeBasedSampling` | Chooses sampling strategy. |
| `--sampling-count` / `-n` | int       | Default: `10`                           | Number of records to sample. |
| `--sampling-partitionKeyPath` | string | Optional                                | Partition key path (for PartitionBasedSampling). |
| `--sampling-days`         | int       | Default: `0` (ignore filter)            | Filters records newer than N days. |
| `--sampling-group-count`  | int       | Default: `10`                           | Used in TimeBasedSampling to split time ranges. |
| `--config`                | string    | Path to DAB config file                 | Provides connection and entity info. |

## Sampling modes

The schema generator supports three sampling strategies based on different use cases:

### `TopNSampling` (Simple)

```sql
SELECT TOP N * FROM c ORDER BY _ts DESC
```

- Selects top N records from the dataset ordered by timestamp.
- **Ideal For**: Small datasets with uniform data structure.

**Options:**

- `sampling-count` (N): Number of records to retrieve (default: 10)
- `sampling-days`: Filter for records newer than N days (optional)

### `PartitionBasedSampling` (Partition-aware)

- Determines partition key path (from config or calculated)
- Fetches distinct partition key values
- Retrieves latest N records per partition

- **Ideal For**: Scenarios with diverse data across partitions.

**Options:**

- `sampling-partitionKeyPath`: Optional; auto-discovered if not provided
- `sampling-count` (N): Records per partition (default: 10)
- `sampling-days`: Filter records by recency (default: 0)

### `TimeBasedSampling` (Time-range aware)

- Calculates min and max `_ts` (timestamps)
- Splits into N time-based groups
- Fetches a few records from each time range

- **Ideal For**: Unknown or evolving schemas, highest diversity

**Options:**

- `sampling-group-count`: Number of time groups (default: 10)
- `sampling-count` (N): Records per group
- `sampling-days`: Defines time window to analyze

> [!NOTE]
> This mode is the most resource-intensive due to cross-partition queries.

## How to use the generated schema

Once generated, the resulting `schema.gql` file can be used with DAB exactly like a manually written one:

```json
{
  "data-source": {
    "database-type": "cosmosdb",
    ...
  },
  "graphql": {
    "enabled": true,
    "schema-file": "path/to/schema.gql"
  }
}
```

## Considerations

The accuracy of the generated schema depends on the data present in the collections. Ensure that the data is representative of the expected structure. For complex scenarios or specific schema requirements, manual schema definition via schema.gql remains available.