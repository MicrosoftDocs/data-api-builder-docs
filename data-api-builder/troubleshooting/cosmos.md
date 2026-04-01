---
title: Azure Cosmos DB troubleshooting - Data API builder
description: Troubleshoot common Azure Cosmos DB connection, emulator, and schema configuration issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# Azure Cosmos DB troubleshooting

> [!div class="checklist"]
> Solutions for common Azure Cosmos DB emulator, connectivity, and schema configuration issues in Data API builder.

## Common questions

### What is Azure Cosmos DB support in DAB?

Data API builder supports Azure Cosmos DB as a NoSQL back end. DAB connects to Cosmos DB using the Azure Cosmos DB .NET SDK and exposes entities as GraphQL types. REST support for Cosmos DB is not available; all queries are served through the GraphQL endpoint.

### What API does DAB use with Cosmos DB?

DAB uses the Azure Cosmos DB for NoSQL API (formerly SQL API). Other Cosmos DB APIs such as MongoDB, Gremlin, and Table are not supported. Ensure your Cosmos DB account is created with the **Azure Cosmos DB for NoSQL** API.

### Is the Cosmos DB emulator supported?

Yes. The Azure Cosmos DB emulator is supported for local development. Set the connection string to the emulator's default endpoint: `AccountEndpoint=https://localhost:8081/;AccountKey=<emulator-key>;`. You must trust the emulator's self-signed certificate on the development machine before DAB can connect.

## Common issues

### Emulator certificate not trusted

**Symptom:** DAB fails to connect to the emulator with an SSL or certificate validation error.

**Cause:** The Azure Cosmos DB emulator uses a self-signed certificate that is not trusted by default on the operating system.

**Resolution:** Export and install the emulator certificate from `https://localhost:8081/_explorer/emulator.pem` into the local machine's trusted root certificate store. On Windows, open the certificate file and install it to **Local Machine > Trusted Root Certification Authorities**. Restart DAB after installing the certificate.

### Cannot connect to emulator

**Symptom:** DAB fails to start with `The remote name could not be resolved: 'localhost'` or a connection refused error pointing at port `8081`.

**Cause:** The emulator is not running, or the endpoint or account key in the connection string is incorrect.

**Resolution:** Start the Azure Cosmos DB emulator from the Start menu or by running the emulator executable. Confirm the connection string uses `AccountEndpoint=https://localhost:8081/` and the correct emulator key, which is displayed on the emulator's data explorer page at `https://localhost:8081/_explorer/index.html`.

### GraphQL schema file not found

**Symptom:** DAB fails to start with an error such as `Schema file not found` or `graphql-schema path is invalid`.

**Cause:** The `graphql.schema` path in `dab-config.json` points to a file that does not exist or uses an incorrect relative path.

**Resolution:** Verify the schema file exists at the path specified in `dab-config.json`. The path is relative to the config file location. Run `dab init` with `--cosmosdb_nosql-schema` to regenerate the config with the correct schema path, then confirm the `.gql` or `.graphql` file is present in that location.

### Query returns empty results

**Symptom:** GraphQL queries return an empty list even though the container has data.

**Cause:** The container name or partition key path in the entity configuration does not match the actual Cosmos DB container, or the database name is incorrect.

**Resolution:** Check the entity's `source` value in `dab-config.json` and confirm it matches the exact container name (case-sensitive). Verify the `database` field under `data-source` matches the Cosmos DB database name. In the Azure portal, open the **Data Explorer** for the account and confirm the database and container names.

### Direct mode TCP connections fail with the Linux emulator

**Symptom:** DAB hangs or times out when connecting to the Cosmos DB Linux emulator in Docker, even with AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=127.0.0.1 set. Requests stall during connection retries.

**Cause:** DAB currently hardcodes ConnectionMode.Direct, which causes the Cosmos SDK to discover physical partition endpoints (such as 172.17.0.2:1025010255) and open TCP connections to them. From the host machine, those container addresses are unreachable. Gateway mode would route all traffic over a single HTTPS endpoint (port 8081 on the emulator) and avoid the problem entirely. This is a known limitation tracked in [GitHub issue #3401](https://github.com/Azure/data-api-builder/issues/3401).

**Resolution:** Set AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=127.0.0.1 when starting the emulator container. This forces the emulator to advertise 127.0.0.1 as its address, making the discovered endpoints reachable from the host. Until Gateway mode is configurable in DAB, the IP override is the recommended workaround for local development.

### On-Behalf-Of (OBO) authentication is not supported

**Symptom:** Configuring On-Behalf-Of (OBO) authentication for an Azure Cosmos DB-backed DAB instance fails or the token is not forwarded as expected.

**Cause:** OBO authentication is currently only supported for SQL Server and Azure SQL. Support for Azure Cosmos DB has not yet been implemented. This is a known limitation tracked in [GitHub issue #3159](https://github.com/Azure/data-api-builder/issues/3159).

**Resolution:** Use a supported authentication method such as the Cosmos DB account key or managed identity. Follow the GitHub issue for updates on when OBO support is expanded to non-SQL Server databases.

### GraphQL in filter fails on Cosmos DB

**Symptom:** A GraphQL query using the in operator against a Cosmos DB-backed entity fails at runtime with Cannot build unknown predicate operation IN, even though in appears in the schema via introspection.

**Cause:** The in operator is exposed in the generated GraphQL schema for IdFilterInput and StringFilterInput, but the underlying Cosmos DB filter translation logic does not implement it. This mismatch between the schema and the query executor is a known bug tracked in [GitHub issue #3061](https://github.com/Azure/data-api-builder/issues/3061).

**Resolution:** Avoid using the in operator in GraphQL queries against Cosmos DB entities. Use one of these workarounds instead:

- Replace in with multiple or + q expressions for a small, fixed list of values.
- Use multiple point-read aliases (item_by_pk) when querying by a known list of IDs.
- Filter client-side after retrieving a broader result set.

### Aggregations are not supported for Cosmos DB

**Symptom:** GraphQL aggregate queries (such as count, sum, or vg) against a Cosmos DB-backed entity fail or are not available in the schema.

**Cause:** Data API builder does not currently support aggregation operations for Azure Cosmos DB. Aggregations are available for relational databases only. This is a known limitation tracked in [GitHub issue #2849](https://github.com/Azure/data-api-builder/issues/2849).

**Resolution:** There is no workaround within DAB at this time. Perform aggregations client-side after retrieving the result set, or use Cosmos DB's built-in query API directly for aggregate operations. Follow the GitHub issue for updates.

### Plural (list) queries cannot be disabled to enforce point reads only

**Symptom:** Clients are able to issue broad items list queries against a Cosmos DB entity, consuming high RUs, when the intent is to allow only point reads via item_by_pk.

**Cause:** Data API builder does not currently provide a configuration option to suppress plural queries and restrict an entity to point reads only. This is a known limitation tracked in [GitHub issue #2433](https://github.com/Azure/data-api-builder/issues/2433).

**Resolution:** As a partial workaround, restrict the list action in the entity's permissions to limit which roles can issue list queries. Full suppression of the plural query type from the schema is not yet supported.

### Hierarchical partition keys (MultiHash) are not supported

**Symptom:** Mutations against a Cosmos DB container that uses hierarchical partition keys (more than one partition key path) fail with the error The 'kind' value 'MultiHash' specified in the partition key definition is invalid. Please choose 'Hash' partition type.

**Cause:** Data API builder only supports single-key (Hash) partition key definitions. Containers configured with hierarchical partition keys (MultiHash) are not supported. This is a known limitation tracked in [GitHub issue #1733](https://github.com/Azure/data-api-builder/issues/1733).

**Resolution:** There is no workaround within DAB at this time. If possible, redesign the container to use a single partition key. If hierarchical partition keys are required by your data model, follow the GitHub issue for updates on when multi-hash support is added.

### MultiHash partition keys are not supported

**Symptom:** Mutations against a Cosmos DB container that uses a hierarchical (multi-hash) partition key fail with The 'kind' value 'MultiHash' specified in the partition key definition is invalid. Please choose 'Hash' partition type.

**Cause:** Data API builder only supports single-value Hash partition keys for Azure Cosmos DB. Containers configured with hierarchical partition keys (MultiHash)  for example, /TenantId, /EntityType, /EntityId  are not supported. This is a known limitation tracked in [GitHub issue #1733](https://github.com/Azure/data-api-builder/issues/1733).

**Resolution:** There is no workaround within DAB at this time. Use a container with a single Hash partition key instead. If hierarchical partitioning is required, consider restructuring the container or following the GitHub issue for updates on when MultiHash partition key support is added.

### Multiple mutations are not atomic on Cosmos DB

**Symptom:** When multiple GraphQL mutations are sent in a single request against Cosmos DB entities, a failure in one mutation does not roll back the others. Partial writes can occur.

**Cause:** Data API builder does not wrap multiple Cosmos DB mutations in a transactional batch. Unlike relational databases, where multiple mutations in a request are executed atomically, Cosmos DB mutations are issued independently. This is a known limitation tracked in [GitHub issue #1621](https://github.com/Azure/data-api-builder/issues/1621).

**Resolution:** Design your application to treat each Cosmos DB mutation as independent. If atomicity is required, use the Cosmos DB SDK directly with transactional batch support, scoped to items within the same logical partition. Follow the GitHub issue for updates on when transactional mutation support is added for Cosmos DB.

### GraphQL type name in schema file does not match entity config

**Symptom:** DAB starts without error but queries return unexpected results or the wrong type, because the GraphQL type name defined in schema.gql does not match the singular type name configured for the entity in dab-config.json.

**Cause:** Data API builder does not currently validate that the GraphQL type name in the schema file matches the singular type name declared for the entity. A mismatch silently produces an inconsistent schema. This is a known limitation tracked in [GitHub issue #1556](https://github.com/Azure/data-api-builder/issues/1556).

**Resolution:** Manually verify that the type name in schema.gql (set via the @model directive) matches the singular value in the entity's graphql.type configuration in dab-config.json. For example, if dab-config.json declares "singular": "Location", the schema file should contain 	ype Location @model(name:"Location").

### GraphQL type name in schema file does not match entity singular type name

**Symptom:** DAB starts without error but queries return unexpected results or the wrong type, because the GraphQL type name defined in schema.gql does not match the singular type name configured for the entity in dab-config.json.

**Cause:** Data API builder does not currently validate that the @model directive name in the GraphQL schema file matches the singular type name set for the entity. When they differ, the mismatch silently produces incorrect schema behavior. This is a known limitation tracked in [GitHub issue #1556](https://github.com/Azure/data-api-builder/issues/1556).

**Resolution:** Manually ensure the type name in schema.gql exactly matches the singular value in the entity's graphql.type configuration in dab-config.json. For example, if the entity defines "singular": "Location", the schema file should declare 	ype Location @model(name:"Location"). Run dab validate after making changes to catch other configuration errors.

### Enum types in the GraphQL schema file cause a schema build failure

**Symptom:** DAB fails to start with a HotChocolate.SchemaException: Unable to resolve type reference ... OrderByInput error when the Cosmos DB schema.gql file defines a GraphQL num type used on an object type field.

**Cause:** Data API builder does not currently support GraphQL enum types in the Cosmos DB schema file. When an enum is used as a field type, the schema builder cannot generate the corresponding OrderByInput type and throws an unhandled exception. This is a known limitation tracked in [GitHub issue #748](https://github.com/Azure/data-api-builder/issues/748).

**Resolution:** Replace enum fields with their scalar equivalents (for example, use String instead of a custom enum type) in schema.gql. Apply enum validation in your application layer rather than in the DAB schema definition.

### Enum types in the GraphQL schema cause DAB to fail on startup

**Symptom:** DAB fails to start with a HotChocolate.SchemaException error such as Unable to resolve type reference 'None: FooOrderByInput' when the Cosmos DB GraphQL schema file defines an enum type used on a model.

**Cause:** Data API builder's schema builder does not correctly handle GraphQL enum types defined in schema.gql. When an enum is referenced as a field type on a model, the internal OrderByInput type generation fails to resolve it, crashing schema initialization. This is a known limitation tracked in [GitHub issue #748](https://github.com/Azure/data-api-builder/issues/748).

**Resolution:** Avoid defining GraphQL enum types in schema.gql for Cosmos DB entities. As a workaround, replace enum fields with String and enforce valid values in the application layer. Follow the GitHub issue for updates on when enum support is added.

### Field mappings (aliases) are not supported for Cosmos DB entities

**Symptom:** A mappings section defined for a Cosmos DB entity in dab-config.json has no effect  the original field names are still exposed in the GraphQL schema rather than the configured aliases.

**Cause:** The mappings feature, which allows exposing database column names under different field names in the API, is implemented for relational databases only. Cosmos DB entities do not currently support field mappings. This is a known limitation tracked in [GitHub issue #1512](https://github.com/Azure/data-api-builder/issues/1512).

**Resolution:** Use the field names exactly as they appear in the Cosmos DB documents. If aliasing is needed, apply it in the client application layer. Follow the GitHub issue for updates on when mapping support is added for Cosmos DB.

### GraphQL mutation variables are not resolved  variable names stored instead of values

**Symptom:** A GraphQL mutation that uses variables (for example, createExample(item: { id: , name:  })) stores the variable names "" and "" in the database instead of the actual values passed in the ariables payload.

**Cause:** Data API builder does not currently resolve GraphQL variable references in mutation inputs for Cosmos DB. Variable substitution is skipped and the literal variable name is written as the field value. This is a known bug tracked in [GitHub issue #1482](https://github.com/Azure/data-api-builder/issues/1482).

**Resolution:** Inline the variable values directly in the mutation body instead of using GraphQL variables. For example, replace id:  with id: "1234". This is not ideal for production use, so follow the GitHub issue for updates on when variable handling is fixed for Cosmos DB mutations.

### Union types in the GraphQL schema file cause a 500 error

**Symptom:** DAB returns a 500 status code on all GraphQL requests when schema.gql defines a GraphQL union type. The startup logs show HotChocolate.SchemaException: Unable to resolve type reference ... OrderByInput.

**Cause:** Data API builder does not support GraphQL union types in the Cosmos DB schema file. Like enum types, union types cause the schema builder to fail when generating sort/filter input types. This is a known bug tracked in [GitHub issue #1384](https://github.com/Azure/data-api-builder/issues/1384).

**Resolution:** Remove union type definitions from schema.gql. Model polymorphic data using a single object type with optional fields, or split the data across separate entities. Follow the GitHub issue for updates on when union type support is added.

### Create mutation fails at runtime when id is defined as nullable in the schema

**Symptom:** A create mutation returns a runtime error even though the schema appears valid. The error occurs because the id field was not provided or was null.

**Cause:** Cosmos DB requires the id field for every document and uses it as part of the partition key. If schema.gql declares id as nullable (for example, id: ID instead of id: ID!), DAB accepts the schema but fails at runtime when a create mutation omits the field. The schema should enforce non-null at schema validation time, but currently does not. This gap is tracked in [GitHub issue #1238](https://github.com/Azure/data-api-builder/issues/1238).

**Resolution:** Always declare the id field as non-null in your Cosmos DB GraphQL schema:

`graphql
type MyEntity @model(name: "MyEntity") {
    id: ID!
    ...
}
`

Ensuring id: ID! causes clients to receive a clear schema-level error if id is omitted, rather than an opaque runtime failure.

### Circular GraphQL relationships cause a stack overflow exception on startup

**Symptom:** DAB crashes on startup with a stack overflow exception when schema.gql defines types that reference each other in a cycle (for example, Player references Game, and Game references Player).

**Cause:** The schema builder walks all type references recursively to generate mutation input types. Circular relationships cause infinite recursion, exhausting the call stack. This is a known bug tracked in [GitHub issue #746](https://github.com/Azure/data-api-builder/issues/746).

**Resolution:** Avoid circular type references in schema.gql. Break the cycle by removing the back-reference from one of the types, or model the relationship as a list of IDs (scalar fields) rather than nested object types. Follow the GitHub issue for updates on when circular relationships are supported.

### Partition key is always id  custom partition key paths are not supported

**Symptom:** DAB only works with Cosmos DB containers that use /id as the partition key. Containers partitioned by any other field (for example, /userId or /category) cannot be queried or mutated correctly.

**Cause:** Data API builder hardcodes id as the partition key for all Cosmos DB entities. There is no way to specify a custom partition key path in either dab-config.json or schema.gql. This is a known limitation tracked in [GitHub issue #747](https://github.com/Azure/data-api-builder/issues/747).

**Resolution:** Design new containers with /id as the partition key when using DAB. For existing containers with a different partition key, DAB is not currently supported. Follow the GitHub issue for updates on when configurable partition keys are added.

### Querying nested arrays within a document (in-item joins) is not supported

**Symptom:** You cannot filter or traverse nested array properties within a Cosmos DB document using DAB. Queries that would require a Cosmos DB JOIN across array elements return no results or an error.

**Cause:** Data API builder does not support Cosmos DB [intra-document joins](/azure/cosmos-db/nosql/query/join) (also called in-item joins), which are needed to query nested arrays within a single document. This is a known limitation tracked in [GitHub issue #262](https://github.com/Azure/data-api-builder/issues/262).

**Resolution:** Flatten nested arrays into separate entities or child documents if you need to filter on their contents. Alternatively, perform post-processing of the full document in your application layer. Follow the GitHub issue for updates on when intra-document join support is added.
