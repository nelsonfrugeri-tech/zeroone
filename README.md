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

Projects built on this foundation inherit these capabilities automatically.

---

## Founds & Experts

Agents are organized in two namespaces:

```
FOUNDS (foundational)                    EXPERTS (specialists)
┌────────────────────────────┐          ┌──────────────────────────┐
│  oracle    — manages       │          │  architect — designs     │
│  sentinel  — monitors      │          │  dev-py    — codes       │
│                            │          │  review-py — reviews     │
│  Work on the foundation.   │          │  debater   — debates     │
│  Build teams, configure    │          │  tech-pm   — plans       │
│  projects, maintain the    │          │  explorer  — explores    │
│  ecosystem.                │          │  builder   — deploys     │
│                            │          │                          │
│  Ecosystem-only agents.    │          │  Pure expertise.         │
│                            │          │  Reusable by any project │
│                            │          │  built on this           │
│                            │          │  foundation.             │
└────────────────────────────┘          └──────────────────────────┘
```

- **Founds** (`agents/founds/`) — Build the foundation for projects. Manage the ecosystem.
- **Experts** (`agents/experts/`) — Pure specialists. Reusable by any project built on this foundation.
- **Skills** (`skills/`) — Knowledge bases that agents consult.

---

## Agents

### Founds (Foundational)

| Agent | Specialty | Model |
|-------|-----------|-------|
| **oracle** | Ecosystem manager, knowledge keeper | Opus |
| **sentinel** | SRE, monitoring, observability | Haiku |

### Experts (Specialists)

| Agent | Specialty | Model |
|-------|-----------|-------|
| **architect** | System design, trade-offs, diagrams | Opus |
| **dev-py** | Python implementation, TDD, quality | Opus |
| **review-py** | Code review, PR analysis, diff comments | Opus |
| **debater** | Compare approaches, debate trade-offs | Opus |
| **tech-pm** | User stories, backlog, roadmap, OKRs | Opus |
| **explorer** | Repository analysis, codebase onboarding | Opus |
| **builder** | Local infra, Docker, deps, env setup | Sonnet |

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
│   │   └── sentinel.md               #   SRE/observability
│   │
│   └── experts/                      # Expert specialists
│       ├── architect.md              #   System design
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

## Autonomy & Permissions

Agents operate in **auto mode** — maximum autonomy for development work, with guardrails for critical operations.

`settings.json` is not versioned (contains local configs). Configure it after cloning:

```json
{
  "permissions": {
    "defaultMode": "auto"
  },
  "autoMode": {
    "allow": [
      "Reading, searching, and exploring files and directories",
      "Writing and editing source code, configs, docs, and scripts",
      "Running build, test, lint, format, and dev server commands",
      "Git operations: status, diff, log, add, commit, branch, checkout, push, pull, fetch",
      "Creating and managing GitHub issues and PRs",
      "Running package managers and Docker operations",
      "Creating directories and new files",
      "Running MCP tool calls"
    ],
    "soft_deny": [
      "Deleting files or directories — always confirm first",
      "Creating, rotating, or modifying tokens, API keys, secrets, or credentials",
      "Modifying .env files, PEM files, certificates, or any file containing secrets",
      "Changing permissions or access controls",
      "Force-pushing or destructive git operations",
      "Publishing packages or deploying to production",
      "Sending messages to external services on behalf of the user"
    ],
    "environment": [
      "Development environment with multiple projects",
      "Agents have high autonomy for code and infrastructure work",
      "Security-sensitive operations always require human approval",
      "File deletion always requires human approval"
    ]
  }
}
```

**Principle:** agents should never be blocked on routine work. Only security-critical and destructive operations require human approval.

---

## PR Standards

Every PR opened by an agent must include:

| Item | Rule |
|------|------|
| **CHANGELOG** | Updated with the changes, following [Keep a Changelog](https://keepachangelog.com/) format |
| **README** | Updated if any documented feature, structure, or config was affected |
| **API Collections** | Updated if endpoints changed (Postman, Insomnia, Bruno) |
| **Version** | Evaluated for semver bump (coordinate with human for major/minor) |

A PR without updated CHANGELOG and README (when applicable) is incomplete.

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
