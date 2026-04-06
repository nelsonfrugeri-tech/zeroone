# Mem0 Knowledge Structure

## Three-Level Scoping Model

```
Mem0 (Qdrant + Ollama nomic-embed-text):
├── team scope       → user_id="team"
├── project scope    → user_id="team:{project}"
└── agent scope      → user_id="{agent}:{project}"
```

| Scope | user_id | What goes here | Who reads |
|-------|---------|----------------|-----------|
| **Team** | `"team"` | Global preferences, cross-project procedures, foundational rules | All agents |
| **Project** | `"team:{project}"` | Architecture, stack decisions, conventions, repo context | All agents working on that project |
| **Agent** | `"{agent}:{project}"` | Agent's own decisions, task outcomes, errors, patterns learned | Only that agent (+ oracle for coordination) |

## Memory Types

| Type | When to store | Example |
|------|--------------|---------|
| `decision` | Technical or product choice with rationale | "Chose OKLCH over HSL — perceptual uniformity" |
| `fact` | Verified project or domain knowledge | "API runs on port 8000, docs at /docs" |
| `preference` | Stated preference from user/lead | "User prefers pt-BR for conversation" |
| `procedure` | Reusable workflow | "To deploy: git push, wait CI, merge PR" |
| `outcome` | Completed task result | "Migrated auth — 3 files, all tests pass" |
| `task_claim` | Coordination: who's working on what | "Oracle-A working on MCP isolation" |
| `blocker` | Coordination: signal blockers | "Blocked on Qdrant timeout" |
| `progress` | Coordination: status updates | "MCP server 80% complete" |
| `conflict` | Coordination: collision detected | "Two agents editing settings.json" |

## Storage Rules
1. **Classify scope first** — team (global), project (shared), agent (personal)
2. **Classify type** — decision, fact, preference, procedure, outcome
3. **Check before storing** — `mem0_search` to avoid duplicates
4. **If exists → update**, if not → store
5. **Store the WHY** — not the WHAT (code shows what, memory explains why)
6. **Absolute dates** — convert "next Thursday" to "2026-04-10"

## Retrieval Flow

Use `mem0_recall_context` for one-call multi-scope retrieval:

```
mem0_recall_context(
  query="current task context",
  agent="neo",
  project="bike-shop",
  agent_limit=5,     # Own past decisions
  project_limit=5,   # Shared project context
  team_limit=3       # Global preferences
)
```

**Total budget: ~13 items** — prevents context overload.

## Query Patterns

```
# Multi-scope retrieval (preferred for task start)
mem0_recall_context(query="...", agent="neo", project="bike-shop")

# Single-scope queries
mem0_search(query="...", user_id="team")                    # Team scope
mem0_search(query="...", user_id="team:bike-shop")          # Project scope
mem0_search(query="...", user_id="neo:bike-shop")           # Agent scope

# Filter by type within a scope
mem0_search(query="architecture", memory_type="decision", user_id="team:bike-shop")

# Coordination queries (always at team scope)
mem0_search(query="active tasks", memory_type="task_claim", user_id="team")
```
