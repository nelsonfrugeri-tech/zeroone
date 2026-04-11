<div align="center">

# Zeroone

### Composable AI agents. Persistent memory. One ecosystem.

[![Claude Code](https://img.shields.io/badge/Claude_Code-CLI-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Agents](https://img.shields.io/badge/7_Agents-Ready-blue?style=for-the-badge)](#agents)
[![Skills](https://img.shields.io/badge/16_Skills-Loaded-purple?style=for-the-badge)](#skills)
[![Memory](https://img.shields.io/badge/Mem0-Shared_Memory-green?style=for-the-badge)](#memory)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**Turn `~/.claude` into a fully autonomous development environment.**
**7 role-based agents, 16 knowledge bases, shared semantic memory, and one bootstrap.**

[Quick Start](#quick-start) · [Agents](#agents) · [Skills](#skills) · [Memory](#memory) · [Scripts](#scripts) · [Infrastructure](#infrastructure)

</div>

---

## What is Zeroone?

**Zeroone** is a standalone manager for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code). Clone it, bootstrap it, and every project you work on gets:

- **7 role-based AI agents** covering the full dev lifecycle
- **16 composable skills** (8 methodology + 8 domain knowledge)
- **Shared semantic memory** that persists across sessions (Mem0 + Qdrant + Ollama)
- **Auto mode permissions** — agents work autonomously, only stop for critical decisions
- **Granular control** — sync specific agents, skills, or MCPs to `~/.claude/`

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/nelsonfrugeri-tech/dev-in-the-loop.git
cd dev-in-the-loop

# 2. Bootstrap (installs everything: Ollama, Qdrant, embeddings, MCP deps, sync)
bash scripts/bootstrap.sh

# 3. Use any agent from any project
claude --agent developer     # Implement features, fix bugs
claude --agent architect     # System design, ADRs, trade-offs
claude --agent ai-engineer   # LLM, RAG, data pipelines
```

That's it. One command sets up the full ecosystem.

### Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | AI agent runtime | `npm install -g @anthropic-ai/claude-code` |
| [Docker](https://docker.com) | Runs Qdrant (vector DB) | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| [uv](https://docs.astral.sh/uv/) | Python package manager | `brew install uv` |

`bootstrap.sh` handles everything else — Ollama, embedding models, MCP server deps, and syncing to `~/.claude/`.

### Configure MCP servers

```bash
# bootstrap.sh generates .mcp.json from .mcp.json.example with absolute paths
# For GitHub MCP, set your token:
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token"
```

| MCP Server | Type | Purpose | Config needed |
|------------|------|---------|---------------|
| **github** | HTTP (remote) | GitHub integration | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **mem0** | stdio | Semantic memory | Defaults work (localhost) |
| **excalidraw** | stdio | Diagrams | None |
| **drawio** | stdio | Diagrams | None |
| **langfuse** | stdio | LLM observability | `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY` (optional) |

---

## Agents

7 role-based agents. Each has a distinct persona and loads specific skills via frontmatter.

| Agent | Model | Skills | Use case |
|-------|-------|--------|----------|
| **developer** | sonnet | implement, test, environment, review, research, ai-engineer | Features, bugs, refactoring, production-ready code |
| **architect** | opus | design, review, research, api-design, security | System design, ADRs, C4 diagrams, trade-off analysis |
| **ai-engineer** | sonnet | ai-engineer, implement, test, environment, review, research | LLM systems, RAG, embeddings, vector DBs, data pipelines |
| **qa** | sonnet | test, environment, review, research | E2E/integration/performance/accessibility testing |
| **sre** | sonnet | operate, review, research, observability, security | Monitoring, alerting, SLO/SLI, incident response, runbooks |
| **tech_pm** | sonnet | manage, review, research | User stories, prioritization, roadmaps, PRDs |
| **zeroone** | sonnet | environment, operate | Ecosystem controller — sync, status, setup workspaces |

### Zeroone Controller

The `zeroone` agent manages the ecosystem itself:

| Command | What it does |
|---------|-------------|
| `status` | Compare repo vs `~/.claude/` — detect drift in agents, skills, settings, infra |
| `sync` | Deploy agents, skills, settings, CLAUDE.md, MCP config to `~/.claude/` |
| `setup {project}` | Create workspace + Qdrant collection for a new project |

---

## Skills

16 composable skills — each is a detailed knowledge base (400-700 lines) with references.

### Capability Skills (8) — Methodology

| Skill | Purpose |
|-------|---------|
| **implement** | TDD/BDD, bug fix protocol, refactoring patterns, vertical slicing, Definition of Done |
| **test** | Testing strategy (pyramid vs trophy), E2E, contract, performance, accessibility |
| **design** | SOLID, ADR, C4 Model, trade-off analysis (ATAM), system decomposition |
| **environment** | Docker Compose, databases, service orchestration, health checks, hot reload |
| **operate** | Three pillars (logs, metrics, traces), SLI/SLO, incident response, alerting |
| **manage** | INVEST stories, RICE/MoSCoW, roadmaps, PRDs, AARRR metrics |
| **review** | Language-agnostic code review, severity taxonomy (BLOCKER/MAJOR/MINOR/NIT) |
| **research** | Technical research methodology, source validation, synthesis templates |

### Knowledge Skills (8) — Domain

| Skill | Purpose |
|-------|---------|
| **python** | Type system, async/await, Pydantic v2, structlog, pytest, ruff/mypy |
| **typescript** | Discriminated unions, React 19+, Server Components, Zustand, Tailwind, Vitest |
| **api-design** | REST, GraphQL, gRPC, OpenAPI, versioning, pagination, error responses |
| **security** | OWASP Top 10, STRIDE, zero trust, auth patterns, secrets management |
| **observability** | OpenTelemetry, Prometheus, Grafana, Jaeger, Langfuse |
| **ai-engineer** | LLM integration, RAG, Qdrant, semantic caching, LangGraph, testing AI systems |
| **frontend-ui** | OKLCH color, fluid typography, container queries, WCAG 2.2, design systems |
| **ci-cd** | GitHub Actions, quality gates, blue/green, canary, release management |

---

## Memory

Persistent semantic memory via Qdrant + Ollama embeddings, exposed through the Mem0 MCP server.

### Two-Scope Model

| Scope | user_id format | Purpose | Who reads |
|-------|---------------|---------|-----------|
| **Project** | `project:{name}` | Shared decisions, architecture, conventions | All agents |
| **Agent** | `{agent}:{project}` | Personal learnings, attempts, errors | Only that agent |

### MCP Tools

| Tool | Purpose |
|------|---------|
| `mem0_store` | Save a memory with type and scope |
| `mem0_recall` | Semantic search (single scope) |
| `mem0_recall_context` | Dual-scope retrieval (agent + project in one call) |
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

## Scripts

| Script | Purpose | When to use |
|--------|---------|-------------|
| `scripts/bootstrap.sh` | Complete first-run setup (Ollama, Qdrant, embeddings, MCP deps, sync) | First time after clone |
| `scripts/sync.sh` | Deploy agents, skills, settings, CLAUDE.md, .mcp.json to `~/.claude/` | After any change to the repo |
| `scripts/status.sh` | Compare repo vs `~/.claude/`, check infra health | To detect drift |
| `scripts/setup-project.sh {name}` | Create workspace + Qdrant collection | Starting a new project |

### What `sync.sh` deploys

```
zeroone repo                    ~/.claude/
├── agents/*.md           →     ├── agents/*.md
├── skills/               →     ├── skills/
├── config/settings.base.json → ├── settings.json
├── config/CLAUDE.global.md   → ├── CLAUDE.md
└── .mcp.json.example     →     .mcp.json (absolute paths)
```

---

## Infrastructure

```
Agent → MCP (mem0-server) → Qdrant (port 6333)
                          → Ollama (port 11434)
```

| Component | Runtime | Port | Purpose |
|-----------|---------|------|---------|
| **Qdrant** | Docker (`infra/docker-compose.yml`) | 6333 | Vector DB for semantic memory |
| **Ollama** | Native (not containerized) | 11434 | Embedding model runtime (GPU acceleration) |
| **nomic-embed-text** | Ollama model | — | 768-dim embedding model |

```bash
# Health check
bash scripts/status.sh
```

---

## Project Structure

```
zeroone/
├── agents/                     # 7 agent definitions
│   ├── developer.md
│   ├── architect.md
│   ├── ai-engineer.md
│   ├── qa.md
│   ├── sre.md
│   ├── tech_pm.md
│   └── zeroone.md
│
├── skills/                     # 16 skills (SKILL.md + references/)
│   ├── implement/              ├── python/
│   ├── test/                   ├── typescript/
│   ├── design/                 ├── api-design/
│   ├── environment/            ├── security/
│   ├── operate/                ├── observability/
│   ├── manage/                 ├── ai-engineer/
│   ├── review/                 ├── frontend-ui/
│   └── research/               └── ci-cd/
│
├── config/                     # Deployment templates
│   ├── settings.base.json      #   Global Claude Code settings
│   └── CLAUDE.global.md        #   Global agent instructions
│
├── mcp/                        # Custom MCP servers
│   └── mem0-server/            #   Semantic memory (Qdrant + Ollama)
│
├── infra/                      # Docker Compose (Qdrant)
│   └── docker-compose.yml
│
├── scripts/                    # Ecosystem operations
│   ├── bootstrap.sh            #   First-run complete setup
│   ├── sync.sh                 #   Deploy to ~/.claude/
│   ├── status.sh               #   Drift detection + health check
│   └── setup-project.sh        #   Create project workspace
│
├── workspaces/                 # Per-project knowledge bases
├── .mcp.json.example           # MCP server config template
├── CLAUDE.md                   # Project-level instructions
├── CHANGELOG.md
└── README.md
```

---

## Autonomy & Permissions

### Full autonomy
Read/write code, run builds/tests, git operations, Docker, package managers, MCP tools.

### Requires approval
File deletion, secrets/credentials, force push, destructive git, production deploys, external messages.

---

## License

MIT

---

<div align="center">

**The foundation for AI-powered development**

[![Claude Code](https://img.shields.io/badge/Powered_by-Claude_Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)

</div>
