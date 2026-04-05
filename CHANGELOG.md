# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **7 new state-of-the-art skills** (#24)
  - `sre-observability` — OpenTelemetry, SLOs, incident response, dashboards
  - `local-infrastructure` — Docker, compose, databases, service orchestration
  - `software-architecture` — SOLID, ADR, C4, trade-offs, API design
  - `dev-methodology` — full dev workflow, TDD, refactoring, vertical slicing
  - `research` — search strategies, source validation, synthesis, debate frameworks
  - `meta-orchestration` — task routing, agent coordination, Mem0 management
  - `qa` — E2E testing, Definition of Done, environment setup/teardown

### Changed
- **Agent architecture: Matrix Personas** — replaced founds/experts model with 6 persona-only agents
  - Deleted all 11 old agents (2 founds + 9 experts)
  - Created 6 new agents: the_architect, neo, trinity, morpheus, oracle, cypher
  - Agents now define only personality and behavior — zero technical knowledge
  - Skills are global: loaded automatically by ALL agents, no per-agent declaration
  - Adversarial review flow: neo (draft) -> the_architect (judge) -> morpheus (debate)
- **Skills cleaned of persona content** — removed personality/tone sections from 8 skills
  - arch-py, arch-ts: removed "Verificabilidade" persona sections
  - ai-engineer: removed philosophical framing
  - review-py, review-ts: removed persona communication sections
  - product-manager: removed opinionated tone
  - github: removed enforcer persona
  - frontend-design: removed philosophical framing
- **CLAUDE.md** updated to document new Matrix agent architecture
- **Skills are now global** — all skills loaded automatically by ALL agents, no per-agent declaration
- **Agents are persona-only** — zero technical knowledge in agent files, personality + tools only
- Agent directory flattened — removed `founds/` and `experts/` subdirectories
- Existing skills cleaned of persona/personality content (review-py, review-ts, arch-py, arch-ts, etc.)
- CLAUDE.md rewritten for Matrix Agent Architecture

### Removed
- `agents/founds/` directory — oracle and sentinel replaced by new agents
- `agents/experts/` directory — all 9 experts replaced by new agents + skills
- Persona/tone content from all existing skills

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
