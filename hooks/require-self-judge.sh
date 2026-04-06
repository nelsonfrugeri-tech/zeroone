#!/usr/bin/env bash
# Hook: PreToolUse on mcp__github__github_create_pr AND Bash
# Blocks PR creation if self-judge.md does not exist in the repo root
# with non-empty content (at least 50 bytes).
# Agents must create self-judge.md with a filled self-review checklist before
# opening any PR.

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Determine if this event is a PR creation we should check.
IS_PR_EVENT=0

if [ "$TOOL" = "mcp__github__github_create_pr" ]; then
  IS_PR_EVENT=1
elif [ "$TOOL" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
  GH_PR_CREATE_RE='(^\s*gh\s+pr\s+create\b|[;|]\s*gh\s+pr\s+create\b|&&\s*gh\s+pr\s+create\b)'
  if echo "$COMMAND" | grep -qE "$GH_PR_CREATE_RE"; then
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
SELF_JUDGE="$ROOT/self-judge.md"

# Check file exists and is non-empty (at least 50 bytes)
if [ -f "$SELF_JUDGE" ] && [ "$(wc -c < "$SELF_JUDGE")" -ge 50 ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "self-judge.md found and non-empty — PR creation allowed."
  }
}
EOF
  exit 0
fi

# Determine failure reason
if [ ! -f "$SELF_JUDGE" ]; then
  REASON="self-judge.md not found in repo root ($ROOT)."
else
  REASON="self-judge.md exists but is empty or too short (< 50 bytes)."
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "PR blocked: $REASON",
    "additionalContext": "Create self-judge.md at the repo root with a filled self-review checklist (at least 50 bytes) before opening a PR. Example checklist: ## Self-Judge\n- [ ] All tests pass\n- [ ] CHANGELOG updated\n- [ ] README updated\n- [ ] No debug code left\n- [ ] Edge cases considered"
  }
}
EOF
exit 2
