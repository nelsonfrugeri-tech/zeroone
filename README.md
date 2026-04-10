<div align="center">

# Zeroone

### Composable AI agents. Persistent memory. One ecosystem.

[![Claude Code](https://img.shields.io/badge/Claude_Code-CLI-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Agents](https://img.shields.io/badge/7_Agents-Ready-blue?style=for-the-badge)](#agents)
[![Skills](https://img.shields.io/badge/16_Skills-Composable-purple?style=for-the-badge)](#skills)
[![Memory](https://img.shields.io/badge/Mem0-Semantic_Memory-green?style=for-the-badge)](#memory)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**Your `~/.claude` as a fully autonomous development environment.**
**7 functional agents, 16 composable skills, semantic memory, zero configuration.**

[Quick Start](#quick-start) · [Agents](#agents) · [Skills](#skills) · [Memory](#memory) · [Workspaces](#workspaces) · [Infrastructure](#infrastructure)

</div>

---

## What is Zeroone?

**Zeroone** is the foundation layer for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code). Clone it, sync it, and every project you work on gets:

- **7 functional AI agents** — each with a distinct role and composable skill set
- **16 skills** — 8 capability (methodology) + 8 knowledge (domain expertise)
- **Semantic memory** — persistent across sessions via Qdrant + Ollama embeddings
- **Project workspaces** — per-project knowledge bases versioned in git
- **Ecosystem controller** — the `zeroone` agent that manages it all

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/nelsonfrugeri-tech/claude-code.git ~/projects/zeroone
cd ~/projects/zeroone

# 2. Set env var (add to your shell profile)
export ZEROONE_HOME="$HOME/projects/zeroone"

# 3. Start memory infrastructure
docker compose -f infra/docker-compose.yml up -d   # Qdrant
ollama pull nomic-embed-text                         # Embedding model

# 4. Sync agents and skills to ~/.claude
bash scripts/sync.sh

# 5. Use any agent from any project
claude --agent developer     # Implement features, fix bugs
claude --agent architect     # System design, ADRs, trade-offs
claude --agent ai-engineer   # LLM, RAG, data pipelines
```

### Prerequisites

| Tool | Purpose |
|------|---------|
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` |
| [Docker](https://docker.com) | Runs Qdrant for semantic memory |
| [Ollama](https://ollama.com) | Local embeddings (nomic-embed-text) — runs native, not containerized |

---

## Agents

7 functional agents. Each composes a specific set of skills via `skills:` frontmatter.

| Agent | Model | Role | Skills |
|-------|-------|------|--------|
| **architect** | opus | System design, ADRs, C4 diagrams, trade-offs | design, review, research, api-design, security |
| **developer** | sonnet | Features, bugs, refactoring, environments, tests | implement, test, environment, review, research, ai-engineer |
| **ai-engineer** | sonnet | LLM integration, RAG, embeddings, data pipelines, ML infra | ai-engineer, implement, test, environment, review, research |
| **tech_pm** | sonnet | User stories, backlog, roadmap, stakeholder communication | manage, review, research |
| **qa** | sonnet | Testing strategy, E2E, integration, performance, validation | test, environment, review, research |
| **sre** | sonnet | Observability, monitoring, SLOs, incidents, alerting | operate, review, research, observability, security |
| **zeroone** | sonnet | Ecosystem controller — sync, status, setup | environment, operate |

### Zeroone Controller

| Command | What it does |
|---------|-------------|
| `status` | Compare repo vs `~/.claude/` — detect drift, check infra health |
| `sync` | Deploy agents and skills from repo to `~/.claude/` |
| `setup {project}` | Create workspace + Qdrant collection for a new project |

Operations live in `scripts/` (status.sh, sync.sh, setup-project.sh).

---

## Skills

16 composable skills — agents load only what they need.

### Capability Skills (8) — Methodology

| Skill | Purpose |
|-------|---------|
| **review** | Language-agnostic review. Severity: BLOCKER/MAJOR/MINOR/NIT |
| **research** | Structured technical research. Platform strategies, validation, synthesis |
| **implement** | Development workflow. TDD/BDD, bug fix protocol, refactoring, vertical slicing |
| **test** | Testing strategy. Pyramid vs trophy, E2E, contract, performance, accessibility |
| **design** | System design. SOLID, ADR, C4 Model, trade-off analysis, decomposition |
| **environment** | Local environments. Docker Compose, databases, service readiness, teardown |
| **manage** | Product management. INVEST stories, RICE/MoSCoW, PRD, metrics |
| **operate** | Production operations. Three pillars, SLI/SLO, incident response, alerting |

### Knowledge Skills (8) — Domain

| Skill | Purpose |
|-------|---------|
| **python** | Type system, async/await, Pydantic v2, structlog, pytest, ruff/mypy |
| **typescript** | Discriminated unions, React 19+, Server Components, Zustand, Tailwind, Vitest |
| **api-design** | REST, GraphQL, gRPC, OpenAPI, versioning, pagination, error responses |
| **security** | OWASP Top 10, STRIDE, zero trust, auth patterns, secrets management |
| **observability** | OpenTelemetry, Prometheus, Grafana, Jaeger, Langfuse |
| **ai-engineer** | LLM integration, RAG, Qdrant, semantic caching, LangGraph |
| **frontend-ui** | OKLCH color, fluid typography, container queries, WCAG 2.2, design systems |
| **ci-cd** | GitHub Actions, quality gates, blue/green, canary, release management |

---

## Memory

Persistent semantic memory via Qdrant + Ollama embeddings.

### Two-Scope Model

| Scope | user_id | Purpose | Who reads |
|-------|---------|---------|-----------|
| **Project** | `project:{name}` | Shared decisions, architecture, conventions | All agents |
| **Agent** | `{agent}:{project}` | Personal learnings, attempts, errors | Only that agent |

### MCP Tools

| Tool | Purpose |
|------|---------|
| `mem0_store` | Save a memory with type and scope |
| `mem0_recall` | Semantic search (single scope) |
| `mem0_recall_context` | Query both scopes in one call (~10 item budget) |
| `mem0_search` | Search with filters (type, project) |
| `mem0_list` | List all memories for a scope |
| `mem0_update` | Update content (re-embeds automatically) |
| `mem0_delete` | Remove by ID or all for a scope |

### Memory Types

| Type | When to store |
|------|--------------|
| `decision` | Technical or product choice with rationale |
| `fact` | Verified project or domain knowledge |
| `preference` | Stated preference from user |
| `procedure` | Reusable workflow |
| `outcome` | Completed task result |

---

## Workspaces

Per-project knowledge bases in `workspaces/{project}/`:

```
workspaces/checkout-ecom/
├── context.md       # Project overview, stack, conventions
├── decisions.md     # Architecture decisions log
└── runbook.md       # Operational runbook
```

Agents discover workspaces via `$ZEROONE_HOME`. Workspaces complement Qdrant memory: static curated knowledge (git) vs dynamic work memories (vector search).

---

## Infrastructure

```
Agent → MCP (mem0-server) → Qdrant (port 6333)
                          → Ollama (port 11434)
```

| Component | How | Why |
|-----------|-----|-----|
| Qdrant | Docker Compose (`infra/docker-compose.yml`) | Vector DB for semantic memory |
| Ollama | Native (not containerized) | GPU acceleration for embeddings |
| nomic-embed-text | `ollama pull nomic-embed-text` | 768-dim embedding model |

```bash
# Start
docker compose -f infra/docker-compose.yml up -d
ollama pull nomic-embed-text

# Verify
bash scripts/status.sh
```

---

## Project Structure

```
zeroone/
├── agents/                     # Agent definitions (persona + skills)
│   ├── architect.md
│   ├── developer.md
│   ├── ai-engineer.md
│   ├── tech_pm.md
│   ├── qa.md
│   ├── sre.md
│   └── zeroone.md
│
├── skills/                     # 8 capability + 8 knowledge
│   ├── review/                 ├── python/
│   ├── research/               ├── typescript/
│   ├── implement/              ├── api-design/
│   ├── test/                   ├── security/
│   ├── design/                 ├── observability/
│   ├── environment/            ├── ai-engineer/
│   ├── manage/                 ├── frontend-ui/
│   └── operate/                └── ci-cd/
│
├── scripts/                    # Ecosystem operations
│   ├── status.sh
│   ├── sync.sh
│   └── setup-project.sh
│
├── workspaces/                 # Per-project knowledge bases
├── infra/                      # Docker Compose (Qdrant)
├── mcp/mem0-server/            # Semantic memory MCP
├── CLAUDE.md                   # Global agent instructions
├── CHANGELOG.md
└── README.md
```

---

## Autonomy & Permissions

### Full autonomy
Read/write code, run builds/tests, git operations, Docker, MCP tools.

### Requires approval
File deletion, secrets, force push, destructive git, production deploys, external messages.

---

## License

MIT

---

<div align="center">

**The foundation for AI-powered development**

[![Claude Code](https://img.shields.io/badge/Powered_by-Claude_Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)

</div>
