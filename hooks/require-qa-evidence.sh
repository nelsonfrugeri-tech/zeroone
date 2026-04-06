#!/usr/bin/env bash
# Hook: PreToolUse on mcp__github__github_create_pr
# Blocks PR creation if no QA evidence file exists in the current branch.
# QA evidence: qa-report.md, test-results.*, qa-evidence.*, *.test-output.*

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Only check PR creation
if [ "$TOOL" != "mcp__github__github_create_pr" ]; then
  exit 0
fi

# Determine repo root
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
if [ -z "$CWD" ]; then
  CWD=$(pwd)
fi

ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
BASE=$(git -C "$ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Files changed vs base branch
CHANGED=$(git -C "$ROOT" diff --name-only "$BASE"...HEAD 2>/dev/null || git -C "$ROOT" diff --name-only HEAD~1 2>/dev/null || echo "")

# Check for QA evidence in changed files or in repo root
QA_IN_DIFF=$(echo "$CHANGED" | grep -iE '(qa-report|test-results|qa-evidence|\.test-output)' || true)

# Also check if a QA evidence file exists anywhere under ROOT
QA_ON_DISK=$(find "$ROOT" -maxdepth 3 \
  -name "qa-report.md" -o \
  -name "qa-report.txt" -o \
  -name "test-results.*" -o \
  -name "qa-evidence.*" -o \
  -name "*.test-output.*" 2>/dev/null | head -1)

if [ -n "$QA_IN_DIFF" ] || [ -n "$QA_ON_DISK" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "QA evidence found — PR creation allowed."
  }
}
EOF
  exit 0
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "PR blocked: no QA evidence found. Create qa-report.md or test-results.* before opening a PR.",
    "additionalContext": "Required: at least one of qa-report.md, test-results.*, qa-evidence.*, or *.test-output.* must exist in the repo or in this branch's diff."
  }
}
EOF
exit 2
