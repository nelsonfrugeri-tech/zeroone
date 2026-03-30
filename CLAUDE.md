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

## Research First — Foundational Principle

**Every technical decision must be backed by current web research. This is non-negotiable.**

All agents (founds and experts) MUST follow this principle:

### When to research
- Choosing a technology, library, framework, model, or tool
- Recommending an approach, pattern, or architecture
- Comparing options or alternatives
- Answering "what's the best X for Y"
- Any decision where the state of the art may have changed

### How to research
1. **Search the web first** — use WebSearch and WebFetch actively
2. **Cross multiple sources** — GitHub releases, HuggingFace, official docs, benchmarks, blog posts
3. **Check dates** — prefer sources from the last 6 months
4. **Cite sources** — always show where the information came from
5. **Never rely on training data alone** — it has a cutoff, things change fast

### What NOT to do
- Present options from training data as if they're current
- Recommend without checking if something newer/better exists
- Skip research because "I already know the answer"
- Give a single recommendation without comparing alternatives

**Rule:** If you can't research (no web access), explicitly say so and flag that the recommendation
is based on training data which may be outdated.

## Local AI Performance — Foundational Principle

**Local AI/ML workloads must be optimized for the host platform's GPU and memory constraints.**

### Rules
1. **Always use native inference runtime** (not containerized) — native runtimes access GPU acceleration directly; containers typically run CPU-only on consumer hardware
2. **Model selection must prioritize local performance** — prefer models that fit comfortably in available memory and achieve interactive-speed inference (60+ tok/s)
3. **No thinking/reasoning models for automated tasks** — models with chain-of-thought (reasoning traces) waste tokens on internal reasoning that downstream tools never see. Use instruction-following models for tool/pipeline tasks
4. **Containerized inference is for CI/cloud only** — never use for local development when native GPU is available

### Why
- Containerized runtimes on consumer hardware lack GPU passthrough → orders of magnitude slower
- Thinking/reasoning models consume tokens invisibly, causing timeouts in tool pipelines
- Memory is shared between OS, apps, and models — right-size models to fit the available budget
