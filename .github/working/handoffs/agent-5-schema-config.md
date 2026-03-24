# Agent 5 Handoff: Schema, Configuration & Observability

## Your Mission
You are a "DAB Docs Author" agent. This is the broadest agent — you handle schema/config documentation updates and observability additions. Hunt through configuration reference docs and monitoring docs to update them for DAB 2.0.

## Repository Structure
- Docs root: `data-api-builder/`
- Config docs: `data-api-builder/configuration/` (index.md, data-source.md, runtime.md, entities.md)
- Monitoring docs: `data-api-builder/concept/monitor/` (application-insights.md, log-analytics.md, health-checks.md, log-levels.md, open-telemetry.md)
- CLI docs: `data-api-builder/command-line/`
- What's new: `data-api-builder/whats-new/version-2-0.md`
- TOC: `data-api-builder/TOC.yml`

## Changes in DAB 2.0

### 1. `fields` Array (Replaces `mappings` + `key-fields`) — DEPRECATION
NEW `fields` array on entities replaces both the `mappings` object and `source.key-fields` array.

**New format:**
```json
{
    "entities": {
        "Book": {
            "source": { "type": "table", "object": "dbo.books" },
            "fields": [
                { "name": "id", "alias": "bookId", "description": "Primary key", "primary-key": true },
                { "name": "title", "alias": "bookTitle", "description": "Book title" },
                { "name": "pub_id", "description": "Publisher foreign key" }
            ],
            "permissions": [...]
        }
    }
}
```

**Schema details:**
- `name` (required): Database column name
- `alias` (optional): Exposed API field name (replaces `mappings`)
- `description` (optional): Field description (used in MCP tool discovery and docs)
- `primary-key` (optional): Boolean, indicates PK field (replaces `source.key-fields`)
- `mappings` is now DEPRECATED (schema marks it as deprecated)
- `source.key-fields` is now DEPRECATED (schema marks it as deprecated)
- Schema enforces: if `fields` is present, `mappings` and `source.key-fields` CANNOT be used

**What to update:**
- `configuration/entities.md` — Add `fields` section, add deprecation notices to `mappings` and `key-fields`
- `configuration/index.md` — Update overview
- TOC.yml — Add fields entries under Entities

### 2. Entity `description` Property
New optional `description` string on entities. Surfaced in generated API docs and GraphQL schema as comments.

```json
{ "entities": { "Book": { "description": "Represents a book in the catalog", ... } } }
```

**What to update:**
- `configuration/entities.md` — document this property

### 3. `source.object-description` Property
New optional property for a human-readable description of the database object, used for MCP tool discovery and documentation.

**What to update:**
- `configuration/entities.md` — add to source section

### 4. `source.parameters` Array Format
Parameters now support an array format with metadata, in addition to the old dictionary format (which is now deprecated).

**New array format:**
```json
{
    "source": {
        "object": "dbo.my_proc",
        "type": "stored-procedure",
        "parameters": [
            { "name": "id", "required": true, "description": "Record ID" },
            { "name": "status", "required": false, "default": "active", "description": "Status filter" }
        ]
    }
}
```

**Old format (deprecated):**
```json
{ "parameters": { "id": 0, "status": "active" } }
```

**What to update:**
- `configuration/entities.md` — parameters section, add new format, deprecation notice for old format
- `concept/database/stored-procedures.md` — update parameter examples

### 5. Health Configuration (Data Source, Entity, Runtime)
Health config exists at THREE levels now:

**Data source level:**
```json
{
    "data-source": {
        "health": {
            "enabled": true,
            "name": "mydb",
            "threshold-ms": 1000
        }
    }
}
```

**Entity level:**
```json
{
    "entities": {
        "Book": {
            "health": { "enabled": true, "first": 100, "threshold-ms": 1000 }
        }
    }
}
```

**Runtime level:**
```json
{
    "runtime": {
        "health": {
            "enabled": true,
            "roles": ["admin"],
            "cache-ttl-seconds": 5,
            "max-query-parallelism": 4
        }
    }
}
```

**What to update:**
- `configuration/data-source.md` — add health section
- `configuration/entities.md` — add/update health section
- `configuration/runtime.md` — add/update runtime health section
- `concept/monitor/health-checks.md` — update with all three config levels

### 6. `currentRole` in /health Response
The `/health` endpoint now includes `currentRole` field showing the effective role.

Role resolution: `X-MS-API-ROLE` header > `authenticated` (if client principal) > `anonymous`

**What to update:**
- `concept/monitor/health-checks.md` — add currentRole documentation

### 7. `cache.level` Property (Entity-Level)
Entity cache now supports a `level` property: `L1` or `L1L2` (default: `L1L2`).

**What to update:**
- `configuration/entities.md` — cache section
- `concept/cache/level-1.md` and `concept/cache/level-2.md` — mention config level property

### 8. `pagination.next-link-relative` Property
New runtime pagination property. When true, `nextLink` in paginated results uses a relative URL. Default: false.

**What to update:**
- `configuration/runtime.md` — pagination section
- REST keyword docs if they discuss nextLink format

### 9. `azure-key-vault.retry-policy` Configuration
New retry policy config for AKV operations:
```json
{
    "azure-key-vault": {
        "endpoint": "https://myvault.vault.azure.net",
        "retry-policy": {
            "mode": "exponential",
            "max-count": 3,
            "delay-seconds": 1,
            "max-delay-seconds": 60,
            "network-timeout-seconds": 60
        }
    }
}
```

**What to update:**
- `concept/config/akv-function.md` — add retry policy documentation
- `configuration/index.md` — if AKV is referenced

### 10. Telemetry Additions

**OpenTelemetry `exporter-protocol`:**
New property: `grpc` (default) or `httpprotobuf`
```json
{ "telemetry": { "open-telemetry": { "exporter-protocol": "grpc" } } }
```

**File sink telemetry:**
```json
{
    "telemetry": {
        "file": {
            "enabled": false,
            "path": "/logs/dab-log.txt",
            "rolling-interval": "Day",
            "retained-file-count-limit": 1,
            "file-size-limit-bytes": 1048576
        }
    }
}
```

**Azure Log Analytics updates:**
```json
{
    "telemetry": {
        "azure-log-analytics": {
            "enabled": false,
            "auth": {
                "custom-table-name": "...",
                "dcr-immutable-id": "...",
                "dce-endpoint": "..."
            },
            "dab-identifier": "DabLogs",
            "flush-interval-seconds": 5
        }
    }
}
```

**Default OTEL in `dab init`:**
New configs from `dab init` now include default OTEL section:
```json
{
    "telemetry": {
        "open-telemetry": {
            "enabled": true,
            "endpoint": "@env('OTEL_EXPORTER_OTLP_ENDPOINT')",
            "headers": "@env('OTEL_EXPORTER_OTLP_HEADERS')",
            "service-name": "@env('OTEL_SERVICE_NAME')"
        }
    }
}
```
Unresolved `@env(...)` values are tolerated at startup.

**What to update:**
- `concept/monitor/open-telemetry.md` — add exporter-protocol, default OTEL in init
- `concept/monitor/log-analytics.md` — update with new auth config structure
- `configuration/runtime.md` — telemetry section updates
- Consider creating a brief file telemetry doc or adding to log-levels.md
- `command-line/dab-init.md` — mention default OTEL section in generated config

### 11. `log-level` Configuration
Runtime telemetry now supports a `log-level` object with namespace-to-level mappings:
```json
{
    "telemetry": {
        "log-level": {
            "Azure.DataApiBuilder": "information",
            "Microsoft.AspNetCore": "warning"
        }
    }
}
```
Levels: trace, debug, information, warning, error, critical, none

**What to update:**
- `concept/monitor/log-levels.md` — add namespace-level configuration
- `configuration/runtime.md` — telemetry section

## MS Learn Requirements
- YAML front matter required on all .md files
- author: jerrynixon, ms.author: jnixon, ms.reviewer: sidandrews, ms.service: data-api-builder
- ms.date: 03/24/2026
- Callouts: `> [!NOTE]`, `> [!IMPORTANT]`, `> [!TIP]`, `> [!WARNING]`
- Code blocks need language identifiers
- Relative links

## Cross-Links
Add cross-links to `../whats-new/version-2-0.md` from updated docs where significant.

## Output
Write report to: `.github/working/reports/agent-5-schema-config-report.md`

Then commit:
```
git add -A
git commit -m "docs: update schema, configuration & observability docs for DAB 2.0

- Document fields array replacing mappings and key-fields (deprecated)
- Add entity description and source.object-description properties
- Document parameters array format for stored procedures
- Update health configuration at data-source, entity, and runtime levels
- Add currentRole to health endpoint documentation
- Document cache.level, pagination.next-link-relative properties
- Add azure-key-vault retry-policy configuration
- Update telemetry docs: exporter-protocol, file sink, log-analytics, log-level
- Document default OTEL settings in dab init
- Add cross-links to what's-new article

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
