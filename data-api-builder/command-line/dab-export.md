---
title: Export schema with the DAB CLI
description: Use the Data API builder (DAB) CLI to export or generate GraphQL schemas from existing configurations or Cosmos DB data.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to export a GraphQL schema from my Data API builder configuration or generate one from Cosmos DB, so that I can use it with my API.
---

# `export` command

Export or generate a GraphQL schema file and save it to disk. Two modes are supported:

 - Fetch existing schema from a temporary DAB runtime instance
 - Generate schema from Cosmos DB for NoSQL data using sampling

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
| `--help`                               | No       | –                                 | Display the help screen                                                  |
| `--version`                            | No       | –                                 | Display version information                                              |

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

## `--graphql`

Enables schema export. Without it, nothing happens.

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-out
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-out
```

---

## `-o, --output`

Directory for schema file. Created if missing.

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-out
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-out
```

---

## `-g, --graphql-schema-file`

Output filename only, defaults to `schema.gql`.

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./out \
  -g custom-schema.gql
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\out ^
  -g custom-schema.gql
```

---

## `--generate`

* false (default): Start runtime, introspect schema
* true: Generate schema from Cosmos DB data

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-gen \
  --generate
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-gen ^
  --generate
```

---

## `-m, --sampling-mode`

Options: `TopNExtractor`, `EligibleDataSampler`, `TimePartitionedSampler`
Default: `TopNExtractor`

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-gen \
  --generate \
  --sampling-mode TopNExtractor
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-gen ^
  --generate ^
  --sampling-mode TopNExtractor
```

---

## `-n, --sampling-count`

* TopNExtractor: total documents
* EligibleDataSampler: per partition
* TimePartitionedSampler: per time group

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-gen \
  --generate \
  --sampling-mode TopNExtractor \
  --sampling-count 25
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-gen ^
  --generate ^
  --sampling-mode TopNExtractor ^
  --sampling-count 25
```

---

## `--sampling-partition-key-path`

Partition key path for EligibleDataSampler

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-partitions \
  --generate \
  --sampling-mode EligibleDataSampler \
  --sampling-partition-key-path /customerId
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-partitions ^
  --generate ^
  --sampling-mode EligibleDataSampler ^
  --sampling-partition-key-path /customerId
```

---

## `-d, --sampling-days`

Filter documents by recency (days)

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-gen \
  --generate \
  --sampling-days 14
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-gen ^
  --generate ^
  --sampling-days 14
```

---

## `--sampling-group-count`

Number of time groups for TimePartitionedSampler

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-time \
  --generate \
  --sampling-mode TimePartitionedSampler \
  --sampling-group-count 8
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-time ^
  --generate ^
  --sampling-mode TimePartitionedSampler ^
  --sampling-group-count 8
```

---

## `-c, --config`

Config file path. If omitted:

1. `dab-config.<DAB_ENVIRONMENT>.json` if env var is set
2. Otherwise `dab-config.json`

### Example

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-out \
  --config ./dab-config.json
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-out ^
  --config .\dab-config.json
```

---

## `--help`

Display the help screen.

### Example

#### [Bash](#tab/bash)

```bash
dab export --help
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export --help
```

---

## `--version`

Display version information.

### Example

#### [Bash](#tab/bash)

```bash
dab export --version
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export --version
```

---

## Return codes

| Code     | Meaning          |
| -------- | ---------------- |
| 0        | Export succeeded |
| Non-zero | Export failed    |

## Examples

### Export existing schema

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-out
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-out
```

---

### Generate schema (TopNExtractor)

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-gen \
  --generate \
  --sampling-mode TopNExtractor \
  --sampling-count 25 \
  --sampling-days 14
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-gen ^
  --generate ^
  --sampling-mode TopNExtractor ^
  --sampling-count 25 ^
  --sampling-days 14
```

---

### Partition-aware sampling

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-partitions \
  --generate \
  --sampling-mode EligibleDataSampler \
  --sampling-partition-key-path /customerId \
  --sampling-count 10
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-partitions ^
  --generate ^
  --sampling-mode EligibleDataSampler ^
  --sampling-partition-key-path /customerId ^
  --sampling-count 10
```

---

### Time-based sampling

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./schema-time \
  --generate \
  --sampling-mode TimePartitionedSampler \
  --sampling-group-count 8 \
  --sampling-count 5 \
  --sampling-days 60
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\schema-time ^
  --generate ^
  --sampling-mode TimePartitionedSampler ^
  --sampling-group-count 8 ^
  --sampling-count 5 ^
  --sampling-days 60
```

---

### Custom output filename

#### [Bash](#tab/bash)

```bash
dab export \
  --graphql \
  -o ./out \
  -g cosmos-schema.graphql \
  --generate \
  --sampling-mode TopNExtractor \
  --sampling-count 15
```

#### [Command Prompt](#tab/cmd)

```cmd
dab export ^
  --graphql ^
  -o .\out ^
  -g cosmos-schema.graphql ^
  --generate ^
  --sampling-mode TopNExtractor ^
  --sampling-count 15
```

---

## Generated file usage

Set `runtime.graphql.schema` to the exported schema file path. For more information, see [Runtime configuration](../configuration/runtime.md).

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
