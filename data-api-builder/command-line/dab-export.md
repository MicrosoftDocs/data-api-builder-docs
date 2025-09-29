---
title: Export schema with the DAB CLI
description: Use the Data API builder (DAB) CLI to export or generate GraphQL schemas from existing configurations or Cosmos DB data.
author: seesharprun
ms.author: jerrynixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: command-line
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to export a GraphQL schema from my Data API builder configuration or generate one from Cosmos DB, so that I can use it with my API.
---

# `export` command

Export or generate a GraphQL schema file and save it to disk. Two modes are supported:

1. Fetch existing schema from a temporary DAB runtime instance
2. Generate schema from Cosmos DB for NoSQL data using sampling

## Syntax

```sh
dab export --graphql -o <output-directory> [options]
```

> [!IMPORTANT]
> Requires a valid DAB config. The database type is read from the config file. No `--database-type` flag is accepted.

## Quick glance

| Option                                 | Required | Default                           | Applies                                                                  |
| -------------------------------------- | -------- | --------------------------------- | ------------------------------------------------------------------------ |
| `--graphql`                            | Yes      | false                             | Must be set for schema export                                            |
| `-o, --output <dir>`                   | Yes      | –                                 | Directory for output schema                                              |
| `-g, --graphql-schema-file <name>`     | No       | `schema.gql`                      | Filename placed inside output dir                                        |
| `--generate`                           | No       | false                             | Generate schema from Cosmos DB data                                      |
| `-m, --sampling-mode <mode>`           | No       | `TopNExtractor`                   | One of: `TopNExtractor`, `EligibleDataSampler`, `TimePartitionedSampler` |
| `-n, --sampling-count <int>`           | No       | Mode-dependent                    | Number of records per mode                                               |
| `--sampling-partition-key-path <path>` | No       | –                                 | For `EligibleDataSampler` only                                           |
| `-d, --sampling-days <int>`            | No       | –                                 | Restrict to records newer than N days                                    |
| `--sampling-group-count <int>`         | No       | –                                 | For `TimePartitionedSampler` only                                        |
| `-c, --config <file>`                  | No       | Env-specific or `dab-config.json` | Path to config file                                                      |

## Behavior

| Mode                   | Description                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| Export existing schema | Starts a temporary runtime, introspects GraphQL schema, writes file |
| Generate schema        | Samples Cosmos DB documents and infers schema                       |

Empty schema results in error:
“Generated GraphQL schema is empty. Please ensure data is available to generate the schema.”

## Sampling modes

### TopNExtractor

* Samples N recent documents
* Optional time filter with `--sampling-days`

Use for smaller, uniform datasets

### EligibleDataSampler

* Partition-aware sampling
* N documents per partition
* `--sampling-partition-key-path` optional

Use when partitions have varied schema

### TimePartitionedSampler

* Splits min/max `_ts` into time groups
* N documents per group
* `--sampling-group-count` required

Use when schema evolves over time

> [!Note]
> More resource intensive due to multiple queries.

## Options

### `--graphql`

Enables schema export. Without it, nothing happens.

### `-o, --output`

Directory for schema file. Created if missing.

### `-g, --graphql-schema-file`

Output filename only, defaults to `schema.gql`.

### `--generate`

* false (default): Start runtime, introspect schema
* true: Generate schema from Cosmos DB data

### `-m, --sampling-mode`

Options: `TopNExtractor`, `EligibleDataSampler`, `TimePartitionedSampler`
Default: `TopNExtractor`

### `-n, --sampling-count`

* TopNExtractor: total documents
* EligibleDataSampler: per partition
* TimePartitionedSampler: per time group

### `--sampling-partition-key-path`

Partition key path for EligibleDataSampler

### `-d, --sampling-days`

Filter documents by recency (days)

### `--sampling-group-count`

Number of time groups for TimePartitionedSampler

### `-c, --config`

Config file path. If omitted:

1. `dab-config.<DAB_ENVIRONMENT>.json` if env var is set
2. Otherwise `dab-config.json`

## Return codes

| Code     | Meaning          |
| -------- | ---------------- |
| 0        | Export succeeded |
| Non-zero | Export failed    |

## Examples

### Export existing schema

```sh
dab export --graphql -o ./schema-out
```

### Generate schema (TopNExtractor)

```sh
dab export --graphql -o ./schema-gen \
  --generate \
  --sampling-mode TopNExtractor \
  --sampling-count 25 \
  --sampling-days 14
```

### Partition-aware sampling

```sh
dab export --graphql -o ./schema-partitions \
  --generate \
  --sampling-mode EligibleDataSampler \
  --sampling-partition-key-path /customerId \
  --sampling-count 10
```

### Time-based sampling

```sh
dab export --graphql -o ./schema-time \
  --generate \
  --sampling-mode TimePartitionedSampler \
  --sampling-group-count 8 \
  --sampling-count 5 \
  --sampling-days 60
```

### Custom output filename

```sh
dab export --graphql -o ./out \
  -g cosmos-schema.graphql \
  --generate \
  --sampling-mode TopNExtractor \
  --sampling-count 15
```

## Generated file usage

Update config:

```json
{
  "data-source": {
    "database-type": "cosmosdb_nosql"
  },
  "runtime": {
    "graphql": {
      "enabled": true,
      "schema-file": "schema.gql"
    }
  }
}
```

> [!TIP]
> Commit the generated schema once stable. Re-run if data model changes.

## Troubleshooting

| Symptom               | Cause                   | Fix                           |
| --------------------- | ----------------------- | ----------------------------- |
| Empty schema          | No or insufficient data | Add representative data       |
| Connectivity error    | Bad connection string   | Fix credentials or network    |
| Missing fields        | Not in sampled docs     | Increase count or change mode |
| Few partition results | Wrong partition key     | Provide correct key path      |
| Slow time sampling    | Large dataset           | Reduce groups or days         |

## Best practices

* Start with TopNExtractor
* Use version control to diff schema changes
* For critical collections, run multiple passes with different parameters
