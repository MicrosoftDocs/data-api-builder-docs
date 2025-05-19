---
title: Schema Generation for Azure CosmosDB for NOSQL
description: Feature that allows for automatic schema generation from CosmosDB collections
author: sajeetharan
ms.author: sasinnat
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 05/13/2025
show_latex: true
---

# Azure CosmosDB for NOSQL Schema Generation in Azure Data API Builder

This feature introduces an enhancement to the Azure Data API Builder (DAB) that allows for automatic schema generation from CosmosDB collections. Previously, users were required to manually provide schema information via a `schema.gql` file. With this update, users have the option to generate the schema automatically, simplifying the setup process.

## Motivation
The manual provision of schema information can be time-consuming and error-prone. By enabling automatic schema generation, DAB aims to:

- Reduce the setup complexity for users.
- Minimize potential errors from manual schema definitions.
- Streamline the integration process with Azure CosmosDB for NOSQL.

## Feature Details

- Automatic Schema Generation: DAB can now infer the schema directly from the existing Azure CosmosDB NOSQL API collections.

- Optional Usage: Users can choose between providing a schema.gql file or leveraging the automatic schema generation feature.

- Enhanced User Experience: This feature simplifies the initial configuration, especially beneficial for rapid prototyping and development scenarios.

## Usage
To utilize the automatic schema generation:

 - Ensure your Azure CosmosDB NOSQL collections are populated with representative data.

 - Configure DAB to connect to your Azure CosmosDB NOSQL instance.

 - Omit the schema.gql file from your setup.

 - Upon initialization, DAB will analyze the collections and generate the corresponding GraphQL schema.

 ### New Capability: Schema Generation via CLI

This update introduces a **schema generation utility** that automates schema creation using existing data in CosmosDB. The feature is available via the DAB CLI and will eventually be exposed via a REST API.

### CLI Usage

The CLI command to generate schema looks like this:

```bash
./Microsoft.DataApiBuilder export --graphql -o <output-path> --generate true \
  --database-type cosmosdb \
  --sampling-mode <sampling-mode> \
  --sampling-count <N> \
  --sampling-partitionKeyPath <partition-key> \
  --sampling-days <days> \
  --sampling-group-count <group-count> \
  --config <dab-config-file>
```

This command uses the provided DAB runtime config to connect to the database and export the schema to the specified output path.

### CLI Options

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

## Sampling Modes

The schema generator supports three sampling strategies based on different use cases:

### 1. TopNSampling (Simple)

```sql
SELECT TOP N * FROM c ORDER BY _ts DESC
```

- Selects top N records from the dataset ordered by timestamp.
- **Ideal For**: Small datasets with uniform data structure.

**Options:**

- `sampling-count` (N): Number of records to retrieve (default: 10)
- `sampling-days`: Filter for records newer than N days (optional)

---

### 2. PartitionBasedSampling (Partition-aware)

- Determines partition key path (from config or calculated)
- Fetches distinct partition key values
- Retrieves latest N records per partition

- **Ideal For**: Scenarios with diverse data across partitions.

**Options:**

- `sampling-partitionKeyPath`: Optional; auto-discovered if not provided
- `sampling-count` (N): Records per partition (default: 10)
- `sampling-days`: Filter records by recency (default: 0)

---

### 3. TimeBasedSampling (Time-range aware)

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

---

## How to Use the Generated Schema

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