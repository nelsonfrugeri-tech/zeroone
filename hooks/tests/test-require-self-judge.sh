#!/usr/bin/env bash
# Tests for require-self-judge.sh.
# Validates trigger logic (MCP vs Bash) and allow/deny behavior based on
# self-judge.md being COMMITTED in the branch diff (not just on disk).

set -euo pipefail

HOOK="$HOME/.claude/hooks/require-self-judge.sh"
PASS=0
FAIL=0

# Temporary directory used as a fake repo
TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

# Initialize git repo with a main branch
git -C "$TMPDIR_ROOT" init -q -b main
git -C "$TMPDIR_ROOT" commit --allow-empty -m "init" -q
# Create a symbolic ref so the hook can find the base branch
git -C "$TMPDIR_ROOT" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main 2>/dev/null || true
git -C "$TMPDIR_ROOT" update-ref refs/remotes/origin/main HEAD

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

MCP_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "mcp__github__github_create_pr", cwd: $cwd}')
BASH_PR_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh pr create --title foo"}}')
BASH_ISSUE_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh issue create --title foo"}}')

# --- No self-judge.md at all → deny ---
check "MCP tool without self-judge.md → deny" "$MCP_INPUT" "deny"
check "Bash gh pr create without self-judge.md → deny" "$BASH_PR_INPUT" "deny"

# --- Non-PR Bash tool → not triggered ---
check "Bash gh issue create → not triggered (exit0)" "$BASH_ISSUE_INPUT" "exit0"

# --- self-judge.md on disk but NOT committed → deny ---
cat > "$TMPDIR_ROOT/self-judge.md" <<'CONTENT'
## Self-Judge
- [x] All tests pass
- [x] CHANGELOG updated
- [x] No debug code left
CONTENT
check "MCP tool with self-judge.md on disk but not committed → deny" "$MCP_INPUT" "deny"
check "Bash gh pr create with self-judge.md on disk but not committed → deny" "$BASH_PR_INPUT" "deny"

# --- Create a feature branch and commit empty self-judge.md → deny (< 50 bytes) ---
git -C "$TMPDIR_ROOT" checkout -q -b feat/test-sj
echo "# SJ" > "$TMPDIR_ROOT/self-judge.md"
git -C "$TMPDIR_ROOT" add self-judge.md
git -C "$TMPDIR_ROOT" commit -q -m "add empty self-judge"
check "MCP tool with short self-judge.md committed → deny" "$MCP_INPUT" "deny"

# --- Commit valid self-judge.md (>= 50 bytes) → allow ---
cat > "$TMPDIR_ROOT/self-judge.md" <<'CONTENT'
## Self-Judge

- [x] All tests pass
- [x] CHANGELOG updated
- [x] README updated
- [x] No debug code left
CONTENT
git -C "$TMPDIR_ROOT" add self-judge.md
git -C "$TMPDIR_ROOT" commit -q -m "fill self-judge checklist"
check "MCP tool with valid self-judge.md committed → allow" "$MCP_INPUT" "allow"
check "Bash gh pr create with valid self-judge.md committed → allow" "$BASH_PR_INPUT" "allow"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
