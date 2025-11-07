#!/bin/bash
# Git Status Reminder
# Check of er uncommitted/unpushed changes zijn en toon reminder

DEVELOPMENT_DIR="$HOME/Development"

# Lijst van repos
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

uncommitted_count=0
unpushed_count=0
uncommitted_repos=()
unpushed_repos=()

for repo in "${repos[@]}"; do
  repo_path="$DEVELOPMENT_DIR/$repo"

  if [ -d "$repo_path/.git" ]; then
    cd "$repo_path"

    # Check uncommitted changes
    if ! git diff-index --quiet HEAD 2>/dev/null; then
      uncommitted_count=$((uncommitted_count + 1))
      uncommitted_repos+=("$repo")
    fi

    # Check unpushed commits
    if [ -n "$(git log origin/main..HEAD 2>/dev/null)" ]; then
      unpushed_count=$((unpushed_count + 1))
      unpushed_repos+=("$repo")
    fi
  fi
done

# Toon reminder als er iets is
if [ $uncommitted_count -gt 0 ] || [ $unpushed_count -gt 0 ]; then
  echo ""
  echo "⚠️  Git Reminder:"

  if [ $uncommitted_count -gt 0 ]; then
    echo "   📝 Uncommitted changes in: ${uncommitted_repos[*]}"
  fi

  if [ $unpushed_count -gt 0 ]; then
    echo "   📤 Unpushed commits in: ${unpushed_repos[*]}"
  fi

  echo "   💡 Vergeet niet te committen en pushen!"
  echo ""
fi
