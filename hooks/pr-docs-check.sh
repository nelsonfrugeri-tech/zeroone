#!/usr/bin/env bash
# Hook: PreToolUse on Bash
# Checks if CHANGELOG.md and README.md were updated before allowing PR creation.
# Returns JSON to block the PR if docs are missing from the diff.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only check PR creation commands
if ! echo "$COMMAND" | grep -qE '(gh pr create|/repos/.*/pulls)'; then
  exit 0
fi

# Get the base branch (usually main)
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Get files changed in this branch vs base
CHANGED=$(git diff --name-only "$BASE"...HEAD 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "")

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
if ls ./*.postman_collection.json ./*.insomnia.json docs/*.postman_collection.json docs/*.insomnia.json 2>/dev/null | head -1 > /dev/null 2>&1; then
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
  exit 0
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
