---
title: Versioning strategy
description: This article highlights Data API builder's versioning strategy. 
author: seantleonard 
ms.author: seleonar 
ms.service: data-api-builder 
ms.topic: versioning-general
ms.date: 9/04/2023 
---

# Versioning overview

This article outlines the versioning strategy used for new releases of Data API builder.

## What is a release?

A **release** in the context of Data API builder refers to every published version of the software, identified by the `Major.Minor.Patch` format. These releases fall into three categories: *stable*, *breaking change*, and *preview*.

### Stable releases

A *stable version* of Data API builder is backwards compatible, meaning that any code you write that relies on one version of a Data API builder can adopt a newer stable version without requiring any code changes to maintain correctness or existing functionality.

### Breaking change releases

A *breaking change version* of Data API builder isn't backwards compatible. Adopting a breaking change version in existing client code may require code changes to ensure the client behaves exactly as it did when targeting the previous version.

Breaking change versions are announced via the breaking change list article and in a GitHub release's change description. Breaking change versions are preceded by publication of a preview/release candidate version unless the changes fix critical security, privacy, or legal issues. While previous versions of Data API builder may remain available on the GitHub releases page, we recommend that you upgrade to the latest release which may include bug fixes.

### Preview releases

Data API builder preview releases are identified with the `X.Y.Z-rc` versioning scheme. The `-rc` suffix indicates that the build is a "release candidate." Preview releases are used to gather feedback about new features and other changes.

Unless we plan to purposely make big changes from the last stable version, we publish the next preview version with everything from the latest stable release and new preview features. But please keep in mind that between these preview versions, the next Data API builder update might break some of the new preview features we added, which means you might need to change your code to make things work again.

Preview versions are not meant for long-term or production use. When a new stable or preview version becomes available, older preview versions might not be accessible anymore. It's best to use preview versions only when you're actively working on new features and are ready to switch to a non-preview version soon after it's released. If some features from a preview version are included in a new stable version, the remaining preview features are usually added to a new preview version for you to try out.

## Version change table

> [!IMPORTANT]
> We may introduce a breaking change to a minor or patch release when the change addresses critical product bugs, legal, security, or privacy concerns.

| Release type | Previous Version | New Version | Notes |
|---|---|---|---|
| Breaking Change | `1.Y.Z` | `2.Y.Z` | New features and bug fixes along with any breaking changes.|
| Stable | `1.1.Z`| `1.2.Z` | New features and bug fixes with no breaking changes unless the changes address critical product bugs, legal, security, or privacy concerns.|
| Stable | `1.1.1` | `1.1.2` | Bug fixes with no new features or breaking changes the unless the changes address critical product bugs, legal, security, or privacy concerns.|
| Preview | `X.Y.1-rc` | `X.Y.2-rc` | New preview features and bug fixes. (Breaking changes are included if the major version is bumped.) |