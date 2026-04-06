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
BASE=$(git -C "$ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# self-judge.md must be COMMITTED in the branch diff, not just on disk.
# This prevents ad-hoc creation by Oracle or other non-dev agents.
CHANGED=$(git -C "$ROOT" diff --name-only "$BASE"...HEAD 2>/dev/null || git -C "$ROOT" diff --name-only HEAD~1 2>/dev/null || echo "")
SJ_IN_DIFF=$(echo "$CHANGED" | grep -E '^self-judge\.md$' || true)

if [ -z "$SJ_IN_DIFF" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "PR blocked: self-judge.md not found in branch diff. The dev agent must create and COMMIT self-judge.md during the SELF-JUDGE stage (after CODE, before QA).",
    "additionalContext": "self-judge.md must be committed in the branch — not created ad-hoc at PR time. Follow the dev-pipeline: CODE → SELF-JUDGE (create self-judge.md with filled checklist) → QA → OPEN PR. See skills/dev-pipeline/references/self-judge/checklist.md for the required format."
  }
}
EOF
  exit 2
fi

# Verify committed file has meaningful content (at least 50 bytes)
SELF_JUDGE="$ROOT/self-judge.md"
if [ ! -f "$SELF_JUDGE" ] || [ "$(wc -c < "$SELF_JUDGE")" -lt 50 ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "PR blocked: self-judge.md is committed but empty or too short (< 50 bytes). Fill the self-review checklist before opening a PR.",
    "additionalContext": "See skills/dev-pipeline/references/self-judge/checklist.md for the required format."
  }
}
EOF
  exit 2
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "self-judge.md found in branch diff and non-empty — PR creation allowed."
  }
}
EOF
exit 0
