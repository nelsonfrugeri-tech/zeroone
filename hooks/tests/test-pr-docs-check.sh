#!/usr/bin/env bash
# Tests for pr-docs-check.sh
# Validates: regex matching, MCP path support, exit codes

set -euo pipefail

HOOK="$HOME/.claude/hooks/pr-docs-check.sh"
PASS=0
FAIL=0

# --- Part 1: Regex matching (unit) ---

check_match() {
  local desc="$1"
  local command="$2"
  local expect_match="$3"  # "yes" or "no"

  if echo "$command" | grep -qE '^\s*gh\s+pr\s+create\b'; then
    actual="yes"
  else
    actual="no"
  fi

  if [ "$actual" = "$expect_match" ]; then
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc"
    echo "  command : $command"
    echo "  expected: $expect_match, got: $actual"
    FAIL=$((FAIL + 1))
  fi
}

# Should MATCH — real gh pr create at command start
check_match "bare gh pr create"                       "gh pr create --title foo --body bar"    "yes"
check_match "gh pr create with leading spaces"        "  gh pr create --title foo"             "yes"

# Should NOT match — false positives and non-start positions
check_match "gh issue create mentioning gh pr create" "gh issue create --body 'see gh pr create for details'" "no"
check_match "echo gh pr create"                       "echo 'gh pr create'"                   "no"
check_match "python print gh pr create"               "python -c \"print('gh pr create')\""   "no"
check_match "comment in script"                       "# gh pr create"                        "no"
check_match "grep for gh pr create"                   "grep 'gh pr create' file.sh"           "no"
check_match "gh pr view (not create)"                 "gh pr view 42"                         "no"
check_match "gh pr list"                              "gh pr list"                             "no"
check_match "gh pr create after semicolon"            "git push; gh pr create --title foo"     "no"
check_match "gh pr create after pipe"                 "cat file | gh pr create"                "no"
check_match "gh pr create after &&"                   "git push && gh pr create --title foo"   "no"
check_match "curl repos pulls API"                    "curl -X POST https://api.github.com/repos/org/repo/pulls" "no"
check_match "gh api repos pulls"                      "gh api /repos/org/repo/pulls"           "no"

# --- Part 2: Integration (MCP path + exit codes) ---

TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

git -C "$TMPDIR_ROOT" init -q -b main
git -C "$TMPDIR_ROOT" commit --allow-empty -m "init" -q
git -C "$TMPDIR_ROOT" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main 2>/dev/null || true
git -C "$TMPDIR_ROOT" update-ref refs/remotes/origin/main HEAD

check_hook() {
  local desc="$1"
  local input_json="$2"
  local expect_decision="$3"  # "allow", "deny", or "exit0"
  local expect_exit="$4"      # expected exit code

  set +e
  result=$(echo "$input_json" | bash "$HOOK" 2>/dev/null)
  actual_exit=$?
  set -e

  if [ -z "$result" ]; then
    decision="exit0"
  else
    decision=$(echo "$result" | jq -r '.hookSpecificOutput.permissionDecision // "exit0"' 2>/dev/null || echo "exit0")
  fi

  if [ "$decision" = "$expect_decision" ] && [ "$actual_exit" -eq "$expect_exit" ]; then
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc"
    echo "  expected: decision=$expect_decision exit=$expect_exit, got: decision=$decision exit=$actual_exit"
    FAIL=$((FAIL + 1))
  fi
}

# MCP tool triggers check — no CHANGELOG → deny with exit 2
MCP_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "mcp__github__github_create_pr", cwd: $cwd, tool_input: {}}')
check_hook "MCP tool without CHANGELOG → deny exit 2" "$MCP_INPUT" "deny" 2

# Non-PR Bash → exit 0 (not triggered)
BASH_ISSUE=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh issue create --title foo"}}')
check_hook "Bash gh issue create → exit0" "$BASH_ISSUE" "exit0" 0

# Add CHANGELOG to branch → allow
git -C "$TMPDIR_ROOT" checkout -q -b feat/test-docs
echo "# Change" > "$TMPDIR_ROOT/CHANGELOG.md"
git -C "$TMPDIR_ROOT" add CHANGELOG.md
git -C "$TMPDIR_ROOT" commit -q -m "add changelog"

BASH_PR=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh pr create --title foo"}}')
MCP_INPUT2=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "mcp__github__github_create_pr", cwd: $cwd, tool_input: {}}')
check_hook "Bash gh pr create with CHANGELOG → allow exit 0" "$BASH_PR" "allow" 0
check_hook "MCP tool with CHANGELOG → allow exit 0" "$MCP_INPUT2" "allow" 0

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
