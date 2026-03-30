<div align="center">

# Claude Code

### The Foundation Layer for AI-Powered Development

[![Claude Code](https://img.shields.io/badge/Claude_Code-CLI-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Agents](https://img.shields.io/badge/Agents-9-blue?style=for-the-badge)](#-agents)
[![Skills](https://img.shields.io/badge/Skills-4-purple?style=for-the-badge)](#-skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Reusable agents and skills that turn `~/.claude` into an intelligent development environment.**
**Any application can use them — they are provider-agnostic and project-independent.**

[Founds & Experts](#-founds--experts) · [Agents](#-agents) · [Skills](#-skills) · [Getting Started](#-getting-started)

</div>

---

## What is this?

**claude-code** is a collection of **agents** and **skills** installed in `~/.claude/` that work with [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code). It provides specialized AI capabilities covering the entire software development lifecycle — from architecture design to code review, debugging, product management, and SRE.

---

## Founds & Experts

Agents are organized in two namespaces:

```
FOUNDS (foundational)                    EXPERTS (specialists)
┌────────────────────────────┐          ┌──────────────────────────┐
│  oracle    — manages       │          │  dev-py    — codes       │
│  sentinel  — monitors      │          │  review-py — reviews     │
│  architect — designs base  │          │  debater   — debates     │
│                            │          │  tech-pm   — plans       │
│  Work on the foundation.   │   ←──    │  explorer  — explores    │
│  Build teams, configure    │  used    │  builder   — deploys     │
│  projects, maintain the    │   by     │                          │
│  ecosystem.                │          │  Pure expertise.         │
│                            │          │  Any project can invoke  │
│  NEVER accessed by         │          │  them via --agent.       │
│  project bots.             │          │                          │
└────────────────────────────┘          └──────────────────────────┘
```

- **Founds** (`agents/founds/`) — Build the foundation for projects. Manage the ecosystem.
- **Experts** (`agents/experts/`) — Pure specialists. Invoked by project bodies via `--agent`.
- **Skills** (`skills/`) — Knowledge bases that agents consult.

### How projects use experts

```
User input → Semantic Router → Expert selection → Claude CLI → Response
                  │
                  ├── "design the API" → architect + opus
                  ├── "review PR #42"  → review-py + sonnet
                  └── "what's the status?" → (direct) + haiku
```

---

## Agents

### Founds (Foundational)

| Agent | Specialty | Model |
|-------|-----------|-------|
| **oracle** | Ecosystem manager, knowledge keeper | Opus |
| **sentinel** | SRE, monitoring, observability | Haiku |
| **architect** | Foundational architecture for projects | Opus |

### Experts (Specialists)

| Agent | Specialty | Model |
|-------|-----------|-------|
| **dev-py** | Python implementation, TDD, quality | Opus |
| **review-py** | Code review, PR analysis, diff comments | Opus |
| **debater** | Compare approaches, debate trade-offs | Opus |
| **tech-pm** | User stories, backlog, roadmap, OKRs | Opus |
| **explorer** | Repository analysis, codebase onboarding | Opus |
| **builder** | Local infra, Docker, deps, env setup | Sonnet |

### Usage

```bash
# Use an expert directly
claude --agent dev-py        # Python dev mode
claude --agent architect     # Architecture mode (also available as found)
claude --agent sentinel      # SRE/monitoring mode

# Invoke from code via Claude CLI
claude -p "Design a notification system" --agent architect --model opus
```

---

## Skills

| Skill | Domain | Used by |
|-------|--------|---------|
| **arch-py** | Python architecture, patterns, type system, async, Pydantic v2 | architect, dev-py, review-py, explorer |
| **review-py** | Code review templates, checklists, severity criteria | review-py |
| **ai-engineer** | LLM engineering, RAG, agents, vector DBs, MLOps | dev-py, debater |
| **product-manager** | Discovery, delivery, OKRs, user stories, roadmap | tech-pm |

---

## Project Structure

```
~/.claude/
├── agents/
│   ├── founds/                       # Foundational agents
│   │   ├── oracle.md                 #   Ecosystem manager
│   │   ├── sentinel.md               #   SRE/observability
│   │   └── architect.md              #   Architecture foundation
│   │
│   └── experts/                      # Expert specialists
│       ├── dev-py.md                 #   Python development
│       ├── review-py.md              #   Code review
│       ├── debater.md                #   Trade-off debates
│       ├── tech-pm.md                #   Product management
│       ├── explorer.md               #   Repo analysis
│       └── builder.md                #   Infrastructure
│
├── skills/                           # Knowledge bases
│   ├── arch-py/                      #   Python architecture
│   ├── ai-engineer/                  #   AI/ML engineering
│   ├── product-manager/              #   Product management
│   └── review-py/                    #   Code review
│
├── hooks/                            # Automations
├── setup/                            # Onboarding
├── CLAUDE.md                         # Global instructions
└── settings.json                     # Shared settings
```

---

## Getting Started

### Prerequisites

| Tool | Install |
|------|---------|
| Claude Code | `npm install -g @anthropic-ai/claude-code` |
| Node.js 18+ | Required for MCP servers |

### Install

```bash
git clone https://github.com/nelsonfrugeri-tech/claude-code.git ~/.claude
bash ~/.claude/setup/bootstrap.sh
bash ~/.claude/setup/bootstrap.sh --check  # verify
```

### Update

```bash
cd ~/.claude && git pull && bash setup/bootstrap.sh
```

---

## Projects Using This Foundation

- [**bike-shop**](https://github.com/nelsonfrugeri-tech/bike-shop) — Multi-agent Slack team with Semantic Router, Mem0 shared memory, and Langfuse observability

---

## Contributing

1. Branch: `git checkout -b feat/my-feature`
2. Add experts in `agents/experts/`, founds in `agents/founds/`, skills in `skills/`
3. **Audit for secrets/PII** — no personal paths, no API keys
4. PR to `main`

**Rules**: Agents must be project-agnostic. Hooks use `$HOME`, never hardcoded paths.

---

## License

MIT

---

<div align="center">

**The foundation for AI-powered development teams**

[![Claude Code](https://img.shields.io/badge/Powered_by-Claude_Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)

</div>
