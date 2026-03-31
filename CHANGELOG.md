# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Multi-Oracle coordination via Agent Teams + Mem0 shared memory
  - Coordination memory types: `task_claim`, `blocker`, `progress`, `conflict`
  - Startup/shutdown protocols for multi-instance coordination
  - Task deduplication and conflict detection via Mem0
  - Team patterns: parallel experts, research+build, multi-Oracle
- Semantic Memory MCP server (`mcp/mem0-server/`) — shared vector memory via Qdrant + Ollama embeddings
  - 6 tools: `mem0_store`, `mem0_recall`, `mem0_search`, `mem0_list`, `mem0_delete`, `mem0_update`
  - No LLM required — Claude Code handles intelligence, server is pure storage + semantic search
  - Persistent memory across terminals and sessions
  - Metadata: type (feedback/project/reference/decision/procedural), project, tags
  - Local embeddings via Ollama (nomic-embed-text) + Qdrant vector DB
- "Local AI Performance" foundational principle in CLAUDE.md

### Changed
- Oracle agent rewritten: markdown knowledge base → Mem0, memory-keeper → Mem0, added Agent Teams coordination
- Memory system migrated from markdown files + memory-keeper hooks to Qdrant vector store
- GitHub MCP server: removed `apps.json` — all credentials now via env vars (`GITHUB_APP_ID`, `GITHUB_APP_PEM_PATH`, `GITHUB_APP_INSTALLATION_ID`, `GITHUB_APP_SLUG`)
- GitHub skill updated to reference env vars instead of apps.json
- All dependencies pinned to exact stable versions (mcp==1.26.0, qdrant-client==1.17.1, httpx==0.28.1, PyJWT==2.12.1, pydantic==2.12.5)

### Added
- `.mcp.json.example` — template with all MCP server configs and env var placeholders
- `isolation: worktree` enforced on all 9 agents — every agent runs in an isolated git worktree
- Semantic Router in founds agents — dynamic model selection (haiku/sonnet/opus), thinking depth, and expert delegation based on task complexity
- Dependency Pinning foundational principle — exact versions only (`==`), never `>=`

### Removed
- `mcp/github-server/apps.json` — contained hardcoded credentials, replaced by env vars
  - 23 memories migrated successfully
  - Content stored intact (no LLM extraction loss)

### Removed
- `hooks/memory-keeper-restore.sh` — replaced by Mem0 MCP
- `hooks/memory-keeper-save.sh` — replaced by Mem0 MCP
- `hooks/memory-keeper-purge.sh` — replaced by Mem0 MCP
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
