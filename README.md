<div align="center">

# 🧠 Claude Code

### The Foundation Layer for AI-Powered Development

[![Claude Code](https://img.shields.io/badge/Claude_Code-CLI-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Agents](https://img.shields.io/badge/Agents-12-blue?style=for-the-badge)](#-agents-spirits)
[![Skills](https://img.shields.io/badge/Skills-5-purple?style=for-the-badge)](#-skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Reusable agents (spirits) and skills that turn `~/.claude` into an intelligent development environment.**
**Any application can use them — they are provider-agnostic and project-independent.**

[Spirits & Bodies](#-spirits--bodies) · [Agents](#-agents-spirits) · [Skills](#-skills) · [Getting Started](#-getting-started) · [Memory](#-memory-keeper)

</div>

---

## 🎯 What is this?

**claude-code** is a collection of **agents** and **skills** installed in `~/.claude/` that work with [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code). It provides specialized AI capabilities covering the entire software development lifecycle — from architecture design to code review, debugging, product management, and SRE.

The key insight: agents and skills are **spirits** — agnostic, reusable capabilities that any application can invoke. External projects create **bodies** (Slack bots, CLI tools, web apps) that dynamically assume these spirits based on the task context.

---

## 👻 Spirits & Bodies

```
SPIRITS (this repo — ~/.claude/)              BODIES (apps that use spirits)
┌────────────────────────────┐          ┌──────────────────────────┐
│  architect    — designs    │          │  Slack bots              │
│  dev-py       — codes     │    ←──   │  CLI tools               │
│  review-py    — reviews   │   used   │  Web APIs                │
│  debater      — debates   │    by    │  Discord bots            │
│  sentinel     — monitors  │          │  GitHub Actions          │
│  tech-pm      — plans     │          │  Cron jobs               │
│  explorer     — explores  │          │  Any app that calls      │
│  builder      — deploys   │          │  Claude Code CLI         │
│  memory-agent — remembers │          │                          │
│  ...                      │          │  ...                     │
└────────────────────────────┘          └──────────────────────────┘
```

- **Spirits** (`~/.claude/agents/`) — Pure expertise. No ties to Slack, GitHub, or any project.
- **Bodies** (external apps) — Interfaces that invoke spirits based on context.
- **Skills** (`~/.claude/skills/`) — Knowledge bases that spirits consult.

---

## 🤖 Agents (Spirits)

<div align="center">

| Spirit | Specialty | Model | Trigger |
|--------|-----------|-------|---------|
| 🏛️ **architect** | System design, trade-offs, diagrams | Opus | Architecture tasks |
| 🐍 **dev-py** | Python implementation, TDD, quality | Opus | Coding tasks |
| 🔍 **review-py** | Code review, PR analysis, diff comments | Opus | PR reviews |
| ⚖️ **debater** | Compare approaches, debate trade-offs | Opus | Technical debates |
| 🔭 **explorer** | Repository analysis, codebase onboarding | Opus | New projects |
| 🔧 **builder** | Local infra, Docker, deps, env setup | Sonnet | Project setup |
| 📋 **tech-pm** | User stories, backlog, roadmap, OKRs | Opus | Product decisions |
| 👁️ **sentinel** | SRE, monitoring, observability, incidents | Haiku | System health |
| 🧬 **memory-agent** | Fact extraction, shared memory management | Haiku | Automatic |
| 🔮 **oracle** | Ecosystem manager, knowledge keeper | Opus | Meta-tasks |
| 📡 **slack-monitor** | Slack agent lifecycle management | Sonnet | Agent ops |
| ⚡ **executor** | Implements skill improvements from issues | Sonnet | Skill updates |

</div>

### Usage

```bash
# Use a spirit directly
claude --agent architect     # Architecture mode
claude --agent dev-py        # Python dev mode
claude --agent sentinel      # SRE/monitoring mode

# Or invoke from code via Claude CLI
claude -p "Design a notification system" --agent architect --model opus
```

### Agent Details

| Agent | Description |
|-------|-------------|
| 🏛️ **Architect** | Software architect and tech lead. Designs systems, defines patterns, identifies flaws and risks. Creates diagrams and guides technical decisions. |
| 🐍 **Dev-Py** | Python developer — 8-step workflow: question → research → design → test → implement → validate → review → document. Test-first always. |
| 🔍 **Review-Py** | Systematic code review between Git branches. Impact analysis, per-file review, and full report. Comments formatted for PR copy-paste. |
| ⚖️ **Debater** | Configurable personality (Socratic/Expert/Collaborative). Debates topics, researches state of the art, creates improvement issues. |
| 🔭 **Explorer** | Analyzes repos, generates `context.md` reports. Covers architecture, contracts, infra, deps, quality. Incremental updates on subsequent runs. |
| 🔧 **Builder** | Spins up local infra automatically. Reads `context.md`, starts Docker, checks `.env`, installs deps, validates with tests. |
| 📋 **Tech-PM** | Product Manager. Defines what to build, prioritizes backlog, writes user stories, plans sprints, manages roadmap. |
| 👁️ **Sentinel** | SRE specialist. Monitors systems, queries traces/metrics, analyzes health, helps with incident response. |
| 🧬 **Memory Agent** | Phantom that observes conversations and extracts facts (decisions, entities, context) into shared memory. |
| 🔮 **Oracle** | Meta-agent. Manages the ecosystem — agents, skills, MCP servers, projects, workspaces. Central knowledge keeper. |

---

## 📚 Skills

<div align="center">

| Skill | Domain | Used by |
|-------|--------|---------|
| 🏗️ **arch-py** | Python architecture, patterns, type system, async, Pydantic v2 | architect, dev-py, review-py, explorer |
| 🔍 **review-py** | Code review templates, checklists, severity criteria | review-py |
| 🤖 **ai-engineer** | LLM engineering, RAG, agents, vector DBs, MLOps | dev-py, debater |
| 📋 **product-manager** | Discovery, delivery, OKRs, user stories, roadmap | tech-pm |
| 👁️ **sre-observability** | Google SRE principles, three pillars, incident response | sentinel |

</div>

---

## 🔄 Multi-Agent Pipelines

### Development Pipeline
```
Explorer → Architect → Dev-Py → Review-Py → Builder
  │            │           │          │          │
  analyze    design    implement   review    deploy
```

### Skill Improvement Pipeline
```
Debater → Executor
  │          │
  debate    implement
```

### Application Pipeline (any body)
```
User input → Semantic Router → Spirit selection → Claude CLI → Response
                  │
                  ├── "design the API" → architect + opus
                  ├── "review PR #42"  → review-py + sonnet
                  └── "what's the status?" → (direct) + haiku
```

---

## 📁 Project Structure

```
~/.claude/
├── agents/                        # 🤖 Spirits
│   ├── architect.md               #   System design
│   ├── builder.md                 #   Infrastructure
│   ├── debater.md                 #   Trade-off debates
│   ├── dev-py.md                  #   Python development
│   ├── executor.md                #   Skill improvements
│   ├── explorer.md                #   Repo analysis
│   ├── memory-agent.md            #   Fact extraction
│   ├── oracle.md                  #   Ecosystem manager
│   ├── review-py.md               #   Code review
│   ├── sentinel.md                #   SRE/observability
│   ├── slack-monitor.md           #   Slack agent ops
│   ├── tech-pm.md                 #   Product management
│   └── adapters/slack.md          #   Slack integration
│
├── skills/                        # 📚 Knowledge bases
│   ├── arch-py/                   #   Python architecture
│   ├── ai-engineer/               #   AI/ML engineering
│   ├── product-manager/           #   Product management
│   ├── review-py/                 #   Code review
│   └── sre-observability.md       #   SRE & observability
│
├── hooks/                         # ⚡ Automations
│   ├── memory-keeper-save.sh
│   ├── memory-keeper-restore.sh
│   ├── memory-keeper-purge.sh
│   └── setup-cron.sh
│
├── setup/                         # 🔧 Onboarding
│   ├── mcp-manifest.json
│   └── bootstrap.sh
│
├── CLAUDE.md                      # 📋 Global instructions
└── settings.json                  # ⚙️ Shared settings

🔒 NOT versioned: settings env values, .mcp.json, workspace/, projects/, hooks/logs/
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Install |
|------|---------|
| ![Claude](https://img.shields.io/badge/Claude_Code-CC785C?style=flat-square&logo=anthropic&logoColor=white) | `npm install -g @anthropic-ai/claude-code` |
| ![Node](https://img.shields.io/badge/Node.js_18+-339933?style=flat-square&logo=node.js&logoColor=white) | Required for MCP servers |

### Install

```bash
git clone https://github.com/nelsonfrugeri-tech/claude-code.git ~/.claude
bash ~/.claude/setup/bootstrap.sh
bash ~/.claude/hooks/setup-cron.sh  # optional: memory purge cron
bash ~/.claude/setup/bootstrap.sh --check  # verify
```

### If `~/.claude` already exists

```bash
REPO_URL=git@github.com:nelsonfrugeri-tech/claude-code.git \
  bash <(curl -sL https://raw.githubusercontent.com/nelsonfrugeri-tech/claude-code/main/setup/bootstrap.sh) --init
```

### Update

```bash
cd ~/.claude && git pull && bash setup/bootstrap.sh
```

---

## 🧠 Memory Keeper

Persistent memory across Claude Code sessions.

```
SessionStart → restore context from memory
  ↓
  Work (decisions, patterns, learnings)
  ↓
PreCompact/Stop → save context to memory
  ↓
  Next session → context restored automatically
```

- **Storage**: `~/mcp-data/memory-keeper/` (SQLite)
- **Purge**: every 15 days, cleans records older than 7 days
- **Backups**: last 3 kept

```bash
~/.claude/hooks/memory-keeper-purge.sh --dry-run  # preview
~/.claude/hooks/memory-keeper-purge.sh --force     # force purge
```

---

## 🏍️ Projects Using This Foundation

- [**bike-shop**](https://github.com/nelsonfrugeri-tech/bike-shop) — Multi-agent Slack team with Semantic Router, Mem0 shared memory, and Langfuse observability

---

## 🤝 Contributing

1. Branch: `git checkout -b feat/my-feature`
2. Add agents in `agents/`, skills in `skills/`
3. **Audit for secrets/PII** — no personal paths, no API keys
4. PR to `main`

**Rules**: Agents must be project-agnostic. Hooks use `$HOME`, never hardcoded paths.

---

## 📄 License

MIT

---

<div align="center">

**The foundation for AI-powered development teams**

[![Claude Code](https://img.shields.io/badge/Powered_by-Claude_Code-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)

</div>
