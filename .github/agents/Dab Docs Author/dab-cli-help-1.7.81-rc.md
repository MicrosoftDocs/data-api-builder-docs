# DAB CLI help output (v1.7.81-rc)

This file captures `dab <command> --help`/help-screen output for quick reference when authoring CLI docs.

Notes:

- The outputs below were captured using `dab <command> -?` on Windows. The CLI reports `Option '?' is unknown.` but still prints the help screen.
- Prefer using `dab <command> --help` when generating authoritative option lists.

## `dab add`

```text
dab add -?
Microsoft.DataApiBuilder 1.7.81-rc+c7927fa9885160ed35bcc9b25b13fd59b88f3133
c Microsoft Corporation. All rights reserved.

ERROR(S):
  Option '?' is unknown.
  Required option 's, source' is missing.
  Required option 'permissions' is missing.

  -s, --source                Required. Name of the source database object.

  --permissions               Required. Permissions required to access the source table or container.

  --source.type               Type of the database object.Must be one of: [table, view, stored-procedure]

  --source.params             Dictionary of parameters and their values for Source object."param1:val1,param2:value2,.."

  --source.key-fields         The field(s) to be used as primary keys.

  --rest                      Route for rest api.

  --rest.methods              HTTP actions to be supported for stored procedure. Specify the actions as a comma separated list. Valid HTTP
                              actions are : [GET, POST, PUT, PATCH, DELETE]

  --graphql                   Type of graphQL.

  --graphql.operation         GraphQL operation to be supported for stored procedure. Valid operations are : [Query, Mutation]

  --fields.include            Fields that are allowed access to permission.

  --fields.exclude            Fields that are excluded from the action lists.

  --policy-request            Specify the rule to be checked before sending any request to the database.

  --policy-database           Specify an OData style filter rule that will be injected in the query sent to the database.

  --cache.enabled             Specify if caching is enabled for Entity, default value is false.

  --cache.ttl                 Specify time to live in seconds for cache entries for Entity.

  --description               Description of the entity.

  --parameters.name           Comma-separated list of parameter names for stored procedure.

  --parameters.description    Comma-separated list of parameter descriptions for stored procedure.

  --parameters.required       Comma-separated list of parameter required flags (true/false) for stored procedure.

  --parameters.default        Comma-separated list of parameter default values for stored procedure.

  --fields.name               Name of the database column to expose as a field.

  --fields.alias              Alias for the field.

  --fields.description        Description for the field.

  --fields.primary-key        Set this field as a primary key.

  -c, --config                Path to config file. Defaults to 'dab-config.json' unless 'dab-config.<DAB_ENVIRONMENT>.json' exists, where
                              DAB_ENVIRONMENT is an environment variable.

  --help                      Display this help screen.

  --version                   Display version information.

  Entity (pos. 0)             Name of the entity.
```

## `dab update`

```text
dab update -?
Microsoft.DataApiBuilder 1.7.81-rc+c7927fa9885160ed35bcc9b25b13fd59b88f3133
c Microsoft Corporation. All rights reserved.

ERROR(S):
  Option '?' is unknown.

  -s, --source                Name of the source table or container.

  --permissions               Permissions required to access the source table or container.

  --relationship              Specify relationship between two entities.

  --cardinality               Specify cardinality between two entities.

  --target.entity             Another exposed entity to which the source entity relates to.

  --linking.object            Database object that is used to support an M:N relationship.

  --linking.source.fields     Database fields in the linking object to connect to the related item in the source entity.

  --linking.target.fields     Database fields in the linking object to connect to the related item in the target entity.

  --relationship.fields       Specify fields to be used for mapping the entities.

  -m, --map                   Specify mappings between database fields and GraphQL and REST fields. format: --map
                              "backendName1:exposedName1,backendName2:exposedName2,...".

  --source.type               Type of the database object.Must be one of: [table, view, stored-procedure]

  --source.params             Dictionary of parameters and their values for Source object."param1:val1,param2:value2,.."

  --source.key-fields         The field(s) to be used as primary keys.

  --rest                      Route for rest api.

  --rest.methods              HTTP actions to be supported for stored procedure. Specify the actions as a comma separated list. Valid HTTP
                              actions are : [GET, POST, PUT, PATCH, DELETE]

  --graphql                   Type of graphQL.

  --graphql.operation         GraphQL operation to be supported for stored procedure. Valid operations are : [Query, Mutation]

  --fields.include            Fields that are allowed access to permission.

  --fields.exclude            Fields that are excluded from the action lists.

  --policy-request            Specify the rule to be checked before sending any request to the database.

  --policy-database           Specify an OData style filter rule that will be injected in the query sent to the database.

  --cache.enabled             Specify if caching is enabled for Entity, default value is false.

  --cache.ttl                 Specify time to live in seconds for cache entries for Entity.

  --description               Description of the entity.

  --parameters.name           Comma-separated list of parameter names for stored procedure.

  --parameters.description    Comma-separated list of parameter descriptions for stored procedure.

  --parameters.required       Comma-separated list of parameter required flags (true/false) for stored procedure.

  --parameters.default        Comma-separated list of parameter default values for stored procedure.

  --fields.name               Name of the database column to expose as a field.

  --fields.alias              Alias for the field.

  --fields.description        Description for the field.

  --fields.primary-key        Set this field as a primary key.

  -c, --config                Path to config file. Defaults to 'dab-config.json' unless 'dab-config.<DAB_ENVIRONMENT>.json' exists, where
                              DAB_ENVIRONMENT is an environment variable.

  --help                      Display this help screen.

  --version                   Display version information.

  Entity (pos. 0)             Name of the entity.
```

## `dab init`

```text
dab init -?
Microsoft.DataApiBuilder 1.7.81-rc+c7927fa9885160ed35bcc9b25b13fd59b88f3133
c Microsoft Corporation. All rights reserved.

ERROR(S):
  Option '?' is unknown.
  Required option 'database-type' is missing.

  --database-type                      Required. Type of database to connect. Supported values: mssql, cosmosdb_nosql,
                                       cosmosdb_postgresql, mysql, postgresql, dwsql

  --connection-string                  (Default: '') Connection details to connect to the database.

  --cosmosdb_nosql-database            Database name for Azure Cosmos DB for NoSql.

  --cosmosdb_nosql-container           Container name for Azure Cosmos DB for NoSql.

  --graphql-schema                     GraphQL schema Path.

  --set-session-context                (Default: false) Enable sending data to MsSql using session context.

  --host-mode                          (Default: Production) Specify the Host mode - Development or Production

  --cors-origin                        Specify the list of allowed origins.

  --auth.provider                      (Default: StaticWebApps) Specify the Identity Provider.

  --auth.audience                      Identifies the recipients that the JWT is intended for.

  --auth.issuer                        Specify the party that issued the jwt token.

  --rest.path                          (Default: /api) Specify the REST endpoint's default prefix.

  --runtime.base-route                 Specifies the base route for API requests.

  --rest.disabled                      (Default: false) Disables REST endpoint for all entities.

  --graphql.path                       (Default: /graphql) Specify the GraphQL endpoint's default prefix.

  --graphql.disabled                   (Default: false) Disables GraphQL endpoint for all entities.

  --mcp.path                           (Default: /mcp) Specify the MCP endpoint's default prefix.

  --mcp.disabled                       (Default: false) Disables MCP endpoint for all entities.

  --rest.enabled                       (Default: true) Enables REST endpoint for all entities. Supported values: true, false.

  --graphql.enabled                    (Default: true) Enables GraphQL endpoint for all entities. Supported values: true, false.

  --mcp.enabled                        (Default: true) Enables MCP endpoint for all entities. Supported values: true, false.

  --rest.request-body-strict           (Default: true) Allow extraneous fields in the request body for REST.

  --graphql.multiple-create.enabled    (Default: false) Enables multiple create operation for GraphQL. Supported values: true, false.

  -c, --config                         Path to config file. Defaults to 'dab-config.json' unless 'dab-config.<DAB_ENVIRONMENT>.json'
                                       exists, where DAB_ENVIRONMENT is an environment variable.

  --help                               Display this help screen.

  --version                            Display version information.
```

## `dab start`

```text
dab start -?
Microsoft.DataApiBuilder 1.7.81-rc+c7927fa9885160ed35bcc9b25b13fd59b88f3133
c Microsoft Corporation. All rights reserved.

ERROR(S):
  Option '?' is unknown.

  --verbose              Specifies logging level as informational.

  --LogLevel             Specifies logging level as provided value. For possible values, see:
                         https://go.microsoft.com/fwlink/?linkid=2263106

  --no-https-redirect    Disables automatic https redirects.

  -c, --config           Path to config file. Defaults to 'dab-config.json' unless 'dab-config.<DAB_ENVIRONMENT>.json' exists, where
                         DAB_ENVIRONMENT is an environment variable.

  --help                 Display this help screen.

  --version              Display version information.
```

## `dab configure`

```text
dab configure -?
Microsoft.DataApiBuilder 1.7.81-rc+c7927fa9885160ed35bcc9b25b13fd59b88f3133
c Microsoft Corporation. All rights reserved.

ERROR(S):
  Option '?' is unknown.

  --data-source.database-type                                       Database type. Allowed values: MSSQL, PostgreSQL, CosmosDB_NoSQL,
                                                                    MySQL.

  --data-source.connection-string                                   Connection string for the data source.

  --data-source.options.database                                    Database name for Cosmos DB for NoSql.

  --data-source.options.container                                   Container name for Cosmos DB for NoSql.

  --data-source.options.schema                                      Schema path for Cosmos DB for NoSql.

  --data-source.options.set-session-context                         Enable session context. Allowed values: true (default), false.

  --runtime.graphql.depth-limit                                     Max allowed depth of the nested query. Allowed values: (0,2147483647]
                                                                    inclusive. Default is infinity. Use -1 to remove limit.

  --runtime.graphql.enabled                                         Enable DAB's GraphQL endpoint. Default: true (boolean).

  --runtime.graphql.path                                            Customize DAB's GraphQL endpoint path. Allowed values: string.
                                                                    Conditions: Prefix with '/', no spaces and no reserved characters.

  --runtime.graphql.allow-introspection                             Allow/Deny GraphQL introspection requests in GraphQL Schema. Default:
                                                                    true (boolean).

  --runtime.graphql.multiple-mutations.create.enabled               Enable/Disable multiple-mutation create operations on DAB's generated
                                                                    GraphQL schema. Default: true (boolean).

  --runtime.rest.enabled                                            Enable DAB's Rest endpoint. Default: true (boolean).

  --runtime.rest.path                                               Customize DAB's REST endpoint path. Default: '/api' Conditions: Prefix
                                                                    path with '/'.

  --runtime.rest.request-body-strict                                Prohibit extraneous REST request body fields. Default: true (boolean).

  --runtime.mcp.enabled                                             Enable DAB's MCP endpoint. Default: true (boolean).

  --runtime.mcp.path                                                Customize DAB's MCP endpoint path. Default: '/mcp' Conditions: Prefix
                                                                    path with '/'.

  --runtime.mcp.dml-tools.enabled                                   Enable DAB's MCP DML tools endpoint. Default: true (boolean).

  --runtime.mcp.dml-tools.describe-entities.enabled                 Enable DAB's MCP describe entities tool. Default: true (boolean).

  --runtime.mcp.dml-tools.create-record.enabled                     Enable DAB's MCP create record tool. Default: true (boolean).

  --runtime.mcp.dml-tools.read-records.enabled                      Enable DAB's MCP read record tool. Default: true (boolean).

  --runtime.mcp.dml-tools.update-record.enabled                     Enable DAB's MCP update record tool. Default: true (boolean).

  --runtime.mcp.dml-tools.delete-record.enabled                     Enable DAB's MCP delete record tool. Default: true (boolean).

  --runtime.mcp.dml-tools.execute-entity.enabled                    Enable DAB's MCP execute entity tool. Default: true (boolean).

  --runtime.cache.enabled                                           Enable DAB's cache globally. (You must also enable each entity's cache
                                                                    separately.). Default: false (boolean).

  --runtime.cache.ttl-seconds                                       Customize the DAB cache's global default time to live in seconds.
                                                                    Default: 5 seconds (Integer).

  --runtime.host.mode                                               Set the host running mode of DAB in Development or Production.
                                                                    Default: Development.

  --runtime.host.cors.origins                                       Overwrite Allowed Origins in CORS. Default: [] (Space separated array
                                                                    of strings).

  --runtime.host.cors.allow-credentials                             Set value for Access-Control-Allow-Credentials header in Host.Cors.
                                                                    Default: false (boolean).

  --runtime.host.authentication.provider                            Configure the name of authentication provider. Default: StaticWebApps.

  --runtime.host.authentication.jwt.audience                        Configure the intended recipient(s) of the Jwt Token.

  --runtime.host.authentication.jwt.issuer                          Configure the entity that issued the Jwt Token.

  --azure-key-vault.endpoint                                        Configure the Azure Key Vault endpoint URL.

  --azure-key-vault.retry-policy.mode                               Configure the retry policy mode. Allowed values: fixed, exponential.
                                                                    Default: exponential.

  --azure-key-vault.retry-policy.max-count                          Configure the maximum number of retry attempts. Default: 3.

  --azure-key-vault.retry-policy.delay-seconds                      Configure the initial delay between retries in seconds. Default: 1.

  --azure-key-vault.retry-policy.max-delay-seconds                  Configure the maximum delay between retries in seconds (for
                                                                    exponential mode). Default: 60.

  --azure-key-vault.retry-policy.network-timeout-seconds            Configure the network timeout for requests in seconds. Default: 60.

  --runtime.telemetry.azure-log-analytics.enabled                   Enable/Disable Azure Log Analytics. Default: False (boolean)

  --runtime.telemetry.azure-log-analytics.dab-identifier            Configure DAB Identifier to allow user to differentiate which logs
                                                                    come from DAB in Azure Log Analytics . Default: DABLogs

  --runtime.telemetry.azure-log-analytics.flush-interval-seconds    Configure Flush Interval in seconds for Azure Log Analytics to specify
                                                                    the time interval to send the telemetry data. Default: 5

  --runtime.telemetry.azure-log-analytics.auth.custom-table-name    Configure Custom Table Name for Azure Log Analytics used to find table
                                                                    to connect

  --runtime.telemetry.azure-log-analytics.auth.dcr-immutable-id     Configure DCR Immutable ID for Azure Log Analytics to find the data
                                                                    collection rule that defines how data is collected

  --runtime.telemetry.azure-log-analytics.auth.dce-endpoint         Configure DCE Endpoint for Azure Log Analytics to find table to send
                                                                    telemetry data

  --runtime.telemetry.file.enabled                                  Enable/Disable File Sink logging. Default: False (boolean)

  --runtime.telemetry.file.path                                     Configure path for File Sink logging. Default: /logs/dab-log.txt

  --runtime.telemetry.file.rolling-interval                         Configure rolling interval for File Sink logging. Default: Day

  --runtime.telemetry.file.retained-file-count-limit                Configure maximum number of retained files. Default: 1

  --runtime.telemetry.file.file-size-limit-bytes                    Configure maximum file size limit in bytes. Default: 1048576

  -c, --config                                                      Path to config file. Defaults to 'dab-config.json' unless
                                                                    'dab-config.<DAB_ENVIRONMENT>.json' exists, where DAB_ENVIRONMENT is
                                                                    an environment variable.

  --help                                                            Display this help screen.

  --version                                                         Display version information.
```