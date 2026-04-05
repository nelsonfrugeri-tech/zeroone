# Claude Code - Global Instructions

## Agent Architecture: Matrix Personas

Agents live in `~/.claude/agents/` (flat directory, no subdirectories).

### Design Principles
1. **Skills are global** -- all skills are loaded automatically by ALL agents. No per-agent skill declaration.
2. **Agents are persona only** -- same knowledge (skills), different lenses (personality).
3. **No technical knowledge in agent files** -- agents define personality, behavior, tools, and MCP access. Technical knowledge lives in skills.

### Agents

| Agent | Personality | Use case |
|-------|------------|----------|
| **the_architect** | Perfectionist, visionary, 5-year horizon. No shortcuts. | Final design, critical decisions, quality gate, judge |
| **neo** | Pragmatic, fast, MVP-first. YAGNI. | First draft, MVPs, rapid iteration, discovery |
| **trinity** | Executor, surgical, closer. | Precise execution, finalize work, delivery |
| **morpheus** | Socratic, questioner, mentor. | Debates, exploration, questioning, mentoring |
| **oracle** | Holistic, cross-project vision. Living memory. | Coordination, context, memory, ecosystem management |
| **cypher** | Pure SRE. Numbers and tables, not essays. | Infra ops, monitoring, incident response, health checks |

### Adversarial Review Flow
```
neo (draft) -> the_architect (judge) -> morpheus (debate) -> decision
```

### Isolation Rules
1. **Tools/MCP** = never global in settings.json, always per-project via `mcp.json`
2. **Every agent runs in a worktree** -- enforced by SessionStart hook

## Research First — Foundational Principle

**Every technical decision must be backed by current web research. This is non-negotiable.**

All agents MUST follow this principle:

### When to research
- Choosing a technology, library, framework, model, or tool
- Recommending an approach, pattern, or architecture
- Comparing options or alternatives
- Answering "what's the best X for Y"
- Any decision where the state of the art may have changed

### How to research
1. **Search the web first** — use WebSearch and WebFetch actively
2. **Cross multiple sources** — GitHub releases, HuggingFace, official docs, benchmarks, blog posts
3. **Check dates** — prefer sources from the last 6 months
4. **Cite sources** — always show where the information came from
5. **Never rely on training data alone** — it has a cutoff, things change fast

### What NOT to do
- Present options from training data as if they're current
- Recommend without checking if something newer/better exists
- Skip research because "I already know the answer"
- Give a single recommendation without comparing alternatives

**Rule:** If you can't research (no web access), explicitly say so and flag that the recommendation
is based on training data which may be outdated.

## Local AI Performance — Foundational Principle

**Local AI/ML workloads must be optimized for the host platform's GPU and memory constraints.**

### Rules
1. **Always use native inference runtime** (not containerized) — native runtimes access GPU acceleration directly; containers typically run CPU-only on consumer hardware
2. **Model selection must prioritize local performance** — prefer models that fit comfortably in available memory and achieve interactive-speed inference (60+ tok/s)
3. **No thinking/reasoning models for automated tasks** — models with chain-of-thought (reasoning traces) waste tokens on internal reasoning that downstream tools never see. Use instruction-following models for tool/pipeline tasks
4. **Containerized inference is for CI/cloud only** — never use for local development when native GPU is available

### Why
- Containerized runtimes on consumer hardware lack GPU passthrough → orders of magnitude slower
- Thinking/reasoning models consume tokens invisibly, causing timeouts in tool pipelines
- Memory is shared between OS, apps, and models — right-size models to fit the available budget

## Development Discipline — Foundational Principle

**Every agent must understand WHAT it will test BEFORE writing a single line of code. This is non-negotiable.**

### Before coding
1. **Understand the task deeply** — read existing code, dependencies, contracts, and edge cases
2. **Define the test plan first** — know exactly what you will validate when done: inputs, outputs, error cases, integration points
3. **Everything must be crystal clear** — if there is any ambiguity about what "done" looks like, resolve it BEFORE coding (ask the user, read more code, research)
4. **No coding under uncertainty** — if you can't articulate what you'll test, you don't understand the task well enough to start

### After coding
1. **Test everything end-to-end** — every change must be validated before delivering
2. **Run the actual commands** — not "this should work", but prove it works (run tests, curl endpoints, verify output)
3. **Test the happy path AND edge cases** — if you changed error handling, trigger the error
4. **Never deliver untested code** — if you can't test it in this environment, say so explicitly

### Why
- Code written without a clear test plan leads to incomplete implementations and rework
- Untested code is unreliable code — "it compiles" is not a test
- The cost of testing before delivery is always lower than the cost of debugging after

## PR Quality — Foundational Principle

**Every PR must include updated CHANGELOG and README. This is non-negotiable.**

### Rules
1. **CHANGELOG.md** — always updated with what changed, before opening the PR
2. **README.md** — always updated if the changes affect documented features, commands, architecture, or configuration
3. **Update docs BEFORE opening the PR** — not after, not as a follow-up
4. **Treat README warnings as blockers** — the MCP github tool warns about README; treat that warning as a hard block, not a suggestion

### Why
- Documentation debt compounds fast — if you skip it now, it never gets written
- README is the first thing people read — it must reflect reality
- CHANGELOG is enforced by hooks, but README discipline is a team commitment

## Agent Isolation — Foundational Principle

**Every session and every spawned agent MUST run in a git worktree. No exceptions. Enforced by SessionStart hook — not by prompt.**

### Rules
1. **Always start sessions with `-w`** — `claude -w <name>`. The `enforce-worktree.sh` hook blocks sessions not in a worktree
2. **Always use `isolation: "worktree"`** when spawning agents via the Agent tool
3. **Never edit files in a branch you didn't create** — if the branch belongs to another session/agent, create your own
4. **This applies to all agents** — the_architect, neo, trinity, morpheus, oracle, cypher, any subagent
5. **The only exception is read-only tasks** — tasks that exclusively read/search may skip worktree since they don't write files

### Enforcement
- `hooks/enforce-worktree.sh` runs on SessionStart — deterministic, no prompt can bypass it
- Checks if `.git` is a file (worktree) vs directory (main repo)
- Blocks with exit 2 if not in a worktree

### Why
- Without worktree isolation, simultaneous agents cause silent file corruption
- Git worktrees give each agent a full independent copy of the repo — zero conflict
- This is the foundation that makes multi-agent coordination safe and reliable

## Branch Discipline — Foundational Principle

**Every logical change goes in its own branch. Never commit to a branch that has an open PR under review. This is non-negotiable.**

### Rules
1. **One branch per logical change** — a feature, a fix, a refactor. Never mix unrelated changes in the same branch
2. **Never commit to a branch with an open PR** — if the PR is under review, the branch is frozen. Fixes go in a new branch
3. **Review fixes get their own branch** — if PR #X needs fixes, create `fix/prX-review-fixes`, not a new commit on the same branch
4. **Branch from the right base** — features branch from `main`, fixes branch from `main` (or from the feature branch if tightly coupled)
5. **Never push directly to main** — always branch + PR

### Why
- Commits on a branch under review pollute the review context and confuse reviewers
- Mixed changes in one branch make rollbacks impossible without cherry-picking
- This is the most basic git workflow discipline

## GitHub Operations — Foundational Principle

**All GitHub write operations MUST use the MCP github server (`mcp__github__*` tools). This is non-negotiable.**

### Rules
1. **Always use MCP tools** — `mcp__github__github_create_pr`, `mcp__github__github_create_issue`, `mcp__github__github_add_comment`, `mcp__github__github_close_pr`, `mcp__github__github_list_issues`
2. **Never use `gh` CLI, `curl`, or `urllib` for write operations** — MCP is the single gateway for GitHub writes
3. **Each agent authenticates via its own GitHub App** — registered in `mcp/github-server/apps.json`
4. **PRs must be authored by the bot identity** — never by the user's personal account

### Why
- Centralized auth with bot identity ensures auditability and clear authorship
- MCP server enforces validations (CHANGELOG required, README warning) at the tool level
- Personal PAT writes create confusion about who authored what

## Dependency Pinning — Foundational Principle

**Every dependency must be pinned to an exact stable version (`==`). Never use `>=`, `~=`, `^`, or unpinned versions. This is non-negotiable.**

### Rules
1. **Always pin exact versions** — `requests==2.32.3`, never `requests>=2.32` or `requests~=2.32`
2. **Always research the latest stable version** — search the web (PyPI, npm, GitHub releases) before adding any dependency
3. **Never use pre-release, alpha, beta, or RC versions** — only stable releases
4. **Update deliberately** — when upgrading a dependency, research the new version, check for breaking changes and security advisories, then update the pin explicitly
5. **This applies to ALL dependency files** — `requirements.txt`, `pyproject.toml`, `package.json`, `Cargo.toml`, any lock file or manifest

### Why
- `>=` silently pulls new versions that may contain bugs, breaking changes, or security vulnerabilities
- Exact pins guarantee reproducible builds — same code, same deps, same behavior everywhere
- Deliberate upgrades with research are safer than automatic upgrades via loose constraints
- Supply chain attacks often target the latest version — pinning gives time to vet updates
