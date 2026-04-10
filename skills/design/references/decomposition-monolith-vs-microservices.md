# Monolith vs Modular Monolith vs Microservices

## The Architecture Spectrum (2026)

The industry has moved beyond the binary monolith-vs-microservices debate.
Architecture exists on a spectrum. The modular monolith is the pragmatic sweet spot
for most teams in 2026.

## Comparison Matrix

| Criteria | Monolith | Modular Monolith | Microservices |
|----------|----------|-----------------|---------------|
| Deployment | Single unit | Single unit | Independent per service |
| Data consistency | ACID transactions | ACID within modules | Eventual consistency |
| Communication | Function calls | Function calls (module API) | Network (HTTP/gRPC/events) |
| Team autonomy | Low | Medium | High |
| Operational complexity | Low | Low | High |
| Latency overhead | None | None | Network hops |
| Debug/trace | Simple stack traces | Simple stack traces | Distributed tracing |
| Technology diversity | Single stack | Single stack | Polyglot possible |
| Scaling granularity | Whole app | Whole app | Per service |
| Dev velocity (small team) | Fast | Fast | Slow (overhead) |
| Dev velocity (large org) | Slow (conflicts) | Medium | Fast (independence) |

## Decision Framework

### Start with the Monolith

```
New project? Start with a monolith.
- You don't know your domain boundaries yet
- Network overhead is unnecessary complexity
- ACID transactions are free
- Debugging is trivial
```

### Graduate to Modular Monolith

```
Growing team (10-50)? Refactor to modular monolith.
- Enforce module boundaries in code
- Each module owns its tables (separate schemas)
- Communication via public module APIs only
- No direct cross-module database access
```

**Modular monolith structure:**
```
src/
  modules/
    orders/
      __init__.py       # Public API exports only
      api.py            # Public functions other modules can call
      domain/           # Internal: business logic
        models.py
        services.py
      infra/            # Internal: database, external calls
        repository.py
        client.py
      tests/
    payments/
      __init__.py
      api.py
      domain/
      infra/
      tests/
```

**Enforcement rules:**
1. `__init__.py` exports only the public API
2. Linting rule: no imports from `modules.X.domain` or `modules.X.infra` by other modules
3. Architecture tests verify no cross-module boundary violations
4. Each module has its own database schema (or schema prefix)

### Extract to Microservices (When Justified)

```
Only extract to microservices when:
- A module needs independent scaling (10x more traffic)
- A module needs different technology (ML in Python, API in Go)
- Team independence is blocked by monolith deployment
- Compliance requires isolation (PCI-DSS, HIPAA)
```

**Extract one module at a time:**
1. Module already has clean API boundary (modular monolith)
2. Replace in-process calls with HTTP/gRPC
3. Extract database tables to separate database
4. Deploy independently
5. Add circuit breakers and timeouts

## Real-World Signals

**Signals you need microservices:**
- Deploy queue is 2+ weeks long
- Teams block each other on releases
- One component needs 100x more resources
- Different regulatory domains (PCI vs non-PCI)

**Signals you DON'T need microservices:**
- "Netflix does it" (you are not Netflix)
- Team < 10 developers
- Single business domain
- No independent scaling needs
- Team lacks distributed systems expertise

## The Amazon Prime Video Case (2023)

Amazon Prime Video moved from microservices BACK to a monolith for their video quality
monitoring system. The distributed architecture had:
- High infrastructure cost (data transfer between services)
- Scaling bottleneck at orchestration layer
- Unnecessary complexity for a single-team service

**Lesson:** Architecture decisions are context-dependent. Even Amazon chooses monoliths
when the context warrants it.

## Sources

- https://blog.bytebytego.com/p/monolith-vs-microservices-vs-modular
- https://www.javacodegeeks.com/2025/12/microservices-vs-modular-monoliths-in-2025-when-each-approach-wins.html
- https://blog.justenougharchitecture.com/microservices-vs-monoliths-vs-modular-monoliths-a-2025-decision-framework/
- Sam Newman, "Building Microservices" (2nd ed, 2021)
