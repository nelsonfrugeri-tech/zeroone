# Research Methodology

## Research Checklist

1. **Codebase search first** — Has this been solved before in this project?
2. **Documentation check** — Is there existing docs on how to approach this?
3. **Web search** — What are current best practices?
4. **Multiple sources** — Cross-reference at least 2-3 sources
5. **Recency check** — Are the sources current (last 6 months)?
6. **Trade-off analysis** — What are the alternatives?

## Research Triggers

Always research when:
- Choosing a library or framework
- Choosing an architectural pattern
- Adding a new dependency
- Dealing with a technology you haven't used recently
- The problem seems common (someone likely solved it well)

Skip research when:
- The solution is obvious and well-established
- You already verified this approach recently
- It is a trivial change with no alternatives

## How to Document Research

For significant decisions, document:
```markdown
## Decision: {what was decided}

### Context
{why this decision was needed}

### Options Considered
1. **Option A**: {description}
   - Pros: {list}
   - Cons: {list}

2. **Option B**: {description}
   - Pros: {list}
   - Cons: {list}

### Decision
Chose Option {X} because {justification}.

### Sources
- {url 1}
- {url 2}
```
