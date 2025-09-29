# `add` command

Add a new entity definition to an existing Data API builder configuration file. You must already have a config created with `dab init`. Use `dab update` to modify entities after creation.

## Syntax

```bash
dab add <entity-name> [options]
```

### Quick glance

| Option                                       | Summary                                                              |
| -------------------------------------------- | -------------------------------------------------------------------- |
| `<entity-name>`                              | Required positional argument. Logical entity name.                   |
| [`-c, --config`](#-c---config)               | Config file path. Default `dab-config.json`.                         |
| [`--cache.enabled`](#--cacheenabled)         | Enable/disable caching for entity.                                   |
| [`--cache.ttl`](#--cachettl)                 | Cache time-to-live in seconds.                                       |
| [`--description`](#--description)            | Free-form description for entity.                                    |
| [`--fields.exclude`](#--fieldsexclude)       | Comma-separated excluded fields.                                     |
| [`--fields.include`](#--fieldsinclude)       | Comma-separated allowed fields (`*` = all).                          |
| [`--graphql`](#--graphql)                    | GraphQL exposure: `false`, `true`, `singular`, or `singular:plural`. |
| [`--graphql.operation`](#--graphqloperation) | Stored procedures only. `query` or `mutation` (default mutation).    |
| [`--permissions`](#--permissions)            | Required. One or more `role:actions` pairs. Repeatable.              |
| [`--policy-database`](#--policy-database)    | OData-style filter applied in DB query.                              |
| [`--policy-request`](#--policy-request)      | Request policy evaluated before DB call.                             |
| [`--rest`](#--rest)                          | REST exposure: `false`, `true`, or custom route.                     |
| [`--rest.methods`](#--restmethods)           | Stored procedures only. Allowed HTTP verbs. Default POST.            |
| [`-s, --source`](#-s---source)               | Required. Database object name (table, view, or stored procedure).   |
| [`--source.key-fields`](#--sourcekey-fields) | Required for views or when PK not inferred. Not allowed for procs.   |
| [`--source.params`](#--sourceparams)         | Stored procedures only. Default parameter values.                    |
| [`--source.type`](#--sourcetype)             | Source type: `table`, `view`, `stored-procedure` (default table).    |

---

## `<entity-name>`

Logical name of the entity in config. Case-sensitive.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": {
      "type": "table",
      "object": "dbo.Books"
    },
    "permissions": [
      {
        "role": "anonymous",
        "actions": [ "read" ]
      }
    ]
  }
}
```

## `-c, --config`

Config file path. Default is `dab-config.json`.

**Example**

```bash
dab add Book --config ./dab-config.mssql.json --source dbo.Books --permissions "anonymous:read"
```

## `--cache.enabled`

Enable or disable caching.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --cache.enabled true
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": {
      "type": "table",
      "object": "dbo.Books"
    },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "cache": {
      "enabled": true
    }
  }
}
```

## `--cache.ttl`

Cache time-to-live in seconds.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --cache.ttl 300
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "cache": {
      "ttl-seconds": 300
    }
  }
}
```

## `--description`

Free-text description of the entity.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --description "Entity for managing book inventory"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "description": "Entity for managing book inventory"
  }
}
```

## `--fields.exclude`

Comma-separated list of fields to exclude.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --fields.exclude "internal_flag,secret_note"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "graphql": {
      "fields": {
        "exclude": [ "internal_flag", "secret_note" ]
      }
    }
  }
}
```

## `--fields.include`

Comma-separated list of fields to expose.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --fields.include "id,title,price"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "graphql": {
      "fields": {
        "include": [ "id", "title", "price" ]
      }
    }
  }
}
```

## `--graphql`

Control GraphQL exposure.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --graphql book:books
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "graphql": {
      "singular": "book",
      "plural": "books"
    }
  }
}
```

## `--graphql.operation`

Stored procedures only. GraphQL operation type. Default is `mutation`.

**Example**

```bash
dab add BookProc --source dbo.MyProc --source.type stored-procedure --permissions "admin:execute" --graphql.operation query
```

**Resulting config**

```json
"entities": {
  "BookProc": {
    "source": { "type": "stored-procedure", "object": "dbo.MyProc" },
    "permissions": [
      { "role": "admin", "actions": [ "execute" ] }
    ],
    "graphql": {
      "operation": "query"
    }
  }
}
```

## `--permissions`

Defines role→actions pairs. Use repeated flags for multiple roles.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --permissions "authenticated:create,read,update,delete"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] },
      { "role": "authenticated", "actions": [ "create", "read", "update", "delete" ] }
    ]
  }
}
```

## `--policy-database`

Database-level policy.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --policy-database "region eq 'US'"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "policies": {
      "database": "region eq 'US'"
    }
  }
}
```

## `--policy-request`

Request-level policy.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --policy-request "@claims.role == 'admin'"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "policies": {
      "request": "@claims.role == 'admin'"
    }
  }
}
```

## `--rest`

Control REST exposure.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --rest BooksApi
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": { "type": "table", "object": "dbo.Books" },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ],
    "rest": {
      "path": "BooksApi"
    }
  }
}
```

## `--rest.methods`

Stored procedures only. HTTP verbs allowed for execution. Defaults to POST. Ignored for tables/views.

**Example**

```bash
dab add BookProc --source dbo.MyProc --source.type stored-procedure --permissions "admin:execute" --rest true --rest.methods GET,POST
```

**Resulting config**

```json
"entities": {
  "BookProc": {
    "source": { "type": "stored-procedure", "object": "dbo.MyProc" },
    "permissions": [
      { "role": "admin", "actions": [ "execute" ] }
    ],
    "rest": {
      "path": "BookProc",
      "methods": [ "GET", "POST" ]
    }
  }
}
```

## `-s, --source`

Required. Name of the database object: table, view, or stored procedure.

**Example**

```bash
dab add Book --source dbo.Books --permissions "anonymous:read"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": {
      "type": "table",
      "object": "dbo.Books"
    },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ]
  }
}
```

## `--source.key-fields`

Required for views. Also required for tables without an inferable PK. Not allowed for stored procedures.

**Example**

```bash
dab add BookView --source dbo.MyView --source.type view --source.key-fields "id,region" --permissions "anonymous:read"
```

**Resulting config**

```json
"entities": {
  "BookView": {
    "source": {
      "type": "view",
      "object": "dbo.MyView",
      "keyFields": [ "id", "region" ]
    },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ]
  }
}
```

## `--source.params`

Stored procedures only. Comma-separated `name:value` pairs. Not allowed for tables or views.

**Example**

```bash
dab add BookProc --source dbo.MyProc --source.type stored-procedure --source.params "year:2024,active:true" --permissions "admin:execute"
```

**Resulting config**

```json
"entities": {
  "BookProc": {
    "source": {
      "type": "stored-procedure",
      "object": "dbo.MyProc",
      "params": {
        "year": 2024,
        "active": true
      }
    },
    "permissions": [
      { "role": "admin", "actions": [ "execute" ] }
    ]
  }
}
```

## `--source.type`

Type of database object. Default: `table`.

**Example**

```bash
dab add Book --source dbo.Books --source.type table --permissions "anonymous:read"
```

**Resulting config**

```json
"entities": {
  "Book": {
    "source": {
      "type": "table",
      "object": "dbo.Books"
    },
    "permissions": [
      { "role": "anonymous", "actions": [ "read" ] }
    ]
  }
}
```
