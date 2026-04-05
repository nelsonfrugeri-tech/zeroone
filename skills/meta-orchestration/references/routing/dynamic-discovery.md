# Dynamic Discovery

## Agent Discovery
```bash
# Agents are discovered by globbing — never hardcode
ls ~/.claude/agents/*.md
```
Parse frontmatter for: name, description, tools, model.

## Skill Discovery
```bash
# Skills are discovered by directory — never hardcode
ls ~/.claude/skills/*/SKILL.md
```
Parse frontmatter for: name, description, triggers.

## Regras
1. **Never hardcode agent or skill lists** — always discover dynamically
2. **Match by description/triggers** — not by name
3. **Fallback to general-purpose** if no specialist matches
4. **Gap detection**: if no agent/skill matches a request, flag it for creation
