<div align="center">

# Claude Code

### Your AI agents never forget. They research, they collaborate, they ship.

[![Claude Code](https://img.shields.io/badge/Claude_Code-CLI-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Agents](https://img.shields.io/badge/6_Agents-Ready-blue?style=for-the-badge)](#-agents)
[![Skills](https://img.shields.io/badge/16_Skills-Loaded-purple?style=for-the-badge)](#-skills)
[![Memory](https://img.shields.io/badge/Mem0-Shared_Memory-green?style=for-the-badge)](#-shared-memory-mem0)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**Turn `~/.claude` into a fully autonomous development environment.**
**6 persona-based agents, 16 knowledge bases, shared semantic memory, and zero configuration.**

[Features](#-features) · [Quick Start](#-quick-start) · [Agents](#-agents) · [Memory](#-shared-memory-mem0) · [Autonomy](#-autonomy--permissions) · [Hooks](#-hooks)

</div>

---

## What is this?

**claude-code** is the foundation layer that makes [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) intelligent. Install it once, and every project you work on gets:

- **6 persona-based AI agents** with distinct personalities covering the full dev lifecycle
- **Shared semantic memory** that persists across sessions and terminals (Mem0 + Qdrant)
- **Auto mode permissions** — agents work autonomously, only stop for critical decisions
- **PR quality hooks** — CHANGELOG and docs enforced programmatically
- **Multi-agent coordination** — parallel work with git worktrees and Agent Teams

Any project built on this foundation inherits all capabilities automatically.

---

## Features

**Matrix Persona Agents** — 6 agents with distinct personalities (the_architect, neo, trinity, morpheus, oracle, cypher). Same skills, different lenses. Adversarial review flow: neo (draft) -> the_architect (judge) -> morpheus (debate).

**Shared Semantic Memory** — Mem0 MCP server backed by Qdrant + Ollama. Store decisions, procedures, context. Search semantically. Persists across terminal restarts. Multiple agents share the same memory pool.

**Research-First Decisions** — Every technical decision backed by current web research. Agents search the web, cross multiple sources, and cite them. Never rely on stale training data.

**Full Autonomy with Guardrails** — Auto mode lets agents code, commit, create PRs, run tests — without asking. Only security-critical operations (secrets, deletions, force-push) require approval.

**PR Quality Enforcement** — Hook blocks PR creation unless CHANGELOG is updated. Warns about README and API collection gaps. No documentation debt.

**Parallel Execution** — Git worktrees isolate filesystem per agent. Agent Teams coordinate via shared task lists and messaging. Mem0 provides persistent cross-agent context.

---

## Quick Start

```bash
# Install
git clone https://github.com/nelsonfrugeri-tech/claude-code.git ~/.claude
cp ~/.claude/.mcp.json.example ~/.claude/.mcp.json
# Edit .mcp.json with your credentials

# Use any agent
claude --agent neo             # Fast, pragmatic, MVP-first
claude --agent the_architect   # Perfectionist, quality gate
claude --agent trinity         # Surgical executor, closer
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
# From any project using this foundation (e.g., bike-shop)
docker compose up -d qdrant ollama

# Pull embedding + LLM models
docker exec ollama ollama pull nomic-embed-text
docker exec ollama ollama pull qwen3:4b
```

---

## Agents

### Matrix Personas

6 agents with distinct personalities. All share the same skills (loaded globally). Differentiation is personality only.

| Agent | Personality | Use case |
|-------|------------|----------|
| **the_architect** | Perfectionist, visionary, 5-year horizon. No shortcuts. | Final design, critical decisions, quality gate, judge |
| **neo** | Pragmatic, fast, MVP-first. YAGNI. | First draft, MVPs, rapid iteration, discovery |
| **trinity** | Executor, surgical, closer. | Precise execution, finalize work, delivery |
| **morpheus** | Socratic, questioner, mentor. | Debates, exploration, questioning, mentoring |
| **oracle** | Holistic, cross-project vision. Living memory. **Entry point for all feature work.** | Feature orchestration, discovery, planning, distribution, monitoring, review, merge |
| **cypher** | Pure SRE. Numbers and tables, not essays. | Infra ops, monitoring, incident response, health checks |

### Oracle Orchestration Flow

Oracle is the **single entry point** for all feature work. The user talks to Oracle, Oracle orchestrates everything:

```
User → Oracle (discovery → planning → distribution)
  → Dev agent (code → self-judge → QA → open PR)
    → Oracle (assign different agent as reviewer)
      → Reviewer (review → approve or request changes)
        → Oracle (notify user → user tests → merge on confirmation)
```

Oracle does NOT write code, review code, or merge without user confirmation. Details in `agents/oracle.md`.

### Adversarial Review Flow

```
neo (draft) -> the_architect (judge) -> morpheus (debate) -> decision
```

### Skills — Knowledge Bases (Global)

All skills are loaded by every agent automatically.

| Skill | Domain |
|-------|--------|
| **arch-py** | Python architecture, patterns, type system, async, Pydantic v2 |
| **arch-ts** | TypeScript/Frontend architecture: React patterns, RSC, state management, testing, tooling |
| **review-py** | Python code review templates, checklists, severity criteria |
| **review-ts** | Frontend code review: accessibility, styling, bundle impact, 28 checks |
| **frontend-design** | UI/UX/Visual design: OKLCH colors, typography, layout, motion, WCAG 2.2, shadcn/ui, 2026 trends |
| **ai-engineer** | LLM engineering, RAG, agents, vector DBs, MLOps |
| **product-manager** | Discovery, delivery, OKRs, user stories, roadmap |
| **github** | GitHub operations via MCP — enforced bot-identity PRs, issues, comments |
| **dev-pipeline** | Mandatory delivery pipeline: CODE → SELF-JUDGE → QA → PR → REVIEW → FIX loop |
| **dev-methodology** | Full dev workflow: TDD, refactoring, vertical slicing, Definition of Done |
| **research** | Structured technical research: search strategies, source validation, synthesis |
| **meta-orchestration** | Task routing, agent coordination, Mem0 management, agent creation |
| **qa** | E2E testing, test strategy, Definition of Done, environment setup/teardown |
| **software-architecture** | SOLID, ADR, C4, trade-offs, API design, event-driven architecture |
| **sre-observability** | OpenTelemetry, SLOs, incident response, dashboards, cost optimization |
| **local-infrastructure** | Docker, compose, databases, service orchestration, env management |

All skills are **global** — loaded automatically by every agent. No per-agent skill declaration.

---

## Shared Memory (Mem0)

Persistent semantic memory shared across all agents and terminals, with **three-level scoping**.

### Three-Level Scoping Model

```
Mem0 (Qdrant + Ollama nomic-embed-text):
├── team scope       → user_id="team"              (global prefs, cross-project rules)
├── project scope    → user_id="team:{project}"    (architecture, stack, conventions)
└── agent scope      → user_id="{agent}:{project}" (agent's own decisions and outcomes)
```

| Scope | user_id | What goes here | Who reads |
|-------|---------|----------------|-----------|
| **Team** | `"team"` | Global preferences, cross-project procedures | All agents |
| **Project** | `"team:{project}"` | Architecture, stack decisions, conventions | All agents on that project |
| **Agent** | `"{agent}:{project}"` | Own decisions, task outcomes, patterns learned | Only that agent (+ oracle) |

### MCP Tools (7)

```
mem0_store()           ← Save with scoped user_id
mem0_recall()          ← Semantic search (single scope)
mem0_recall_context()  ← Query all 3 scopes in one call (~13 item budget)
mem0_search()          ← Filter by type, project, scope
mem0_list()            ← Browse all memories
mem0_update()          ← Modify existing memories
mem0_delete()          ← Remove outdated memories
```

### Memory Types

| Type | What to store | Example |
|------|--------------|---------|
| `decision` | Technical/product choices with rationale | "Chose OKLCH over HSL — perceptual uniformity" |
| `fact` | Verified project or domain knowledge | "API runs on port 8000, docs at /docs" |
| `preference` | Stated preference from user/lead | "Always use pt-BR for conversation" |
| `procedure` | Reusable workflows | "To deploy: git push, wait CI, merge PR" |
| `outcome` | Completed task results | "Migrated auth — 3 files, all tests pass" |
| `task_claim` | Coordination: who's working on what | "Oracle-A working on MCP isolation" |
| `blocker` | Coordination: signal blockers | "Blocked on Qdrant timeout" |
| `progress` | Coordination: status updates | "MCP server 80% complete" |
| `conflict` | Coordination: collision detected | "Two agents editing settings.json" |

---

## GitHub Integration (MCP)

All GitHub write operations go through a dedicated MCP server with bot identity — PRs, issues, and comments are created as the agent's GitHub App, never the user's personal account.

```
Agent (oracle, neo, trinity, ...)
        │
        ▼
┌────────────────────────┐
│  GitHub MCP Server     │
│                        │
│  github_create_pr()    │ ← Bot identity (oracle-zeroone)
│  github_create_issue() │ ← Multi-app: each agent has its own App
│  github_add_comment()  │ ← JWT → installation token auth
│  github_merge_pr()     │ ← Merge with merge/squash/rebase
│  github_close_pr()     │
│  github_list_issues()  │
│                        │
│  Auth: per-agent envs  │ ← GITHUB_APP_{AGENT}_ID, _PEM_PATH, _INSTALLATION_ID, _SLUG
│  Fallback: generic envs│ ← GITHUB_APP_ID (used when agent has no own App)
└────────────────────────┘
```

### Registered Agents

| Agent | App Slug | Status |
|-------|----------|--------|
| **oracle** | `oracle-zeroone` | Active |
| **neo** | `neo-zeroone` | Active |
| **trinity** | — | Pending (uses fallback) |
| **morpheus** | — | Pending (uses fallback) |
| **the_architect** | `the-architect-zeroone` | Active |
| **cypher** | — | Pending (uses fallback) |

**Rules enforced by the `github` skill:**
- All GitHub writes MUST use `mcp__github__*` tools — never `curl`, `gh CLI`, or raw HTTP
- CHANGELOG must be updated before creating a PR (blocks otherwise)
- README warnings treated as hard blocks
- Credentials configured via env vars in `.mcp.json` — never hardcoded in source
- Each agent authenticates via per-agent env vars (`GITHUB_APP_{AGENT}_*`) with generic fallback

---

## Autonomy & Permissions

Agents operate in **auto mode** — maximum autonomy for development work, with guardrails for critical operations.

### Full autonomy (no approval needed)

- Read, write, edit any source code, configs, docs
- Run build, test, lint, format, dev server commands
- Git operations: commit, push, pull, branch, checkout
- Create GitHub issues and PRs
- Run package managers, Docker, infrastructure commands
- MCP tool calls (memory, diagrams, etc.)

### Always requires human approval

- **File deletion** — `rm`, `git rm`, `shred`
- **Secrets** — creating, rotating, or modifying tokens, API keys, PEM files
- **Environment files** — modifying `.env` or any file containing secrets
- **Access control** — permissions, IAM, GitHub repo settings
- **Force push** — `git push --force` to any branch
- **Destructive git** — `reset --hard`, `clean -f`, `branch -D`
- **Publishing** — deploying to production, publishing packages
- **External messages** — Slack, email, webhooks on behalf of the user

### Configure auto mode

Add to your `settings.json` (not versioned — configure after cloning):

```json
{
  "permissions": {
    "defaultMode": "auto"
  },
  "autoMode": {
    "allow": [
      "Reading, searching, and exploring files",
      "Writing and editing source code, configs, docs",
      "Running build, test, lint, format commands",
      "Git operations: commit, push, pull, branch",
      "Creating GitHub issues and PRs",
      "Running package managers and Docker",
      "MCP tool calls"
    ],
    "soft_deny": [
      "Deleting files or directories",
      "Creating or modifying tokens, API keys, secrets",
      "Modifying .env files or certificates",
      "Force-pushing or destructive git operations",
      "Publishing or deploying to production",
      "Sending messages to external services"
    ]
  }
}
```

---

## Hooks

Programmatic enforcement — agents can't skip these even if they wanted to.

### PR Enforcement Gates

Every PR creation attempt — via `gh pr create` (Bash) or `mcp__github__github_create_pr` (MCP) — passes through three independent gates before it is allowed.

```
Agent tries to open PR (Bash or MCP)
        │
        ▼
┌───────────────────────────┐
│    pr-docs-check.sh       │  PreToolUse / Bash only
│                           │
│  CHANGELOG updated?       │──── No → PR BLOCKED
│       Yes                 │
│  README updated?          │──── No → Warning (not blocked)
│  API collections updated? │──── Changed but not updated → Warning
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│  require-qa-evidence.sh   │  PreToolUse / Bash + MCP
│                           │
│  qa-report.md or          │
│  test-results.* present?  │──── No → PR BLOCKED
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│  require-self-judge.sh    │  PreToolUse / Bash + MCP
│                           │
│  self-judge.md exists     │
│  and >= 50 bytes?         │──── No → PR BLOCKED
└───────────────────────────┘
        │
        ▼
     PR allowed
```

**Note:** `pr-docs-check.sh` only triggers on actual `gh pr create` invocations (anchored regex). Prose mentions of "gh pr create" in issue bodies or echo commands are not matched.

#### self-judge.md

Create this file at the repo root before opening any PR. Minimum content example:

```markdown
## Self-Judge

- [x] All tests pass
- [x] CHANGELOG updated
- [x] README updated
- [x] No debug code left
- [x] Edge cases considered
```

---

## Parallel Execution

Run multiple agents simultaneously without conflicts.

### Git Worktrees

Each agent gets its own isolated copy of the codebase:

```bash
# Terminal 1: Oracle working on memory migration
claude --worktree memory-migration --agent oracle

# Terminal 2: Oracle working on PR reviews
claude --worktree pr-reviews --agent oracle

# Terminal 3: dev-py implementing a feature
claude --worktree feat-auth --agent dev-py
```

### Agent Teams + Multi-Oracle Coordination

Multiple Oracle instances coordinate through Mem0 shared memory and Agent Teams:

```
Terminal 1: Oracle (task A)     Terminal 2: Oracle (task B)     Terminal 3: Oracle (task C)
       │                              │                           │
       │  mem0_search(task_claim)     │  mem0_search(task_claim)  │  mem0_search(task_claim)
       │  → sees B and C              │  → sees A and C           │  → sees A and B
       │                              │                           │
       └──────────────┬───────────────┴───────────────────────────┘
                      │
                      ▼
           ┌─────────────────────┐
           │  Mem0 (shared)      │
           │                     │
           │  task_claim → who   │ ← Prevents duplicate work
           │  decision → what    │ ← Shares architectural choices
           │  blocker → blocked  │ ← Signals blockers to team
           │  progress → status  │ ← Status updates
           │  conflict → alert   │ ← Collision detection
           └─────────────────────┘
```

**Coordination protocol:**
1. **Startup** — `mem0_search(memory_type="task_claim")` to check active work
2. **Claim** — `mem0_store(memory_type="task_claim")` before starting
3. **Work** — Store decisions and progress for visibility
4. **Finish** — Delete task claim, store final progress summary

**Team patterns:**
- **Parallel experts** — Oracle spawns dev-py + review-py + architect in worktrees
- **Research + Build** — explorer → architect → dev-py pipeline
- **Multi-Oracle** — Peer-to-peer coordination via Mem0 shared memory, no lead needed

Enable in `settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
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
│   └── cypher.md                  #   Pure SRE, numbers and tables
│
├── skills/                        # Knowledge bases (global, all agents)
│   ├── arch-py/                   #   Python architecture
│   ├── arch-ts/                   #   TypeScript/Frontend architecture
│   ├── review-py/                 #   Python code review
│   ├── review-ts/                 #   Frontend code review
│   ├── frontend-design/           #   UI/UX/Visual design
│   ├── ai-engineer/               #   AI/ML engineering
│   ├── github/                    #   GitHub operations (enforced MCP usage)
│   ├── product-manager/           #   Product management
│   ├── meta-orchestration/        #   Task routing, agent coordination, memory
│   ├── dev-methodology/           #   Full dev workflow, TDD, refactoring
│   ├── dev-pipeline/              #   Mandatory delivery pipeline
│   ├── qa/                        #   E2E testing, Definition of Done
│   ├── research/                  #   Search strategies, source validation
│   ├── software-architecture/     #   SOLID, ADR, C4, trade-offs
│   ├── sre-observability/         #   OpenTelemetry, SLOs, incident response
│   └── local-infrastructure/      #   Docker, compose, databases
│
├── mcp/                           # MCP servers
│   ├── mem0-server/               #   Scoped semantic memory (3-level)
│   │   ├── server.py              #   7 tools, Qdrant + Ollama embeddings
│   │   └── pyproject.toml         #   Dependencies
│   └── github-server/             #   GitHub operations via bot identity
│       └── server.py              #   JWT → installation token (env var auth)
│
├── hooks/                         # Programmatic enforcement
│   ├── pr-docs-check.sh           #   Blocks PR without CHANGELOG (Bash, anchored regex)
│   ├── require-qa-evidence.sh     #   Blocks PR without QA evidence (Bash + MCP)
│   ├── require-self-judge.sh      #   Blocks PR without self-judge.md (Bash + MCP)
│   ├── enforce-worktree.sh        #   Blocks sessions not in a worktree
│   └── tests/                     #   Hook test suites (29 cases total)
│
├── CLAUDE.md                      # Global agent instructions
├── CHANGELOG.md                   # Version history
└── settings.json                  # Permissions, hooks, auto mode (not versioned)
```

---

## Foundational Principles

These are encoded in `CLAUDE.md` and enforced across all agents:

| Principle | What it means |
|-----------|--------------|
| **Research First** | Every technical decision backed by current web research. Never rely on training data alone. |
| **Autonomy with Guardrails** | Maximum speed for routine work. Human approval only for security-critical operations. |
| **PR Quality** | No PR without updated CHANGELOG. README and API docs checked automatically. |
| **Matrix Personas** | 6 agents with distinct personalities, same skills. Adversarial review flow for quality. |
| **Scoped Memory** | Three-level Mem0 scoping (team/project/agent). Nothing gets lost between sessions. |
| **Never Push Main** | All changes via branch + PR. No exceptions. |

---

## PR Standards

Every PR must include:

| Item | Enforcement |
|------|-------------|
| **CHANGELOG** | Hook blocks PR if missing |
| **README** | Hook warns if not updated |
| **API Collections** | Hook warns if endpoints changed |
| **Version** | Manual — coordinate with human for major/minor bumps |

---

## Contributing

1. Branch: `git checkout -b feat/my-feature`
2. Add agents in `agents/`, skills in `skills/`
3. Update `CHANGELOG.md` with your changes
4. **Audit for secrets/PII** — no personal paths, no API keys
5. PR to `main`

**Rules**: Agents must be project-agnostic. No hardcoded paths. Use `$HOME` and env vars.

---

## License

MIT

---

<div align="center">

**The foundation for AI-powered development teams**

[![Claude Code](https://img.shields.io/badge/Powered_by-Claude_Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)

</div>
