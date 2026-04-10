---
name: design
description: |
  Software architecture knowledge base (2026). Covers SOLID principles with real trade-offs,
  Architecture Decision Records (ADR/MADR template), C4 Model (Context/Container/Component/Code),
  system decomposition (DDD, bounded contexts), trade-off analysis (ATAM, utility trees),
  fitness functions, microservices vs monolith vs modular monolith decision tree,
  security architecture (zero trust, STRIDE threat modeling), API design (REST/GraphQL/gRPC),
  and event-driven architecture (CQRS, event sourcing).
  Use when: (1) Making architectural decisions, (2) Writing ADRs, (3) Creating C4 diagrams,
  (4) Evaluating trade-offs, (5) Planning system decomposition, (6) Designing APIs,
  (7) Choosing between monolith/microservices.
  Triggers: /design, architecture, ADR, C4, trade-off, decomposition, design review.
type: capability
---

# Design — Software Architecture Methodology

## Purpose

This skill is the knowledge base for software architecture (2026).
It is **language-agnostic** — it complements language skills with the design and architectural
decision-making layer.

**What this skill contains:**
- SOLID principles with real trade-offs (not textbook)
- Architecture Decision Records (ADR) — templates, lifecycle, MADR
- C4 Model (Context, Container, Component, Code)
- Diagrams — when to use each type
- Design review with fitness functions
- System decomposition (DDD, bounded contexts)
- Trade-off analysis (ATAM, utility trees)
- Security architecture (zero trust, STRIDE, defense in depth)
- API design (REST, GraphQL, gRPC)
- Event-driven architecture (CQRS, event sourcing)
- Microservices vs monolith vs modular monolith decision

---

## Philosophy

### Architecture is About Decisions, Not Diagrams

Software architecture is the set of decisions that are expensive to change.
Diagrams are just the visual representation of those decisions.

### Fundamental Principles

1. **Explicit and documented decisions** — every significant architectural decision deserves an ADR
2. **Trade-offs, never silver bullets** — every decision has cost and benefit; quantify them
3. **Simplicity first** — start with the simplest solution that solves the problem
4. **Fitness functions as guardrails** — automated metrics protect architectural decisions
5. **Evolution, not big bang** — architecture evolves incrementally

---

## 1. SOLID Principles — With Real Trade-offs

SOLID is not dogma. It is a toolkit. Each principle has cost and context where it makes sense.

### Single Responsibility Principle (SRP)

**What it really means:** A module has one, and only one, reason to change.

**Real trade-off:**
- Excessive SRP = explosion of tiny classes/modules
- Insufficient SRP = god classes that change for 5 different reasons
- **Heuristic:** if you can't name the responsibility in one phrase, it's too large; if you need 3 classes to follow one flow, it's too granular

### Open/Closed Principle (OCP)

**What it really means:** Open for extension, closed for modification.

**Real trade-off:**
- Premature OCP = unnecessary abstractions, Strategy pattern for something that changes once
- **Heuristic:** apply OCP when the variation point has already appeared 2+ times, not the first time

### Liskov Substitution Principle (LSP)

**What it really means:** Subtypes must be substitutable for their base types.

**Real trade-off:**
- Prefer composition; use inheritance only for genuine "is-a" relationships

### Interface Segregation Principle (ISP)

**What it really means:** Clients should not depend on interfaces they don't use.

**Real trade-off:**
- Excessive ISP = 20 one-method interfaces, impossible to navigate
- **Heuristic:** group by usage cohesion, not maximum granularity

### Dependency Inversion Principle (DIP)

**What it really means:** High-level modules should not depend on low-level modules; both should depend on abstractions.

**Real trade-off:**
- DIP is essential at architectural boundaries (domain vs infrastructure)
- DIP on EVERYTHING = indirection hell
- **Heuristic:** apply at boundaries; within the same module, direct dependencies are ok

### When NOT to Apply SOLID

- Prototypes and MVPs (throwaway code is cheaper than abstraction)
- Utility scripts (< 200 lines)
- Glue code between systems (simple adapters)

---

## 2. Architecture Decision Records (ADR)

ADRs capture significant architectural decisions with context, alternatives, and consequences.

### MADR Template

```markdown
# ADR-{NNN}: {Decision Title}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-XXX}

## Context

{What problem are we solving? What is the technical and business context?
What constraints exist? What motivated this decision?}

## Decision Drivers

- {driver 1: e.g., latency < 100ms for p99}
- {driver 2: e.g., team has Python experience}
- {driver 3: e.g., budget limited to 2 instances}

## Considered Options

### Option A: {Name}
- **Pros:** {benefits}
- **Cons:** {costs}
- **Effort:** {effort estimate}

### Option B: {Name}
- **Pros:** {benefits}
- **Cons:** {costs}
- **Effort:** {effort estimate}

## Decision

{Which option was chosen and WHY. Explain the reasoning.}

## Consequences

### Positive
- {positive consequence}

### Negative
- {negative consequence and how to mitigate}

### Risks
- {identified risk and probability}

## Related Decisions

- {ADR-XXX: related decision}

## Notes

- {date of decision}
- {participants}
```

### Lifecycle

```
Proposed -> Accepted -> [Active]
                     -> Deprecated (technology/context changed)
                     -> Superseded by ADR-XXX (decision replaced)
```

### Best Practices

1. **One decision per ADR** — split if necessary
2. **Write DURING the decision** — not after
3. **5-10 minutes to read** — concise, focused
4. **Store in `/docs/adr/`** — versioned with the code
5. **Accepted ADRs are immutable** — new decision = new ADR that supersedes
6. **Review every 6-12 months** — deprecate what no longer applies

---

## 3. C4 Model

The C4 Model by Simon Brown organizes diagrams in 4 levels of progressive zoom.

### Level 1: System Context

**What it shows:** The system as a black box + users + external systems.
**Audience:** Everyone (devs, PMs, stakeholders).
**Rule:** Maximum 10-15 elements.

```
[User] --> [Your System] --> [External System A]
                         --> [External System B]
```

### Level 2: Container

**What it shows:** Deployable containers within the system (web app, API, database, queue).
**Audience:** Devs and ops.
**Rule:** One container = one deployment unit. Database is a container. Queue is a container.

```
[Web App] --> [API Server] --> [Database]
                           --> [Message Queue] --> [Worker]
```

### Level 3: Component

**What it shows:** Logical components within a container (controllers, services, repositories).
**Audience:** Team developers.
**Rule:** Use only for complex containers. Not needed for all.

### Level 4: Code

**What it shows:** Classes/functions within a component.
**Rule:** Almost never worth maintaining. Use the IDE.

### When to Create Each Level

| Level | When to create | When to update | Maintain? |
|-------|----------------|----------------|-----------|
| Context | Always | Each new external system | Yes |
| Container | Always | Each new container | Yes |
| Component | Complex containers | Large refactors | Maybe |
| Code | Never (use IDE) | — | No |

---

## 4. Fitness Functions

Fitness functions are automated metrics that protect architectural decisions.

```
Fitness Function = metric + baseline + target + threshold + automation
```

| Aspect | Example | Tool |
|--------|---------|------|
| Coupling | Cyclic dependencies = 0 | deptry, madge |
| Complexity | Cyclomatic complexity < 15 | ruff, biome |
| Performance | p99 latency < 200ms | k6, locust |
| Security | Critical vulnerabilities = 0 | Snyk, Trivy |
| Coverage | Test coverage > 80% | pytest-cov, vitest |
| Bundle | Bundle size < 200KB gzip | webpack-bundle-analyzer |
| API | Breaking changes = 0 | openapi-diff |

### Architecture Tests (Fitness Functions in Code)

```python
# Domain layer must not import infrastructure
def test_domain_does_not_import_infra():
    """Ensure domain module has no infrastructure dependencies."""
    import ast
    import pathlib

    domain_files = pathlib.Path("src/domain").rglob("*.py")
    forbidden = {"sqlalchemy", "redis", "httpx", "boto3"}

    for f in domain_files:
        tree = ast.parse(f.read_text())
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    assert alias.name.split(".")[0] not in forbidden
```

---

## 5. Design Review Checklist

```markdown
## Pre-Review
- [ ] ADR written for significant decisions
- [ ] C4 diagrams updated (Context + Container)
- [ ] Fitness functions defined for quality attributes

## Functional
- [ ] All functional requirements covered
- [ ] Edge cases identified and handled
- [ ] Error handling at all boundaries

## Quality Attributes
- [ ] Performance: SLOs defined and tested
- [ ] Scalability: bottlenecks identified
- [ ] Security: threat model updated
- [ ] Reliability: failure modes mapped
- [ ] Maintainability: complexity controlled

## Operability
- [ ] Structured logging in all components
- [ ] Metrics exposed (RED/USE)
- [ ] Health checks implemented
- [ ] Runbooks for known failure modes

## API
- [ ] Contracts defined (OpenAPI, Protobuf, GraphQL schema)
- [ ] Versioning planned
- [ ] Rate limiting configured
- [ ] Backward compatibility verified
```

---

## 6. System Decomposition

### DDD — Bounded Contexts

**Bounded Context** = logical boundary where a domain model is consistent.

```
Decomposition Heuristics:
1. Linguistic boundary  — do terms change meaning? (e.g., "Order" in Sales vs Shipping)
2. Data ownership       — who is the source of truth for this entity?
3. Rate of change       — do parts change at different speeds?
4. Team boundary        — different teams? Consider separate bounded contexts
5. Compliance boundary  — regulatory requirements isolate components?
```

### Decomposition Strategies

| Strategy | When to use | Risk |
|----------|-------------|------|
| By business capability | Clear domains, aligned teams | May create silos |
| By subdomain (DDD) | Core vs supporting vs generic | Requires domain expertise |
| By volatility | Parts that change a lot vs stable | Overengineering |
| By data ownership | Each service owns its data | Distributed transactions |
| Strangler fig | Gradual legacy migration | Long, requires discipline |

### Anti-patterns

1. **Distributed monolith** — microservices that need to deploy together
2. **Shared database** — multiple services reading/writing the same table
3. **Chatty services** — 10 calls between services for one operation
4. **Nano-services** — services so small that overhead > value

---

## 7. Microservices vs Monolith Decision

### Decision Tree

```
Start here: Do you have well-defined bounded contexts?
  |
  NO --> Use modular monolith
  |
  YES --> Do different parts need to scale independently?
    |
    NO --> Use modular monolith
    |
    YES --> Do you have multiple teams (6+ engineers)?
      |
      NO --> Use modular monolith
      |
      YES --> Do you have mature DevOps practices?
        |
        NO --> Use modular monolith, build DevOps first
        |
        YES --> Consider microservices
```

### Maturity Requirements for Microservices

Before splitting into microservices, you MUST have:
- [ ] Service discovery
- [ ] Distributed tracing (OpenTelemetry)
- [ ] Centralized logging
- [ ] API gateway
- [ ] Circuit breakers
- [ ] Automated testing at service boundaries
- [ ] CI/CD per service
- [ ] On-call rotation (microservices fail in new ways)

---

## 8. Trade-off Analysis (ATAM)

### Utility Tree

```
Quality Attribute
  |
  +-- Stimulus Scenario
  |     Priority: (H,M,L) business x (H,M,L) technical risk
  |
  Example:
    Performance
      |
      +-- "1000 concurrent users, response < 200ms p99" (H,H)
      +-- "Batch job processes 1M records in < 5min" (M,M)

    Availability
      |
      +-- "System survives single AZ failure" (H,H)
      +-- "Zero-downtime deployments" (H,M)
```

### Trade-off Quantification

Don't just list trade-offs — quantify them:

```markdown
| Decision | Option A | Option B | Winner |
|----------|----------|----------|--------|
| Latency p99 | 50ms | 200ms | A |
| Throughput | 1K rps | 10K rps | B |
| Dev effort | 2 weeks | 6 weeks | A |
| Ops complexity | Low | High | A |
| Cost/month | $500 | $2000 | A |
| Scalability ceiling | 5K users | 500K users | B |
```

---

## 9. Security Architecture

### Zero Trust Principles

```
1. Never trust, always verify
2. Assume breach
3. Least privilege access
4. Micro-segmentation
5. Continuous verification
```

### Defense in Depth Layers

```
Layer 1: Network     — firewall, VPN, network segmentation
Layer 2: Identity    — MFA, SSO, identity provider (OIDC)
Layer 3: Application — input validation, output encoding, CSRF tokens
Layer 4: Data        — encryption at rest, encryption in transit, key rotation
Layer 5: Monitoring  — audit logs, anomaly detection, SIEM
```

### STRIDE Threat Modeling

| Threat | Description | Mitigation |
|--------|-------------|------------|
| **S**poofing | Faking identity | Authentication, MFA |
| **T**ampering | Modifying data | Integrity checks, signing |
| **R**epudiation | Denying actions | Audit logging |
| **I**nformation Disclosure | Data leak | Encryption, access control |
| **D**enial of Service | Overloading system | Rate limiting, CDN |
| **E**levation of Privilege | Unauthorized access | Least privilege, RBAC |

### Security Checklist

```markdown
- [ ] Authentication: OIDC/OAuth2, MFA for privileged ops
- [ ] Authorization: RBAC or ABAC, least privilege
- [ ] Input validation: schema validation at every boundary
- [ ] Secrets management: vault, never hardcoded, rotation policy
- [ ] Encryption: TLS 1.3 in transit, AES-256 at rest
- [ ] Dependency scanning: automated CVE checks in CI
- [ ] Audit logging: who did what when (immutable)
- [ ] Rate limiting: per-user, per-endpoint
- [ ] CORS: restrict to known origins
- [ ] CSP: Content-Security-Policy headers
```

---

## 10. API Design

### REST

```
- Use nouns for resources: /users/{id}, not /getUser/{id}
- Use HTTP methods: GET (read), POST (create), PUT (replace), PATCH (update), DELETE (remove)
- Versioning: /v1/users or Accept: application/vnd.api+json;version=1
- Status codes: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 404 Not Found, 409 Conflict
- Pagination: cursor-based for large datasets, page-based for UI
- Error format: {code, message, details[]}
```

### GraphQL

```
- Use for data-intensive UIs with flexible queries
- Schema-first: define SDL before implementation
- Resolver depth limiting: prevent N+1 in resolvers
- DataLoader pattern: batch and cache database calls
- Persisted queries: for production (prevent arbitrary queries)
```

### gRPC

```
- Use for internal service-to-service communication
- Protocol Buffers: strongly typed, compact, fast
- Bidirectional streaming for real-time data
- Deadline propagation: always set deadlines on calls
```

### API Design Checklist

```markdown
- [ ] Contract defined first (OpenAPI / Protobuf / GraphQL schema)
- [ ] Versioning strategy decided
- [ ] Breaking vs non-breaking changes documented
- [ ] Rate limiting configured
- [ ] Authentication scheme documented
- [ ] Error responses standardized
- [ ] Pagination strategy defined
- [ ] Idempotency for mutation endpoints (POST/PUT)
```

---

## Reference Files

- [references/adr-templates.md](references/adr-templates.md) — ADR templates, lifecycle, examples
- [references/c4-model.md](references/c4-model.md) — C4 guide, Structurizr DSL examples
- [references/fitness-functions.md](references/fitness-functions.md) — Fitness function catalog
- [references/decomposition.md](references/decomposition.md) — DDD patterns, bounded contexts
- [references/api-design.md](references/api-design.md) — REST, GraphQL, gRPC patterns
- [references/security.md](references/security.md) — Zero trust, STRIDE, security checklist
