---
title: Validate configuration with the DAB CLI
description: Use the Data API builder (DAB) CLI to validate configuration files for schema, permissions, connectivity, and metadata before runtime starts.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to validate my Data API builder configuration, so that I can catch errors before starting the runtime or deploying.
---

# `validate` command

Validate a Data API builder configuration file without starting the runtime. Runs a sequence of checks (schema, structure, permissions, connectivity, metadata) and returns an exit code for success (0) or failure (non-zero). Useful in CI/CD pipelines.

## Syntax

```bash
dab validate [options]
```

### Quick glance

| Option                         | Summary                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------- |
| [`-c, --config`](#-c---config) | Path to the config file. Defaults to environment-specific or `dab-config.json`. |

> [!Note]
> `validate` accepts no flags other than `--config`.

## Exit Codes

| Code     | Meaning                                          |
| -------- | ------------------------------------------------ |
| 0        | Config passed all stages.                        |
| non-zero | One or more stages failed. See logs for details. |

CI example:

#### [Bash](#tab/bash)

```bash
dab validate && echo "OK" || { echo "INVALID CONFIG"; exit 1; }
```

#### [Command Prompt](#tab/cmd)

```cmd
dab validate
if %errorlevel%==0 (echo OK) else (echo INVALID CONFIG & exit /b 1)
```

---

## `-c, --config`

Path to the config file. If omitted, validator looks for `dab-config.<DAB_ENVIRONMENT>.json` first, then `dab-config.json`.

### Example

#### [Bash](#tab/bash)

```bash
dab validate \
  --config ./dab-config.prod.json
```

#### [Command Prompt](#tab/cmd)

```cmd
dab validate ^
  --config ./dab-config.prod.json
```

---

## Validation Stages

Validation happens in order. If one stage fails, later stages are skipped.

### 1. Schema

Checks that the config JSON matches the schema.

#### Rules

* `$schema` is reachable or structurally valid
* `data-source`, `runtime`, and `entities` sections exist and are well-formed
* Disallowed unexpected properties (per schema)
* Enum values (like `database-type`) are valid

#### Failures & Fixes

| Problem             | Example                   | Fix                               |
| ------------------- | ------------------------- | --------------------------------- |
| Misspelled property | `"conn-string"`           | Use `"connection-string"`.        |
| Invalid enum        | `"database-type": "mydb"` | Use supported values.             |
| Wrong shape         | `entities` as array       | Use object keyed by entity names. |

### 2. Config Properties

Checks consistency beyond schema.

#### Rules

* Valid `database-type` supplied
* For `cosmosdb_nosql`, database and GraphQL schema path are required. A container may also be required depending on entities. REST settings are ignored.
* At least one endpoint (REST, GraphQL, MCP) must be enabled
* REST/GraphQL paths start with `/` and do not collide
* Legacy `*.disabled` flags emit warnings but do not fail
* If using JWT, both issuer and audience must be set

#### Failures & Fixes

| Problem                  | Example                              | Fix                      |
| ------------------------ | ------------------------------------ | ------------------------ |
| All endpoints off        | REST=false, GraphQL=false, MCP=false | Re-enable one.           |
| Cosmos DB missing schema | no `graphql-schema`                  | Provide schema path.     |
| Auth mismatch            | Issuer set, audience missing         | Provide both or neither. |

### 3. Permissions

Checks that each entity’s permissions are valid.

#### Rules

* Each entry has a non-empty role
* Actions must be valid:

  * Tables/views: `create, read, update, delete, *`
  * Stored procs: `execute, *`
* No empty action lists
* A single action set must be either `*` OR explicit actions, not both

#### Failures & Fixes

| Problem            | Example                   | Fix                   |
| ------------------ | ------------------------- | --------------------- |
| Unsupported action | `"drop"`                  | Use `read`, etc.      |
| SP with CRUD       | Stored proc uses `update` | Use `execute` or `*`. |
| Empty list         | `"actions": []`           | Provide actions.      |

### 4. Database Connection

Checks that the database connection works.

#### Rules

* Connection string parseable
* Credentials valid
* Database/container exists

#### Failures & Fixes

| Problem    | Example            | Fix                         |
| ---------- | ------------------ | --------------------------- |
| Timeout    | Server unreachable | Check network/firewall.     |
| Bad login  | Auth failed        | Fix username/password.      |
| Missing DB | DB not found       | Create DB or update config. |

### 5. Entity Metadata

Checks entity definitions against the database.

#### Rules

* Source object exists
* Tables/views: key fields valid, included/excluded fields exist
* Views always need `source.key-fields`
* Stored procedures: params match signature
* Relationships: target entity exists, linking fields align with keys; linking.object must exist for many-to-many
* Policies reference valid fields
* Caching TTL non-negative

#### Failures & Fixes

| Problem               | Example                               | Fix                      |
| --------------------- | ------------------------------------- | ------------------------ |
| Missing key fields    | View without `key-fields`             | Add `source.key-fields`. |
| Bad column            | `fields.include` lists missing column | Remove or fix name.      |
| Relationship mismatch | Linking fields count != PK count      | Fix linking fields.      |

## Output Examples

Success:

```
Data API builder <version>
Config is valid.
```

Failure:

```
Data API builder <version>
Error: View 'sales_summary' missing required key-fields.
Config is invalid.
```

> [!Note]
> Validation errors are stage-specific. Fix the first failing stage before rerunning.

## Environment-Specific Files

If `DAB_ENVIRONMENT` is set, `validate` loads `dab-config.<DAB_ENVIRONMENT>.json`.

#### Example

#### [Bash](#tab/bash)

```bash
export DAB_ENVIRONMENT=Staging
dab validate
```

#### [Command Prompt](#tab/cmd)

```cmd
set DAB_ENVIRONMENT=Staging
dab validate
```

---

> [!Note]
> The validator checks only a single resolved file. It does not merge environment variants.

## Example Usage

Basic:

#### [Bash](#tab/bash)

```bash
dab validate
```

#### [Command Prompt](#tab/cmd)

```cmd
dab validate
```

---

Explicit file:

#### [Bash](#tab/bash)

```bash
dab validate \
  --config ./configs/dab-config.test.json
```

#### [Command Prompt](#tab/cmd)

```cmd
dab validate ^
  --config ./configs/dab-config.test.json
```

---

Multi-environment:

#### [Bash](#tab/bash)

```bash
for env in Development Staging Production; do
  echo "Validating $env..."
  DAB_ENVIRONMENT=$env dab validate || exit 1
done
```

#### [Command Prompt](#tab/cmd)

```cmd
for %E in (Development Staging Production) do ^
  echo Validating %E... ^
  set DAB_ENVIRONMENT=%E ^& dab validate ^|^| exit /b 1
```

---

CI fast-fail:

#### [Bash](#tab/bash)

```bash
dab validate && echo "OK" || { echo "INVALID CONFIG"; exit 1; }
```

#### [Command Prompt](#tab/cmd)

```cmd
dab validate
if %errorlevel%==0 (echo OK) else (echo INVALID CONFIG & exit /b 1)
```

---

## Workflow

1. Run `dab validate`
2. Fix the first failing stage
3. Re-run until exit code is 0
4. Commit validated config

> [!TIP]
> Validate small changes often. Use version control diffs to pinpoint regressions quickly.
