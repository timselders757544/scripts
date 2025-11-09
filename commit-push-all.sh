#!/bin/bash

# Commit and Push All Repositories
# Finds all git repositories in Development and commits + pushes any changes

# Detect machine and set base directory
if [[ -d "/Volumes/DevSSD/Development" ]]; then
    BASE_DIR="/Volumes/DevSSD/Development"
    MACHINE="MacMini"
elif [[ -d "$HOME/Development" ]]; then
    BASE_DIR="$HOME/Development"
    MACHINE="MacBook"
else
    echo "❌ Development directory not found!"
    exit 1
fi

echo "🚀 Commit & Push All Repositories on $MACHINE"
echo "📁 Base directory: $BASE_DIR"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counter for stats
TOTAL=0
COMMITTED=0
SKIPPED=0
ERRORS=0

commit_and_push_repo() {
    local repo_path=$1
    local repo_name=$(basename "$repo_path")

    TOTAL=$((TOTAL + 1))

    echo -e "${BLUE}━━━ $repo_name ━━━${NC}"
    cd "$repo_path" || return

    # Check if it's a git repository
    if [[ ! -d ".git" ]]; then
        echo -e "${YELLOW}⚠️  Not a git repository (skipping)${NC}"
        echo ""
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    # Get current branch
    BRANCH=$(git branch --show-current)
    echo "📍 Branch: $BRANCH"

    # Check for any changes (staged, unstaged, or untracked)
    if [[ -z $(git status --porcelain) ]]; then
        echo -e "${GREEN}✓ Already clean - nothing to commit${NC}"
        echo ""
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    # Show what will be committed
    echo "📝 Changes to commit:"
    git status --short
    echo ""

    # Stage all changes
    git add .

    # Generate commit message based on changes
    COMMIT_MSG="Update $repo_name

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    # Commit
    if git commit -m "$COMMIT_MSG" --quiet; then
        echo -e "${GREEN}✓ Committed${NC}"
    else
        echo -e "${RED}✗ Commit failed${NC}"
        echo ""
        ERRORS=$((ERRORS + 1))
        return
    fi

    # Push
    if git push --quiet 2>&1; then
        echo -e "${GREEN}✓ Pushed to remote${NC}"
        COMMITTED=$((COMMITTED + 1))
    else
        echo -e "${RED}✗ Push failed${NC}"
        ERRORS=$((ERRORS + 1))
    fi

    echo ""
}

# Find all git repositories (max depth 1 - only direct subdirectories)
echo "🔍 Scanning for git repositories..."
echo ""

# First handle the base Development directory itself if it's a git repo
if [[ -d "$BASE_DIR/.git" ]]; then
    commit_and_push_repo "$BASE_DIR"
fi

# Then handle all subdirectories that are git repos
for dir in "$BASE_DIR"/*/ ; do
    if [[ -d "$dir/.git" ]]; then
        commit_and_push_repo "$dir"
    fi
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📊 Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total repositories: $TOTAL"
echo -e "${GREEN}Committed & pushed: $COMMITTED${NC}"
echo -e "${YELLOW}Skipped (clean): $SKIPPED${NC}"
if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Errors: $ERRORS${NC}"
fi
echo ""

if [[ $COMMITTED -gt 0 ]]; then
    echo -e "${GREEN}🎉 All changes committed and pushed!${NC}"
else
    echo -e "${YELLOW}✓ All repositories were already in sync${NC}"
fi
