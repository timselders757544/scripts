#!/bin/bash

echo "=== COMPLETE CLAUDE CODE REINSTALLATION ==="
echo ""
echo "This will:"
echo "  1. Stop all Claude Code processes"
echo "  2. Remove ALL Claude Code files and configs"
echo "  3. Fresh install latest version"
echo "  4. Clean OAuth login"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "→ Step 1: Stopping Claude Code processes..."
pkill -9 -f claude
tmux kill-session -t claude-code 2>/dev/null || true
sleep 2
echo "✓ Processes stopped"

echo ""
echo "→ Step 2: Backing up current config..."
BACKUP_DIR="$HOME/claude-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

[ -f ~/.claude.json ] && cp ~/.claude.json "$BACKUP_DIR/"
[ -d ~/.claude ] && cp -r ~/.claude "$BACKUP_DIR/"
[ -d ~/.config/claude ] && cp -r ~/.config/claude "$BACKUP_DIR/"
[ -d ~/.config/claude-code ] && cp -r ~/.config/claude-code "$BACKUP_DIR/"

echo "✓ Backup created at: $BACKUP_DIR"

echo ""
echo "→ Step 3: Removing ALL Claude Code files..."

# Remove configs
rm -rf ~/.claude
rm -rf ~/.config/claude
rm -rf ~/.config/claude-code
rm -f ~/.claude.json

# Remove native installation
rm -rf ~/.local/share/claude-code
rm -f ~/.local/bin/claude

# Remove npm-global installation (if exists)
npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true

echo "✓ All files removed"

echo ""
echo "→ Step 4: Fresh installation (native)..."

# Download and install latest native version
curl -fsSL https://claude.ai/download/cli/install.sh | sh

echo ""
echo "→ Step 5: Verify installation..."
~/.local/bin/claude --version

echo ""
echo "=== INSTALLATION COMPLETE ==="
echo ""
echo "Next steps:"
echo "  1. Run: ~/.local/bin/claude login"
echo "  2. CRITICAL: During OAuth, if you see organization selector:"
echo "     - Choose: 'claude.pry675@passmail.net's Organization'"
echo "     - NOT: 'Tim's Individual Org'"
echo "  3. After login, check organization:"
echo "     cat ~/.claude.json | grep -A 5 oauthAccount"
echo "  4. Verify billing type is 'stripe_subscription'"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
