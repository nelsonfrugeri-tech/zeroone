---
name: implement
description: |
  Complete software development methodology. Covers the full workflow
  QUESTION > RESEARCH > DESIGN > TEST > IMPLEMENT > VALIDATE > REVIEW,
  test-first (TDD/BDD/ATDD), bug fix workflow, refactoring patterns (strangler fig,
  branch by abstraction, parallel change, Mikado), feature decomposition (vertical slicing,
  walking skeleton), self-review checklist, Definition of Done, technical debt management,
  and CI discipline.
  Use when: (1) Planning how to approach a development task, (2) Defining test strategy,
  (3) Refactoring legacy systems, (4) Breaking large features into incremental deliveries,
  (5) Preparing code for review, (6) Managing technical debt.
  Triggers: /implement, development workflow, TDD, BDD, refactoring, vertical slice,
  walking skeleton, definition of done, technical debt, code review checklist.
type: capability
---

# Implement — Software Development Methodology

## Purpose

This skill is the knowledge base for systematic software development methodology.
It defines HOW to develop software — the process, discipline, and quality gates that
transform requirements into production-ready code.

**What this skill contains:**
- Complete development workflow (7 phases)
- Test-first methodology (TDD, BDD, ATDD)
- Bug fix workflow (systematic reproduction to prevention)
- Refactoring methodology (strangler fig, branch by abstraction, parallel change)
- Large feature decomposition (vertical slicing, walking skeleton)
- Code review self-check before submitting
- Definition of Done criteria
- Technical debt management (quadrant model)
- CI discipline (small commits, green builds, fast feedback)

**What this skill does NOT contain:**
- Language-specific patterns (those live in `python`, `typescript`)
- Test frameworks/tools (those live in `python`, `typescript`, `test`)
- Architecture patterns (those live in `design`)

---

## Philosophy

### Process is Discipline, Not Bureaucracy

Good methodology eliminates waste, reduces rework, and builds confidence.
Bad methodology adds ceremony without value. This skill targets the former.

### Principles

1. **Understand before building** — read existing code, contracts, dependencies, and edge cases
2. **Test before implementing** — define acceptance criteria first, write failing tests
3. **Deliver in thin vertical slices** — each slice is deployable, testable, and valuable
4. **Never deliver untested code** — "it compiles" is not a test
5. **Leave the codebase better than you found it** — Boy Scout Rule
6. **Small commits, green builds, fast feedback** — each commit is atomic and buildable

---

## 1. Development Workflow — 7 Phases

```
QUESTION > RESEARCH > DESIGN > TEST > IMPLEMENT > VALIDATE > REVIEW
```

Every task — feature, bug fix, refactor — follows these phases.
No phase can be skipped. The depth of each phase scales with task complexity.

### Phase 1: QUESTION

**Goal:** Ensure crystal-clear understanding of the task.

**Actions:**
- Read the issue/ticket/requirement completely
- Read related code, tests, and documentation
- Identify ambiguities and resolve them BEFORE coding
- Map dependencies (what does this affect?)
- Identify constraints (performance, compatibility, security)

**Exit criteria:**
- [ ] Can articulate the problem in one sentence
- [ ] Can describe the expected behavior (inputs -> outputs)
- [ ] Can list affected components/files
- [ ] All ambiguities resolved (asked the user if necessary)

**Anti-patterns:**
- Starting to code before understanding full scope
- Assuming requirements when unclear
- Ignoring edge cases discovered during questioning

---

### Phase 2: RESEARCH

**Goal:** Ground decisions in current knowledge, not assumptions.

**Actions:**
- Search for existing solutions in the codebase (was this solved before?)
- Research current best practices (libraries, patterns, approaches)
- Check if dependencies need updates
- Cross-reference multiple sources (docs, GitHub, blogs, benchmarks)
- **Dependency security check** (mandatory before any `pip install` / `pnpm add`):
  1. Search for latest stable version (never trust training data)
  2. Check CVEs: NVD, GitHub Advisories, Snyk
  3. Verify library is maintained (last release, issues, active maintainer)
  4. After installing: `pip-audit` / `npm audit`

**Exit criteria:**
- [ ] Aware of existing solutions in the codebase
- [ ] Aware of current best practices for this problem type
- [ ] Dependencies identified with pinned versions and **security verified**
- [ ] Trade-offs of different approaches understood

---

### Phase 3: DESIGN

**Goal:** Make design decisions explicit before writing code.

**Actions:**
- Define the API / public interface first
- Identify data model / schema changes
- Choose the pattern (and document WHY)
- Consider at least 2 approaches with trade-offs
- Document the chosen approach briefly

**Deliverables (scale to task size):**
- Trivial: mental model, no artifact needed
- Small: comment in code or issue
- Medium: brief design note (bullet points)
- Large: design document with diagrams

**Exit criteria:**
- [ ] Interfaces/contracts defined
- [ ] Pattern chosen with justification
- [ ] Edge cases identified
- [ ] Breaking changes identified (if any)

---

### Phase 4: TEST (Write Tests First)

**Goal:** Encode expected behavior as executable tests BEFORE implementing.

**Actions:**
- Write failing tests that capture acceptance criteria
- Include happy path, edge cases, and error cases
- Use test names that describe behavior, not implementation
- Set up fixtures and test data

**Test naming convention:**
```
test_<behavior>_when_<condition>_then_<expected>
```

**Examples:**
```python
def test_create_user_when_email_valid_then_returns_user():
    ...

def test_create_user_when_email_duplicate_then_raises_conflict():
    ...
```

**Exit criteria:**
- [ ] Tests written and failing (RED phase)
- [ ] Tests cover happy path
- [ ] Tests cover main edge cases
- [ ] Tests cover error/exception paths
- [ ] Test names describe behavior clearly

---

### Phase 5: IMPLEMENT

**Goal:** Write the minimum code to make tests pass, then refactor.

**The RED-GREEN-REFACTOR cycle:**
```
RED:      Write a failing test
GREEN:    Write the simplest code that passes
REFACTOR: Improve design while staying green
REPEAT
```

**Exit criteria:**
- [ ] All tests passing
- [ ] Code follows project style and patterns
- [ ] No unnecessary complexity
- [ ] Refactoring complete (clean code)

---

### Phase 6: VALIDATE

**Goal:** Prove the code works end-to-end, not just in unit tests.

**Actions:**
- Run the full test suite (unit + integration + e2e)
- Run linters and type checkers (`ruff`, `mypy`, `biome`)
- Test manually if applicable (curl endpoints, check UI)
- Verify in an environment as close to production as possible
- Check for regressions (did something else break?)

**Exit criteria:**
- [ ] All tests passing (unit, integration, e2e)
- [ ] Linters clean (zero warnings)
- [ ] Type checker clean
- [ ] Manual verification done (if applicable)
- [ ] No regressions introduced

---

### Phase 7: REVIEW (Self-Check)

**Goal:** Catch problems BEFORE submitting for review.

**Actions:**
- Run the self-check checklist (see Section 6)
- Review your own diff as if you were the reviewer
- Update documentation (CHANGELOG, README, API docs)
- Clean commits (atomic, well-described)
- Verify branch is up to date with base

**Exit criteria:**
- [ ] Self-check checklist passed
- [ ] Documentation updated
- [ ] Commits clean and atomic
- [ ] Branch rebased on base branch
- [ ] Ready for review

---

## 2. Test-First Methodology

### TDD (Test-Driven Development)

Developer-centered. Focus on correct implementation of individual units.

**Cycle:**
```
1. RED    — Write a failing test
2. GREEN  — Write the simplest code to pass
3. REFACTOR — Improve design, keep green
4. REPEAT
```

**When to use:**
- Business logic, algorithms, data transformations
- Pure functions, utility code
- Any code with clear inputs and outputs

**Key rules:**
- Never write production code without a failing test
- Write only enough code to pass the current test
- Refactor only when green
- Each test should test ONE behavior

---

### BDD (Behavior-Driven Development)

User-centered. Focus on system behavior from the user's perspective.
Uses natural language (Given-When-Then) to describe behavior.

**Format:**
```gherkin
Feature: User registration

  Scenario: Successful registration with valid email
    Given a new user with email "user@example.com"
    When they submit the registration form
    Then the account is created
    And a welcome email is sent

  Scenario: Registration fails with duplicate email
    Given an existing user with email "user@example.com"
    When a new user tries to register with "user@example.com"
    Then the registration is rejected with "Email already exists"
```

**When to use:**
- User-facing features
- Cross-functional communication (devs + product + QA)
- Acceptance criteria that need stakeholder validation
- API contract tests

---

### ATDD (Acceptance Test-Driven Development)

Combines TDD + BDD. Write acceptance tests first (BDD style), then implement using TDD.

```
1. Write acceptance test (BDD — Given/When/Then)
2. Run it — it fails (no implementation)
3. Use TDD to implement the internal components
4. Acceptance test passes — feature is done
```

**When to use:**
- Complex features with multiple components
- Features requiring stakeholder approval
- API endpoints (acceptance = API contract, TDD = internal logic)

---

## 3. Bug Fix Workflow

Every bug fix follows a systematic 6-step process.

```
REPRODUCE > ISOLATE > WRITE TEST > FIX > VALIDATE > PREVENT
```

### Step 1: REPRODUCE

- Create a reliable reproduction case
- Document exact steps, inputs, environment
- Confirm the bug exists (not user error or stale data)
- If you can't reproduce it, you can't fix it

### Step 2: ISOLATE

- Narrow down the affected code path
- Use binary search (comment code, bisect commits)
- Identify the root cause, not just the symptom
- `git bisect` for regression bugs

```bash
git bisect start
git bisect bad HEAD
git bisect good v1.2.0
# Git will binary search through commits
# Test each one, mark good/bad
git bisect good  # or git bisect bad
# When found:
git bisect reset
```

### Step 3: WRITE TEST (before fixing)

- Write a test that reproduces the bug
- The test MUST fail on current code
- This is your regression safety net
- Name clearly: `test_<what>_when_<condition>_does_not_<bug_behavior>`

### Step 4: FIX

- Fix the root cause, not the symptom
- Change the minimum amount of code
- Do not mix the fix with refactoring or features

### Step 5: VALIDATE

- Run the failing test — it must now pass
- Run the full test suite — no regressions
- Test manually if applicable
- Test the original reproduction case

### Step 6: PREVENT

- Add the regression test to CI
- Consider if the bug class needs a linter rule
- Document the root cause if not obvious
- Consider if similar bugs exist elsewhere

---

## 4. Refactoring Methodology

Refactoring changes code structure without changing behavior.
Always refactor with safety nets (tests). Never refactor without tests.

### When to Refactor

- During the REFACTOR step of TDD (every cycle)
- When adding a feature requires changing existing code
- When code smells make the area hard to understand
- When technical debt is budgeted in the sprint
- NEVER as a separate "refactoring sprint" (integrate into daily work)

### Patterns

#### 4.1 Strangler Fig Pattern

**When:** Replace a large legacy system/component incrementally.

```
1. IDENTIFY the component to replace
2. CREATE the new implementation alongside the old one
3. ROUTE traffic/calls gradually to the new implementation
4. MONITOR both implementations in parallel
5. REMOVE the old implementation once the new one is proven
```

**Benefits:** Zero big-bang risk, rollback always possible, production validation at each step

**Anti-patterns:** Trying to replace everything at once, leaving the old code forever

#### 4.2 Branch by Abstraction

**When:** Refactoring components deep in the stack with upstream dependencies.

```
1. IDENTIFY the component to refactor and its callers
2. CREATE an abstraction layer (interface/protocol) between callers and component
3. CHANGE all callers to use the abstraction
4. CREATE the new implementation behind the abstraction
5. SWITCH the abstraction to use the new implementation
6. REMOVE the old implementation
```

**Benefits:** All changes happen on trunk (no long-lived branches), callers decoupled

#### 4.3 Parallel Change (Expand-Migrate-Contract)

**When:** Changing an interface/API that has multiple consumers.

```
1. EXPAND  — Add the new interface alongside the old one
2. MIGRATE — Move consumers to the new interface one by one
3. CONTRACT — Remove the old interface once all consumers migrated
```

```python
# Phase 1: EXPAND
class UserService:
    def get_user(self, user_id: int) -> dict:          # old
        ...
    def get_user_by_uuid(self, uuid: str) -> User:     # new
        ...

# Phase 2: MIGRATE consumers

# Phase 3: CONTRACT
class UserService:
    def get_user_by_uuid(self, uuid: str) -> User:     # only new
        ...
```

#### 4.4 Mikado Method

**When:** Large refactoring with unknown dependencies.

```
1. SET a refactoring goal
2. TRY to implement it directly
3. If it breaks things, NOTE the prerequisite
4. REVERT your change
5. IMPLEMENT the prerequisite first
6. TRY the goal again
7. REPEAT until the goal succeeds
```

Produces a dependency graph (Mikado Graph) of required changes.

---

## 5. Feature Decomposition

### Vertical Slicing

**Central principle:** Each slice cuts through ALL layers (UI, API, business logic, data)
and delivers visible user value.

**Horizontal slice (WRONG):**
```
Sprint 1: Build database schema
Sprint 2: Build API endpoints
Sprint 3: Build frontend
Sprint 4: Integration testing
Sprint 5: Finally works end-to-end
```

**Vertical slice (RIGHT):**
```
Slice 1: User can create an account (simple form, one API, one table)
Slice 2: User can log in (auth flow end-to-end)
Slice 3: User can update profile (edit form, API, validation)
```

### Slicing Heuristics

| Technique | Description | Example |
|-----------|-------------|---------|
| **By workflow step** | Each step in a process becomes a slice | Checkout: add to cart, enter address, pay |
| **By business rule** | Each rule becomes a slice | Pricing: base price, bulk discount, loyalty |
| **By data variation** | Each data type becomes a slice | Import: CSV first, then Excel, then API |
| **By operation** | CRUD operations as separate slices | Users: create first, then read, update, delete |
| **By persona** | Different user types as slices | Admin dashboard, then user dashboard |

### Walking Skeleton

**Definition:** The thinnest possible slice of real functionality that can be built,
deployed, and tested end-to-end.

**Characteristics:**
- Cuts through ALL layers (UI to database)
- Deployable to production (even with feature flag)
- Has automated tests
- Has CI/CD configured
- Takes at most 1-4 days

**Example — e-commerce walking skeleton:**
```
UI:       Single page with a "Buy" button and a product name
API:      POST /orders with hardcoded product
Business: Create order with fixed price
Database: orders table with id, product, status
Deploy:   Docker + CI + staging environment
Test:     E2E test: click Buy -> order created
```

Then increment: add product catalog, cart, payment, etc.

### Feature Decomposition Template

```markdown
## Feature: {name}

### Walking Skeleton (Slice 0)
- {thinnest end-to-end path}
- Target: {1-4 days}

### Slice 1: {name}
- User story: As a {persona}, I want {action}, so that {value}
- Acceptance criteria: Given {context}, When {action}, Then {result}
- Estimated: {days}

### Slice 2: {name}
...

### Out of scope (explicit)
- {what we are NOT building}
```

---

## 6. Self-Check Before Review

Run this checklist BEFORE submitting code for review.

### Correctness
- [ ] Code does what the ticket/issue asks
- [ ] All acceptance criteria met
- [ ] Edge cases handled
- [ ] Error cases handled with appropriate messages
- [ ] No off-by-one errors
- [ ] No null/undefined access without guards

### Tests
- [ ] All new code has tests
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Tests cover happy path, edge cases, error cases
- [ ] Test names describe behavior
- [ ] All tests pass locally
- [ ] No flaky tests introduced

### Code Quality
- [ ] No `TODO` or `FIXME` without a linked issue
- [ ] No commented-out code
- [ ] No debug print/log statements left
- [ ] Variable/function names are descriptive
- [ ] Functions are small and focused (single responsibility)
- [ ] No code duplication
- [ ] Full type hints (Python) or strict types (TypeScript)

### Security
- [ ] No secrets or credentials in code
- [ ] User input validated and sanitized
- [ ] SQL injection prevented (parameterized queries)
- [ ] No sensitive data in logs
- [ ] Authentication/authorization checks implemented

### Performance
- [ ] No N+1 queries
- [ ] No unnecessary API calls in loops
- [ ] Resources properly managed (connections, files, locks)
- [ ] Appropriate caching considered

### Documentation
- [ ] CHANGELOG.md updated
- [ ] README.md updated (if user-facing changes)
- [ ] API documentation updated (if endpoints changed)
- [ ] Comments in code for non-obvious logic
- [ ] Docstrings on public functions/classes

### Git Hygiene
- [ ] Commits are atomic and well-described
- [ ] No merge commits (rebased on base branch)
- [ ] No unrelated changes mixed in
- [ ] Branch name follows convention

---

## 7. Definition of Done

A piece of work is DONE when ALL of these are true:

### Code
- [ ] Implementation complete and matches acceptance criteria
- [ ] Code follows project style and conventions
- [ ] No TODOs that weren't in the original scope
- [ ] All linters pass (ruff, mypy, biome — zero warnings)

### Tests
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing (if applicable)
- [ ] E2E tests written and passing (if applicable)
- [ ] Test coverage meets project threshold
- [ ] No flaky tests

### Review
- [ ] Self-check checklist passed
- [ ] Code reviewed by at least one other person
- [ ] All review comments resolved or explicitly deferred with rationale
- [ ] Reviewer approved (no BLOCKERs remaining)

### Integration
- [ ] All CI checks passing
- [ ] No merge conflicts
- [ ] Branch up to date with base branch
- [ ] Successfully merged to base branch

### Documentation
- [ ] CHANGELOG.md updated
- [ ] README.md updated if user-facing features changed
- [ ] API documentation updated if contracts changed

### Deployment
- [ ] Successfully deployed to staging
- [ ] Smoke tests passing in staging
- [ ] No monitoring alerts triggered after deployment
- [ ] Rollback plan known

---

## 8. Technical Debt Management

### The Quadrant Model

```
              RECKLESS                    PRUDENT
DELIBERATE    "We don't have time         "We must ship now, but know
              for design"                  the trade-offs"

INADVERTENT   "What's layering?"          "Now we know how we should
                                           have done it"
```

**Reckless + deliberate:** Never acceptable. This is cutting corners knowingly.
**Prudent + deliberate:** Acceptable with explicit decision and scheduled payback.
**Inadvertent:** Discovered through code review and retrospectives — refactor when found.

### Managing Debt

1. **Make it visible** — log debt items in your issue tracker
2. **Classify it** — Reckless/Prudent, Deliberate/Inadvertent
3. **Budget for it** — reserve 20% of each sprint for tech debt
4. **Pay it incrementally** — Boy Scout Rule: leave code better than you found it
5. **Never let it accumulate silently** — discuss debt in retrospectives

---

## 9. CI Discipline

### Small Commits

- Each commit is atomic, focused, and buildable
- CI must pass on every commit — no exceptions
- Broken builds are the team's top priority

### Commit Message Format

```
<type>(<scope>): <description>

<body> (optional)

<footer> (optional)
```

**Types:** feat, fix, refactor, test, docs, chore, perf

**Examples:**
```
feat(auth): add JWT refresh token rotation
fix(orders): prevent N+1 query on order list
refactor(users): extract user validation to service layer
test(payments): add integration tests for webhook handling
```

### Branch Strategy

- Feature branches: `feat/issue-{N}-{description}`
- Bug fixes: `fix/issue-{N}-{description}`
- Refactoring: `refactor/{description}`
- Never commit directly to `main` or `develop`

---

## Reference Files

- [references/tdd.md](references/tdd.md) — TDD cycles, examples, AI-assisted TDD
- [references/bdd.md](references/bdd.md) — BDD format, Gherkin examples, tools
- [references/bug-fix.md](references/bug-fix.md) — Bug fix workflow detail, git bisect guide
- [references/refactoring.md](references/refactoring.md) — Refactoring patterns with examples
- [references/vertical-slicing.md](references/vertical-slicing.md) — Slicing techniques, examples
- [references/self-check.md](references/self-check.md) — Extended self-check checklist
