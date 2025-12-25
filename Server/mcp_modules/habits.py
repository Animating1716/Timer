"""
Habits MCP Module
Provides tools for checking habit completion status
"""

import os
import json
import httpx
from datetime import datetime, date, timedelta
from typing import Optional
from pathlib import Path

from mcp.types import Tool

from .base import MCPModule


# Local storage path for habit data (synced from iOS app)
DATA_DIR = Path(os.getenv("HABIT_DATA_DIR", "/data/habits"))


class HabitsModule(MCPModule):
    """Module for habit tracking MCP tools"""

    TOOLS = [
        "habits_today",
        "habits_week",
        "habits_check",
        "habits_summary",
    ]

    def get_tools(self) -> list[Tool]:
        return [
            Tool(
                name="habits_today",
                description="Get all habits and their completion status for today. Returns a list of habits with name, completed status, count, and daily goal.",
                inputSchema={
                    "type": "object",
                    "properties": {},
                    "required": []
                }
            ),
            Tool(
                name="habits_week",
                description="Get habit completion overview for the past 7 days. Shows which days had all habits completed.",
                inputSchema={
                    "type": "object",
                    "properties": {},
                    "required": []
                }
            ),
            Tool(
                name="habits_check",
                description="Check if a specific habit was completed today",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "habit_name": {
                            "type": "string",
                            "description": "Name of the habit to check (e.g., 'Exercise', 'Meditation')"
                        }
                    },
                    "required": ["habit_name"]
                }
            ),
            Tool(
                name="habits_summary",
                description="Get a natural language summary of today's habit progress",
                inputSchema={
                    "type": "object",
                    "properties": {},
                    "required": []
                }
            ),
        ]

    def handles_tool(self, name: str) -> bool:
        return name in self.TOOLS

    async def call_tool(self, name: str, arguments: dict) -> str:
        if name == "habits_today":
            return await self._get_today()
        elif name == "habits_week":
            return await self._get_week()
        elif name == "habits_check":
            return await self._check_habit(arguments.get("habit_name", ""))
        elif name == "habits_summary":
            return await self._get_summary()
        else:
            return f"Unknown tool: {name}"

    async def _load_data(self, date_str: Optional[str] = None) -> dict:
        """Load habit data for a specific date"""
        if date_str is None:
            date_str = date.today().isoformat()

        data_file = DATA_DIR / f"{date_str}.json"

        if data_file.exists():
            with open(data_file) as f:
                return json.load(f)

        # Return empty structure if no data
        return {"date": date_str, "habits": [], "last_updated": None}

    async def _get_today(self) -> str:
        """Get today's habits status"""
        data = await self._load_data()

        if not data.get("habits"):
            return "Keine Habit-Daten für heute gefunden. Öffne die App um zu synchronisieren."

        result = f"📅 Habits für heute ({date.today().strftime('%d.%m.%Y')}):\n\n"

        for habit in data["habits"]:
            status = "✅" if habit["completed"] else "❌"
            progress = f"{habit['count']}/{habit['goal']}"
            result += f"{status} {habit['name']}: {progress}\n"

        completed = sum(1 for h in data["habits"] if h["completed"])
        total = len(data["habits"])
        result += f"\n📊 Gesamt: {completed}/{total} erledigt"

        return result

    async def _get_week(self) -> str:
        """Get week overview"""
        result = "📅 Wochenübersicht:\n\n"

        for i in range(6, -1, -1):
            day = date.today() - timedelta(days=i)
            data = await self._load_data(day.isoformat())

            day_name = day.strftime("%a %d.%m")
            if day == date.today():
                day_name = "Heute"
            elif day == date.today() - timedelta(days=1):
                day_name = "Gestern"

            if data.get("habits"):
                completed = sum(1 for h in data["habits"] if h["completed"])
                total = len(data["habits"])
                if completed == total:
                    status = "🟢"
                elif completed > 0:
                    status = "🟡"
                else:
                    status = "🔴"
                result += f"{status} {day_name}: {completed}/{total}\n"
            else:
                result += f"⚪ {day_name}: Keine Daten\n"

        return result

    async def _check_habit(self, habit_name: str) -> str:
        """Check a specific habit"""
        if not habit_name:
            return "Bitte gib einen Habit-Namen an."

        data = await self._load_data()

        if not data.get("habits"):
            return "Keine Habit-Daten für heute gefunden."

        # Find habit (case-insensitive)
        habit = None
        for h in data["habits"]:
            if h["name"].lower() == habit_name.lower():
                habit = h
                break

        if not habit:
            available = ", ".join(h["name"] for h in data["habits"])
            return f"Habit '{habit_name}' nicht gefunden. Verfügbare Habits: {available}"

        if habit["completed"]:
            return f"✅ Ja, '{habit['name']}' wurde heute erledigt ({habit['count']}/{habit['goal']})."
        else:
            return f"❌ Nein, '{habit['name']}' wurde heute noch nicht erledigt ({habit['count']}/{habit['goal']})."

    async def _get_summary(self) -> str:
        """Get natural language summary"""
        data = await self._load_data()

        if not data.get("habits"):
            return "Ich habe keine Habit-Daten für heute. Hast du die App schon geöffnet?"

        habits = data["habits"]
        completed = [h for h in habits if h["completed"]]
        pending = [h for h in habits if not h["completed"]]

        if len(completed) == len(habits):
            return f"🎉 Alle {len(habits)} Habits für heute erledigt! Gut gemacht."

        if len(completed) == 0:
            habit_list = ", ".join(h["name"] for h in pending)
            return f"Du hast heute noch keine Habits erledigt. Offen: {habit_list}"

        completed_list = ", ".join(h["name"] for h in completed)
        pending_list = ", ".join(h["name"] for h in pending)

        return f"Du hast {len(completed)} von {len(habits)} Habits erledigt.\n✅ Erledigt: {completed_list}\n❌ Offen: {pending_list}"


# Utility function for syncing data from iOS
def save_habit_data(habits: list[dict], date_str: Optional[str] = None):
    """Save habit data (called by sync endpoint)"""
    if date_str is None:
        date_str = date.today().isoformat()

    DATA_DIR.mkdir(parents=True, exist_ok=True)
    data_file = DATA_DIR / f"{date_str}.json"

    data = {
        "date": date_str,
        "habits": habits,
        "last_updated": datetime.now().isoformat()
    }

    with open(data_file, "w") as f:
        json.dump(data, f, indent=2)
