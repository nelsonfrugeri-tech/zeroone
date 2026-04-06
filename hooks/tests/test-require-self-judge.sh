#!/usr/bin/env bash
# Tests for require-self-judge.sh.
# Validates trigger logic (MCP vs Bash) and allow/deny behavior based on
# self-judge.md presence and content length.

set -euo pipefail

HOOK="$HOME/.claude/hooks/require-self-judge.sh"
PASS=0
FAIL=0

# Temporary directory used as a fake repo root
TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

# Initialize a minimal git repo
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

MCP_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "mcp__github__github_create_pr", cwd: $cwd}')
BASH_PR_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh pr create --title foo"}}')
BASH_ISSUE_INPUT=$(jq -n --arg cwd "$TMPDIR_ROOT" '{tool_name: "Bash", cwd: $cwd, tool_input: {command: "gh issue create --title foo"}}')

# No self-judge.md → deny
check "MCP tool without self-judge.md → deny" "$MCP_INPUT" "deny"
check "Bash gh pr create without self-judge.md → deny" "$BASH_PR_INPUT" "deny"

# Non-PR Bash tool → not triggered
check "Bash gh issue create → not triggered (exit0)" "$BASH_ISSUE_INPUT" "exit0"

# Empty self-judge.md (0 bytes) → deny
touch "$TMPDIR_ROOT/self-judge.md"
check "MCP tool with empty self-judge.md → deny" "$MCP_INPUT" "deny"
check "Bash gh pr create with empty self-judge.md → deny" "$BASH_PR_INPUT" "deny"

# Short self-judge.md (< 50 bytes) → deny
echo "# Self-Judge" > "$TMPDIR_ROOT/self-judge.md"
check "MCP tool with short self-judge.md (< 50 bytes) → deny" "$MCP_INPUT" "deny"

# Valid self-judge.md (>= 50 bytes) → allow
cat > "$TMPDIR_ROOT/self-judge.md" <<'EOF'
## Self-Judge

- [x] All tests pass
- [x] CHANGELOG updated
- [x] README updated
- [x] No debug code left
EOF
check "MCP tool with valid self-judge.md → allow" "$MCP_INPUT" "allow"
check "Bash gh pr create with valid self-judge.md → allow" "$BASH_PR_INPUT" "allow"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
