#!/usr/bin/env python3
"""
HTTP Sync Server for iOS App
Receives habit data from iOS app and stores it locally
"""

import os
from datetime import date
from typing import Optional

from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel
from dotenv import load_dotenv

from mcp_modules.habits import save_habit_data

load_dotenv()

app = FastAPI(title="Habit Timer Sync API")

# Simple API key auth
API_KEY = os.getenv("SYNC_API_KEY", "change-me-in-production")


class HabitStatus(BaseModel):
    name: str
    completed: bool
    count: int
    goal: int


class SyncRequest(BaseModel):
    date: Optional[str] = None  # ISO format, defaults to today
    habits: list[HabitStatus]


def verify_api_key(x_api_key: str = Header(...)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return True


@app.post("/sync")
async def sync_habits(request: SyncRequest, x_api_key: str = Header(...)):
    """Receive habit data from iOS app"""
    verify_api_key(x_api_key)

    habits = [h.model_dump() for h in request.habits]
    date_str = request.date or date.today().isoformat()

    save_habit_data(habits, date_str)

    return {"status": "ok", "date": date_str, "habits_count": len(habits)}


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
