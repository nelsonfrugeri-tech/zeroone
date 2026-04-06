#!/usr/bin/env bash
# Hook: TaskCompleted
# Blocks task completion without deliverables.
# Checks: new commits on branch, open PR, test evidence.

INPUT=$(cat)

# Determine repo root
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
if [ -z "$CWD" ]; then
  CWD=$(pwd)
fi

ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

REASONS=""

# 1. Check for commits ahead of base branch
BASE=$(git -C "$ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
AHEAD=$(git -C "$ROOT" rev-list --count "${BASE}..HEAD" 2>/dev/null || echo "0")

if [ "$AHEAD" -eq 0 ]; then
  REASONS="${REASONS}no commits ahead of ${BASE}; "
fi

# 2. Check for test evidence on disk
TEST_FILE=$(find "$ROOT" -maxdepth 4 \
  -name "pytest-*.xml" -o \
  -name "test-results.xml" -o \
  -name "test-results.json" -o \
  -name "coverage.xml" -o \
  -name "coverage.json" -o \
  -name "junit*.xml" -o \
  -name "qa-report.md" -o \
  -name "test-output.txt" -o \
  -name "*.test-output.*" -o \
  -name "test_results.*" \
  2>/dev/null | head -1)

if [ -z "$TEST_FILE" ]; then
  REASONS="${REASONS}no test evidence file found; "
fi

if [ -z "$REASONS" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "TaskCompleted",
    "permissionDecision": "allow",
    "additionalContext": "Task completion validated: commits exist and test evidence found."
  }
}
EOF
  exit 0
fi

# Strip trailing "; "
REASONS=$(echo "$REASONS" | sed 's/; $//')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "TaskCompleted",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Task completion blocked: ${REASONS}.",
    "additionalContext": "To complete a task: (1) commit your changes, (2) ensure test evidence exists (qa-report.md, test-results.xml, etc.). All checks must pass before marking done."
  }
}
EOF
exit 2
