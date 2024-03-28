---
title: Policies Configuration
description: Part of the configuration documentation for Data API builder, focusing on Policies Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file-policy
ms.date: 03/04/2024
---

# Entity & Database Policies

The `policy` section, defined per `action`, defines item-level security rules (database policies) which limit the results returned from a request. The subsection `database` denotes the database policy expression that is evaluated during request execution.

## Syntax overview

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "policy": {
        "database": "<Expression>"
      }
    }
  }
}
```

**Syntax**

The `database` policy: an OData-like expression that is translated into a query predicate the database evaluates. This includes operators like `eq`, `lt`, and `gt`. In order for results to be returned for a request, the request's query predicate resolved from a database policy must evaluate to `true` when executing against the database.

|Example Item Policy|Predicate
|-|-
|`@item.OwnerId eq 2000`|`WHERE Table.OwnerId = 2000`
|`@item.OwnerId gt 2000`|`WHERE Table.OwnerId > 2000`
|`@item.OwnerId lt 2000`|`WHERE Table.OwnerId < 2000`

> A `predicate` is an expression that evaluates to TRUE or FALSE. Predicates are used in the search condition of [WHERE](/sql/t-sql/queries/where-transact-sql) clauses and [HAVING](/sql/t-sql/queries/select-having-transact-sql) clauses, the join conditions of [FROM](/sql/t-sql/queries/from-transact-sql) clauses, and other constructs where a Boolean value is required.
([Microsoft Learn Docs](/sql/t-sql/queries/predicates?view=sql-server-ver16&preserve-view=true))

**Database policy**

Two types of directives can be used when authoring a database policy expression:

|Directive|Description
|-|-
|`@claims`| access a claim within the validated access token provided in the request.
|`@item`| represents a field of the entity for which the database policy is defined.

> [!NOTE]
> When **Azure Static Web Apps** authentication (EasyAuth) is configured, a limited number of claims types are available for use in database policies: `identityProvider`, `userId`, `userDetails`, and `userRoles`. For more information, see Azure Static Web App's [Client principal data](/azure/static-web-apps/user-information?tabs=javascript#client-principal-data) documentation.

|Example Database Policy
|-
|`@claims.UserId eq @item.OwnerId`
|`@claims.UserId gt @item.OwnerId`
|`@claims.UserId lt @item.OwnerId`

Data API builder compares the value of the `UserId` claim to the value of the database field `OwnerId`. The result payload only includes records that fulfill **both** the request metadata and the database policy expression.

### Limitations

Database policies are supported for tables and views. Stored procedures can't be configured with policies.

Database policies can't be used to prevent a request from executing within a database because they are resolved as query predicates in the generated queries passed to the database engine. 

Database policies are only supported for the `actions` **create**, **read**, **update**, and **delete**.

### Supported OData-like operators

#### Binary Operators

| Operator | Description | Sample Syntax |
|----------|-------------|---------------|
| `and`    | Logical AND | `"@item.status eq 'active' and @item.age gt 18"` |
| `or`     | Logical OR  | `"@item.region eq 'US' or @item.region eq 'EU'"` |
| `eq`     | Equals      | `"@item.type eq 'employee'"` |
| `gt`     | Greater than| `"@item.salary gt 50000"` |
| `lt`     | Less than   | `"@item.experience lt 5"` |

[Learn more about Binary Operators.](/dotnet/api/microsoft.odata.uriparser.binaryoperatorkind?view=odata-core-7.0&preserve-view=true)

#### Unary Operators

| Operator | Description         | Sample Syntax |
|----------|---------------------|---------------|
| `-`      | Negate (numeric)    | `"@item.balance lt -100"` |
| `not`    | Logical negate (NOT) | `"not @item.status eq 'inactive'"` |

[Learn more about Unary Operators.](/dotnet/api/microsoft.odata.uriparser.unaryoperatorkind?view=odata-core-7.0&preserve-view=true)

### Entity Field Names Restrictions

- **Rules**: Must start with a letter or underscore (`_`), followed by up to 127 letters, underscores (`_`), or digits (`0-9`).
  
- **Impact**: Fields not adhering to these rules can't be directly used in database policies.

- **Solution**: Utilize the `mappings` section to create aliases for fields that don't meet these naming conventions; this ensures all fields can be included in policy expressions.

### Utilizing `mappings` for Nonconforming Fields

If your entity field names don't meet the OData syntax rules, you can define conforming aliases in the `mappings` section of your configuration. Here’s an example approach to work around field naming restrictions:

```json
"mappings": {
  "validFieldName": "NonConforming-Field_Name1",
  "anotherValidField": "Invalid Field Name 2"
}
```

In this example, `NonConforming-Field_Name1` and `Invalid Field Name 2` are original database field names that don't meet the OData naming conventions. By mapping to `validFieldName` and `anotherValidField`, respectively, you ensure these fields can be referenced in database policy expressions without issue.

This approach not only helps in adhering to the OData naming conventions but also enhances the clarity and accessibility of your data model within both GraphQL and RESTful endpoints.

## Example

Consider an entity named `Employee` within a Data API configuration that utilizes both claims and item directives. It ensures data access is securely managed based on user roles and entity ownership:

```json
{
  "entities": {
    "Employee": {
      "rest": {
        "enabled": true,
        "path": "/employees",
        "methods": ["GET", "POST", "PUT"]
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "Employee",
          "plural": "Employees"
        },
        "operation": "query"
      },
      "source": {
        "object": "EmployeesTable",
        "type": "table",
        "key-fields": ["EmployeeId"],
        "parameters": {}
      },
      "mappings": {
        "employeeId": "EmployeeId",
        "employeeName": "Name",
        "department": "DepartmentId"
      },
      "policy": {
        "database": "@claims.role eq 'HR' or @claims.UserId eq @item.EmployeeId"
      }
    }
  }
}
```

### Walkthrough

**Entity Definition**: The `Employee` entity is configured for REST and GraphQL interfaces, indicating its data can be queried or manipulated through these endpoints.

**Source Configuration**: Identifies the `EmployeesTable` in the database, with `EmployeeId` as the key field.

**Mappings**: Aliases are used to map `EmployeeId`, `Name`, and `DepartmentId` from the database to `employeeId`, `employeeName`, and `department` in the API, simplifying the field names and potentially obfuscating sensitive database schema details.

**Policy Application**: The `policy` section applies a database policy using an OData-like expression. This policy restricts data access to users with the HR role (`@claims.role eq 'HR'`) or to users whose `UserId` claim matches the `EmployeeId` field in the database (`@claims.UserId eq @item.EmployeeId`). It ensures that employees can only access their own records unless they belong to the HR department. Policies can enforce row-level security based on dynamic conditions. 