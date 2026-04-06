# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed
- **pr-docs-check.sh false positive on prose and echo** (#3) — `grep -qE '(gh pr create|/repos/.*/pulls)'` matched substrings anywhere in the command, causing false positives when Python subprocess or `echo` commands contained the substring. The regex now matches only `^\s*gh\s+pr\s+create\b` (command start). The `/repos/.*/pulls` pattern was removed — once gh CLI writes are blocked by deny rules, this hook only catches edge cases where the substring appears in unrelated commands.

### Added
- **require-qa-evidence.sh Bash matcher** (#1) — The QA evidence hook previously only triggered on `mcp__github__github_create_pr` tool calls. Agents using `gh pr create` via the Bash tool bypassed the check entirely. The hook now detects both: MCP tool calls (existing behavior) and Bash `gh pr create` invocations using the same robust regex. Registered as a second Bash PreToolUse matcher in `settings.json`.
- **require-self-judge.sh hook** (#2) — New hook that blocks all PR creation (both MCP and CLI paths) unless `self-judge.md` is **committed in the branch diff** with at least 50 bytes of content. The dev agent must create and commit self-judge.md during the SELF-JUDGE stage — ad-hoc creation at PR time is blocked. Registered for both `Bash` and `mcp__github__github_create_pr` matchers in `settings.json`.
- **Test suite for all three hooks** — `hooks/tests/test-pr-docs-check.sh` (14 cases), `hooks/tests/test-require-qa-evidence.sh` (6 cases), `hooks/tests/test-require-self-judge.sh` (8 cases — validates git diff check, not just disk presence). All tests are executable and self-reporting.

### Fixed
- **Worktree path exclusion deadlock** — `verify-tests-passed.sh`, `require-qa-evidence.sh`, and `validate-task-completion.sh` had `-not -path "*/.claude/worktrees/*"` which excluded ALL files when ROOT was itself a worktree. Now only excludes other agents' worktrees, not the current one.
- **pr-docs-check.sh missing MCP matcher** — Hook only fired on Bash commands; MCP `github_create_pr` calls bypassed CHANGELOG check. Now registered for both matchers and handles both tool types.
- **pr-docs-check.sh exit 0 on deny** — Hook returned `permissionDecision: deny` in JSON but `exit 0`. Changed to `exit 2` for deny path.
- **enforce-worktree.sh silent allow without jq** — When `jq` was missing, hook silently allowed sessions outside worktrees. Now blocks with `exit 2` and clear error.
- **require-self-judge.sh no checklist validation** — Hook only checked file size (>50 bytes). An agent could write 50 chars of filler. Now validates at least 3 real checklist items (`- [x]` or `- [ ]` format).

### Changed
- **oracle.md delegation template** — Dev agents are now explicitly instructed to: (1) create and commit `self-judge.md` during SELF-JUDGE stage, (2) open the PR themselves. Oracle does NOT open PRs or create self-judge.md.
- **dev-pipeline stages.md** — SELF-JUDGE stage now specifies mandatory output: `self-judge.md` committed in branch, enforced by hook.

### Fixed
- **Hook JSON schema for Stop and TaskCompleted events** (#50) — `verify-tests-passed.sh` and `validate-task-completion.sh` were using the PreToolUse schema (`hookSpecificOutput.permissionDecision`), which is invalid for Stop/TaskCompleted events and caused "JSON validation failed" in the Claude Code runtime. Both hooks now use the correct schema: `{"decision": "approve|block", "reason": "..."}`.
- **qa-report.md in hooks/ bypassing enforcement** (#50) — `verify-tests-passed.sh`, `validate-task-completion.sh`, and `require-qa-evidence.sh` all used `find` without excluding the `hooks/` directory. The `hooks/qa-report.md` historical file always satisfied the check, making it a no-op. All three hooks now add `-not -path "*/hooks/*"` to the find command. The stale `hooks/qa-report.md` file is deleted.
- **pr-docs-check.sh diff against wrong HEAD** (#52) — The hook used `git diff --name-only "$BASE"...HEAD`, which evaluates HEAD of the running branch (e.g., main), producing an empty diff. The hook now extracts the `--head` branch from the `gh pr create` command and diffs `"$BASE"..origin/$HEAD_BRANCH`. Falls back to the previous behavior if `--head` is not present.
- **GitHub MCP PEM path unexpanded env var detection** (#51) — `server.py` `_get_installation_token` now detects when `pem_path` is a literal unexpanded shell variable (starts with `${` or `$`) and raises a clear error message explaining the cause and how to fix it, instead of a confusing "PEM file not found" error.

### Added
- **`settings.json` hooks registration** (#42) — enforcement hooks wired into harness: `require-qa-evidence.sh` on `PreToolUse(mcp__github__github_create_pr)`, `verify-tests-passed.sh` on `Stop`, `validate-task-completion.sh` on `TaskCompleted`. Deny rules added: `git push origin main`, `git push --force*`, `rm -rf *`.

### Changed
- **Multi-agent GitHub auth** — `_get_installation_token` now looks up per-agent env vars (`GITHUB_APP_{AGENT}_*`) with fallback to generic vars. Oracle, Neo, and The Architect registered. All secrets moved to `${ENV_VAR}` references in `.mcp.json` — zero hardcoded credentials.

### Added
- **3 enforcement hooks** (#39, #40, #41) — deterministic quality gates for the dev pipeline
  - `hooks/require-qa-evidence.sh` — PreToolUse: blocks `mcp__github__github_create_pr` if no QA evidence file (qa-report.md, test-results.*, etc.) exists
  - `hooks/verify-tests-passed.sh` — Stop: blocks agent from stopping without test evidence (output files or test refs in git log); supports pytest, npm test, cargo test, go test, jest, rspec, phpunit
  - `hooks/validate-task-completion.sh` — TaskCompleted: blocks task completion if no commits ahead of base branch or no test evidence file found
- **`reviewer` agent** (#43) — dedicated read-only code reviewer with `disallowedTools: [Write, Edit]` enforcement. Reviews code quality, security (OWASP Top 10), patterns; posts findings via GitHub MCP comments with severity classification (`[BLOCKER]`, `[MAJOR]`, `[MINOR]`, `[NIT]`). Memory scoping consistent with all other agents.

### Changed
- **Oracle as entry point** (#27) — oracle.md rewritten as single entry point for all feature work: 6-phase orchestration flow (discovery, planning, distribution, monitoring, review orchestration, merge), communication protocol with SendMessage patterns, delegation template, explicit boundaries (no code, no review, no merge without user confirmation). README updated with orchestration flow diagram.

### Added
- **Three-level scoped memory system** (#25) — adapted from bike-shop Memory System v0.3.0
  - Three scopes: `team` (global), `team:{project}` (project), `{agent}:{project}` (agent)
  - 5 primary memory types: `decision`, `fact`, `preference`, `procedure`, `outcome`
  - New `mem0_recall_context` tool — queries all 3 scopes in one call with retrieval budget (~13 items)
  - Save protocol: classify scope → classify type → check duplicates → store/update
  - Memory hygiene criteria with per-scope cleanup protocol
  - All 6 agents updated with Memory Scoping section
  - `meta-orchestration` skill rewritten with three-level scoping, retrieval flow, and save protocol
  - Reference docs updated: `knowledge-structure.md`, `hygiene.md`
- **`dev-pipeline` skill** (#26) — mandatory delivery pipeline: CODE → SELF-JUDGE → QA → PR → REVIEW → FIX loop. 8 reference files covering stages, transitions, self-judge checklist, QA protocol, review handoff, and templates
- **7 new state-of-the-art skills** (#24)
  - `sre-observability` — OpenTelemetry, SLOs, incident response, dashboards
  - `local-infrastructure` — Docker, compose, databases, service orchestration
  - `software-architecture` — SOLID, ADR, C4, trade-offs, API design
  - `dev-methodology` — full dev workflow, TDD, refactoring, vertical slicing
  - `research` — search strategies, source validation, synthesis, debate frameworks
  - `meta-orchestration` — task routing, agent coordination, Mem0 management
  - `qa` — E2E testing, Definition of Done, environment setup/teardown
- **Language Rules** foundational principle in CLAUDE.md — strict language separation by context

### Changed
- **All 15 skills** now declare "Skill global — carregada automaticamente por todos os agents"
  - 9 skills updated: arch-py, arch-ts, ai-engineer, review-py, review-ts, product-manager, github, frontend-design, research

## [0.2.0] - 2026-03-31

### Added
- **Frontend ecosystem**: 3 new skills + 2 new expert agents (44 files, ~15,300 lines)
  - **arch-ts** skill — TypeScript/Frontend architecture: type system, React patterns, RSC, state management, testing, tooling (19 reference files)
  - **review-ts** skill — Frontend code review: templates, checklist (28 checks), severity criteria, accessibility + styling categories (7 files)
  - **frontend-design** skill — UI/UX/Visual design: OKLCH colors, fluid typography, modern CSS layout, motion, UX patterns, WCAG 2.2, shadcn/ui ecosystem, 2026 visual trends (16 reference files)
  - **dev-ts** agent — TypeScript/Frontend developer with 8-step workflow, test-first, accessibility-first, bundle-aware
  - **review-ts** agent — Systematic frontend code review between git branches with accessibility and bundle impact analysis
- **Semantic Memory MCP server** (`mcp/mem0-server/`) — shared vector memory via Qdrant + Ollama embeddings
  - 6 tools: `mem0_store`, `mem0_recall`, `mem0_search`, `mem0_list`, `mem0_delete`, `mem0_update`
  - No LLM required — Claude Code handles intelligence, server is pure storage + semantic search
  - Persistent memory across terminals and sessions
  - Metadata: type (feedback/project/reference/decision/procedural), project, tags
  - Local embeddings via Ollama (nomic-embed-text) + Qdrant vector DB
- **Multi-Oracle coordination** via Agent Teams + Mem0 shared memory
  - Coordination memory types: `task_claim`, `blocker`, `progress`, `conflict`
  - Startup/shutdown protocols for multi-instance coordination
  - Task deduplication and conflict detection via Mem0
  - Team patterns: parallel experts, research+build, multi-Oracle
- **Worktree enforcement hook** (`hooks/enforce-worktree.sh`) — deterministic SessionStart hook that blocks sessions not in a worktree
  - Tests: 5 cases (main repo blocked, worktree allowed, non-git allowed, empty cwd, actionable error message)
- **`github_merge_pr` tool** in GitHub MCP server — merge PRs via bot identity with merge/squash/rebase support
- **Semantic Router** in founds agents — dynamic model selection (haiku/sonnet/opus), thinking depth, and expert delegation based on task complexity
- `.mcp.json.example` — template with all MCP server configs and env var placeholders
- `isolation: worktree` enforced on all 9 agents
- Foundational principles in CLAUDE.md:
  - "GitHub Operations" — all GitHub writes must use MCP tools
  - "Branch Discipline" — one branch per change, never commit to a branch under review
  - "Dependency Pinning" — exact versions only (`==`), never `>=`
  - "Local AI Performance" — native inference, no thinking models for automation
  - "Agent Isolation" expanded — scope changed from agents-only to all sessions + agents; enforcement via hook

### Changed
- **Workspace → Mem0 migration**: all agents now use Mem0 for project context instead of `.claude/workspace/` files
  - Explorer, Builder, dev-py, dev-ts, review-py, review-ts, architect all migrated
  - Oracle knowledge base moved from markdown files to Mem0
  - 23 memories migrated successfully
- Oracle agent rewritten: markdown knowledge base → Mem0, added Agent Teams coordination
- Oracle Semantic Router: experts and skills now discovered dynamically from directories
- Oracle frontmatter: added arch-ts, review-ts, frontend-design skills
- GitHub MCP server: removed `apps.json` — all credentials now via env vars
- GitHub skill updated to reference env vars instead of apps.json
- All dependencies pinned to exact stable versions (mcp==1.26.0, qdrant-client==1.17.1, httpx==0.28.1, PyJWT==2.12.1, pydantic==2.12.5)
- Debater agent: replaced hardcoded personal paths with `$HOME` env var

### Removed
- `setup/` directory — stale bootstrap; MCPs now configured via `.mcp.json`
- `mcp/github-server/apps.json` — replaced by env vars
- `hooks/memory-keeper-restore.sh`, `memory-keeper-save.sh`, `memory-keeper-purge.sh` — replaced by Mem0 MCP
- Memory-keeper hooks from `settings.json` (SessionStart, PreCompact, Stop)
- `mcp__memory-keeper__*` permission from settings.json

## [0.1.0] - 2026-03-30

### Added
- Agent autonomy rules with auto mode configuration
- PR standards: mandatory CHANGELOG, README, and API collection updates
- PR docs check hook (`hooks/pr-docs-check.sh`) — blocks PR creation without CHANGELOG
- CHANGELOG.md tracking

### Changed
- Reorganized agents into `founds/` (oracle, sentinel) and `experts/` (architect, dev-py, review-py, debater, tech-pm, explorer, builder)
- CLAUDE.md rewritten with founds/experts architecture, autonomy rules, and PR checklist
- README rewritten — project-agnostic, with autonomy and PR standards docs

### Removed
- `agents/slack-monitor.md` — unused
- `agents/memory-agent.md` — concept replaced by Mem0 MCP (planned)
- `agents/executor.md` — pipeline never used
- `agents/adapters/slack.md` — procedural doc with hardcoded paths
- `skills/sre-observability.md` — inlined into sentinel
