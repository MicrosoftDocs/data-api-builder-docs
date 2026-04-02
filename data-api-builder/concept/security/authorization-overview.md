---
title: Authorization overview
description: Learn how to control what authenticated users can do with Data API builder's fine-grained authorization system.
---

# Authorization overview

Authorization determines what authenticated users are allowed to do in your Data API builder application. While authentication verifies *who* a user is, authorization controls *what* they can access and modify.

## Key authorization concepts

### Entity permissions

Control CRUD operations (Create, Read, Update, Delete) at the entity level. Each role can be granted or denied specific actions on specific entities.

### Role-based access control

Assign users to roles and grant permissions based on role membership. Roles simplify management of large user groups with similar access patterns.

### Row-level security (RLS)

Filter data based on user identity or session context. Users see only the rows they're authorized to access, enforced at the database level.

### API policies

Apply OData predicates and filters to API responses. Policies automatically restrict query results based on user claims and identity.

### Claims-based authorization

To determine access, use claims from authentication tokens (for example, groups, roles, custom attributes). Claims provide flexible, granular permission decisions.

## How it works

1. **User authenticates** using one of the supported authentication methods
2. **System extracts claims** from the authentication token (roles, groups, organization, etc.)
3. **Authorization rules are evaluated** against the user's claims and the requested resource
4. **Access is granted or denied** based on entity permissions, policies, and row-level security rules

## Authorization decision flow

```
User Request
    ↓
Authentication (verify user identity)
    ↓
Extract Claims (roles, groups, custom attributes)
    ↓
Check Entity Permissions (allowed actions?)
    ↓
Apply Policies (OData filters)
    ↓
Apply Row-Level Security (data-level filtering)
    ↓
Return Authorized Response
```

## Layered security model

Data API builder uses multiple authorization layers:

- **Entity-level**: Which entities and operations are accessible
- **Policy-level**: What data is returned (filtering based on claims)
- **Row-level**: Database applies row filtering through RLS
- **API-level**: HTTP headers and request validation

## Next steps

- [Entity permissions](authorization.md)—Configure CRUD operations per entity
- [Role inheritance](role-inheritance.md)—Build role hierarchies
- [API policies](database-policies.md)—Apply OData filters based on claims
- [Row-level security](row-level-security.md)—Filter data at the database level
- [Best practices](best-practices.md)—Security hardening guidance
