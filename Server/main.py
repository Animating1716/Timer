#!/usr/bin/env python3
"""
MCP Server for Habit Timer App
Runs on VPS, reads from CloudKit, exposes MCP tools
"""

import asyncio
import json
import os
from datetime import datetime, date
from typing import Optional
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

# Load environment variables
load_dotenv()

# Import MCP modules
from mcp_modules.habits import HabitsModule
from mcp_modules.base import MCPModule

# Initialize server
server = Server("habit-timer-mcp")

# Initialize modules
modules: dict[str, MCPModule] = {}


def register_module(name: str, module: MCPModule):
    """Register an MCP module"""
    modules[name] = module


# Register default modules
register_module("habits", HabitsModule())


@server.list_tools()
async def list_tools() -> list[Tool]:
    """List all available tools from all modules"""
    tools = []
    for module in modules.values():
        tools.extend(module.get_tools())
    return tools


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Route tool calls to appropriate modules"""
    for module in modules.values():
        if module.handles_tool(name):
            result = await module.call_tool(name, arguments)
            return [TextContent(type="text", text=result)]

    return [TextContent(type="text", text=f"Unknown tool: {name}")]


async def main():
    """Run the MCP server"""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())
