---
name: dev-methodology
description: |
  Metodologia completa de desenvolvimento de software. Cobre o workflow completo
  QUESTIONAR > PESQUISAR > PROJETAR > TESTAR > IMPLEMENTAR > VALIDAR > REVISAR,
  test-first (TDD/BDD), workflow de bug fix, refactoring (strangler fig, branch by abstraction,
  parallel change), decomposicao de features (vertical slicing, walking skeleton), code review
  self-check, Definition of Done, gestao de debito tecnico, pair/mob programming, e disciplina CI.
  Use quando: (1) Planejar como atacar uma tarefa de desenvolvimento, (2) Definir estrategia de testes,
  (3) Refatorar sistemas legados, (4) Quebrar features grandes em entregas incrementais,
  (5) Preparar codigo para review, (6) Gerenciar debito tecnico.
  Triggers: /dev-methodology, development workflow, TDD, BDD, refactoring, vertical slice,
  walking skeleton, definition of done, technical debt, code review checklist.
---

# Dev-Methodology — Metodologia de Desenvolvimento

## Propósito

Esta skill é a **knowledge base** for systematic software development methodology.
It defines HOW to develop software — the process, discipline, and quality gates that
turn requirements into production-ready code.

**Who uses this skill:**

- Agent `dev-ts` -> development workflow and test discipline

- Agent `architect` -> feature breakdown and design methodology
- Any agent that writes code

**What this skill contains:**
- Full development workflow (7 phases)
- Test-first methodology (TDD, BDD, ATDD)
- Bug fix workflow (systematic reproduction to prevention)
- Refactoring methodology (strangler fig, branch by abstraction, parallel change)
- Large feature breakdown (vertical slicing, walking skeleton)
- Code review self-check before submitting
- Definition of Done criteria
- Technical debt management (quadrant model)
- Pair/mob programming patterns
- CI discipline (small commits, green builds, fast feedback)

**What this skill does NOT contain:**
- Language-specific patterns (those live in `arch-py`, `arch-ts`)
- Testing frameworks/tools (those live in `arch-py`, `arch-ts`)
- Architecture patterns (those live in `arch-py`, `arch-ts`, `ai-engineer`)
- Execution workflow (that lives in the agents themselves)

---

## Filosofia

### Processo não é burocracia — é disciplina

Good methodology eliminates waste, reduces rework, and builds confidence.
Bad methodology adds ceremony without value. This skill targets the former.

### Princípios

**1. Understand before you build**
- Read existing code, contracts, dependencies, and edge cases
- If you cannot articulate what "done" looks like, you do not understand the task

**2. Test before you implement**
- Define acceptance criteria first
- Write failing tests that encode those criteria
- Implement just enough to pass
- Refactor while green

**3. Deliver in thin vertical slices**
- Each slice is deployable, testable, and valuable
- Prefer a walking skeleton over a layered approach
- Small batches reduce risk and accelerate feedback

**4. Never deliver untested code**
- "It compiles" is not a test
- Run the actual commands, verify the actual output
- Test happy path AND edge cases

**5. Leave the codebase better than you found it**
- Boy Scout Rule: clean up what you touch
- Budget time for technical debt in every iteration
- Refactor with safety nets (tests), never without

**6. Small commits, green builds, fast feedback**
- Each commit is atomic, focused, and buildable
- CI must pass on every commit — no exceptions
- Broken builds are the team's top priority

---

## 1. Workflow de Desenvolvimento — 7 Phases

```
QUESTIONAR > PESQUISAR > PROJETAR > TESTAR > IMPLEMENTAR > VALIDAR > REVISAR
```

Every task — feature, bug fix, refactor — follows these phases.
Phases can be quick (minutes for a trivial fix) or deep (days for a complex feature),
but none can be skipped.

### Fase 1: QUESTIONAR

**Goal:** Ensure crystal-clear understanding of the task.

**Actions:**
- Read the issue/ticket/requirement completely
- Read related code, tests, and documentation
- Identify ambiguities and resolve them BEFORE coding
- Map dependencies (what does this touch?)
- Identify constraints (performance, compatibility, security)

**Exit criteria:**
- [ ] Can articulate the problem in one sentence
- [ ] Can describe the expected behavior (inputs -> outputs)
- [ ] Can list affected components/files
- [ ] All ambiguities resolved (asked the user if needed)

**Anti-patterns:**
- Starting to code before understanding the full scope
- Assuming requirements when they are unclear
- Ignoring edge cases discovered during questioning

**Reference:** [references/workflow/questioning.md](references/workflow/questioning.md)

---

### Fase 2: PESQUISAR

**Goal:** Ground decisions in current knowledge, not assumptions.

**Actions:**
- Search for existing solutions in the codebase (has this been solved before?)
- Search the web for current best practices (libraries, patterns, approaches)
- Check if dependencies need updating
- Review how similar systems solve this problem
- Cross-check multiple sources (docs, GitHub, blogs, benchmarks)

**Exit criteria:**
- [ ] Aware of existing solutions in the codebase
- [ ] Aware of current best practices for this type of problem
- [ ] Dependencies identified with pinned versions
- [ ] Trade-offs of different approaches understood

**Anti-patterns:**
- Relying solely on training data / memory without verifying
- Choosing the first approach found without comparing alternatives
- Skipping research because "I already know the answer"

**Reference:** [references/workflow/research.md](references/workflow/research.md)

---

### Fase 3: PROJETAR

**Goal:** Make design decisions explicit before writing code.

**Actions:**
- Define the public API / interface first
- Identify the data model / schema changes
- Choose the pattern (and document WHY)
- Consider at least 2 approaches with trade-offs
- Document the chosen approach briefly

**Deliverables (scale to task size):**
- Trivial: mental model, no artifact needed
- Small: comment in the code or issue
- Medium: brief design note (bullet points)
- Large: design document with diagrams

**Exit criteria:**
- [ ] Interfaces/contracts defined
- [ ] Pattern chosen with justification
- [ ] Edge cases identified
- [ ] Breaking changes identified (if any)

**Anti-patterns:**
- Designing in your head without writing anything down
- Over-engineering (YAGNI — You Aren't Gonna Need It)
- Under-designing (skipping straight to code for complex tasks)
- Designing without considering testability

**Reference:** [references/workflow/design.md](references/workflow/design.md)

---

### Fase 4: TESTAR — Write Tests First)

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

**Exemplos:**
```python
def test_create_user_when_email_valid_then_returns_user():
    ...

def test_create_user_when_email_duplicate_then_raises_conflict():
    ...

def test_calculate_discount_when_premium_user_then_applies_10_percent():
    ...
```

**Exit criteria:**
- [ ] Tests written and failing (RED phase)
- [ ] Tests cover happy path
- [ ] Tests cover key edge cases
- [ ] Tests cover error/exception paths
- [ ] Test names describe behavior clearly

**Anti-patterns:**
- Writing tests after implementation (loses the design benefit of TDD)
- Testing implementation details instead of behavior
- Writing tests that always pass (tautological tests)
- Skipping error case tests

**Reference:** [references/testing/test-first.md](references/testing/test-first.md)

---

### Fase 5: IMPLEMENTAR

**Goal:** Write the minimum code to make tests pass, then refactor.

**Actions:**
- Implement just enough to pass the first test (GREEN phase)
- Run tests after each small change
- Once green, refactor for clarity and design (REFACTOR phase)
- Repeat RED-GREEN-REFACTOR cycle
- Commit after each meaningful green state

**RED-GREEN-REFACTOR cycle:**
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

**Anti-patterns:**
- Writing all code first, then running tests
- Gold-plating (adding features not in the tests)
- Skipping the refactor step
- Large commits with many unrelated changes

**Reference:** [references/workflow/implementation.md](references/workflow/implementation.md)

---

### Fase 6: VALIDAR

**Goal:** Prove the code works end-to-end, not just in unit tests.

**Actions:**
- Run the full test suite (unit + integration + e2e)
- Run linters and type checkers (`ruff`, `mypy`, `biome`)
- Test manually if applicable (curl endpoints, verify UI)
- Verify in an environment as close to production as possible
- Check for regressions (did anything else break?)

**Exit criteria:**
- [ ] All tests passing (unit, integration, e2e)
- [ ] Linters clean (zero warnings)
- [ ] Type checker clean
- [ ] Manual verification done (if applicable)
- [ ] No regressions introduced

**Anti-patterns:**
- Declaring "done" without running the full suite
- Ignoring linter warnings
- Testing only the happy path manually
- Not checking for regressions

**Reference:** [references/workflow/validation.md](references/workflow/validation.md)

---

### Fase 7: REVISAR — Self-Check)

**Goal:** Catch issues BEFORE submitting for review.

**Actions:**
- Run the self-check checklist (see section 6)
- Review your own diff as if you were the reviewer
- Update documentation (CHANGELOG, README, API docs)
- Clean up commits (atomic, well-messaged)
- Verify branch is up to date with base

**Exit criteria:**
- [ ] Self-check checklist passed
- [ ] Documentation updated
- [ ] Commits clean and atomic
- [ ] Branch rebased on base branch
- [ ] Ready for review

**Anti-patterns:**
- Submitting without self-review
- Forgetting documentation updates
- Messy commit history (WIP, fix, fix2, etc.)
- Submitting with failing CI

**Reference:** [references/code-review/self-check.md](references/code-review/self-check.md)

---

## 2. Metodologia Test-First

### TDD

Developer-centric. Focus on correct implementation of individual units.

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

**Reference:** [references/testing/tdd.md](references/testing/tdd.md)

### BDD

User-centric. Focus on system behavior from the user's perspective.
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
- API contract testing

**Reference:** [references/testing/bdd.md](references/testing/bdd.md)

### ATDD (Acceptance Test-Driven Development)

Combines TDD + BDD. Write acceptance tests first (BDD-style),
then implement using TDD for internal components.

**Workflow:**
```
1. Write acceptance test (BDD — Given/When/Then)
2. Run it — it fails (no implementation)
3. Use TDD to implement the internal components
4. Acceptance test passes — feature is done
```

**When to use:**
- Complex features with multiple components
- Features requiring stakeholder sign-off
- API endpoints (acceptance = API contract, TDD = internal logic)

**Reference:** [references/testing/atdd.md](references/testing/atdd.md)

### Combined approach (recommended)

```
BDD (acceptance layer)
 |
 +-- TDD (unit layer for each component)
```

- BDD captures WHAT the system should do (user perspective)
- TDD captures HOW each unit works (developer perspective)
- Both written BEFORE implementation

### AI-Assisted TDD (2025+)

AI accelerates TDD without replacing the discipline:

| Stage | AI Role |
|-------|---------|
| Test scaffolding | Generate starter test structure from function signature |
| Edge cases | Suggest corner scenarios humans miss |
| Refactoring | Highlight redundant tests, suggest cleaner patterns |
| Assertions | Suggest more specific assertions |

**Rule:** AI generates, human validates. Never blindly accept AI-generated tests.

---

## 3. Workflow de Bug Fix

Every bug fix follows a systematic 6-step process.

```
REPRODUCE > ISOLATE > WRITE TEST > FIX > VALIDATE > PREVENT
```

### Step 1: REPRODUCE

- Create a reliable reproduction case
- Document exact steps, inputs, environment
- Confirm the bug exists (not user error or stale data)
- If you cannot reproduce, you cannot fix

### Step 2: ISOLATE

- Narrow down the affected code path
- Use binary search (comment out code, bisect commits)
- Identify the root cause, not just the symptom
- `git bisect` is your friend for regression bugs

```bash
# Find the commit that introduced the bug
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
- The test MUST fail on the current code
- This is your regression safety net
- Name it clearly: `test_<what>_when_<condition>_does_not_<bug_behavior>`

### Step 4: FIX

- Fix the root cause, not the symptom
- Change the minimum amount of code
- Do not mix the fix with refactoring or features

### Step 5: VALIDATE

- Run the failing test — it should now pass
- Run the full test suite — no regressions
- Test manually if applicable
- Test the original reproduction case

### Step 6: PREVENT

- Add the regression test to CI
- Consider if the bug class needs a linter rule
- Document the root cause if non-obvious
- Consider if similar bugs exist elsewhere

**Reference:** [references/workflow/bug-fix.md](references/workflow/bug-fix.md)

---

## 4. Metodologia de Refactoring

Refactoring changes code structure without changing behavior.
Always refactor with safety nets (tests). Never refactor without tests.

### When to refactor

- During the REFACTOR step of TDD (every cycle)
- When adding a feature requires changing existing code
- When code smells make the area hard to understand
- When technical debt is budgeted in the sprint
- NEVER as a separate "refactoring sprint" (integrate into daily work)

### Key patterns

#### 4.1 Strangler Fig Pattern

**When:** Replacing a large legacy system/component incrementally.

**How:**
```
1. IDENTIFY the component to replace
2. CREATE the new implementation alongside the old one
3. ROUTE traffic/calls gradually to the new implementation
4. MONITOR both implementations in parallel
5. REMOVE the old implementation once the new one is proven
```

**Key benefits:**
- Zero big-bang risk — rollback is always possible
- Each migration step is small and testable
- Production validation at every step

**Anti-patterns:**
- Trying to replace everything at once
- Not monitoring the new implementation in production
- Leaving the old code forever (complete the migration)

#### 4.2 Branch by Abstraction

**When:** Refactoring components deep in the stack with upstream dependencies.

**How:**
```
1. IDENTIFY the component to refactor and its callers
2. CREATE an abstraction layer (interface/protocol) between callers and the component
3. CHANGE all callers to use the abstraction
4. CREATE the new implementation behind the abstraction
5. SWITCH the abstraction to use the new implementation
6. REMOVE the old implementation
```

**Key benefits:**
- All changes happen on trunk (no long-lived branches)
- Callers are decoupled from implementation
- Can switch implementations with a flag

#### 4.3 Parallel Change (Expand-Migrate-Contract)

**When:** Changing an interface/API that has multiple consumers.

**How:**
```
1. EXPAND  — Add the new interface alongside the old one
2. MIGRATE — Move consumers to the new interface one by one
3. CONTRACT — Remove the old interface once all consumers migrated
```

**Exemplo:**
```python
# Phase 1: EXPAND — add new method, keep old
class UserService:
    def get_user(self, user_id: int) -> dict:          # old
        ...
    def get_user_by_uuid(self, uuid: str) -> User:     # new
        ...

# Phase 2: MIGRATE — move callers to new method

# Phase 3: CONTRACT — remove old method
class UserService:
    def get_user_by_uuid(self, uuid: str) -> User:     # only new
        ...
```

#### 4.4 Mikado Method

**When:** Large refactoring with unknown dependencies.

**How:**
```
1. SET a refactoring goal
2. TRY to implement it directly
3. If it breaks things, NOTE the prerequisite
4. REVERT your change
5. IMPLEMENT the prerequisite first
6. TRY the goal again
7. REPEAT until the goal succeeds
```

Produces a dependency graph (Mikado Graph) of changes needed.

**Reference:** [references/refactoring/patterns.md](references/refactoring/patterns.md)

---

## 5. Decomposição de Features Grandes

### Vertical Slicing

**Core principle:** Every slice cuts through ALL layers (UI, API, business logic, data)
and delivers user-visible value.

**Horizontal slice (BAD):**
```
Sprint 1: Build database schema
Sprint 2: Build API endpoints
Sprint 3: Build frontend
Sprint 4: Integration testing
Sprint 5: Finally works end-to-end
```

**Vertical slice (GOOD):**
```
Slice 1: User can create an account (simple form, one API, one table)
Slice 2: User can log in (auth flow end-to-end)
Slice 3: User can update profile (edit form, API, validation)
```

### Slicing heuristics

| Technique | Description | Example |
|-----------|-------------|---------|
| **By workflow step** | Each step of a process becomes a slice | Checkout: add to cart, enter address, pay |
| **By business rule** | Each rule becomes a slice | Pricing: base price, bulk discount, loyalty discount |
| **By data variation** | Each data type becomes a slice | Import: CSV first, then Excel, then API |
| **By operation** | CRUD operations as separate slices | Users: create first, then read, update, delete |
| **By persona** | Different user types as slices | Admin dashboard, then user dashboard |
| **By acceptance criteria** | Each criterion becomes a slice | Each Given/When/Then is a slice |

### Walking Skeleton

**Definition:** The thinnest possible slice of real functionality that can be built,
deployed, and tested end-to-end.

**Purpose:**
- Validates the architecture early
- Establishes the deployment pipeline
- Creates the foundation for incremental development
- De-risks technical unknowns

**Characteristics:**
- Cuts through ALL layers (UI to database)
- Is deployable to production (even if feature-flagged)
- Has automated tests
- Has CI/CD configured
- Takes 1-4 days maximum

**Example — E-commerce walking skeleton:**
```
UI:       Single page with a "Buy" button and a product name
API:      POST /orders with hardcoded product
Business: Create order with fixed price
Database: orders table with id, product, status
Deploy:   Docker + CI + staging environment
Test:     E2E test: click Buy -> order created
```

Then flesh out incrementally: add product catalog, cart, payment, etc.

### Feature breakdown template

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

**Reference:** [references/feature-breakdown/vertical-slicing.md](references/feature-breakdown/vertical-slicing.md)

---

## 6. Self-Check de Code Review

**Before submitting code for review, run this checklist yourself.**

The goal is to catch obvious issues before wasting a reviewer's time.

### Correctness

- [ ] Code does what the ticket/issue asks for
- [ ] All acceptance criteria met
- [ ] Edge cases handled
- [ ] Error cases handled with appropriate messages
- [ ] No off-by-one errors
- [ ] No null/undefined access without guards

### Testes

- [ ] All new code has tests
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Tests cover happy path, edge cases, error cases
- [ ] Test names describe behavior
- [ ] All tests pass locally
- [ ] No flaky tests introduced

### Code quality

- [ ] No `TODO` or `FIXME` without a linked issue
- [ ] No commented-out code
- [ ] No debug prints/logs left in
- [ ] Variable/function names are descriptive
- [ ] Functions are small and focused (single responsibility)
- [ ] No code duplication
- [ ] Type hints complete (Python) or strict types (TypeScript)

### Security

- [ ] No secrets or credentials in code
- [ ] User input validated and sanitized
- [ ] SQL injection prevented (parameterized queries)
- [ ] No sensitive data in logs
- [ ] Authentication/authorization checks in place

### Performance

- [ ] No N+1 queries
- [ ] No unnecessary API calls in loops
- [ ] Resources properly managed (connections, files, locks)
- [ ] Appropriate caching considered

### Documentação

- [ ] CHANGELOG.md updated
- [ ] README.md updated (if user-facing changes)
- [ ] API documentation updated (if endpoints changed)
- [ ] Code comments for non-obvious logic
- [ ] Docstrings on public functions/classes

### Git hygiene

- [ ] Commits are atomic and well-messaged
- [ ] No merge commits (rebased on base branch)
- [ ] No unrelated changes mixed in
- [ ] Branch name follows convention

**Reference:** [references/code-review/self-check.md](references/code-review/self-check.md)

---

## 7. Definition of Done

A task is only "done" when ALL of these are true.
Non-negotiable. No exceptions.

### Code

- [ ] Implementation complete and working
- [ ] All tests passing (unit + integration + e2e where applicable)
- [ ] Linters clean (zero warnings)
- [ ] Type checker clean
- [ ] No new technical debt introduced without tracking

### Documentação

- [ ] CHANGELOG.md updated
- [ ] README.md updated (if applicable)
- [ ] API docs updated (if applicable)
- [ ] Architecture decision recorded (if applicable)

### Review

- [ ] Self-check checklist passed
- [ ] Code review completed and approved
- [ ] Review feedback addressed

### Deployment

- [ ] CI pipeline green
- [ ] Deployable to staging/production
- [ ] Feature flag configured (if gradual rollout)
- [ ] Monitoring/alerting in place (if new service/endpoint)

### Acceptance

- [ ] All acceptance criteria verified
- [ ] Manually tested (if applicable)
- [ ] No regressions introduced

---

## 8. Gestão de Débito Técnico

### The Technical Debt Quadrant

Classify debt on two axes: **deliberate vs inadvertent** and **prudent vs reckless**.

```
                    Prudent                          Reckless
            +---------------------------+---------------------------+
Deliberate  | "We know this is a        | "We don't have time for   |
            |  shortcut and will fix    |  tests or design, just    |
            |  it next sprint"          |  ship it"                 |
            | ACTION: Track in backlog, | ACTION: Risk flag, demand |
            | schedule repayment date   | scope cut or more time    |
            +---------------------------+---------------------------+
Inadvertent | "Now we know how we       | "What's a design pattern?"|
            |  should have done it"     |                           |
            | ACTION: Schedule          | ACTION: Pair with senior  |
            | incremental refactors     | engineer, add automated   |
            | as knowledge improves     | tests, training           |
            +---------------------------+---------------------------+
```

### Management rules

**1. Make debt visible**
- Every shortcut gets a ticket/issue with `tech-debt` label
- Include: what, why, impact, estimated effort to fix
- Link to the code location

**2. Budget capacity**
- Allocate 20-30% of sprint capacity for debt and quality work
- Teams with high reckless debt may need 40-50% temporarily
- Never zero — debt compounds

**3. Prioritize by impact**
- High-traffic code paths first
- Code that changes frequently first
- Security-related debt is always P0

**4. Pay incrementally**
- Boy Scout Rule: leave code cleaner than you found it
- Attach small debt fixes to related feature work
- Avoid "refactoring sprints" — they never finish

**5. Prevent new debt**
- Code review catches reckless debt
- Linters and type checkers catch inadvertent debt
- Architecture reviews catch strategic debt

**Reference:** [references/technical-debt/quadrant.md](references/technical-debt/quadrant.md)

---

## 9. Pair e Mob Programming

### Pair Programming

Two developers, one computer. Two roles that switch frequently.

**Driver:** Writes the code. Focused on the current line.
**Navigator:** Thinks about direction, catches mistakes, considers the big picture.

**When to pair:**
- Onboarding new team members
- Complex or risky code
- Debugging hard-to-reproduce issues
- Knowledge sharing
- When stuck for more than 30 minutes

**Styles:**

| Style | How it works | Best for |
|-------|-------------|----------|
| **Driver-Navigator** | Classic: one types, one guides | General development |
| **Ping-Pong** | A writes test, B implements, swap | TDD, learning |
| **Strong-Style** | Navigator dictates every keystroke | Teaching, onboarding |

**Rules:**
- Switch roles every 15-25 minutes (use a timer)
- Navigator does NOT grab the keyboard
- Take breaks — pairing is intense
- Both names on the commit

### Mob Programming

Whole team, one computer. One driver, everyone else navigates.

**When to mob:**
- Critical architectural decisions
- Complex integration work
- Team alignment on patterns
- Spikes and discovery

**Rules:**
- Rotate driver every 10-15 minutes
- Driver only writes what the mob tells them
- Everyone participates (no spectators)
- "Yes, and..." over "No, but..."
- Breaks every 50 minutes

**Reference:** [references/workflow/pairing.md](references/workflow/pairing.md)

---

## 10. Disciplina de CI

### Commit discipline

**Atomic commits:**
- Each commit does ONE thing
- Each commit compiles and passes tests
- Each commit has a clear message

**Commit message format:**
```
<type>: <short description>

<optional body explaining WHY, not WHAT>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

**Anti-patterns:**
- `WIP`, `fix`, `fix2`, `final`, `final2`
- Commits that break the build
- Commits mixing unrelated changes
- Giant commits with 500+ lines changed

### Branch discipline

- Feature branches: `feat/<name>`
- Bug fix branches: `fix/<name>`
- Refactor branches: `refactor/<name>`
- Short-lived: merge within 1-3 days
- Never commit to a branch with an open PR under review

### CI pipeline expectations

```
Every push triggers:
  1. Lint (ruff/biome)        — < 30s
  2. Type check (mypy/tsc)    — < 60s
  3. Unit tests               — < 2min
  4. Integration tests        — < 5min
  5. Build                    — < 2min
  ──────────────────────────
  Total: < 10min target
```

### Green build rules

- A broken build is the team's top priority
- The person who broke it fixes it immediately
- If you cannot fix it in 10 minutes, revert
- Never merge on red
- Never add "skip CI" without justification

### Fast feedback principles

- Fail fast: linters and type checks run first
- Parallelize: independent test suites run concurrently
- Cache: dependencies and build artifacts cached
- Selective: only run affected tests when possible
- Local: developers can run the full pipeline locally

**Reference:** [references/ci/discipline.md](references/ci/discipline.md)

---

## Workflow Integration with Other Skills

This skill defines the PROCESS. Other skills define the TOOLS and PATTERNS.

| Phase | This Skill | Other Skills |
|-------|-----------|--------------|
| QUESTIONAR | How to question | — |
| PESQUISAR | When to research | `ai-engineer` (AI patterns) |
| PROJETAR | Design methodology | `arch-py` / `arch-ts` (patterns) |
| TESTAR | TDD/BDD process | `arch-py` (pytest), `arch-ts` (vitest) |
| IMPLEMENTAR | RED-GREEN-REFACTOR | `arch-py` / `arch-ts` (code patterns) |
| VALIDAR | Validation checklist | `arch-py` (ruff/mypy), `arch-ts` (biome) |
| REVISAR | Self-check process | `review-py` / `review-ts` (review criteria) |

---

## References

### Workflow
- [references/workflow/questioning.md](references/workflow/questioning.md) - Deep questioning techniques
- [references/workflow/research.md](references/workflow/research.md) - Research methodology
- [references/workflow/design.md](references/workflow/design.md) - Design documentation
- [references/workflow/implementation.md](references/workflow/implementation.md) - Implementation discipline
- [references/workflow/validation.md](references/workflow/validation.md) - Validation checklist
- [references/workflow/bug-fix.md](references/workflow/bug-fix.md) - Bug fix systematic process
- [references/workflow/pairing.md](references/workflow/pairing.md) - Pair and mob programming

### Testes
- [references/testing/test-first.md](references/testing/test-first.md) - Test-first principles
- [references/testing/tdd.md](references/testing/tdd.md) - TDD deep dive
- [references/testing/bdd.md](references/testing/bdd.md) - BDD with Given-When-Then
- [references/testing/atdd.md](references/testing/atdd.md) - Acceptance TDD

### Refactoring
- [references/refactoring/patterns.md](references/refactoring/patterns.md) - Strangler fig, branch by abstraction, parallel change, Mikado

### Feature Breakdown
- [references/feature-breakdown/vertical-slicing.md](references/feature-breakdown/vertical-slicing.md) - Vertical slicing and walking skeleton

### Code Review
- [references/code-review/self-check.md](references/code-review/self-check.md) - Pre-submission checklist

### CI
- [references/ci/discipline.md](references/ci/discipline.md) - CI discipline and commit hygiene

### Technical Debt
- [references/technical-debt/quadrant.md](references/technical-debt/quadrant.md) - Quadrant model and management

### External Sources
- [TDD vs BDD vs DDD in 2025](https://medium.com/@sharmapraveen91/tdd-vs-bdd-vs-ddd-in-2025-choosing-the-right-approach-for-modern-software-development-6b0d3286601e)
- [Test-Driven Development Guide 2025](https://www.nopaccelerate.com/test-driven-development-guide-2025/)
- [Strangler Fig Pattern](https://www.gocodeo.com/post/how-the-strangler-fig-pattern-enables-safe-and-gradual-refactoring)
- [Branch by Abstraction - AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-decomposing-monoliths/branch-by-abstraction.html)
- [Vertical Slicing - Walking Skeleton](https://blog.devgenius.io/red-loop-part-5-vertical-slice-walking-skeleton-c75e2003fe2c)
- [Technical Debt Quadrant](https://scalablehuman.com/2025/08/25/exploring-the-technical-debt-quadrant-strategies-for-managing-software-debt/)
- [Trunk-Based Development](https://trunkbaseddevelopment.com/)
- [DORA Capabilities: Trunk-based Development](https://dora.dev/capabilities/trunk-based-development/)
