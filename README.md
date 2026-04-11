<div align="center">

# Zeroone

### Composable AI agents. Persistent memory. One ecosystem.

[![Claude Code](https://img.shields.io/badge/Claude_Code-CLI-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Agents](https://img.shields.io/badge/8_Agents-Ready-blue?style=for-the-badge)](#-agents)
[![Skills](https://img.shields.io/badge/16_Skills-Loaded-purple?style=for-the-badge)](#-skills)
[![Memory](https://img.shields.io/badge/Mem0-Shared_Memory-green?style=for-the-badge)](#-shared-memory-mem0)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**Turn `~/.claude` into a fully autonomous development environment.**
**8 persona-based agents, 16 knowledge bases, shared semantic memory, and zero configuration.**

[Quick Start](#quick-start) · [Agents](#agents) · [Skills](#skills) · [Memory](#memory) · [Workspaces](#workspaces) · [Infrastructure](#infrastructure)

</div>

---

## What is Zeroone?

**Zeroone** is the foundation layer for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code). Clone it, sync it, and every project you work on gets:

- **8 persona-based AI agents** with distinct personalities covering the full dev lifecycle
- **Shared semantic memory** that persists across sessions and terminals (Mem0 + Qdrant)
- **Auto mode permissions** — agents work autonomously, only stop for critical decisions
- **PR quality hooks** — CHANGELOG and docs enforced programmatically
- **Multi-agent coordination** — parallel work with git worktrees and Agent Teams

Any project built on this foundation inherits all capabilities automatically.

---

## Features

**Matrix Persona Agents** — 8 agents with distinct personalities (the_architect, neo, trinity, morpheus, oracle, cypher, reviewer, zeroone). Same skills, different lenses. Adversarial review flow: neo (draft) -> the_architect (judge) -> morpheus (debate).

**Shared Semantic Memory** — Mem0 MCP server backed by Qdrant + Ollama. Store decisions, procedures, context. Search semantically. Persists across terminal restarts. Multiple agents share the same memory pool.

**Research-First Decisions** — Every technical decision backed by current web research. Agents search the web, cross multiple sources, and cite them. Never rely on stale training data.

**Full Autonomy with Guardrails** — Auto mode lets agents code, commit, create PRs, run tests — without asking. Only security-critical operations (secrets, deletions, force-push) require approval.

**PR Quality Enforcement** — Hook blocks PR creation unless CHANGELOG is updated. Warns about README and API collection gaps. No documentation debt.

**Parallel Execution** — Git worktrees isolate filesystem per agent. Agent Teams coordinate via shared task lists and messaging. Mem0 provides persistent cross-agent context.

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
| [Docker](https://docker.com) | Runs Qdrant + Ollama for shared memory |
| Node.js 18+ | MCP server runtime |

### Configure MCP servers

```bash
# Copy the example and fill in your credentials
cp .mcp.json.example .mcp.json

# Edit .mcp.json and set your values:
# - GitHub: GITHUB_APP_ID, GITHUB_APP_PEM_PATH, GITHUB_APP_INSTALLATION_ID, GITHUB_APP_SLUG
# - Mem0: defaults work for local Docker (localhost:6333, localhost:11434)
# - Langfuse: LANGFUSE_PUBLIC_KEY, LANGFUSE_SECRET_KEY (optional)
```

See [`.mcp.json.example`](.mcp.json.example) for all available env vars.

### Start memory infrastructure

```bash
# Start Qdrant (from the zeroone repo)
cd infra && docker compose up -d

# Start Ollama natively (not containerized — required for GPU acceleration)
ollama serve

# Pull the embedding model
ollama pull nomic-embed-text
```

See [`infra/README.md`](infra/README.md) for full setup details, port reference, and troubleshooting.

---

## Agents

8 agents with distinct personalities. All share the same skills (loaded globally). Differentiation is personality only.

| Agent | Personality | Use case |
|-------|------------|----------|
| **the_architect** | Perfectionist, visionary, 5-year horizon. No shortcuts. | Final design, critical decisions, quality gate, judge |
| **neo** | Pragmatic, fast, MVP-first. YAGNI. | First draft, MVPs, rapid iteration, discovery |
| **trinity** | Executor, surgical, closer. | Precise execution, finalize work, delivery |
| **morpheus** | Socratic, questioner, mentor. | Debates, exploration, questioning, mentoring |
| **oracle** | Holistic, cross-project vision. Living memory. **Entry point for all feature work.** | Feature orchestration, discovery, planning, distribution, monitoring, review, merge |
| **cypher** | Pure SRE. Numbers and tables, not essays. | Infra ops, monitoring, incident response, health checks |
| **reviewer** | Read-only, detail-oriented code reviewer. | Code quality, security audits, PR review comments |
| **zeroone** | Ecosystem controller. Detects drift, syncs, manages infra. | Sync agents/skills to ~/.claude, setup project workspaces, check infra health |

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
~/.claude/
├── agents/                        # Matrix Personas (flat directory)
│   ├── the_architect.md           #   Perfectionist, quality gate, judge
│   ├── neo.md                     #   Pragmatic, MVP-first, fast mover
│   ├── trinity.md                 #   Executor, surgical closer
│   ├── morpheus.md                #   Socratic questioner, mentor
│   ├── oracle.md                  #   Ecosystem manager, living memory
│   ├── cypher.md                  #   Pure SRE, numbers and tables
│   ├── reviewer.md                #   Read-only code reviewer
│   └── zeroone.md                 #   Ecosystem controller (sync, setup, status)
│
├── workspaces/                    # Per-project knowledge bases
│   └── {project}/                 #   context.md, decisions.md, runbook.md
│
├── infra/                         # Memory infrastructure
│   ├── docker-compose.yml         #   Qdrant v1.17.1 (persistent volume)
│   └── README.md                  #   Startup guide, ports, troubleshooting
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
