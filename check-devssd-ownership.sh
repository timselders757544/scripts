#!/bin/bash
# Check and fix DevSSD volume ownership
# Prevents "Server disconnected" errors in Claude Desktop

VOLUME="/Volumes/DevSSD"

if [ -d "$VOLUME" ]; then
  OWNERSHIP=$(diskutil info "$VOLUME" | grep "Owners:" | awk '{print $2}')

  if [ "$OWNERSHIP" = "Disabled" ]; then
    echo "⚠️  DevSSD ownership disabled - fixing..."
    sudo diskutil enableOwnership "$VOLUME"
    if [ $? -eq 0 ]; then
      echo "✅ Ownership enabled"
    else
      echo "❌ Failed to enable ownership (need sudo)"
    fi
  else
    echo "✅ DevSSD ownership OK"
  fi
else
  echo "ℹ️  DevSSD not mounted (dit is OK als je het niet gebruikt)"
fi
