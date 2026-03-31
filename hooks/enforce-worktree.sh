#!/bin/bash
# Enforce worktree isolation — blocks sessions not running in a worktree.
# Deterministic: no prompt can bypass this.
#
# Known limitation: git submodules also use a .git file, so sessions inside
# submodules are allowed through. Use `git worktree list` for stricter checks.

if ! command -v jq &>/dev/null; then
  echo "WARNING: jq not found. enforce-worktree.sh requires jq to validate worktree." >&2
  exit 0
fi

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# If we can't read cwd, allow (don't break things)
if [ -z "$CWD" ]; then
  exit 0
fi

# Check if running inside a git worktree
if git -C "$CWD" rev-parse --is-inside-work-tree &>/dev/null; then
  TOPLEVEL=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)

  # A worktree has a .git FILE (not directory) pointing to the main repo
  if [ -f "$TOPLEVEL/.git" ]; then
    exit 0  # We're in a worktree — allow
  else
    # Main repo .git is a directory — NOT a worktree
    echo "BLOCKED: Session must run in a git worktree." >&2
    echo "Restart with: claude -w <name>" >&2
    echo "Example: claude -w fix-bug-123" >&2
    exit 2
  fi
fi

# Not a git repo at all — allow (might be a non-git directory)
exit 0
