#!/usr/bin/env bash
# Hook: PreToolUse on Bash AND mcp__github__github_create_pr
# Checks if CHANGELOG.md and README.md were updated before allowing PR creation.
# Returns JSON to block the PR if docs are missing from the diff.

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Determine if this is a PR creation event (MCP or Bash)
IS_PR_EVENT=0

if [ "$TOOL" = "mcp__github__github_create_pr" ]; then
  IS_PR_EVENT=1
elif [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
  if echo "$COMMAND" | grep -qE '^\s*gh\s+pr\s+create\b'; then
    IS_PR_EVENT=1
  fi
fi

if [ "$IS_PR_EVENT" -eq 0 ]; then
  exit 0
fi

# Determine repo root
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
if [ -z "$CWD" ]; then
  CWD=$(pwd)
fi

ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

# Get the base branch (usually main)
BASE=$(git -C "$ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Try to extract --head branch from the gh pr create command (Bash path only)
HEAD_BRANCH=""
if [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
  HEAD_BRANCH=$(echo "$COMMAND" | grep -oE '\-\-head\s+\S+' | awk '{print $2}' || true)
fi

# Get files changed in this branch vs base
if [ -n "$HEAD_BRANCH" ]; then
  git -C "$ROOT" fetch origin "$HEAD_BRANCH" 2>/dev/null || true
  CHANGED=$(git -C "$ROOT" diff --name-only "$BASE"..origin/"$HEAD_BRANCH" 2>/dev/null || git -C "$ROOT" diff --name-only HEAD~1 2>/dev/null || echo "")
else
  CHANGED=$(git -C "$ROOT" diff --name-only "$BASE"...HEAD 2>/dev/null || git -C "$ROOT" diff --name-only HEAD~1 2>/dev/null || echo "")
fi

MISSING=""

# Check CHANGELOG
if ! echo "$CHANGED" | grep -q "CHANGELOG.md"; then
  MISSING="${MISSING}CHANGELOG.md "
fi

# Check README (only warn, don't block — not every PR needs README changes)
README_WARNING=""
if ! echo "$CHANGED" | grep -q "README.md"; then
  README_WARNING="README.md was not updated — verify if changes affect documented features."
fi

# Check API collections if any exist and endpoints changed
API_WARNING=""
if ls "$ROOT"/*.postman_collection.json "$ROOT"/*.insomnia.json "$ROOT"/docs/*.postman_collection.json "$ROOT"/docs/*.insomnia.json 2>/dev/null | head -1 > /dev/null 2>&1; then
  if echo "$CHANGED" | grep -qE '\.(py|ts|js|go|rs)$'; then
    if ! echo "$CHANGED" | grep -qE '(postman|insomnia|bruno)'; then
      API_WARNING="API collection files exist but were not updated — verify if endpoints changed."
    fi
  fi
fi

# Block if CHANGELOG is missing
if [ -n "$MISSING" ]; then
  WARNINGS=""
  [ -n "$README_WARNING" ] && WARNINGS="$README_WARNING "
  [ -n "$API_WARNING" ] && WARNINGS="${WARNINGS}${API_WARNING}"

  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "PR blocked: ${MISSING}not updated in this branch. ${WARNINGS}Update these files before opening the PR.",
    "additionalContext": "MANDATORY: Update ${MISSING}before opening this PR. ${WARNINGS}This is enforced by the pr-docs-check hook."
  }
}
EOF
  exit 2
fi

# Warn about README and API collections (don't block)
if [ -n "$README_WARNING" ] || [ -n "$API_WARNING" ]; then
  CONTEXT="${README_WARNING} ${API_WARNING}"
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "PR docs reminder: ${CONTEXT}"
  }
}
EOF
  exit 0
fi

exit 0
