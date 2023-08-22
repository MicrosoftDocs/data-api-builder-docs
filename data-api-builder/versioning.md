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

This article outlines the versioning strategy used for new releases of Data API builder. Data API builder is currently in **Public Preview**.

Each published version of Data API builder is considered a *release* and is defined with the `Major.Minor.Patch` format. Releases are characterized as *stable*, *breaking change*, and *preview*.

## Stable releases

>[!WARNING]
> While we make every effort to maintain backwards compatibility with stable versions, we may introduce breaking changes as we respond to customer feedback about new features and bugs. For more information, see the [breaking changes article](./breaking-changes.md).

A *stable version* of Data API builder is backwards compatible, meaning that any code you write that relies on one version of a Data API builder can adopt a newer stable version without requiring any code changes to maintain correctness or existing functionality.

## Breaking change releases

A *breaking change version* of Data API builder isn't backwards compatible. Adopting a breaking change version in existing client code may require code changes to ensure the client behaves exactly as it did when targeting the previous version.

Breaking change versions are announced via the breaking change list article and in a GitHub release's change description. Breaking change versions are typically preceded by publication of a preview/release candidate version. While previous versions of Data API builder may remain available on the GitHub releases page, we recommend that you upgrade to the latest release which may include bug fixes.

## Preview releases

Data API builder preview releases are identified with the `X.Y.Z-rc` versioning scheme. The `-rc` suffix indicates that the build is a "release candidate." Preview releases are used to gather feedback about new features and other changes.

Unless explicitly intended to introduce a breaking change from the previous stable version, new preview versions include all the features of the most recent stable version and add new preview features. However, between preview versions, a new Data API builder release may break any of the newly added preview features.

Previews aren't intended for long-term nor production use. Anytime a new stable or preview version becomes available, existing preview versions may become unavailable after the availability of the new version. Use preview versions only in situations where you're actively developing against new features and you're prepared to adopt a new, non-preview version soon after it's released. If some features from a preview version are released in a new stable version, remaining features still in preview will typically be published in a new preview version.