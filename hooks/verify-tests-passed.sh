#!/usr/bin/env bash
# Hook: Stop
# Blocks agent from stopping if no test evidence is found.
# Checks for test output files or recent test commands in git log.
# Supports: pytest, npm test, cargo test, go test, jest, mocha, rspec, phpunit

INPUT=$(cat)

# Determine repo root from cwd in input or fallback to pwd
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
if [ -z "$CWD" ]; then
  CWD=$(pwd)
fi

ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")

# 1. Check for test output files on disk
TEST_FILE=$(find "$ROOT" -maxdepth 4 \
  -name "pytest-*.xml" -o \
  -name "test-results.xml" -o \
  -name "test-results.json" -o \
  -name "coverage.xml" -o \
  -name "coverage.json" -o \
  -name "coverage.txt" -o \
  -name "junit*.xml" -o \
  -name "qa-report.md" -o \
  -name "test-output.txt" -o \
  -name "*.test-output.*" -o \
  -name "test_results.*" \
  2>/dev/null | head -1)

if [ -n "$TEST_FILE" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "allow",
    "additionalContext": "Test evidence found: $TEST_FILE"
  }
}
EOF
  exit 0
fi

# 2. Check recent git log for test commands (last 10 commits)
TEST_IN_LOG=$(git -C "$ROOT" log --oneline -20 --pretty=format:"%s %b" 2>/dev/null | \
  grep -iE '(pytest|npm test|cargo test|go test|jest|mocha|rspec|phpunit|test pass|tests pass|all tests|test suite)' | head -1 || true)

if [ -n "$TEST_IN_LOG" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "allow",
    "additionalContext": "Test evidence in git log: $TEST_IN_LOG"
  }
}
EOF
  exit 0
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Stop blocked: no test evidence found. Run tests (pytest, npm test, cargo test, go test, etc.) and ensure output is captured before stopping.",
    "additionalContext": "Create a test output file (e.g., qa-report.md, test-results.xml) or include test results in a commit message before the agent stops."
  }
}
EOF
exit 2
