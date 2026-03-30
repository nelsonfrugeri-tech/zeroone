# Claude Code - Global Instructions

## Agent Architecture: Founds & Experts

Agents are organized in two namespaces under `~/.claude/agents/`:

### founds/ — Foundational Agents
Agents that build the foundation for projects. They manage the Claude Code ecosystem,
build teams, configure projects, maintain memory, and monitor health.

- **oracle** — Ecosystem manager, knowledge keeper
- **sentinel** — SRE, observability, monitoring
- **architect** — Foundational architecture for projects

**Rule:** Founds agents are NEVER accessible by project bots (bike-shop, etc.).
They work WITHIN the claude-code ecosystem (~/.claude/).

### experts/ — Expert Specialists
Pure specialists, reusable expertise. Projects invoke them via `--agent {expert}`.

- **dev-py** — Python development
- **review-py** — Code review Python
- **debater** — Approach comparison & trade-offs
- **tech-pm** — Product management
- **explorer** — Codebase exploration
- **builder** — Infrastructure / Docker

**Rule:** Experts are agnostic — they don't know about Slack, bike-shop, or any specific app.
Context comes from the Body (project) that invokes them.

### Isolation Rules
1. **Experts** = agnostic, reusable by any project body
2. **Founds** = ecosystem-only, NEVER accessible by project bodies
3. **Tools/MCP** = NEVER global in settings.json, always per-project via `mcp.json`
4. **Bodies** inherit experts but NOT ecosystem tools/MCPs
