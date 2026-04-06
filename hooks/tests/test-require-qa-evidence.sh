#!/usr/bin/env bash
# Tests for require-qa-evidence.sh.
# Validates trigger logic (MCP vs Bash) and allow/deny behavior based on
# QA evidence presence.

set -euo pipefail

HOOK="$HOME/.claude/hooks/require-qa-evidence.sh"
PASS=0
FAIL=0

# Temporary directory used as a fake repo root with a git stub
TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

# Initialize a minimal git repo so git commands work
git -C "$TMPDIR_ROOT" init -q
git -C "$TMPDIR_ROOT" commit --allow-empty -m "init" -q

check() {
  local desc="$1"
  local input_json="$2"
  local expect="$3"  # "allow", "deny", or "exit0"

  result=$(echo "$input_json" | bash "$HOOK" 2>/dev/null || true)
  if [ -z "$result" ]; then
    decision="exit0"
  else
    decision=$(echo "$result" | jq -r '.hookSpecificOutput.permissionDecision // "exit0"' 2>/dev/null || echo "exit0")
  fi

  if [ "$decision" = "$expect" ]; then
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc"
    echo "  expected: $expect, got: $decision"
    echo "  output  : $result"
    FAIL=$((FAIL + 1))
  fi
}

# MCP tool — triggers check (no QA evidence → deny)
MCP_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "mcp__github__github_create_pr", cwd: $cwd}')
check "MCP tool without QA evidence → deny" "$MCP_INPUT" "deny"

# Bash gh pr create — triggers check (no QA evidence → deny)
BASH_PR_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh pr create --title foo"}}')
check "Bash gh pr create without QA evidence → deny" "$BASH_PR_INPUT" "deny"

# Bash gh issue create — does NOT trigger (exit 0, no JSON output → "exit0")
BASH_ISSUE_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh issue create --title foo"}}')
check "Bash gh issue create → not triggered (exit0)" "$BASH_ISSUE_INPUT" "exit0"

# Bash with gh pr create mentioned in body prose — does NOT trigger
BASH_PROSE_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh issue create --body \"run gh pr create later\""}}')
check "gh issue create mentioning gh pr create in body → not triggered (exit0)" "$BASH_PROSE_INPUT" "exit0"

# Create a QA evidence file — now allow
touch "$TMPDIR_ROOT/qa-report.md"
echo "# QA Report" >> "$TMPDIR_ROOT/qa-report.md"

check "MCP tool with qa-report.md present → allow" "$MCP_INPUT" "allow"
check "Bash gh pr create with qa-report.md present → allow" "$BASH_PR_INPUT" "allow"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
