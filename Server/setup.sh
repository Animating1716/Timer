#!/bin/bash
#
# Setup script for Habit Timer MCP Server on VPS
# Run this on your Hetzner VPS
#

set -e

echo "🚀 Setting up Habit Timer MCP Server..."

# Configuration
INSTALL_DIR="/opt/habit-timer"
DATA_DIR="/data/habits"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo)"
    exit 1
fi

# Create directories
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DATA_DIR"

# Copy files (assumes this script is run from the Server directory)
echo "📋 Copying files..."
cp -r . "$INSTALL_DIR/"

# Create .env file if not exists
if [ ! -f "$INSTALL_DIR/.env" ]; then
    echo "🔐 Creating .env file..."
    API_KEY=$(openssl rand -hex 32)
    cat > "$INSTALL_DIR/.env" << EOF
SYNC_API_KEY=$API_KEY
HABIT_DATA_DIR=$DATA_DIR
EOF
    echo "Generated API key: $API_KEY"
    echo "⚠️  Save this API key! You'll need it in your iOS app."
fi

# Create network if not exists
echo "🌐 Setting up Docker network..."
docker network create proxy-network 2>/dev/null || true

# Build and start containers
echo "🐳 Building and starting Docker containers..."
cd "$INSTALL_DIR"
docker compose up -d --build

# Show status
echo ""
echo "✅ Setup complete!"
echo ""
echo "📊 Status:"
docker compose ps
echo ""
echo "🔗 Sync endpoint: http://YOUR_DOMAIN:8080/sync"
echo "🔗 Health check:  http://YOUR_DOMAIN:8080/health"
echo ""
echo "📝 Next steps:"
echo "1. Configure nginx reverse proxy (see nginx.conf.example)"
echo "2. Add API key to your iOS app"
echo "3. Configure Claude Desktop MCP (see claude_config.json)"
echo ""
echo "🔧 MCP Server usage:"
echo "   docker exec -it habit-sync python main.py"
