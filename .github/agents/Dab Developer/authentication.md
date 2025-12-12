# Authentication & authorization — agent guide

This is optimized for fixing the common “it works locally but not in prod” and “I get 401/403” problems.

## The role evaluation algorithm (must-know)

A request is evaluated in the context of exactly **one** role.

| Token provided | `X-MS-API-ROLE` provided | `X-MS-API-ROLE` exists in token | Resulting role |
| --- | --- | --- | --- |
| No | No | No | `anonymous` |
| Yes | No | No | `authenticated` |
| Yes | Yes | No | Exception (rejected) |
| Yes | Yes | Yes | `X-MS-API-ROLE` value |

Key consequence:

- To use a **user role**, the client must send `X-MS-API-ROLE`, and the role must be present in the token.

## Local auth (for dev/test)

### Provider: `Simulator`

Use when you want basic role simulation without setting up an identity provider.

- All requests are treated as authenticated (at least role `authenticated`).
- You can select a specific role (including `anonymous`) via `X-MS-API-ROLE`.
- Limitation: database policies that depend on custom claims can’t be exercised (claims can’t be set).

Minimal config shape to look for:

```json
"host": {
  "mode": "development",
  "authentication": {
    "provider": "Simulator"
  }
}
```

### Provider: `AppService`

Use when you want to simulate App Service / Container Apps auth headers locally.

- Client sends `X-MS-CLIENT-PRINCIPAL` (Base64 JSON) + `X-MS-API-ROLE`.
- The principal JSON includes `userRoles`.

Minimal principal template:

```json
{
  "identityProvider": "test",
  "userId": "12345",
  "userDetails": "john@contoso.com",
  "userRoles": ["author", "editor"]
}
```

## Azure auth (JWT)

### Provider: Azure AD / JWT validation

Core idea:

- Client obtains an access token.
- DAB validates token issuer/audience.
- Roles from the token control authorization.

Config shape to look for (don’t guess exact nesting if uncertain; validate with schema/CLI + existing config):

```json
"authentication": {
  "provider": "AzureAD",
  "jwt": {
    "audience": "<APP_ID>",
    "issuer": "https://login.microsoftonline.com/<TENANT_ID>/v2.0"
  }
}
```

### Role selection header (`X-MS-API-ROLE`)

- Required to authorize as a custom role.
- Value must exactly match a role claim in the token.

## Permissions checklist (403 troubleshooting)

When a request is rejected:

1) Determine selected role (table above).
2) Confirm the entity includes that role in `permissions`.
3) Confirm the role includes the needed action:

- Tables/views: `create`, `read`, `update`, `delete`
- Stored procedures: `execute`

4) If field filters exist (`fields.include`/`fields.exclude`), confirm requested fields are allowed.
5) If policies exist (`policy.database` / `policy.request`), confirm they evaluate as expected.

## SQL session context (row-level security)

If `--set-session-context true` is enabled at init-time, SQL session context can be used for row-level security.

Agent guidance:

- Treat this as an advanced scenario; confirm the customer’s SQL policy and expected claim key.
- Validate behavior by reproducing the predicate with a direct SQL query (outside DAB) before debugging DAB.
