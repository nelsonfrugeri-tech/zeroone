#!/usr/bin/env bash
# zeroone sync — deploy everything from repo to ~/.claude/
set -euo pipefail

ZEROONE_HOME="${ZEROONE_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
CLAUDE_HOME="$HOME/.claude"

# Check for uncommitted changes
if ! git -C "$ZEROONE_HOME" diff --quiet 2>/dev/null || \
   ! git -C "$ZEROONE_HOME" diff --cached --quiet 2>/dev/null; then
    echo "ERROR: uncommitted changes in zeroone repo. Commit or stash first."
    exit 1
fi

# Ensure target dirs exist
mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"

# --- Agents ---
echo "Syncing agents..."
cp "$ZEROONE_HOME"/agents/*.md "$CLAUDE_HOME/agents/"
echo "  $(ls "$ZEROONE_HOME"/agents/*.md | wc -l | tr -d ' ') agents deployed"

# --- Skills ---
echo "Syncing skills..."
rsync -a --delete "$ZEROONE_HOME/skills/" "$CLAUDE_HOME/skills/"
echo "  $(ls -d "$ZEROONE_HOME"/skills/*/ | wc -l | tr -d ' ') skills deployed"

# --- Settings ---
echo "Syncing settings..."
cp "$ZEROONE_HOME/config/settings.base.json" "$CLAUDE_HOME/settings.json"
echo "  settings.json deployed"

# --- Global CLAUDE.md ---
echo "Syncing CLAUDE.md..."
cp "$ZEROONE_HOME/config/CLAUDE.global.md" "$CLAUDE_HOME/CLAUDE.md"
echo "  CLAUDE.md deployed"

# --- MCP (project-level, absolute paths) ---
echo "Syncing .mcp.json..."
python3 -c "
import json

with open('$ZEROONE_HOME/.mcp.json.example') as f:
    config = json.load(f)

for name, server in config.get('mcpServers', {}).items():
    args = server.get('args', [])
    for i, arg in enumerate(args):
        if arg.startswith('mcp/') or arg.startswith('mcp-servers/'):
            args[i] = '$ZEROONE_HOME/' + arg

with open('$ZEROONE_HOME/.mcp.json', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"
echo "  .mcp.json deployed (absolute paths)"

echo ""
echo "Sync complete. Running status..."
echo ""
bash "$(dirname "$0")/status.sh"
