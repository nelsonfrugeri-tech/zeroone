#!/usr/bin/env bash
# Tests for pr-docs-check.sh regex matching logic.
# These tests validate that only actual gh pr create invocations are matched,
# and that false positives (prose, echo, embedded strings) are rejected.

set -euo pipefail

PASS=0
FAIL=0

check_match() {
  local desc="$1"
  local command="$2"
  local expect_match="$3"  # "yes" or "no"

  GH_PR_CREATE_RE='(^\s*gh\s+pr\s+create\b|[;|]\s*gh\s+pr\s+create\b|&&\s*gh\s+pr\s+create\b)'
  API_PULLS_RE='(^\s*(curl|gh\s+api)\b.*\/repos\/[^/]+\/[^/]+\/pulls\b)'

  if echo "$command" | grep -qE "$GH_PR_CREATE_RE" || \
     echo "$command" | grep -qE "$API_PULLS_RE"; then
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

# Should MATCH — real gh pr create invocations
check_match "bare gh pr create"                       "gh pr create --title foo --body bar"    "yes"
check_match "gh pr create with leading spaces"        "  gh pr create --title foo"             "yes"
check_match "gh pr create after semicolon"            "git push; gh pr create --title foo"     "yes"
check_match "gh pr create after pipe"                 "cat file | gh pr create"                "yes"
check_match "gh pr create after &&"                   "git push && gh pr create --title foo"   "yes"
check_match "curl repos pulls API"                    "curl -X POST https://api.github.com/repos/org/repo/pulls" "yes"
check_match "gh api repos pulls"                      "gh api /repos/org/repo/pulls"           "yes"

# Should NOT match — false positives
check_match "gh issue create mentioning gh pr create" "gh issue create --body 'see gh pr create for details'" "no"
check_match "echo gh pr create"                       "echo 'gh pr create'"                   "no"
check_match "python print gh pr create"               "python -c \"print('gh pr create')\""   "no"
check_match "comment in script"                       "# gh pr create"                        "no"
check_match "grep for gh pr create"                   "grep 'gh pr create' file.sh"           "no"
check_match "curl to non-pulls endpoint"              "curl https://api.github.com/repos/org/repo/issues" "no"
check_match "gh pr view (not create)"                 "gh pr view 42"                         "no"
check_match "gh pr list"                              "gh pr list"                             "no"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
