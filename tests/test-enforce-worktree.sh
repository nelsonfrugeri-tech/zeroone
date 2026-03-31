#!/bin/bash
# Tests for hooks/enforce-worktree.sh
# Run: bash tests/test-enforce-worktree.sh
#
# Requires: git, jq

set -euo pipefail

HOOK="$(cd "$(dirname "$0")/.." && pwd)/hooks/enforce-worktree.sh"
TMPDIR_BASE=$(mktemp -d)
PASSED=0
FAILED=0

cleanup() {
  rm -rf "$TMPDIR_BASE"
}
trap cleanup EXIT

assert_exit() {
  local test_name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $test_name (exit $actual)"
    PASSED=$((PASSED + 1))
  else
    echo "  FAIL: $test_name (expected exit $expected, got $actual)"
    FAILED=$((FAILED + 1))
  fi
}

echo "=== enforce-worktree.sh tests ==="
echo ""

# --- Test 1: blocks in main repo (not a worktree) ---
echo "Test 1: blocks in main repo"
REPO="$TMPDIR_BASE/main-repo"
git init "$REPO" &>/dev/null
echo '{}' > "$REPO/dummy"
git -C "$REPO" add . && git -C "$REPO" commit -m "init" &>/dev/null

EXIT_CODE=0
echo "{\"cwd\": \"$REPO\"}" | bash "$HOOK" 2>/dev/null || EXIT_CODE=$?
assert_exit "main repo blocked" 2 "$EXIT_CODE"

# --- Test 2: allows in worktree ---
echo "Test 2: allows in worktree"
WORKTREE="$TMPDIR_BASE/my-worktree"
git -C "$REPO" worktree add "$WORKTREE" -b test-branch &>/dev/null

EXIT_CODE=0
echo "{\"cwd\": \"$WORKTREE\"}" | bash "$HOOK" 2>/dev/null || EXIT_CODE=$?
assert_exit "worktree allowed" 0 "$EXIT_CODE"

# --- Test 3: allows in non-git directory ---
echo "Test 3: allows in non-git directory"
NON_GIT="$TMPDIR_BASE/non-git"
mkdir -p "$NON_GIT"

EXIT_CODE=0
echo "{\"cwd\": \"$NON_GIT\"}" | bash "$HOOK" 2>/dev/null || EXIT_CODE=$?
assert_exit "non-git allowed" 0 "$EXIT_CODE"

# --- Test 4: allows when cwd is empty ---
echo "Test 4: allows when cwd is empty"
EXIT_CODE=0
echo '{}' | bash "$HOOK" 2>/dev/null || EXIT_CODE=$?
assert_exit "empty cwd allowed" 0 "$EXIT_CODE"

# --- Test 5: error message is actionable ---
echo "Test 5: error message contains restart command"
STDERR=$(echo "{\"cwd\": \"$REPO\"}" | bash "$HOOK" 2>&1 >/dev/null || true)
if echo "$STDERR" | grep -q "claude -w"; then
  echo "  PASS: error message contains 'claude -w'"
  PASSED=$((PASSED + 1))
else
  echo "  FAIL: error message missing 'claude -w'. Got: $STDERR"
  FAILED=$((FAILED + 1))
fi

# --- Summary ---
echo ""
echo "=== Results: $PASSED passed, $FAILED failed ==="
[ "$FAILED" -eq 0 ] && exit 0 || exit 1
