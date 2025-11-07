#!/bin/bash

# Unified Sync Script - Works on both MacBook and MacMini
# Syncs all repositories: pulls from remote, pushes local changes

# Detect which machine we're on and set the correct base path
if [[ -d "/Volumes/DevSSD/Development" ]]; then
    # MacMini - external SSD
    BASE_DIR="/Volumes/DevSSD/Development"
    MACHINE="MacMini"
elif [[ -d "$HOME/Development" ]]; then
    # MacBook - local disk
    BASE_DIR="$HOME/Development"
    MACHINE="MacBook"
else
    echo "❌ Development directory not found!"
    exit 1
fi

echo "🔄 Syncing all repositories on $MACHINE"
echo "📁 Base directory: $BASE_DIR"
echo ""

# List of all repositories to sync
REPOS=(
    "Buckminster"
    "Claude-Code"
    "Claude-Code-Cloud"
    "Memonic"
    "big-arms"
    "boezem-boys-app"
    "chief-of-staff"
    "design-system"
    "mcp-servers"
    "microdosing-frans"
)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

sync_repo() {
    local repo=$1
    local repo_path="$BASE_DIR/$repo"

    if [[ ! -d "$repo_path" ]]; then
        echo -e "${YELLOW}⚠️  $repo - NOT FOUND (skipping)${NC}"
        return
    fi

    echo -e "${BLUE}━━━ $repo ━━━${NC}"
    cd "$repo_path" || return

    # Check if it's a git repository
    if [[ ! -d ".git" ]]; then
        echo -e "${YELLOW}⚠️  Not a git repository${NC}"
        echo ""
        return
    fi

    # Fetch latest from remote
    echo "📥 Fetching..."
    git fetch --quiet

    # Check if there are uncommitted changes
    if [[ -n $(git status --porcelain) ]]; then
        echo -e "${YELLOW}⚠️  Uncommitted changes - skipping pull/push${NC}"
        git status --short
        echo ""
        return
    fi

    # Check if local is behind remote
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}⚠️  No upstream branch configured${NC}"
        echo ""
        return
    fi

    BASE=$(git merge-base @ @{u})

    if [[ $LOCAL = $REMOTE ]]; then
        echo -e "${GREEN}✅ Up to date${NC}"
    elif [[ $LOCAL = $BASE ]]; then
        echo "📥 Pulling changes..."
        git pull --quiet
        echo -e "${GREEN}✅ Pulled successfully${NC}"
    elif [[ $REMOTE = $BASE ]]; then
        echo "📤 Pushing changes..."
        git push --quiet
        echo -e "${GREEN}✅ Pushed successfully${NC}"
    else
        echo -e "${RED}⚠️  Diverged - manual intervention needed${NC}"
    fi

    echo ""
}

# Sync all repositories
for repo in "${REPOS[@]}"; do
    sync_repo "$repo"
done

echo -e "${GREEN}🎉 Sync complete!${NC}"
