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
