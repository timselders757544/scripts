#\!/bin/bash

# Start Claude Code in TMux sessie met automatische organization fix

SESSION_NAME="claude-code"
WORKING_DIR="/Volumes/DevSSD/Development"
CLAUDE_CONFIG="$HOME/.claude.json"
TMUX_BIN="/usr/local/bin/tmux"
NODE_BIN="/usr/local/bin/node"
CLAUDE_BIN="/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"

# Function to check and fix organization + subscription settings
check_and_fix_claude_config() {
    echo "→ Checking Claude Code configuration..."
    
    if [ ! -f "$CLAUDE_CONFIG" ]; then
        echo "✓ No config file yet (will be created on first run)"
        return 0
    fi
    
    # Run the fix
    python3 << 'PYTHON_EOF'
import json
import sys

CONFIG_PATH = "/Users/timselders/.claude.json"
SUBSCRIPTION_ORG = "24610c16-cc14-40f3-87b1-da9ea34f78cc"
PREPAID_ORG = "57d545fb-0b4b-4c2a-8f4c-c0725bcdc3f4"

with open(CONFIG_PATH, "r") as f:
    data = json.load(f)

fixed = []

# 1. Check organization
current_org = data.get("oauthAccount", {}).get("organizationUuid")
if current_org == PREPAID_ORG:
    data["oauthAccount"]["organizationUuid"] = SUBSCRIPTION_ORG
    data["oauthAccount"]["organizationBillingType"] = "stripe_subscription"
    data["oauthAccount"]["organizationName"] = "claude.pry675@passmail.net's Organization"
    fixed.append("organization (prepaid → subscription)")
elif current_org != SUBSCRIPTION_ORG:
    # Unknown org, set to subscription
    if "oauthAccount" in data:
        data["oauthAccount"]["organizationUuid"] = SUBSCRIPTION_ORG
        data["oauthAccount"]["organizationBillingType"] = "stripe_subscription"
        fixed.append("organization (unknown → subscription)")

# 2. Check hasAvailableSubscription
if data.get("hasAvailableSubscription") == False:
    data["hasAvailableSubscription"] = True
    fixed.append("hasAvailableSubscription (False → True)")

# 3. Remove API key from MCP if present
if "mcpServers" in data and "memonic" in data["mcpServers"]:
    if "env" in data["mcpServers"]["memonic"]:
        if "ANTHROPIC_API_KEY" in data["mcpServers"]["memonic"]["env"]:
            del data["mcpServers"]["memonic"]["env"]["ANTHROPIC_API_KEY"]
            fixed.append("removed API key from MCP")

# 4. Clear s1mAccessCache if wrong org was cached
if "s1mAccessCache" in data:
    if PREPAID_ORG in data["s1mAccessCache"]:
        del data["s1mAccessCache"][PREPAID_ORG]
        fixed.append("cleared prepaid org cache")

if fixed:
    with open(CONFIG_PATH, "w") as f:
        json.dump(data, f, indent=2)
    print("✓ Fixed: " + ", ".join(fixed))
else:
    print("✓ Configuration is correct")

PYTHON_EOF
}

# Run config check/fix BEFORE starting Claude Code
check_and_fix_claude_config

echo ""

# Check of tmux sessie al bestaat
if TMUX= "$TMUX_BIN" has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "✓ Claude Code sessie bestaat al"
    echo "→ Attaching naar sessie '$SESSION_NAME'..."
    TMUX= "$TMUX_BIN" attach -t "$SESSION_NAME"
else
    echo "→ Starting nieuwe Claude Code sessie..."
    cd "$WORKING_DIR" || exit 1
    TMUX= "$TMUX_BIN" new-session -s "$SESSION_NAME" -c "$WORKING_DIR" "$NODE_BIN $CLAUDE_BIN"
fi
