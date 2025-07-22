---
title: Release, versioning, and breaking change policies
description: A set of policies governs Data API builder related to breaking changes, notifications, releases, and versioning.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/11/2025
---

# Policies for Data API builder

A set of policies governs Data API builder related to breaking changes, notifications, releases, and versioning.

## Versioning and releases

A **release** in the context of Data API builder refers to every published version of the software, identified by the `Major.Minor.Patch` format. These releases fall into three categories: *stable*, *breaking change*, and *preview*. 

### Container Update Responsibility
The Data API builder container does not update automatically. Customers are responsible for monitoring new releases, evaluating their importance (including security updates), and updating deployed containers accordingly.

Keeping the container up to date is the **customer’s responsibility**.

### Stable releases

A *stable version* of Data API builder is backwards compatible. Backwards compatible implies that any code you write that relies on one version of a Data API builder can adopt a newer stable version without requiring any code changes to maintain correctness or existing functionality.

### Breaking change releases

A *breaking change version* of Data API builder isn't backwards compatible. Adopting a breaking change version in existing client code might require code changes to ensure the client behaves exactly as it did when targeting the previous version.

Breaking change versions are announced via the breaking change list article and in a GitHub release's change description. Publication of a preview/release candidate version precedes breaking change versions unless the changes fix critical security, privacy, or legal issues. While previous versions of Data API builder might remain available on the GitHub releases page, we recommend that you upgrade to the latest release, which might include bug fixes.

### Preview releases

Data API builder preview releases are identified with the `X.Y.Z-rc` versioning scheme. The `-rc` suffix indicates that the build is a "release candidate." Preview releases are used to gather feedback about new features and other changes.

Unless we plan to purposely make significant changes from the last stable version, we publish the next preview version with everything from the latest stable release and new preview features. The next Data API builder update might break some of the new preview features we added between preview versions. This breaking behavior means you might need to change your code to make things work again.

Preview versions aren't meant for long-term or production use. When a new stable or preview version becomes available, older preview versions might not be accessible anymore. It's best to use preview versions only when you're actively working on new features and are ready to switch to a non-preview version soon after release. If some features from a preview version are included in a new stable version, the remaining preview features are added to a new preview version for you to try out.

### Version change table

> [!IMPORTANT]
> We might introduce a breaking change to a minor or patch release when the change addresses critical product bugs, legal, security, or privacy concerns.

| Release type | Previous Version | New Version | Notes |
|---|---|---|---|
| Breaking Change | `1.Y.Z` | `2.Y.Z` | New features and bug fixes along with any breaking changes.|
| Stable | `1.1.Z`| `1.2.Z` | New features and bug fixes with no breaking changes unless the changes address critical product bugs, legal, security, or privacy concerns.|
| Stable | `1.1.1` | `1.1.2` | Bug fixes with no new features or breaking changes unless the changes address critical product bugs, legal, security, or privacy concerns.|
| Preview | `X.Y.1-rc` | `X.Y.2-rc` | New preview features and bug fixes. (Breaking changes are included if the major version is bumped.) |

## Breaking Changes

To prioritize security, enhance features, and maintain code quality, new versions of our software might include breaking changes. While we strive to minimize these changes through careful architectural choices, they can still occur. In such cases, we make it a priority to announce them and provide possible solutions.

> [!IMPORTANT]
> We might make changes without prior notice if the change is considered non-breaking, or if it is a breaking change being made to address critical product bugs or legal, security, or privacy concerns.

### What is a breaking change?

A breaking change is a modification that requires you to update your application to prevent disruptions. In Data API builder, breaking changes can include alterations to REST API contracts, GraphQL schema generation, and other elements that affect compatibility and functionality.

#### Breaking change examples

The following examples are a *nonexhaustive* list of breaking changes to Data API builder:

- REST API contract modifications
- Alterations in GraphQL schema generation
- Changes affecting backwards compatibility
- Removal or renaming of APIs or parameters
- Changes in error codes
- Adjustments to permission definition functionality
- Removal of allowed parameters, request fields, or response fields
- Addition of mandatory parameters or request fields without default values
- Modifications to intended API endpoint functionality

### Definition of a nonbreaking change

A **non-breaking change** refers to a change that can be integrated into your application without causing disruption. Nonbreaking changes are typically communicated after implementation. Your application should be designed to handle these changes without prior notice.

#### Non-Breaking Change Examples

The following examples are a *nonexhaustive* list of nonbreaking changes to Data API builder:

- Introduction of new endpoints
- Addition of methods to existing endpoints
- Incorporation of new fields in responses and requests
- Adjustments to field order within responses
- Introduction of optional request headers
- Changes to data length and response size
- Alterations to error messages and codes
- Fixes to HTTP response codes
- Extra metadata in generated OpenAPI documents

### How do we communicate breaking changes?

We make it a priority to inform you promptly about breaking changes. You can find breaking change notifications in the release notes of Data API builder releases on GitHub.

## Current breaking change list

Breaking changes and feature retirements are announced in this article.

- *As of now, there are no breaking changes*

## Related content

- [What's new](./whats-new/index.yml)
- [Database-specific-features](./reference-database-specific-features.md)
