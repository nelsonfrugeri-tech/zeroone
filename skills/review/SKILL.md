---
name: review
description: |
  Language-agnostic code review methodology. Covers severity taxonomy (BLOCKER/MAJOR/MINOR/NIT),
  comment templates, review checklist (security, performance, testing, code quality, architecture),
  decision criteria (approve, approve with caveats, block), and review process workflow.
  Use when: (1) Reviewing any PR regardless of language, (2) Classifying issue severity,
  (3) Writing structured review comments, (4) Making merge/block decisions.
  Triggers: /review, code review, PR review, security review, quality gate.
type: capability
---

# Review — Code Review Methodology

## Purpose

This skill is the knowledge base for systematic code review. It is **language-agnostic** — the
methodology, severity taxonomy, comment templates, and decision criteria apply to any language.
Language-specific checklists (Python, TypeScript) are in the references.

**What this skill contains:**
- Severity taxonomy (BLOCKER, MAJOR, MINOR, NIT)
- Review checklist (universal categories)
- Comment templates (structured feedback format)
- Decision criteria (approve, approve with caveats, block)
- Review process workflow

---

## Philosophy

### Review is a Quality Gate, Not a Gatekeeping Exercise

The goal of review is better software. Every comment must be:
- **Actionable** — specific finding with file:line reference, not vague complaints
- **Constructive** — propose an alternative when you identify a problem
- **Classified** — every finding carries a severity so priority is clear
- **Independent** — the reviewer must not be the author of the code

### Principles

1. **Read before judging** — read the full diff and all touched files before forming any opinion
2. **Classify every finding** — BLOCKER, MAJOR, MINOR, or NIT — no ambiguity
3. **Summarize the verdict** — total BLOCKERs/MAJORs/MINORs, final recommendation
4. **Never modify code** — reviewers describe, authors fix
5. **No blockers = approved** — explicitly state "No blockers found — approved" when clean

---

## 1. Severity Taxonomy

### BLOCKER

**When to use:**
- Security vulnerabilities (injection, XSS, secrets hardcoded, auth bypass)
- Data loss potential (unhandled errors on write paths, missing transactions)
- Correctness bugs (logic errors that produce wrong results in critical paths)
- Breaking API changes without versioning

**Effect:** Merge must be blocked until resolved. Requires immediate correction.

**Template:**
```markdown
[BLOCKER] {Short description}

**File:** {path}:{line}
**Issue:** {clear description of the problem in 1-2 sentences}

**Current code:**
```{lang}
{problematic code}
```

**Suggested fix:**
```{lang}
{corrected code}
```

**Impact:** {what happens if this ships}
**Action:** Block merge. Must be corrected before any approval.
```

---

### MAJOR

**When to use:**
- Performance problems (N+1 queries in hot paths, O(n²) where O(n) is possible)
- Missing tests on critical code paths
- Memory leaks or resource leaks
- Error handling absent in operations that can fail
- Architecture violations that create significant coupling

**Effect:** Should be corrected before merge or immediately after. Creates significant technical debt.

**Template:**
```markdown
[MAJOR] {Short description}

**File:** {path}:{line}
**Issue:** {description}

**Current code:**
```{lang}
{problematic code}
```

**Suggested fix:**
```{lang}
{corrected code}
```

**Impact if unaddressed:** {production impact}
**Action:** Fix before merge (preferred) or create a ticket and fix immediately after.
```

---

### MINOR

**When to use:**
- Missing type annotations / type hints
- Non-descriptive naming
- Code quality issues (high cyclomatic complexity, code duplication, missing docstrings)
- Test assertions that are too weak
- Code style deviations

**Effect:** Does not block merge. Should be fixed in a follow-up. Affects maintainability.

**Template:**
```markdown
[MINOR] {Short description}

**File:** {path}:{line}
**Issue:** {description}
**Suggestion:** {what to do instead}
**Why:** {brief explanation of the benefit}
```

---

### NIT

**When to use:**
- Personal preference (when both approaches are correct)
- Trivial formatting inconsistencies not caught by linters
- Optional improvements

**Effect:** No action required. Nice to have.

**Template:**
```markdown
[NIT] {Short description} — {one-line suggestion}
```

---

## 2. Review Checklist

Apply to every changed file, regardless of language.

### Security
- [ ] No secrets or credentials hardcoded (API keys, passwords, tokens)
- [ ] External input is validated before use
- [ ] SQL/command/HTML injection is prevented
- [ ] Authentication and authorization enforced at every boundary
- [ ] Sensitive data not logged (PII, passwords, tokens)
- [ ] Cryptographic operations use approved algorithms and libraries
- [ ] Security headers set (for web endpoints)

**Typical severity:** BLOCKER

### Performance
- [ ] No N+1 query patterns (loops with DB calls inside)
- [ ] Efficient algorithms for the data scale (O(n²) is suspicious)
- [ ] Resources managed (connections, file handles closed after use)
- [ ] No unnecessary serialization/deserialization in hot paths
- [ ] Caching considered for expensive, repeated operations

**Typical severity:** MAJOR (hot paths) / MINOR (cold paths)

### Testing
- [ ] Critical code paths have tests
- [ ] Tests are not brittle (test behavior, not implementation)
- [ ] Assertions are specific (not just "it doesn't crash")
- [ ] Error paths are tested (not just happy path)
- [ ] Test names describe the behavior being tested

**Typical severity:** BLOCKER (no tests on critical code) / MAJOR (<50% coverage on critical path)

### Code Quality
- [ ] Types are explicit (type hints, TypeScript types — no implicit `any`)
- [ ] Error handling is explicit — no silent swallowing of exceptions
- [ ] Structured logging (not print/console.log)
- [ ] Public APIs have documentation/docstrings
- [ ] Naming is descriptive and self-documenting
- [ ] Single Responsibility — each function/class does one thing
- [ ] DRY — code is not duplicated
- [ ] Cyclomatic complexity is reasonable (< 10 per function)
- [ ] Imports organized and unused imports removed

**Typical severity:** MINOR / MAJOR (public APIs)

### Architecture
- [ ] Separation of concerns (business logic not mixed with I/O)
- [ ] Dependency injection (dependencies not created inline in business logic)
- [ ] No circular dependencies introduced
- [ ] Dependencies are pinned to exact versions
- [ ] Async/await used correctly (no blocking calls in async context)
- [ ] Configuration externalized (not hardcoded)

**Typical severity:** MINOR / MAJOR (serious violation)

### Frontend-Specific (TypeScript/React)
- [ ] No secrets or API keys in client-side code
- [ ] `dangerouslySetInnerHTML` is sanitized
- [ ] ARIA labels on interactive elements
- [ ] Semantic HTML (`nav`, `main`, `article`, `section`)
- [ ] Keyboard navigation functional
- [ ] Color contrast WCAG AA (4.5:1)
- [ ] Error Boundaries on critical routes
- [ ] No unnecessary `"use client"` directives
- [ ] Images optimized (next/image, lazy loading, WebP)

**References:** [references/checklist-python.md](references/checklist-python.md) | [references/checklist-typescript.md](references/checklist-typescript.md)

---

## 3. Decision Criteria

### BLOCK MERGE

**Condition:** 1 or more BLOCKER findings

**Template:**
```markdown
**Recommendation:** BLOCK MERGE

**Verdict:** Found {n} BLOCKER(s) that must be resolved before this PR can be merged.

**Blockers:**
- {blocker 1} — {file}:{line}
- {blocker 2} — {file}:{line}

**Summary:** {n} BLOCKER, {n} MAJOR, {n} MINOR, {n} NIT
```

---

### APPROVE WITH CAVEATS

**Condition:** 0 BLOCKERs, 1 or more MAJORs

**Template:**
```markdown
**Recommendation:** APPROVE WITH CAVEATS

**Verdict:** No blockers found. {n} MAJOR finding(s) must be resolved before production.

**Majors (fix before production):**
- {major 1} — {file}:{line}
- {major 2} — {file}:{line}

**Action:** Merge is acceptable, but create tickets for MAJOR findings and resolve before next release.

**Summary:** 0 BLOCKER, {n} MAJOR, {n} MINOR, {n} NIT
```

---

### APPROVE

**Condition:** 0 BLOCKERs, 0 MAJORs

**Template:**
```markdown
**Recommendation:** APPROVE

**Verdict:** No blocking issues found. MINOR findings and NITs can be addressed as continuous improvement.

**Minor findings (optional, follow-up):**
- {minor 1}

**Summary:** 0 BLOCKER, 0 MAJOR, {n} MINOR, {n} NIT
```

---

### APPROVE WITH PRAISE

**Condition:** Few or zero findings (only NIT), high-quality code

**Template:**
```markdown
**Recommendation:** APPROVE

**Verdict:** Excellent quality. Patterns applied consistently. Zero blocking issues.

**Highlights:**
- {highlight 1}
- {highlight 2}

**Summary:** 0 BLOCKER, 0 MAJOR, 0 MINOR, {n} NIT
```

---

## 4. Review Process Workflow

```
1. READ the issue/PR description — understand the intent before reading the code
2. READ the full diff — all changed files, not just the interesting ones
3. READ the context — files called by the changed code, tests, related files
4. APPLY the checklist — go through each category systematically
5. WRITE findings — use the comment templates, classify every finding
6. WRITE the summary — total counts, final recommendation, clear verdict
7. POST the review — all findings documented, no verbal-only feedback
```

### What to Check First

Priority order when time is limited:

1. **Security** — BLOCKERs live here most often
2. **Correctness** — logic bugs, data integrity
3. **Tests** — missing coverage on critical paths
4. **Architecture** — coupling, separation of concerns
5. **Performance** — N+1 queries, algorithm efficiency
6. **Code quality** — type hints, naming, documentation

### Never Do

- Review your own code — always use a different reviewer
- Give verbal feedback that's not documented — findings must be written
- Say "looks good" without checking security and tests
- Skip the summary — always state the total counts and final verdict

---

## Reference Files

- [references/checklist-python.md](references/checklist-python.md) — Python-specific review checklist (25 checks)
- [references/checklist-typescript.md](references/checklist-typescript.md) — TypeScript/React-specific review checklist (28 checks)
- [references/comment-templates.md](references/comment-templates.md) — Comment examples by issue type
