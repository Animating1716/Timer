"""Base class for MCP modules"""

from abc import ABC, abstractmethod
from typing import Any
from mcp.types import Tool


class MCPModule(ABC):
    """Base class for MCP modules - extend this to add new functionality"""

    @abstractmethod
    def get_tools(self) -> list[Tool]:
        """Return list of tools this module provides"""
        pass

    @abstractmethod
    def handles_tool(self, name: str) -> bool:
        """Check if this module handles a given tool"""
        pass

    @abstractmethod
    async def call_tool(self, name: str, arguments: dict) -> str:
        """Execute a tool and return result as string"""
        pass
