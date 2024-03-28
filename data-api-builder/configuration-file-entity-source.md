---
title: Entities Basic Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entities Basic Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

# Source

The `{entity}.source` configuration is pivotal in defining the connection between the API-exposed entity and its underlying database object. This property specifies the database table, view, or stored procedure that the entity represents, establishing a direct link for data retrieval and manipulation.

## Syntax overview

```json
{
  ...
  "entities" {
    "<entity-name>": {
      ...
      "source": {
        "object": "<string>",
        "type": "<view> | <stored-procedure> | <table>",
        "key-fields": [ "<array-of-strings>" ],
        "parameters": {
            "<name>": "<value>",
            "<name>": "<value>"
        }        
      }
    }
  }
}
```

For straightforward scenarios, where the entity maps directly to a single database table or collection, the source property needs only the name of that database object. This simplicity facilitates quick setup for common use cases.

## Type property

The `type` property identifies the type of database object behind the entity, these include `view`, `table`, and `stored-procedure`. Some types require additional properties. The `type` property is required and there is not default value. 

```json
{
  "entities" {
    "<entity-name>": {
      "type": "<view> | <stored-procedure> | <table>",
      ...
    }
  }
}
```

**View**

Views require the `key-fields` property to be provided, so that Data API builder knows how it can identify and return a single item, if needed. If `type` is set to `view` without `key-fields`, the Data API builder engine will refuse to start.

## Key-fields property

The `{entity}.key-fields` setting is necessary for entities backed by views, so Data API builder knows how it can identify and return a single item, if needed. If `type` is set to `view` without `key-fields`, the Data API builder engine will refuse to start.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "type": "view",
      "key-fields": [ "<field-name>" ]
    }
  }
}
```

## Parameters property

The `{entity}.parameters` setting is important for entities backed by stored procedures, enabling developers to specify parameters and their default values. This ensures that if certain parameters are not provided within an HTTP request, the system can fall back to these predefined values.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "type": "stored-procedure",
      "parameters": {
        "<parameter-name-1>" : "<default-value>",
        "<parameter-name-2>" : "<default-value>",
        "<parameter-name-3>" : "<default-value>"
      }
    }
  }
}
```

### Example - Stored Procedure Select

![Many-to-many diagram](media/many-to-many.png)

```json
{
  "entities": {
    "Todo": {
      "type": "stored-procedure",
      "source": {
        "type": "stored-procedure",
        "object": "GetUserTodos"
      },
      "parameters": {
        "UserId": 0, 
        "Completed": null,
        "CategoryName": null
      },
      "mapping": {
        "Id": "todo_id",
        "Title": "todo_title",
        "Description": "todo_description",
        "Completed": "todo_completed"
      }
    }
  }
}
```

 - The `Todo` entity is configured to be backed by a stored procedure.
 - The `type` property within source is set to `stored-procedure`, indicating the kind of source object the entity is mapped to.
 - The `object` property within source is the name of the stored procedure in the database.

**Notice mapping**

Also in this example, the (optional) `mapping` property is added to the configuration for the "Todo" entity. It specifies how the fields in the entity (`Id`, `Title`, `Description`, and `Completed`) map to the corresponding fields in the underlying data source or stored procedure parameters (`todo_id`, `todo_title`, `todo_description`, and `todo_completed`, respectively). This mapping ensures that the correct data is passed between the entity and the stored procedure during create/update operations.

The above example would leverage the following SQL procedure.

```sql
CREATE PROCEDURE GetUserTodos
    @UserId INT,
    @Completed BIT = NULL,
    @CategoryName NVARCHAR(100) = NULL
AS
BEGIN
    SELECT t.*
    FROM Todo t
    INNER JOIN users_todos ut ON t.id = ut.todo_id
    INNER JOIN Category c ON t.category_id = c.id
    WHERE ut.user_id = @UserId
    AND ISNULL(@Completed, t.completed)
    AND ISNULL(@CategoryName, c.name)
END
```

 - `@UserId`: Mandatory parameter without a default value. It's used to fetch todos for a specific user.
 - `@Completed`: Optional parameter. If provided, it filters the todos by their completion status.
 - `@CategoryName`: Optional parameter. If provided, it filters the todos by category name.

### Example - Stored Procedure Update

```json
{
  "entities": {
    "Todo": {
      "type": "stored-procedure",
      "source": {
        "object": "UpsertTodo"
      },
      "method": "POST", // Specify the HTTP method as POST
      "parameters": {
        "Id": 0,
        "Title": null,
        "Description": null,
        "Completed": null
      }
    }
  }
}
```

This example, explicitly sets the HTTP method for interacting with this entity to `POST` using the method property.

```SQL
CREATE PROCEDURE UpsertTodo
    @Id INT,
    @Title NVARCHAR(100),
    @Description NVARCHAR(255),
    @Completed BIT
AS
BEGIN
    SET NOCOUNT ON;

    MERGE INTO Todo AS target
    USING (VALUES (@Id, @Title, @Description, @Completed)) AS source (Id, Title, Description, Completed)
    ON target.Id = source.Id
    WHEN MATCHED THEN
        UPDATE SET
            Title = source.Title,
            Description = source.Description,
            Completed = source.Completed
    WHEN NOT MATCHED THEN
        INSERT (Id, Title, Description, Completed)
        VALUES (source.Id, source.Title, source.Description, source.Completed);
END;
```