# Habit Timer

Eine iOS App für progressives Habit-Tracking mit Timer-Funktion und MCP-Server Integration.

## Features

- **Progressive Timer**: Timer-Dauer erhöht sich bei jeder Session um einstellbaren Wert (1-60s)
- **Habit Tracking**: Tägliche Habits mit Fortschrittsanzeige
- **Wochenübersicht**: Sehe deinen Fortschritt der letzten 7 Tage
- **MCP Integration**: Frage Claude ob du heute deine Habits erledigt hast

## Projekt-Struktur

```
Timer/
├── iOS/                    # iOS App (SwiftUI + SwiftData)
│   └── Timer/
│       ├── Models/         # Datenmodelle
│       ├── Views/          # UI Komponenten
│       ├── ViewModels/     # Business Logic
│       └── Services/       # Sync, Haptics, etc.
└── Server/                 # MCP Server (Python)
    ├── main.py             # MCP Server Entry Point
    ├── sync_server.py      # HTTP Sync API
    ├── mcp_modules/        # Erweiterbare MCP Module
    └── docker-compose.yml  # Docker Deployment
```

## iOS App Setup

### 1. Xcode Projekt erstellen

1. Öffne Xcode → File → New → Project
2. Wähle "App" (iOS)
3. Projektname: `Timer`
4. Interface: SwiftUI
5. Storage: SwiftData
6. ✅ Include Tests

### 2. Dateien hinzufügen

Kopiere alle Dateien aus `iOS/Timer/` in dein Xcode Projekt:
- Drag & Drop in den Project Navigator
- "Copy items if needed" aktivieren
- "Create folder references" wählen

### 3. Capabilities aktivieren

1. Wähle das Target in Xcode
2. Signing & Capabilities → + Capability
3. Füge hinzu:
   - **Background Modes** → Audio (für Timer im Hintergrund)
   - **Push Notifications**
   - **iCloud** → CloudKit (optional, für Backup)

### 4. Bundle ID anpassen

In `TimerApp.swift` und `CloudKitService.swift`:
```swift
// Ändere zu deiner Bundle ID
cloudKitDatabase: .private("iCloud.com.DEINNAME.HabitTimer")
```

### 5. Sync Service konfigurieren

In `SyncService.swift`:
```swift
private let syncURL: URL? = URL(string: "https://deine-domain.com/sync")
private let apiKey: String = "dein-api-key"
```

### 6. Build & Run

- Verbinde dein iPhone
- Wähle dein Device als Target
- ⌘R zum Starten

## VPS Server Setup

### 1. Dateien auf VPS kopieren

```bash
scp -r Server/* user@dein-vps:/tmp/habit-timer/
```

### 2. Setup Script ausführen

```bash
ssh user@dein-vps
cd /tmp/habit-timer
sudo bash setup.sh
```

Das Script:
- Erstellt `/opt/habit-timer`
- Generiert einen API Key
- Startet Docker Container

### 3. Nginx konfigurieren

```bash
# SSL Zertifikat erstellen
sudo certbot certonly --nginx -d habits.deine-domain.com

# Config kopieren
sudo cp nginx.conf.example /etc/nginx/sites-available/habits
sudo ln -s /etc/nginx/sites-available/habits /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### 4. API Key notieren

Nach dem Setup wird ein API Key generiert. Notiere ihn für die iOS App!

```bash
cat /opt/habit-timer/.env
```

## MCP Integration

### Claude Desktop konfigurieren

Füge zu `~/.config/claude/claude_desktop_config.json` hinzu:

```json
{
  "mcpServers": {
    "habit-timer": {
      "command": "ssh",
      "args": [
        "user@dein-vps",
        "docker", "exec", "-i", "habit-sync", "python", "main.py"
      ]
    }
  }
}
```

### Verfügbare MCP Tools

| Tool | Beschreibung |
|------|--------------|
| `habits_today` | Alle Habits mit Status für heute |
| `habits_week` | Wochenübersicht |
| `habits_check` | Prüfe ob ein bestimmter Habit erledigt ist |
| `habits_summary` | Zusammenfassung in natürlicher Sprache |

### Beispiel-Prompts

- "Habe ich heute schon Sport gemacht?"
- "Wie sieht meine Habit-Woche aus?"
- "Welche Habits fehlen mir noch heute?"

## Eigene MCP Module hinzufügen

1. Erstelle neue Datei in `Server/mcp_modules/`:

```python
# mcp_modules/my_module.py
from mcp.types import Tool
from .base import MCPModule

class MyModule(MCPModule):
    TOOLS = ["my_tool"]

    def get_tools(self) -> list[Tool]:
        return [
            Tool(
                name="my_tool",
                description="Beschreibung",
                inputSchema={"type": "object", "properties": {}}
            )
        ]

    def handles_tool(self, name: str) -> bool:
        return name in self.TOOLS

    async def call_tool(self, name: str, arguments: dict) -> str:
        return "Ergebnis"
```

2. Registriere in `main.py`:

```python
from mcp_modules.my_module import MyModule
register_module("my_module", MyModule())
```

## Updates deployen

### iOS App

```bash
# In Xcode
1. Version/Build Number erhöhen
2. Product → Archive
3. Distribute App → TestFlight
```

### Server

```bash
ssh user@dein-vps
cd /opt/habit-timer
git pull  # oder scp neue Dateien
docker compose up -d --build
```

## Troubleshooting

### Timer läuft nicht im Hintergrund
- Prüfe Background Modes Capability
- iOS beendet Apps nach ~30s - die App scheduled eine Local Notification

### Sync funktioniert nicht
- Prüfe API Key in iOS App und Server .env
- Prüfe Nginx Logs: `sudo tail -f /var/log/nginx/error.log`
- Prüfe Container Logs: `docker logs habit-sync`

### MCP Server antwortet nicht
- Prüfe SSH Verbindung zum VPS
- Prüfe ob Container läuft: `docker ps`
- Teste manuell: `docker exec -it habit-sync python main.py`
