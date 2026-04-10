#!/usr/bin/env bash
# zeroone sync — deploy agents and skills from repo to ~/.claude/
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

# Sync agents
echo "Syncing agents..."
cp "$ZEROONE_HOME"/agents/*.md "$CLAUDE_HOME/agents/"
echo "  $(ls "$ZEROONE_HOME"/agents/*.md | wc -l | tr -d ' ') agents deployed"

# Sync skills
echo "Syncing skills..."
rsync -a --delete "$ZEROONE_HOME/skills/" "$CLAUDE_HOME/skills/"
echo "  $(ls -d "$ZEROONE_HOME"/skills/*/ | wc -l | tr -d ' ') skills deployed"

echo ""
echo "Sync complete. Running status..."
echo ""
bash "$(dirname "$0")/status.sh"
