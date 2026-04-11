# Claude Code - Global Instructions

## Development Discipline — Foundational Principle

**Every task must have a clear test plan BEFORE writing any code. This is non-negotiable.**

### Before coding
1. **Understand the task deeply** — read existing code, dependencies, contracts, and edge cases
2. **Define the test plan first** — know exactly what you will validate: inputs, outputs, error cases, integration points
3. **Everything must be crystal clear** — if there is any ambiguity about what "done" looks like, resolve it BEFORE coding (ask the user, read more code, research)
4. **No coding under uncertainty** — if you can't articulate what you'll test, you don't understand the task well enough to start

### After coding
1. **Test everything end-to-end** — every change must be validated before delivering
2. **Run the actual commands** — not "this should work", but prove it works (run tests, curl endpoints, verify output)
3. **Test the happy path AND edge cases** — if you changed error handling, trigger the error
4. **Never deliver untested code** — if you can't test it in this environment, say so explicitly

## Research First — Foundational Principle

**Every technical decision must be backed by current web research. This is non-negotiable.**

### When to research
- Choosing a technology, library, framework, model, or tool
- Recommending an approach, pattern, or architecture
- Comparing options or alternatives
- Any decision where the state of the art may have changed

### How to research
1. **Search the web first** — use WebSearch and WebFetch actively
2. **Cross multiple sources** — official docs, GitHub releases, benchmarks, blog posts
3. **Check dates** — prefer sources from the last 6 months
4. **Cite sources** — always show where the information came from
5. **Never rely on training data alone** — it has a cutoff, things change fast

**Rule:** If you can't research (no web access), explicitly say so and flag that the recommendation
is based on training data which may be outdated.

## Branch Discipline — Foundational Principle

**Every logical change goes in its own branch. Never commit to a branch with an open PR. This is non-negotiable.**

### Rules
1. **One branch per logical change** — a feature, a fix, a refactor. Never mix unrelated changes
2. **Never commit to a branch with an open PR** — if the PR is under review, the branch is frozen
3. **Review fixes get their own branch** — if PR #X needs fixes, create a new branch
4. **Branch from the right base** — features from main, fixes from main or the feature branch
5. **Never push directly to main** — always branch + PR

## PR Quality — Foundational Principle

**Every PR must include updated documentation. This is non-negotiable.**

### Rules
1. **CHANGELOG.md** — always updated with what changed, before opening the PR
2. **README.md** — always updated if changes affect documented features, commands, or configuration
3. **Update docs BEFORE opening the PR** — not after, not as a follow-up

## Dependency Pinning — Foundational Principle

**Every dependency must be pinned to an exact stable version. Never use loose constraints. This is non-negotiable.**

### Rules
1. **Always pin exact versions** — `requests==2.32.3`, never `requests>=2.32`
2. **Always research the latest stable version** — check the web before adding any dependency
3. **Never use pre-release versions** — only stable releases
4. **Update deliberately** — research the new version, check for breaking changes, then update the pin
5. **Applies to ALL dependency files** — requirements.txt, pyproject.toml, package.json, Cargo.toml
