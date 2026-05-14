---
title: Use SQL MCP Server with local models
description: Connect local LLMs like Ollama to SQL MCP Server using the MCP Python SDK. Covers schema pre-injection, response discipline, and field metadata practices for small models.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 05/14/2026
# Customer Intent: As a developer in a regulated or air-gapped environment, I want to connect a local LLM to SQL MCP Server so that I can query databases without cloud AI services.
---

# Use SQL MCP Server with local models

[!INCLUDE[Note - SQL MCP availability](includes/note-availability.md)]

SQL MCP Server works with any MCP-compatible client, not just cloud-hosted AI services. If your environment restricts cloud LLM access — common in healthcare, defense, finance, energy, and maritime industries — you can connect a local model served through [Ollama](https://ollama.com/) or similar tools. This guide covers setup, field metadata configuration, and prompt patterns that make small local models reliable.

## Prerequisites

- Data API builder CLI installed and configured with at least one entity. [Install the CLI](../command-line/install.md).
- [Ollama](https://ollama.com/) with a model that supports tool calling (for example, `qwen3:8b`, `llama3.1:8b`).
- [Python 3.10+](https://www.python.org/downloads/) with the `mcp` and `ollama` packages.
- A running SQL Server instance with data.

## Step 1: Configure field metadata

Field metadata is the most important configuration step for local model accuracy. Without field names and descriptions, agents see only entity names and guess column names incorrectly.

> [!WARNING]
> Skipping this step produces an MCP server that technically works but is functionally unusable by any model that reads tool responses. The model has no information about your columns.

Add field metadata with the DAB CLI:

```dotnetcli
dab add ServerInventory \
  --source dbo.ServerInventory \
  --permissions "anonymous:read" \
  --description "SQL Server instance inventory with version, environment, and sizing data"
```

```dotnetcli
dab update ServerInventory \
  --fields.name InstanceName --fields.primary-key true \
  --fields.description "SQL Server instance name (e.g., YOURSERVER01)"

dab update ServerInventory \
  --fields.name Environment \
  --fields.description "Deployment environment. Valid values: Prod, Dev, Test, UAT"

dab update ServerInventory \
  --fields.name SQLVersion \
  --fields.description "SQL Server version year. Valid values: 2016, 2017, 2019, 2022"

dab update ServerInventory \
  --fields.name DatabaseCount \
  --fields.description "Number of user databases on this instance"

dab update ServerInventory \
  --fields.name TotalSizeGB \
  --fields.description "Total database size in gigabytes"
```

### List valid values for constrained columns

Small models hallucinate similar but incorrect filter values. If a column stores a fixed set of values, list them in the description. For example, a model receiving `"Valid values: Prod, Dev, Test, UAT"` can reason that "production" maps to `Prod` rather than guessing `Production`.

For more patterns and CLI examples, see [constrained and enum-like values](./how-to-add-descriptions.md#constrained-and-enum-like-values).

> [!NOTE]
> The `dab update` CLI treats commas as argument separators. If your description contains commas, edit `dab-config.json` directly instead.

## Step 2: Start SQL MCP Server

```dotnetcli
dab start
```

SQL MCP Server listens on `http://localhost:5000/mcp` using streamable HTTP transport by default. Any client that implements the MCP protocol can connect to this endpoint.

## Step 3: Connect your local model

Build an MCP client that connects your Ollama model to SQL MCP Server. The following Python example uses the [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk) and the `ollama` package.

### Install dependencies

```bash
pip install mcp ollama
```

### Minimal Python harness

```python
import asyncio
import json
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client
import ollama

MCP_URL = "http://localhost:5000/mcp"
MODEL = "qwen3:8b"

async def get_schema(session: ClientSession) -> str:
    """Call describe_entities and format results for the system prompt."""
    result = await session.call_tool("describe_entities", arguments={})
    entities = json.loads(result.content[0].text)
    lines = []
    for entity in entities.get("entities", []):
        fields = ", ".join(
            f"{f['name']} ({f.get('description', 'no description')})"
            for f in entity.get("fields", [])
        )
        lines.append(f"- {entity['name']}: {entity.get('description', '')}")
        if fields:
            lines.append(f"  Fields: {fields}")
    return "\n".join(lines)

async def run(user_question: str):
    async with streamablehttp_client(MCP_URL) as (read, write, _):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # Pre-inject schema into the system prompt
            schema_text = await get_schema(session)
            system_prompt = f"""You query a SQL database through MCP tools.

Available entities:
{schema_text}

Rules:
- Use the exact field names shown above.
- Answer count questions with the count only.
- Do not produce summaries unless asked.
- Do not invent example data. Only return data from tool responses.
- If no results, say "No results found" and stop.
"""
            # Get available tools for Ollama
            tools_result = await session.list_tools()
            ollama_tools = [
                {
                    "type": "function",
                    "function": {
                        "name": t.name,
                        "description": t.description or "",
                        "parameters": t.inputSchema,
                    },
                }
                for t in tools_result.tools
            ]

            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_question},
            ]

            # Chat loop: let the model call tools until it produces a final answer
            while True:
                response = ollama.chat(
                    model=MODEL, messages=messages, tools=ollama_tools
                )
                msg = response["message"]
                messages.append(msg)

                if not msg.get("tool_calls"):
                    print(msg["content"])
                    break

                for tc in msg["tool_calls"]:
                    result = await session.call_tool(
                        tc["function"]["name"],
                        arguments=tc["function"]["arguments"],
                    )
                    messages.append(
                        {
                            "role": "tool",
                            "content": result.content[0].text,
                        }
                    )

asyncio.run(run("How many SQL 2019 servers are in production?"))
```

This harness handles the full cycle: schema pre-injection, tool discovery, multi-turn tool calling, and final answer extraction. Adjust `MODEL` and `MCP_URL` for your environment.

## Pre-inject schema at startup

Small local models (under 14B parameters) produce more reliable tool calls when schema metadata is in the system prompt before the conversation begins. Instead of relying on the model to call `describe_entities` on its own during conversation, call it at harness startup and inject the result.

### Why pre-injection matters

| Approach | Behavior with small models |
|----------|---------------------------|
| Dynamic discovery | Model must decide to call `describe_entities` first, then interpret results, then call the right tool with correct field names. Multiple points of failure. |
| Pre-injection | Model sees entity names, field names, and descriptions immediately. Correct tool calls on the first attempt. |

The harness example in the previous section demonstrates this pattern. The `get_schema()` function calls `describe_entities` once at startup and formats the result into the system prompt.

> [!TIP]
> Larger cloud models (GPT-4o, Claude) typically discover schema during conversation without pre-injection. This pattern is most valuable for models under 14B parameters.

## Constrain model responses

A model can make a correct tool call, retrieve the right data, and still produce a wrong answer. For example, a model asked "how many production servers?" might retrieve 16 rows correctly, then respond with a 40-line executive summary containing hallucinated examples instead of the number `16`.

Add explicit negative rules to your system prompt:

```text
Rules:
- Answer count questions with the count only.
- Do not produce summaries unless the user asks for one.
- Do not invent example data. Only return data from tool responses.
- If a tool returns no results, say "No results found" and stop.
```

Tool-calling fidelity and answer discipline are different problems. DAB ensures accurate data retrieval through the tool layer. Your prompt harness controls how the model presents results.

## Considerations

| Topic | Details |
|-------|---------|
| **Hardware** | Tool calling works on modest hardware. An 8B model with 8 GB VRAM on an Nvidia GPU produces useful results with ~30-second response times. |
| **Batch vs. interactive** | Small models are well-suited for batch processing (performance reports, inventory queries) where latency tolerance is higher. |
| **Tool availability** | `aggregate_records` is available in version 2.0 preview and later only. On version 1.7.x, count and aggregation queries force the model to read all matching rows. See [tool availability by version](./data-manipulation-language-tools.md#tool-availability-by-version). |
| **Transport** | Local models connect via streamable HTTP to `/mcp`. The [stdio transport](./stdio-transport.md) is an alternative for single-process setups. |
| **Authentication** | For local development, use `anonymous` permissions. For production, configure [authentication](./how-to-configure-authentication.md) appropriate to your environment. |

## Related content

- [Add descriptions to entities](how-to-add-descriptions.md)
- [Data manipulation tools](data-manipulation-language-tools.md)
- [Deploy in air-gapped environments](../deployment/air-gapped.md)
- [Configure authentication](how-to-configure-authentication.md)
- [Stdio transport](stdio-transport.md)
