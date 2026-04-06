---
name: meta-orchestration
description: |
  Baseline de conhecimento para meta-orquestracao de agents em ecossistemas Claude Code. Cobre classificacao
  de complexidade de tarefas, selecao dinamica de modelo (Haiku/Sonnet/Opus), roteamento inteligente para
  experts, discovery dinamico de agents e skills, coordenacao multi-agent peer-to-peer via Mem0,
  protocolos de claim/release, gestao de memoria semantica (tipos, curadoria, poda), criacao de agents,
  resolucao de conflitos, e gestao de contexto cross-project. Use quando: (1) Rotear tarefas para o agent/modelo
  certo, (2) Coordenar multiplos agents em paralelo, (3) Gerenciar memoria persistente compartilhada,
  (4) Criar novos agents/skills, (5) Detectar gaps no ecossistema.
  Triggers: /meta-orchestration, task routing, agent coordination, memory management, agent creation.
---

# Meta-Orchestration — Orquestração Multi-Agent

## Propósito

Esta skill é a **knowledge base** for orchestrating multi-agent ecosystems in Claude Code.
It codifies patterns for task routing, model selection, agent coordination, and shared memory management.

**Global skill** — loaded automatically by all agents.

- Agent `sentinel` -> health monitoring, coordination checks
- Any foundational agent that manages the ecosystem

**What this skill contains:**
- Task complexity classification with signals and heuristics
- Model selection matrix (Haiku, Sonnet, Opus) by complexity and task type
- Dynamic agent and skill discovery patterns
- Task routing decision tree
- Multi-agent coordination protocol (claim, work, report, release)
- Mem0 knowledge structure (memory types, lifecycle, queries)
- Memory hygiene and curation (keep vs prune criteria)
- Agent creation templates
- Conflict resolution and duplicate work detection
- Cross-project context management

**What this skill does NOT contain:**
- Domain-specific expertise (that lives in specialist agents/skills)
- Implementation code for MCP servers or tools
- Project-specific configuration

---

## 1. Classificação de Complexidade de Tarefas

Classify every incoming task before deciding how to execute it.

### Níveis de Complexidade

| Level | Signals | Examples |
|-------|---------|----------|
| **trivial** | Single lookup, status check, one-liner edit | "what branch am I on?", "list MCP servers", "show git log" |
| **low** | Straightforward change, clear scope, single file | "rename variable X to Y", "update CHANGELOG", "fix typo in line 42" |
| **medium** | Multi-step, requires reading context, multiple files | "add a new API endpoint", "fix this bug", "implement feature X" |
| **high** | Architectural decisions, trade-offs, design work | "redesign auth system", "plan database migration", "evaluate SSE vs stdio" |
| **critical** | Cross-cutting, impacts multiple systems, irreversible | "restructure agent ecosystem", "security audit", "production incident" |

### Heurística de Classificação

```
1. How many files are touched?
   - 0-1 file -> trivial or low
   - 2-5 files -> medium
   - 5+ files or cross-project -> high or critical

2. Are there architectural decisions?
   - No decisions, just execution -> trivial/low/medium
   - Trade-offs to evaluate -> high
   - Irreversible system-wide impact -> critical

3. Does it require domain specialization?
   - General knowledge -> handle directly
   - Specialized domain -> delegate to agent

4. What is the blast radius if done wrong?
   - Cosmetic -> trivial/low
   - Functional regression -> medium/high
   - Data loss, security breach, ecosystem corruption -> critical
```

### Resolução de Ambiguidade

When classification is unclear, **round up** one level. The cost of over-thinking
is lower than the cost of under-thinking a high-impact task.

**Reference:** [references/routing/complexity-classification.md](references/routing/complexity-classification.md)

---

## 2. Seleção de Modelo

Match model capability to task complexity. Tactical model switching optimizes costs
by 60-80% without sacrificing quality.

### Matriz de Seleção

| Complexity | Model | Thinking Instruction | Rationale |
|------------|-------|---------------------|-----------|
| **trivial** | `haiku` | (none) | Fast, cheap. No reasoning needed. |
| **low** | `sonnet` | (none) | Balanced. Good for straightforward changes. |
| **medium** | `sonnet` | "Think step by step" | Guided reasoning for multi-step tasks. |
| **high** | `opus` | "Analyze deeply, consider trade-offs, think step by step before acting" | Deep analysis for architectural decisions. |
| **critical** | `opus` | "This is critical. Reason exhaustively. Consider all edge cases, risks, and second-order effects before proposing anything" | Maximum reasoning for irreversible changes. |

### Capacidades dos Modelos

| Model | Strengths | Weaknesses | Cost Relative |
|-------|-----------|------------|---------------|
| **Haiku** | Speed, simple tasks, status checks | Limited reasoning depth | Lowest |
| **Sonnet** | Balanced reasoning, code generation, 90% of dev tasks | Not ideal for deep architectural analysis | Medium |
| **Opus** | Deep reasoning, trade-off analysis, architectural decisions | Slower, expensive, overkill for simple tasks | Highest |

### Override de Modelo por Domínio

Some task domains override the default model selection:

| Domain | Override | Reason |
|--------|----------|--------|
| Security analysis | Minimum `sonnet` | Security requires careful reasoning |
| Code review | `sonnet` (default) | Balanced analysis |
| Architecture design | `opus` | Trade-off evaluation |
| Documentation | `haiku` or `sonnet` | Low reasoning demand |
| Refactoring | `sonnet` | Pattern recognition |

### Instruções de Raciocínio por Profundidade

Thinking instructions are embedded in the prompt sent to the agent:

- **None** (trivial/low): Just the task description
- **Step-by-step** (medium): "Think step by step before implementing."
- **Deep analysis** (high): "Analyze deeply. Consider trade-offs, edge cases, and risks. Think step by step before proposing a solution."
- **Exhaustive** (critical): "This is critical. Reason exhaustively about all implications, second-order effects, and failure modes before acting. Show your reasoning."

**Reference:** [references/routing/model-selection.md](references/routing/model-selection.md)

---

## 3. Descoberta Dinâmica

Never maintain hardcoded lists. The filesystem IS the registry.

### Descoberta de Agents

Scan `~/.claude/agents/` at session start to build the current agent roster.

```bash
# Discover all available agents
for f in ~/.claude/agents/*.md; do head -10 "$f"; echo "---"; done
```

Each agent `.md` file has frontmatter with `name` and `description` fields.
Match the task domain to the agent's `description`.

**Matching heuristic:**
1. Parse `description` field from each agent's frontmatter
2. Match task keywords against agent descriptions
3. If multiple experts match, prefer the more specialized one
4. If no agent matches, handle directly or propose creating a new one (gap detection)

### Descoberta de Skills

Scan `~/.claude/skills/` at session start to discover all available skills.

```bash
# Discover all skills and their descriptions
for f in ~/.claude/skills/*/SKILL.md; do head -12 "$f"; echo "---"; done
```

Each `SKILL.md` has frontmatter with `name`, `description`, and `triggers` fields.
Match task context to the skill's `triggers` and `description`.

### Detecção de Lacunas

If a task requires a capability that does not exist in the ecosystem:

1. **Identify the gap**: "This task needs X, but no agent/skill/MCP provides it"
2. **Propose creation**: Suggest creating the missing component to the user
3. **Never improvise**: Do not use workarounds when the ecosystem should have the capability built-in

Examples of detectable gaps:
- Task needs Jira integration but no Jira MCP exists
- Task needs deployment but no deploy skill exists
- Task needs a language specialist (e.g., Rust) but no `dev-rust` agent exists

**Reference:** [references/routing/dynamic-discovery.md](references/routing/dynamic-discovery.md)

---

## 4. Árvore de Decisão de Roteamento

```
Task received
  |
  +-- Is it about the ecosystem itself? (agents, skills, MCP, CLAUDE.md)
  |     YES --> Handle directly (Oracle scope)
  |
  +-- Is it trivial? (grep, status, quick lookup)
  |     YES --> Handle directly, no delegation
  |
  +-- Does it require cross-project context only Oracle has?
  |     YES --> Handle directly
  |
  +-- Did the user explicitly ask Oracle to do it?
  |     YES --> Handle directly
  |
  +-- Classify complexity (Section 1)
  |
  +-- Select model (Section 2)
  |
  +-- Discover matching agent (Section 3)
  |     |
  |     +-- Expert found --> Delegate with isolation: "worktree"
  |     |
  |     +-- No agent found --> Gap detection (Section 3)
  |           |
  |           +-- Propose new agent to user
  |           +-- Or handle directly if within Oracle's capability
  |
  +-- Execute delegation
        |
        Agent(
          subagent_type="<agent-name>",
          model="<chosen-model>",
          prompt="<thinking instruction> + <task> + <context>",
          isolation="worktree"
        )
```

### Delegation Template

When delegating to an agent, the prompt must include:
1. **Thinking instruction** (based on complexity level)
2. **Task description** (clear, specific, actionable)
3. **Context** (relevant files, decisions, constraints)
4. **Acceptance criteria** (what "done" looks like)

```
Agent(
  subagent_type="dev-py",
  model="sonnet",
  prompt="Think step by step before implementing.\n\nTask: Add a DELETE endpoint for issues in the GitHub MCP server.\n\nContext:\n- Server file: mcp/github-server/server.py\n- Follow existing endpoint patterns\n- Must validate agent_name parameter\n\nAcceptance criteria:\n- Endpoint handles DELETE /issues/{id}\n- Returns 204 on success\n- Tests pass",
  isolation="worktree"
)
```

### When NOT to Delegate

| Condition | Action |
|-----------|--------|
| Ecosystem management task | Handle directly |
| Trivial task (grep, status) | Handle directly |
| Cross-project context needed | Handle directly |
| User explicitly asked Oracle | Handle directly |
| Read-only exploration | May skip worktree isolation |

**Reference:** [references/routing/decision-tree.md](references/routing/decision-tree.md)

---

## 5. Coordenação Multi-Agent Protocol

Multiple Oracle instances coordinate as **peers** via shared Mem0 memory.
No leader election. Each Oracle is autonomous and self-coordinating.

### Protocol: Claim, Work, Report, Release

```
Phase 1: CLAIM
  - mem0_search(metadata={"type": "coordination", "subtype": "claim"}) -> see what others are doing
  - Check for scope overlap with existing claims
  - If overlap -> store conflict memory, alert user
  - If clear -> mem0_store(content="Working on X", metadata={"type": "coordination", "subtype": "claim"})

Phase 2: WORK
  - Execute the task
  - Store decisions: mem0_store(memory_type="decision")
  - Store blockers: mem0_store(metadata={"type": "coordination", "subtype": "blocker"})
  - Update progress on long tasks: mem0_store(metadata={"type": "coordination", "subtype": "progress"})

Phase 3: REPORT
  - Store completion summary: mem0_store(metadata={"type": "coordination", "subtype": "progress"})
  - Store reusable knowledge: mem0_store(metadata={"type": "decision"})

Phase 4: RELEASE
  - Delete coordination claim memories
  - Delete resolved blocker memories
  - Update/archive completed progress memories
```

### Deduplication Rule

Before claiming any task:

```
results = mem0_search(query="<task description>", metadata={"type": "coordination", "subtype": "claim"})
```

If an active claim exists for the same or overlapping scope:
- Do NOT start the task
- Alert the user about the existing claim
- Offer to wait or work on a different task

### Conflict Detection

A conflict occurs when:
1. Two agents claim overlapping file scopes
2. Two agents make contradictory decisions about the same system
3. An agent's work invalidates another agent's in-progress work

Response to conflict:
```
mem0_store(
  content="Conflict: Agent A editing settings.json while Agent B also modifying it",
  metadata={"type": "coordination", "subtype": "conflict"},
  tags="active"
)
```
Then alert the user immediately.

### Spawning Agents

Any Oracle can spawn agents as subagents. Agents always run in isolated worktrees.

```bash
# Discover experts dynamically
ls ~/.claude/agents/*.md | xargs -I{} head -3 {}
```

Experts are stateless -- they receive context in the prompt, do their work, and return results.
They do not coordinate with each other directly. Oracle manages all coordination.

**Reference:** [references/coordination/peer-protocol.md](references/coordination/peer-protocol.md)

---

## 6. Mem0 Knowledge Structure

All persistent knowledge lives in Mem0 (Qdrant vector store + Ollama embeddings).
Shared across all terminals and agents.

### Tipos de Memória

| Type | Purpose | Lifecycle | Example |
|------|---------|-----------|---------|
| `feedback` | User corrections and preferences | Long-lived, rarely pruned | "Never push to main" |
| `project` | Project state, decisions, context | Lives with project | "Project X uses event-driven arch" |
| `reference` | External system pointers | Long-lived | "Bugs tracked in Linear INGEST" |
| `decision` | Architectural/technical decisions | Long-lived unless superseded | "Chose stdio over SSE for MCP" |
| `procedural` | How-to knowledge, reusable procedures | Long-lived, updated | "Steps to create a GitHub App" |
| `task_claim` | Coordination: who's working on what | Ephemeral (session lifetime) | "Oracle-A working on MCP isolation" |
| `blocker` | Coordination: signal blockers | Ephemeral (until resolved) | "Blocked on Qdrant timeout" |
| `progress` | Coordination: status updates | Ephemeral to medium | "MCP server 80% complete" |
| `conflict` | Coordination: collision detected | Ephemeral (until resolved) | "Two agents editing settings.json" |

### Regras de Armazenamento

| Event | Action |
|-------|--------|
| Session start | `mem0_search(metadata={"type": "coordination", "subtype": "claim"})` -- check peers |
| Session start | `mem0_recall("pending work, recent decisions")` -- restore context |
| Task claimed | `mem0_store(metadata={"type": "coordination", "subtype": "claim"})` |
| Decision made | `mem0_store(memory_type="decision")` |
| Procedure learned | `mem0_store(metadata={"type": "decision"})` |
| Problem solved | `mem0_store(metadata={"type": "decision"}, tags="troubleshooting")` |
| Project configured | `mem0_store(memory_type="project", project="X")` |
| Agent created/modified | `mem0_store(metadata={"type": "decision"})` |
| Blocker hit | `mem0_store(metadata={"type": "coordination", "subtype": "blocker"}, tags="active")` |
| Session end | Store progress summary, delete task_claims, delete resolved blockers |

### Padrões de Consulta

```
# Restore context at session start
mem0_recall(query="pending work, recent changes", limit=10)

# Check what other agents are doing
mem0_search(query="active tasks", metadata={"type": "coordination", "subtype": "claim"}, limit=20)

# Find how-to knowledge
mem0_search(query="how to create GitHub App", metadata={"type": "decision"})

# Find project context
mem0_search(query="architecture decisions", memory_type="decision", project="bike-shop")

# List all claims for cleanup
mem0_list(metadata={"type": "coordination", "subtype": "claim"}, limit=50)

# Clean up stale memories
mem0_delete(memory_id="<id>")

# Update outdated memory
mem0_update(memory_id="<id>", content="Updated procedure...", metadata={"type": "decision"})
```

**Reference:** [references/memory/knowledge-structure.md](references/memory/knowledge-structure.md)

---

## 7. Higiene de Memória and Curation

Memory without curation becomes noise. Active pruning is as important as active storage.

### When to Prune

Evaluate at every session start:

| Signal | Action |
|--------|--------|
| Project not mentioned in weeks, user confirmed abandonment | Archive project memories |
| Decision superseded by a newer decision | Delete old, or mark `[SUPERSEDED]` |
| Troubleshooting for a bug that was permanently fixed | Remove the workaround |
| Procedure references versions/paths/configs that no longer exist | Update or remove |
| Task claims older than 7 days without update | Delete (stale) |
| Duplicate memories covering the same information | Keep the most complete, delete others |

### Manter vs Podar Criteria

**KEEP when:**
- Reusable procedure (setup, creation, configuration)
- Architectural decision with documented trade-offs (the "why")
- Referenced by other memories or documents
- Contains information that would be hard to reconstruct (tokens, IDs, configs)
- Actively consulted in recent sessions

**PRUNE when:**
- References versions/paths/configs that no longer exist
- Describes workaround for a problem solved at the root
- Documents a decision explicitly reverted
- Duplicates information that exists elsewhere
- Not consulted in last 30 days AND not a core procedure

### Protocolo de Limpeza

```
# Periodic cleanup (every session start)
1. mem0_list(metadata={"type": "coordination", "subtype": "claim"}) -> delete completed/abandoned claims
2. mem0_list(metadata={"type": "coordination", "subtype": "blocker"}) -> delete resolved blockers
3. mem0_search(query="outdated, old, deprecated") -> review and prune

# Deep cleanup (weekly or on demand)
4. mem0_list(metadata={"type": "decision"}) -> verify procedures still accurate
5. mem0_list(memory_type="decision") -> check for superseded decisions
6. mem0_list(memory_type="project") -> archive dead projects
```

### Golden Rule

> Prefer a knowledge base with 20 precise, current documents over 100 where half are outdated.
> Wrong information is worse than missing information.

**Reference:** [references/memory/hygiene.md](references/memory/hygiene.md)

---

## 8. Criação de Agents Templates

When creating a new agent, follow this structure.

### Foundational Agent Template (founds/)

```markdown
---
name: <agent-name>
description: <what this agent does, 1-2 sentences>
skills: [<skill-1>, <skill-2>]
tools: [<tool-1>, <tool-2>]
mcp: [<mcp-server-1>]
---

# <Agent Name>

## Identity
- **Name**: <name>
- **Role**: <role description>
- **Scope**: <what this agent manages>

## Responsibilities
1. <responsibility 1>
2. <responsibility 2>

## Workflow
### On session start:
1. <step>

### During execution:
1. <step>

### On session end:
1. <step>

## Principles
1. <principle>
```

### Expert Agent Template (experts/)

```markdown
---
name: <expert-name>
description: <pure specialist description, domain-only>
skills: [<domain-skill>]
---

# <Expert Name>

## Identity
- **Name**: <name>
- **Role**: <specialist role>
- **Scope**: <domain scope>

## Expertise
- <capability 1>
- <capability 2>

## Workflow
1. Receive task with context from orchestrator
2. Execute within domain specialization
3. Return results

## Principles
1. <domain principle>
```

### Checklist for New Agents

- [ ] Agent file created in correct namespace (`founds/` or `experts/`)
- [ ] Frontmatter includes `name`, `description`, `skills`
- [ ] Description is accurate and helps with dynamic discovery
- [ ] Skills referenced actually exist in `~/.claude/skills/`
- [ ] MCP servers referenced (if any) are configured
- [ ] Agent has clear scope boundaries (does not overlap with existing agents)
- [ ] Stored in Mem0: `mem0_store(metadata={"type": "decision"}, content="Created agent X: ...")`

**Reference:** [references/agents/creation-templates.md](references/agents/creation-templates.md)

---

## 9. Resolução de Conflitos

### Detecção de Trabalho Duplicado

Before any task, check for active claims with overlapping scope:

```
results = mem0_search(query="<task description>", metadata={"type": "coordination", "subtype": "claim"})
```

**Overlap heuristics:**
- Same file paths mentioned in claim and new task
- Same feature/system being modified
- Same project and same subsystem

### Lock Patterns

Mem0 task_claims act as advisory locks (not enforced by infrastructure):

```
# Acquire lock
mem0_store(
  content="LOCK: Editing mcp/github-server/server.py - adding delete endpoint",
  metadata={"type": "coordination", "subtype": "claim"},
  tags="active,lock"
)

# Release lock
mem0_delete(memory_id="<claim-id>")
```

### Resolução Strategies

| Conflict Type | Resolution |
|---------------|------------|
| Same file, different sections | Coordinate: one agent waits for the other |
| Same file, same section | Alert user, let them decide priority |
| Contradictory decisions | Store both, escalate to user for resolution |
| Stale claim blocking new work | If claim > 7 days without update, delete and proceed |

### Escalação Protocol

When conflict cannot be auto-resolved:
1. Store conflict memory with full details
2. Present both sides to the user
3. Wait for user decision
4. Update memories based on resolution

**Reference:** [references/coordination/conflict-resolution.md](references/coordination/conflict-resolution.md)

---

## 10. Contexto Cross-Project Management

Oracle maintains context across all active projects.

### Project Registry

Each active project should have memories stored with `project` tag:

```
mem0_store(
  content="Project bike-shop: Slack bot team (Mr. Robot, Elliot, Tyrell). Stack: Python, Claude CLI.",
  memory_type="project",
  project="bike-shop"
)
```

### Cross-Project Queries

When a task might span projects:

```
# Find related decisions across projects
mem0_search(query="authentication approach", memory_type="decision")

# Find shared procedures
mem0_search(query="MCP server setup", metadata={"type": "decision"})
```

### Context Transfer to Experts

When delegating to an agent, provide only the relevant project context:

1. Query Mem0 for project-specific decisions and constraints
2. Include only what the expert needs (not full project history)
3. Include relevant file paths and architectural decisions
4. Never include credentials, tokens, or sensitive data in expert prompts

### Project Lifecycle

| Phase | Actions |
|-------|---------|
| **Onboarding** | Store setup, configs, architecture decisions, team structure |
| **Active development** | Update decisions, progress, blockers as they occur |
| **Maintenance** | Reduce update frequency, keep core decisions and procedures |
| **Archival** | Mark project memories as archived, keep only reusable procedures |

**Reference:** [references/coordination/cross-project.md](references/coordination/cross-project.md)

---

## Quick Reference: Routing Examples

| User Request | Complexity | Model | Expert | Action |
|-------------|------------|-------|--------|--------|
| "fix typo in README line 42" | trivial | (self) | (none) | Handle directly |
| "rename variable foo to bar" | low | sonnet | dev-py | Delegate |
| "add delete endpoint to MCP server" | medium | sonnet | dev-py | Delegate with step-by-step |
| "should we use SSE or stdio for MCP?" | high | opus | architect | Delegate with deep analysis |
| "restructure agents for multi-tenancy" | critical | opus | architect | Delegate with exhaustive reasoning, review output |
| "list all MCP servers" | trivial | (self) | (none) | Handle directly |
| "create new expert agent for Go" | medium | (self) | (none) | Handle directly (ecosystem task) |
| "review PR #42" | medium | sonnet | review-py | Delegate |

---

## References

### Routing
- [references/routing/complexity-classification.md](references/routing/complexity-classification.md) - Extended classification signals and examples
- [references/routing/model-selection.md](references/routing/model-selection.md) - Model comparison and cost optimization
- [references/routing/dynamic-discovery.md](references/routing/dynamic-discovery.md) - Agent and skill discovery patterns
- [references/routing/decision-tree.md](references/routing/decision-tree.md) - Full routing decision tree with edge cases

### Coordination
- [references/coordination/peer-protocol.md](references/coordination/peer-protocol.md) - Multi-Oracle peer coordination
- [references/coordination/conflict-resolution.md](references/coordination/conflict-resolution.md) - Conflict detection and resolution
- [references/coordination/cross-project.md](references/coordination/cross-project.md) - Cross-project context management

### Memory
- [references/memory/knowledge-structure.md](references/memory/knowledge-structure.md) - Mem0 memory types and query patterns
- [references/memory/hygiene.md](references/memory/hygiene.md) - Memory curation and pruning rules

### Agents
- [references/agents/creation-templates.md](references/agents/creation-templates.md) - Agent creation templates and checklist

### External Sources
- [LLM Orchestration Frameworks 2026](https://aimultiple.com/llm-orchestration) - Framework comparison
- [Multi-Agent Memory Systems](https://mem0.ai/blog/multi-agent-memory-systems) - Production memory patterns
- [State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026) - Memory architecture trends
- [Claude Code Sub-Agents](https://code.claude.com/docs/en/sub-agents) - Official subagent documentation
- [Claude Code Model Selection](https://claudefa.st/blog/models/model-selection) - Model routing patterns
- [OpenAI Agent Orchestration](https://openai.github.io/openai-agents-python/multi_agent/) - Orchestration patterns
- [Multi-Agent Orchestration Architectures](https://arxiv.org/html/2601.13671v1) - Academic survey of protocols
