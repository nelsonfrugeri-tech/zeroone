# Agent Creation Templates

## Agent File Structure
```markdown
---
name: agent-name
description: One-line description of the agent's purpose
model: sonnet (or opus, haiku)
tools: [Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch]
mcp_servers: [github, mem0]  # optional
---

[Agent personality and behavior instructions]
[What this agent does and doesn't do]
[How it approaches problems]
[Output format expectations]
```

## Creation Checklist
- [ ] Clear, non-overlapping purpose (no duplicate agents)
- [ ] Personality defined (how it thinks, not what it knows)
- [ ] Tools are minimal (only what's needed)
- [ ] MCP servers listed if needed
- [ ] Model appropriate for complexity level
- [ ] Description is searchable (for dynamic discovery)

## Naming Convention
- Lowercase, hyphenated: `dev-py`, `review-ts`
- Name reflects role, not implementation
- Avoid generic names: `helper`, `assistant`, `worker`

## Anti-patterns
- Embedding technical knowledge in agent file (use skills)
- Giving all tools to every agent (principle of least privilege)
- Creating agents for one-off tasks (use inline prompts)
