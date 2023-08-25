---
title: Breaking changes overview
description: This article defines what breaking and non-breaking changes are in Data API builder. 
author: seantleonard 
ms.author: seleonar 
ms.service: data-api-builder 
ms.topic: versioning-breakingchanges
ms.date: 9/04/2023 
---


# Breaking Changes

To prioritize security, enhance features, and maintain code quality, new versions of our software might include breaking changes. While we strive to minimize these changes through careful architectural choices, they can still occur. In such cases, we make it a priority to announce them and provide possible solutions.

> [!IMPORTANT]
> We may make changes without prior notice if the change is considered non-breaking, or if it is a breaking change being made to address critical product bugs or legal, security, or privacy concerns.

## What is a breaking change?

A breaking change is a modification that could necessitate adjustments to your application to prevent disruptions. In Data API builder, breaking changes can include alterations to REST API contracts, GraphQL schema generation, and other elements that impact compatibility and functionality.

### Breaking change examples

The following examples are a *non-exhaustive* list of breaking changes to Data API builder:

1. REST API contract modifications
2. Alterations in GraphQL schema generation
3. Changes affecting backwards compatibility
4. Removal or renaming of APIs or parameters
5. Changes in error codes
6. Adjustments to permission definition functionality
7. Removal of allowed parameters, request fields, or response fields
8. Addition of mandatory parameters or request fields without default values
9. Modifications to intended API endpoint functionality

## Definition of a non-breaking change

A **non-breaking change** refers to a change that can be integrated into your application without causing disruption. We typically communicate non-breaking changes after they have already been implemented. Your application should be designed to handle these changes without prior notice.

### Non-Breaking Change Examples

The following examples are a *non-exhaustive* list of non-breaking changes to Data API builder:

1. Introduction of new endpoints
2. Addition of methods to existing endpoints
3. Incorporation of new fields in responses and requests
4. Adjustments to field order within responses
5. Introduction of optional request headers
6. Changes to data length and response size
7. Alterations to error messages and codes
8. Fixes to HTTP response codes
9. Additional metadata in generated OpenAPI documents

## How Do We Communicate Breaking Changes?

We make it a priority to inform you promptly about breaking changes. You can find breaking change notifications in the release notes of Data API builder releases on GitHub, as well as in the dedicated [breaking changes list article](./breaking-change-list.md).