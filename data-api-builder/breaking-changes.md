---
title: Breaking changes overview
description: This article defines what breaking and non-breaking changes are in Data API builder. 
author: seantleonard 
ms.author: seleonar 
ms.service: data-api-builder 
ms.topic: versioning-breakingchanges
ms.date: 8/27/2023 
---


# Overview

This article defines what constitutes a breaking change in new versions of Data API builder. 

> [!IMPORTANT]
> We may make changes without prior notice if the change is considered non-breaking, or if it is a breaking change being made to address critical product bugs or legal, security, or privacy concerns.

## Definition of a breaking change

A *breaking change* is a change that may require you to make changes to your application in order to avoid disruption. 

The follow changes are considered breaking changes to the Data API builder engine:

- REST API contract changes
- GraphQL schema generation changes
- Changes that affect backwards compatibility 
- Removing or renaming APIs or API parameters
- Changes in Error Codes
- Changes to the intended functionality of permission definitions
- Removal of an allowed parameter, request field, or response field
- Addition of a required parameter or request field without default values
- Changes to the intended functionality of an API endpoint. _For example, if a DELETE request (REST) or delete mutation (GraphQL) previously used to archive the resource but now hard deletes the resource._
- Introduction of a new validation for request content

The follow changes are considered breaking changes to Data API builder's runtime configuration file:

- New required fields in the configuration file
- Introduction of a new validation

## Definition of a non-breaking change

A *non-breaking* change is a change that you can adapt to at your own discretion and pace without disruption. In most cases, we will communicate non-breaking changes after they are already made. Ensure that your application is designed to be able to handle the following types of non-breaking changes without prior notice:

> [!WARNING] 
> Changes you make to your database may result in a newly generated representation of your database in the REST and GraphQL endpoints. Databases changes are not considered breaking changes in Data API builder.

The follow changes are considered non-breaking changes to the Data API builder engine:

- Addition of new endpoints (e.g. `/graphql`, `/api`, `/swagger`, and `/openapi`)
- Addition of new methods to existing endpoints
- Addition of new fields in the following scenarios:
  - New fields in responses
  - New optional request fields or parameters
  - New required request fields that have default values
  - New optional properties in the runtime configuration
- Addition of a new value returned for an existing text field
- Changes to the order of fields returned within a response
- Addition of an optional request header
- Removal of redundant request header
- Changes to the length of data returned within a field
- Changes to the overall response size
- Changes to error messages. _We do not recommend parsing error messages to perform business logic. Instead, you should only rely on HTTP response codes and error codes._
- Fixes to HTTP response codes and error codes from incorrect code to correct code
- Additional metadata included in the generated OpenAPI document.

The follow changes are considered non-breaking changes to Data API builder's runtime configuration file:
 
- New optional properties in the configuration file

## Change Notifications

We make every effort to give timely notification of breaking changes. Breaking change notifications can be found in the release notes of Data API builder releases on GitHub as well as on the breaking changes list article.