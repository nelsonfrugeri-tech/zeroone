# Claude Code - Global Instructions

## Agent Architecture: Founds & Experts

Agents are organized in two namespaces under `~/.claude/agents/`:

### founds/ — Foundational Agents
Agents that build the foundation for projects. They manage the Claude Code ecosystem,
build teams, configure projects, maintain memory, and monitor health.

- **oracle** — Ecosystem manager, knowledge keeper
- **sentinel** — SRE, observability, monitoring

**Rule:** Founds agents are ecosystem-only. They work within the claude-code
foundation and are not directly consumed by downstream projects.

### experts/ — Expert Specialists
Pure specialists with reusable expertise. Available to any project built on this foundation.

- **architect** — System design, trade-offs, diagrams
- **dev-py** — Python development
- **review-py** — Code review Python
- **debater** — Approach comparison & trade-offs
- **tech-pm** — Product management
- **explorer** — Codebase exploration
- **builder** — Infrastructure / Docker

**Rule:** Experts are agnostic — they carry no knowledge of specific projects,
platforms, or integrations. Context comes from the project that uses them.

### Isolation Rules
1. **Experts** = agnostic, reusable by any project built on this foundation
2. **Founds** = ecosystem-only, not consumed by downstream projects
3. **Tools/MCP** = never global in settings.json, always per-project via `mcp.json`

## Autonomy Rules

Agents operate in **auto mode** with maximum autonomy. Do NOT ask for approval on routine operations.

### Full autonomy (just do it)
- Read, write, edit any source code, config, docs, scripts
- Run build, test, lint, format, dev server commands
- Git operations: status, diff, log, add, commit, branch, checkout, push, pull
- Create/manage GitHub issues and PRs
- Run package managers, Docker, infrastructure commands
- Create directories and files
- MCP tool calls

### ALWAYS ask the human first
- **File deletion** — never delete files without explicit approval
- **Secrets & credentials** — creating, rotating, or modifying tokens, API keys, PEM files, certificates
- **Environment files** — modifying .env or any file containing secrets
- **Access control** — changing permissions, IAM, GitHub repo permissions
- **Force push** — git push --force to any branch
- **Destructive git** — reset --hard, clean -f, branch -D on remote branches
- **Publishing** — deploying to production, publishing packages
- **External messages** — sending messages to Slack, email, webhooks on behalf of the user

## PR Checklist (mandatory for every PR)

Before opening any PR, agents MUST complete ALL applicable items. This is not optional.

### 1. CHANGELOG
- Update `CHANGELOG.md` with the changes in this PR
- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Categorize: Added, Changed, Deprecated, Removed, Fixed, Security
- If the project doesn't have a CHANGELOG.md yet, create one

### 2. README
- Read the current `README.md` and check if any section is affected by the changes
- Update affected sections (architecture, setup, usage, config, structure, etc.)
- If adding a new feature, document it in README
- If removing something, remove it from README

### 3. API Collections (if applicable)
- Check if the project has Postman/Insomnia/Bruno collections
- If API endpoints were added, changed, or removed, update the collection
- Common locations: `docs/`, `postman/`, `*.postman_collection.json`, `*.insomnia.json`

### 4. Version
- If the project uses semantic versioning, evaluate if the version should be bumped
- Coordinate with the human on version bumps for major/minor changes

**Rule:** A PR without updated CHANGELOG and README (when applicable) is incomplete.
Do not open it. Do the work first.
