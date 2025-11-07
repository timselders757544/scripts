#!/bin/bash
# Git Auto-Pull Script
# Pullt automatisch alle git repos in Development folder

DEVELOPMENT_DIR="$HOME/Development"
LOG_FILE="$HOME/.git-auto-pull.log"

echo "=== Git Auto-Pull gestart: $(date) ===" >> "$LOG_FILE"

# Pull Development meta repo eerst
if [ -d "$DEVELOPMENT_DIR/.git" ]; then
  echo "📥 Pulling Development meta..." >> "$LOG_FILE"
  cd "$DEVELOPMENT_DIR"
  git pull --quiet >> "$LOG_FILE" 2>&1
  [ $? -eq 0 ] && echo "  ✅ Development meta gepulled" >> "$LOG_FILE"
fi

# Lijst van repos om te pullen
repos=(
  "big-arms"
  "boezem-boys-app"
  "buckminster"
  "chief-of-staff"
  "claude-code-cloud"
  "design-system"
  "mcp-servers-macbook"
  "mcp-servers-macmini"
  "memonic"
  "microdosing-frans"
)

for repo in "${repos[@]}"; do
  repo_path="$DEVELOPMENT_DIR/$repo"

  if [ -d "$repo_path/.git" ]; then
    echo "📥 Pulling $repo..." >> "$LOG_FILE"
    cd "$repo_path"

    # Check of er uncommitted changes zijn
    if ! git diff-index --quiet HEAD 2>/dev/null; then
      echo "  ⚠️  $repo heeft uncommitted changes - skip pull" >> "$LOG_FILE"
      continue
    fi

    # Pull changes
    git pull --quiet >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
      echo "  ✅ $repo gepulled" >> "$LOG_FILE"
    else
      echo "  ❌ $repo pull failed" >> "$LOG_FILE"
    fi
  else
    echo "  ⚠️  $repo is geen git repo" >> "$LOG_FILE"
  fi
done

echo "=== Git Auto-Pull voltooid: $(date) ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
