---
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: include
ms.date: 06/11/2025
---

Install the `Microsoft.DataApiBuilder` package from NuGet as a .NET tool.

1. Use `dotnet tool install` to install the latest version of the `Microsoft.DataApiBuilder` with the `--global` argument.

    ```dotnetcli
    dotnet tool install --global Microsoft.DataApiBuilder
    ```

    > [!NOTE]
    > If the package is already installed, update the package instead using `dotnet tool update`.
    >
    > ```dotnetcli
    > dotnet tool update --global Microsoft.DataApiBuilder
    > ```
    >

1. Verify that the tool is installed with `dotnet tool list` using the `--global` argument.

    ```dotnetcli
    dotnet tool list --global
    ```
