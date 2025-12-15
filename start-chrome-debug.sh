#!/bin/bash
# Start Chrome met remote debugging voor MCP server
# Gebruik: ./start-chrome-debug.sh

PORT=9222
PROFILE_DIR="/tmp/chrome-debug-profile"

# Check of Chrome al draait op deze port
if lsof -i :$PORT > /dev/null 2>&1; then
    echo "✓ Chrome draait al op port $PORT"
    echo "  Open http://127.0.0.1:$PORT om te verifiëren"
    exit 0
fi

echo "Starting Chrome met debugging op port $PORT..."

# Start Chrome met debugging
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --remote-debugging-port=$PORT \
    --user-data-dir="$PROFILE_DIR" \
    > /dev/null 2>&1 &

sleep 2

if lsof -i :$PORT > /dev/null 2>&1; then
    echo "✓ Chrome gestart met debugging"
    echo "  Port: $PORT"
    echo "  Profile: $PROFILE_DIR"
    echo ""
    echo "Let op: Dit is een tijdelijk profiel (geen bookmarks/wachtwoorden)"
    echo "Voor authenticated sites: log eerst in via deze Chrome instance"
else
    echo "✗ Chrome starten mislukt"
    exit 1
fi
