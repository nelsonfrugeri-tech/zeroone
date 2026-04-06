---
name: software-architecture
description: |
  Baseline de conhecimento para arquitetura de software estado da arte. Cobre SOLID com trade-offs reais,
  Architecture Decision Records (ADR), C4 Model, diagramas, design review com fitness functions,
  decomposição de sistemas, analise de trade-offs (ATAM/ATRAF), estrategia de testes por camada,
  seguranca (zero trust, defense in depth), performance, observabilidade, API design (REST/GraphQL/gRPC),
  event-driven architecture (CQRS, event sourcing), e framework de decisão microservices vs monolith vs
  modular monolith. Use quando: (1) Tomar decisões arquiteturais, (2) Documentar ADRs, (3) Criar diagramas
  C4, (4) Avaliar trade-offs, (5) Planejar decomposição de sistemas, (6) Definir estrategia de testes,
  (7) Projetar APIs, (8) Escolher entre monolith/microservices.
  Triggers: /software-architecture, architecture, ADR, C4, trade-off, decomposition, design review.
---

# Software Architecture — Arquitetura de Software

## Propósito

Esta skillé a **biblioteca de conhecimento** para arquitetura de software (2026).
Ela é **language-agnostic** — complementa skills como `arch-py` e `arch-ts` com a camada de design e decisão arquitetural.

**Skill global** — carregada automaticamente por todos os agents.


- Voce diretamente -> quando precisar de referencia de patterns arquiteturais

**O que esta skill contem:**
- SOLID principles com trade-offs reais (nao textbook)
- Architecture Decision Records (ADR) — templates, lifecycle, MADR
- C4 Model (Context, Container, Component, Code)
- Diagramas: quando usar cada tipo
- Design review com fitness functions
- Decomposicao de sistemas (DDD, bounded contexts)
- Trade-off analysis (ATAM, ATRAF, utility trees)
- Estrategia de testes por camada arquitetural
- Seguranca (zero trust, defense in depth)
- Performance e avaliação de capacidade
- Observabilidade by design
- API design (REST, GraphQL, gRPC)
- Event-driven architecture (CQRS, event sourcing)
- Microservices vs monolith vs modular monolith

**O que esta skill NAO contem:**
- Implementacao em linguagem especifica (isso está em `arch-py`, `arch-ts`)
- Workflow de execucao — isso esta nos agents
- Infraestrutura/DevOps — isso está em `local-infrastructure` skill

---

## Filosofia

### Arquitetura e sobre decisões, não diagramas

**Arquitetura de software é o conjunto de decisões que são caras de mudar.**
Diagramas são apenas a representação visual dessas decisões.

### Principios Fundamentais

**1. Decisoes explícitas e documentadas**
- Toda decisão arquitetural significativa merece um ADR
- O "porquê" e mais importante que o "o que"
- Decisoes não documentadas são decisões perdidas

**2. Trade-offs, nunca silver bullets**
- Toda decisão tem custo e beneficio
- Quantifique trade-offs (latencia, throughput, custo, complexidade)
- "Depende"é a resposta certa — o que importa e do que depende

**3. Simplicidade primeiro**
- Comece com a solucao mais simples que resolve o problema
- Adicione complexidade apenas quando justificada por evidencia
- Modular monolith > microservices ate provar o contrario

**4. Fitness functions como guardrails**
- Defina metricas automatizadas para proteger decisões arquiteturais
- Se não pode medir, não pode garantir
- Fitness functions > documentação (documentação mente, metricas nao)

**5. Evolucao, não big bang**
- Arquitetura evolui incrementalmente
- Decisoes são reversiveis ate certo ponto — minimize o custo de reversao
- Prefira decisões que manteem opcoes abertas (last responsible moment)

---

## 1. SOLID Principles — Com Trade-offs Reais

SOLID não e dogma. E um toolkit. Cada principio tem custo e contexto onde faz sentido.

### Single Responsibility Principle (SRP)

**O que realmente significa:** Um modulo tem uma, e apenas uma, razao para mudar.

**Trade-off real:**
- SRP excessivo = explosion de classes/modulos com 10 linhas cada
- SRP insuficiente = god classes que mudam por 5 razoes diferentes
- **Heuristica:** se voce não consegue nomear a responsabilidade em uma frase, esta grande demais; se precisa de 3 classes para ler um fluxo, esta granular demais

### Open/Closed Principle (OCP)

**O que realmente significa:** Extensivel sem modificar o codigo existente.

**Trade-off real:**
- OCP prematuro = abstractions desnecessarias, Strategy pattern para algo que muda uma vez
- OCP ignorado = shotgun surgery em cada mudanca de requisito
- **Heuristica:** aplique OCP quando o ponto de variacao JA apareceu 2+ vezes, não na primeira vez

### Liskov Substitution Principle (LSP)

**O que realmente significa:** Subtipos devem ser substituiveis por seus tipos base sem quebrar o programa.

**Trade-off real:**
- LSP garante contratos confiaveis, mas heranca profunda cria fragilidade
- **Heuristica:** prefira composicao; use heranca apenas para "is-a" genuino

### Interface Segregation Principle (ISP)

**O que realmente significa:** Clientes não devem depender de interfaces que não usam.

**Trade-off real:**
- ISP excessivo = 20 interfaces de um metodo cada, impossivel navegar
- ISP ignorado = fat interfaces que forcam implementacoes vazias
- **Heuristica:** agrupe por coesao de uso, não por granularidade maxima

### Dependency Inversion Principle (DIP)

**O que realmente significa:** Modulos de alto nivel não devem depender de modulos de baixo nivel; ambos devem depender de abstracoes.

**Trade-off real:**
- DIP e essencial em boundaries arquiteturais (domain vs infra)
- DIP em TUDO = indirection hell, cada classe tem uma interface
- **Heuristica:** aplique em boundaries; dentro do mesmo modulo, dependencias diretas são ok

### Quando NAO aplicar SOLID

- Prototipos e MVPs (descarte e mais barato que abstraction)
- Scripts utilitarios (< 200 linhas)
- Glue code entre sistemas (adaptadores simples)

---

## 2. Architecture Decision Records (ADR)

ADRs capturam decisões arquiteturais significativas com contexto, alternativas e consequencias.

### MADR Template (Markdown Any Decision Record)

```markdown
# ADR-{NNN}: {Titulo da Decisao}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-XXX}

## Context

{Qual problema estamos resolvendo? Qual é o contexto tecnico e de negocio?
Quais constraints existem? O que motivou essa decisão?}

## Decision Drivers

- {driver 1: e.g., latencia < 100ms para p99}
- {driver 2: e.g., time tem experiencia com Python}
- {driver 3: e.g., budget limita a 2 instancias}

## Considered Options

### Option A: {Nome}
- **Pros:** {beneficios}
- **Cons:** {custos}
- **Effort:** {estimativa de esforco}

### Option B: {Nome}
- **Pros:** {beneficios}
- **Cons:** {custos}
- **Effort:** {estimativa de esforco}

### Option C: {Nome}
- **Pros:** {beneficios}
- **Cons:** {custos}
- **Effort:** {estimativa de esforco}

## Decision

{Qual opcao foi escolhida e PORQUE. Explicar o raciocinio.}

## Consequences

### Positive
- {consequencia positiva}

### Negative
- {consequencia negativa e como mitigar}

### Risks
- {risco identificado e probabilidade}

## Related Decisions

- {ADR-XXX: decisão relacionada}

## Notes

- {data da decisão}
- {participantes}
```

### Lifecycle

```
Proposed -> Accepted -> [Active]
                     -> Deprecated (tecnologia/contexto mudou)
                     -> Superseded by ADR-XXX (decisão substituida)
```

### Boas Práticas

1. **Uma decisão por ADR** — split se necessario
2. **Escreva DURANTE a decisão** — não apos
3. **5-10 minutos para ler** — conciso, focado
4. **Armazene em `/docs/adr/`** — versionado com o codigo
5. **ADRs aceitos são imutaveis** — nova decisão = novo ADR que supersede
6. **Review a cada 6-12 meses** — deprecie o que não se aplica mais

**Referência:** [references/adr/templates.md](references/adr/templates.md)

---

## 3. C4 Model

O C4 Model de Simon Brown organiza diagramas em 4 niveis de zoom progressivo.

### Level 1: System Context

**O que mostra:** O sistema como caixa preta + usuarios + sistemas externos.
**Audiencia:** Todos (devs, PMs, stakeholders).
**Regra:** Maximo 10-15 elementos. Se tiver mais, esta detalhado demais.

```
[User] --> [Your System] --> [External System A]
                         --> [External System B]
```

### Level 2: Container

**O que mostra:** Containers deployaveis dentro do sistema (web app, API, database, queue).
**Audiencia:** Devs e ops.
**Regra:** Um container = uma unidade de deployment. Database e container. Queue e container.

```
[Web App] --> [API Server] --> [Database]
                           --> [Message Queue] --> [Worker]
```

### Level 3: Component

**O que mostra:** Componentes logicos dentro de um container (controllers, services, repositories).
**Audiencia:** Devs do time.
**Regra:** Use apenas para containers complexos. Nao precisa fazer para todos.

### Level 4: Code

**O que mostra:** Classes/funcoes dentro de um componente.
**Audiencia:** Dev individual.
**Regra:** Quase nunca vale a pena manter atualizado. Use IDE.

### Structurizr DSL

```
workspace {
    model {
        user = person "User" "End user of the system"
        system = softwareSystem "My System" "Core business system" {
            webapp = container "Web App" "React SPA" "TypeScript"
            api = container "API" "REST API" "Python/FastAPI"
            db = container "Database" "PostgreSQL" "SQL"
        }
        external = softwareSystem "Payment Gateway" "Processes payments"

        user -> webapp "Uses"
        webapp -> api "Calls" "HTTPS/JSON"
        api -> db "Reads/Writes" "SQL"
        api -> external "Processes payments" "HTTPS"
    }
    views {
        systemContext system "Context" { include * autoLayout }
        container system "Containers" { include * autoLayout }
    }
}
```

### Quando usar cada nivel

| Nivel | Quando criar | Quando atualizar | Manter? |
|-------|-------------|-----------------|---------|
| Context | Sempre | A cada novo sistema externo | Sim |
| Container | Sempre | A cada novo container | Sim |
| Component | Containers complexos | Refactors grandes | Talvez |
| Code | Nunca (use IDE) | — | Nao |

**Referência:** [references/c4-model/guide.md](references/c4-model/guide.md)

---

## 4. Diagram Types — Quando Usar Cada Um

| Diagrama | Propósito | Ferramenta |
|----------|-----------|------------|
| C4 Context | Visao de alto nivel, stakeholders | Structurizr, draw.io |
| C4 Container | Arquitetura de deployment | Structurizr, draw.io |
| Sequence | Fluxo temporal entre componentes | Mermaid, PlantUML |
| Data Flow (DFD) | Como dados se movem pelo sistema | draw.io |
| Entity Relationship | Schema de banco de dados | dbdiagram.io, draw.io |
| State Machine | Estados e transicoes de uma entidade | Mermaid, XState |
| Deployment | Onde cada container roda (infra) | draw.io, Structurizr |
| Dependency Graph | Acoplamento entre modulos | madge, deptry |

### Regras de ouro para diagramas

1. **Titulo claro** — o que o diagrama mostra
2. **Legenda** — cores, formas, protocolos
3. **Direcao dos fluxos** — setas indicam direcao da chamada/dados
4. **Maximo 15-20 elementos** — se tiver mais, quebre em sub-diagramas
5. **Versione com o codigo** — diagramas desatualizados são piores que nenhum

---

## 5. Design Review — Methodology

### Fitness Functions

Fitness functions são metricas automatizadas que protegem decisões arquiteturais.

```
Fitness Function = metrica + baseline + target + threshold + automacao
```

| Aspecto | Exemplo de Fitness Function | Ferramenta |
|---------|---------------------------|------------|
| Coupling | Dependencias ciclicas = 0 | deptry, madge |
| Complexity | Complexidade ciclomatica < 15 | ruff, biome |
| Performance | p99 latencia < 200ms | k6, locust |
| Security | Vulnerabilidades criticas = 0 | Snyk, Trivy |
| Coverage | Cobertura de testes > 80% | pytest-cov, vitest |
| Bundle | Bundle size < 200KB gzip | webpack-bundle-analyzer |
| API | Breaking changes = 0 | openapi-diff |

### Design Review Checklist

```markdown
## Pre-Review
- [ ] ADR escrito para decisões significativas
- [ ] C4 diagrams atualizados (Context + Container)
- [ ] Fitness functions definidas para quality attributes

## Functional
- [ ] Todos os requisitos funcionais cobertos
- [ ] Edge cases identificados e tratados
- [ ] Error handling em todos os boundaries

## Quality Attributes
- [ ] Performance: SLOs definidos e testados
- [ ] Scalability: bottlenecks identificados
- [ ] Security: threat model atualizado
- [ ] Reliability: failure modes mapeados
- [ ] Maintainability: complexity controlada

## Operability
- [ ] Logging estruturado em todos os components
- [ ] Metrics expostas (RED/USE)
- [ ] Health checks implementados
- [ ] Runbooks para failure modes conhecidos

## API
- [ ] Contratos definidos (OpenAPI, Protobuf, GraphQL schema)
- [ ] Versionamento planejado
- [ ] Rate limiting configurado
- [ ] Backward compatibility verificada
```

**Referência:** [references/trade-off-analysis/fitness-functions.md](references/trade-off-analysis/fitness-functions.md)

---

## 6. System Decomposition

### Domain-Driven Design (DDD) — Bounded Contexts

**Bounded Context** = limite logico onde um modelo de dominio e consistente.

```
Decomposition Heuristics:
1. Linguistic boundary  — termos mudam de significado? (ex: "Order" em Sales vs Shipping)
2. Data ownership       — quem é o source of truth para esta entidade?
3. Rate of change       — partes do sistema mudam em velocidades diferentes?
4. Team boundary        — equipes diferentes? Considere bounded contexts separados
5. Compliance boundary  — requisitos regulatorios isolam componentes?
```

### Strategies

| Strategy | Quando usar | Risco |
|----------|-------------|-------|
| By business capability | Dominios claros, times alinhados | Pode criar silos |
| By subdomain (DDD) | Core vs supporting vs generic | Requer domain expertise |
| By volatility | Partes que mudam muito vs estaveis | Overengineering |
| By data ownership | Cada service owns seus dados | Distributed transactions |
| Strangler fig | Migracao gradual de legado | Longo, requer disciplina |

### Anti-patterns de decomposição

1. **Distributed monolith** — microservices que precisam deploy juntos
2. **Shared database** — multiplos services lendo/escrevendo a mesma tabela
3. **Chatty services** — 10 chamadas entre services para uma operacao
4. **Nano-services** — services tao pequenos que a overhead > valor

**Referência:** [references/decomposition/strategies.md](references/decomposition/strategies.md)

---

## 7. Trade-off Analysis

### ATAM (Architecture Tradeoff Analysis Method)

Processo estruturado do SEI/CMU para avaliar como decisões impactam quality attributes.

```
1. Present business drivers
2. Present architecture
3. Identify architectural approaches
4. Generate quality attribute utility tree
5. Analyze architectural approaches (scenarios)
6. Identify sensitivity points and trade-offs
7. Document risks and non-risks
```

### Utility Tree

Ferramenta para priorizar quality attributes com cenarios concretos.

```
Quality Attribute
  |
  +-- Stimulus Scenario
  |     Priority: (H,M,L) for business x (H,M,L) for technical risk
  |
  +-- Exemplo:
        Performance
          |
          +-- "1000 concurrent users, response < 200ms p99" (H,H)
          +-- "Batch job processes 1M records in < 5min" (M,M)

        Availability
          |
          +-- "System survives single AZ failure" (H,H)
          +-- "Zero-downtime deployments" (H,M)
```

### Trade-off Quantification Framework

Nao basta listar trade-offs — quantifique.

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

**Decisao:** Se o sistema precisa escalar alem de 5K users no proximo ano, Option B. Caso contrario, Option A com menor custo e complexidade.

**Referência:** [references/trade-off-analysis/atam.md](references/trade-off-analysis/atam.md)

---

## 8. Testing Strategy by Architectural Layer

### Test Pyramid by Layer

```
                    /\
                   /  \     E2E Tests (full system)
                  /    \    Contract Tests (API boundaries)
                 /------\   Integration Tests (component + infra)
                /________\  Unit Tests (domain logic)
```

| Layer | Test Type | What to test | Tools |
|-------|-----------|-------------|-------|
| Domain | Unit | Business rules, value objects, entities | pytest, vitest |
| Application | Unit + Integration | Use cases, service orchestration | pytest, vitest |
| API boundary | Contract | API schemas, backward compat | schemathesis, pact |
| Infrastructure | Integration | DB queries, external APIs | testcontainers |
| System | E2E | Critical user journeys | playwright, k6 |

### Contract Testing

Para sistemas distribuidos, contract tests > E2E tests:

```
Consumer-Driven Contracts:
1. Consumer define expectativa (mock)
2. Provider verifica que atende o contrato
3. Contratos vivem no repo do consumer
4. CI do provider roda verificacao
```

### Architecture Tests

Testes que verificam regras arquiteturais (fitness functions em codigo):

```python
# Exemplo: domain layer must not import infrastructure
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

**Referência:** [references/testing-strategy/by-layer.md](references/testing-strategy/by-layer.md)

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

### Threat Modeling (STRIDE)

| Threat | Description | Mitigation |
|--------|-------------|------------|
| **S**poofing | Faking identity | Authentication, MFA |
| **T**ampering | Modifying data | Integrity checks, signing |
| **R**epudiation | Denying actions | Audit logging |
| **I**nformation Disclosure | Data leak | Encryption, access control |
| **D**enial of Service | Overloading system | Rate limiting, CDN |
| **E**levation of Privilege | Gaining unauthorized access | Least privilege, RBAC |

### Security by Design Checklist

```markdown
- [ ] Authentication: OIDC/OAuth2, MFA for privileged ops
- [ ] Authorization: RBAC or ABAC, principle of least privilege
- [ ] Input validation: schema validation at every boundary
- [ ] Secrets management: vault, never hardcoded, rotation policy
- [ ] Encryption: TLS 1.3 in transit, AES-256 at rest
- [ ] Dependency scanning: automated CVE checks in CI
- [ ] Audit logging: who did what when (immutable)
- [ ] Rate limiting: per-user, per-endpoint
- [ ] CORS: restrict to known origins
- [ ] CSP: Content-Security-Policy headers
```

**Referência:** [references/security/zero-trust.md](references/security/zero-trust.md)

---

## 10. Performance Evaluation

### Método RED (for request-driven services)

| Metric | What | SLO Example |
|--------|------|-------------|
| **R**ate | Requests per second | Sustain 5K rps |
| **E**rrors | Error rate percentage | < 0.1% 5xx |
| **D**uration | Latency distribution | p99 < 200ms |

### Método USE (for resources)

| Metric | What | SLO Example |
|--------|------|-------------|
| **U**tilization | % of resource used | CPU < 70% |
| **S**aturation | Queue depth / backlog | Queue < 100 items |
| **E**rrors | Resource errors | Disk errors = 0 |

### Capacity Planning

```
1. Define load model (users, requests, data growth)
2. Measure current capacity (benchmark)
3. Project growth (linear, exponential)
4. Identify bottleneck (CPU, memory, I/O, network)
5. Plan scaling strategy (vertical, horizontal, caching)
6. Set alerts at 70% utilization
```

### Performance Budget

```markdown
| Resource | Budget | Current | Status |
|----------|--------|---------|--------|
| API p99 | < 200ms | 145ms | OK |
| DB query p95 | < 50ms | 32ms | OK |
| Frontend LCP | < 2.5s | 1.8s | OK |
| Frontend bundle | < 200KB gzip | 187KB | OK |
| Memory per instance | < 512MB | 380MB | OK |
```

---

## 11. Observability by Design

### Three Pillars

| Pillar | What | Tools |
|--------|------|-------|
| **Logs** | Discrete events, structured (JSON) | structlog, pino, Loki |
| **Metrics** | Aggregated measurements over time | Prometheus, Datadog |
| **Traces** | Request flow across services | OpenTelemetry, Jaeger |

### Observability Architecture Principles

1. **Structured logging** — JSON, not free text. Include correlation IDs
2. **RED/USE metrics** — expose from every service
3. **Distributed tracing** — OpenTelemetry SDK in every service
4. **Health checks** — `/health` (liveness) + `/ready` (readiness)
5. **SLOs, not just SLAs** — internal targets stricter than external promises
6. **Dashboards per service** — RED metrics + business KPIs
7. **Alerts on symptoms, not causes** — alert on error rate, investigate cause

### Correlation ID Pattern

```
Client -> API Gateway -> Service A -> Service B -> Database
           |                |            |
           +--- X-Request-Id: abc-123 ---+

Every log line includes request_id="abc-123"
Every span includes trace_id from OpenTelemetry
```

**Referência:** [references/observability/design-patterns.md](references/observability/design-patterns.md)

---

## 12. API Design

### REST — When and How

**Quando usar:** APIs publicas, CRUD-heavy, ampla compatibilidade.

```
Design Principles:
1. Resources, not actions    — /users, not /getUsers
2. HTTP verbs for semantics  — GET (read), POST (create), PUT (replace), PATCH (update), DELETE
3. Plural nouns             — /users/123, not /user/123
4. Consistent naming        — snake_case or camelCase, pick one
5. Pagination              — cursor-based > offset (for large datasets)
6. Versioning              — /v1/users or Accept: application/vnd.api.v1+json
7. HATEOAS                 — links for discoverability (optional, pragmatic)
8. Idempotency             — POST with Idempotency-Key header
```

**Error format (RFC 9457 — Problem Details):**
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "Email field is required",
  "instance": "/users/123"
}
```

### GraphQL — When and How

**Quando usar:** Frontend-driven, dados relacionais complexos, multiplos clients com necessidades diferentes.

```
Design Principles:
1. Schema-first design     — define schema antes do resolver
2. Pagination: Relay spec  — Connections with edges/nodes/pageInfo
3. Error handling          — errors array + partial data
4. N+1 prevention          — DataLoader pattern (batching)
5. Depth limiting          — prevent deeply nested queries (DoS)
6. Persisted queries       — client sends hash, not full query (security + perf)
7. Federation              — Apollo Federation for multi-team schemas
```

**Trade-off:** GraphQL e mais complexo de cachear (nao usa HTTP cache nativo).

### gRPC — When and How

**Quando usar:** Comunicacao interna entre servicos, alta performance, streaming.

```
Design Principles:
1. Proto-first             — define .proto before implementation
2. Backward compatibility  — never remove/rename fields, use reserved
3. Streaming               — server, client, bidirectional
4. Deadlines               — always set, propagate across services
5. Error model             — google.rpc.Status with details
6. Health checking         — grpc.health.v1.Health service
7. Reflection              — enable for debugging (grpcurl)
```

**Performance:** gRPC achieves 5-7x lower latency vs REST for internal communication due to HTTP/2 multiplexing + Protocol Buffers binary serialization.

### Decision Framework

| Criteria | REST | GraphQL | gRPC |
|----------|------|---------|------|
| Public API | Best | Good | Poor (tooling) |
| Internal services | Good | Overkill | Best |
| Mobile clients | Good | Best (no overfetch) | Good |
| Streaming | Poor (SSE/WS) | Subscriptions | Best |
| Caching | Best (HTTP cache) | Complex | Manual |
| Learning curve | Low | Medium | Medium |
| Browser support | Native | Native | Via proxy |
| Schema evolution | Manual | Built-in | Protobuf rules |

**Referência:** [references/api-design/comparison.md](references/api-design/comparison.md)

---

## 13. Event-Driven Architecture

### Core Patterns

**Event Notification:** Fire and forget. Producer emite evento, consumers reagem.
```
Order Service --[OrderPlaced]--> Notification Service
                              --> Inventory Service
                              --> Analytics Service
```

**Event-Carried State Transfer:** Evento carrega dados completos, consumers mantem copia local.
```
User Service --[UserUpdated { id, name, email, ... }]--> Search Index
                                                      --> Cache
```

**Event Sourcing:** Estado e derivado de sequencia de eventos imutaveis.
```
Events: [AccountOpened, MoneyDeposited(100), MoneyWithdrawn(30), MoneyDeposited(50)]
State:  { balance: 120 }
```

**CQRS (Command Query Responsibility Segregation):** Separa modelo de escrita (commands) do modelo de leitura (queries).
```
Write Model (normalized, consistent) --[events]--> Read Model (denormalized, fast)
```

### When to Use Each

| Pattern | Use when | Avoid when |
|---------|----------|------------|
| Event Notification | Loose coupling, async reactions | Need synchronous response |
| State Transfer | Consumers need data locally, reduce coupling | Huge payloads, privacy |
| Event Sourcing | Audit trail critical, time-travel debugging | Simple CRUD, team inexperienced |
| CQRS | Read/write patterns differ significantly | Simple domains, small data |

### Event Schema Design

```json
{
  "event_id": "uuid",
  "event_type": "order.placed",
  "event_version": "1.0",
  "timestamp": "2026-04-05T10:30:00Z",
  "source": "order-service",
  "correlation_id": "request-uuid",
  "data": {
    "order_id": "ord-123",
    "total": 99.90
  },
  "metadata": {
    "user_id": "usr-456"
  }
}
```

### Trade-offs

| Benefit | Cost |
|---------|------|
| Loose coupling | Debugging complexity (distributed traces) |
| Scalability | Eventual consistency (stale reads) |
| Auditability (event sourcing) | Schema evolution (versioning events) |
| Independent deployment | Infrastructure complexity (broker, DLQ) |

**Referência:** [references/event-driven/patterns.md](references/event-driven/patterns.md)

---

## 14. Microservices vs Monolith — Decision Framework

### The Spectrum

```
Monolith --> Modular Monolith --> Microservices
  (simple)     (best of both)     (complex, scalable)
```

### Decision by Team Size

| Team Size | Recommendation | Reason |
|-----------|---------------|--------|
| 1-10 devs | Monolith | Coordination cost < distributed system cost |
| 10-50 devs | Modular Monolith | Module boundaries without network overhead |
| 50+ devs | Microservices | Independent deployment justifies overhead |

### Modular Monolith — The Sweet Spot (2026)

**O que e:** Single deployment unit com modulos bem isolados internamente.

```
src/
  modules/
    orders/
      api/          # Public API (other modules call this)
      domain/       # Business logic (internal)
      infra/        # Database, external calls (internal)
    payments/
      api/
      domain/
      infra/
    users/
      api/
      domain/
      infra/
```

**Rules:**
1. Modules communicate only via public API (never direct DB access)
2. Each module owns its tables (no shared tables)
3. Cross-module calls are in-process (function calls, not HTTP)
4. Extracting a module to a service later = change API from function call to HTTP/gRPC

### Decision Checklist

```markdown
Choose MONOLITH when:
- [ ] Team < 10 developers
- [ ] Single business domain
- [ ] ACID transactions needed across entities
- [ ] Rapid prototyping / MVP phase
- [ ] Simple deployment requirements

Choose MODULAR MONOLITH when:
- [ ] Team 10-50 developers
- [ ] Multiple business domains but one deployment
- [ ] Want service boundaries without network complexity
- [ ] Planning future extraction to services
- [ ] Need strong consistency within the system

Choose MICROSERVICES when:
- [ ] Team 50+ developers (or multiple independent teams)
- [ ] Independent deployment is critical
- [ ] Different scaling requirements per component
- [ ] Polyglot stack needed (different languages per service)
- [ ] Organizational structure matches (Conway's Law)
```

### Migration Path

```
1. Monolith (start here)
2. Identify domain boundaries
3. Refactor to Modular Monolith
4. Extract modules to services (one at a time, Strangler Fig)
5. Microservices (only where justified)
```

**Referência:** [references/decomposition/monolith-vs-microservices.md](references/decomposition/monolith-vs-microservices.md)

---

## Composicao com Outras Skills

| Aspecto | Software Architecture | Arch-Py | Arch-Ts |
|---------|----------------------|---------|---------|
| Scope | Design e decisões | Implementacao Python | Implementacao TS |
| SOLID | Trade-offs e quando usar | Patterns Python | Patterns TS |
| ADR | Templates e lifecycle | — | — |
| C4 | Diagramas e niveis | — | — |
| API Design | REST/GraphQL/gRPC | FastAPI, Pydantic | Next.js API routes |
| Testing | Estrategia por camada | pytest | vitest, playwright |
| Security | Patterns arquiteturais | Python security | Frontend security |

**Sempre use esta skill como fundacao de decisões arquiteturais, depois arch-py/arch-ts para implementacao.**

---

## Referências por Dominio

### ADR
- [references/adr/templates.md](references/adr/templates.md) - MADR template completo e variantes

### C4 Model
- [references/c4-model/guide.md](references/c4-model/guide.md) - C4 Model com Structurizr DSL

### Decomposition
- [references/decomposition/strategies.md](references/decomposition/strategies.md) - DDD, bounded contexts, heuristics
- [references/decomposition/monolith-vs-microservices.md](references/decomposition/monolith-vs-microservices.md) - Decision framework detalhado

### API Design
- [references/api-design/comparison.md](references/api-design/comparison.md) - REST vs GraphQL vs gRPC

### Event-Driven
- [references/event-driven/patterns.md](references/event-driven/patterns.md) - CQRS, event sourcing, sagas

### Trade-off Analysis
- [references/trade-off-analysis/atam.md](references/trade-off-analysis/atam.md) - ATAM process e utility trees
- [references/trade-off-analysis/fitness-functions.md](references/trade-off-analysis/fitness-functions.md) - Automated architecture guardrails

### Security
- [references/security/zero-trust.md](references/security/zero-trust.md) - Zero trust, defense in depth, STRIDE

### Testing Strategy
- [references/testing-strategy/by-layer.md](references/testing-strategy/by-layer.md) - Test pyramid, contract tests, architecture tests

### Observability
- [references/observability/design-patterns.md](references/observability/design-patterns.md) - Three pillars, RED/USE, correlation IDs

### External Resources
- [C4 Model](https://c4model.com/)
- [Structurizr](https://structurizr.com/)
- [ADR GitHub](https://adr.github.io/)
- [MADR](https://adr.github.io/madr/)
- [ATAM — SEI/CMU](https://www.sei.cmu.edu/library/architecture-tradeoff-analysis-method-collection/)
- [Fitness Functions — Thoughtworks](https://www.thoughtworks.com/insights/articles/fitness-function-driven-development)
- [NIST Zero Trust SP 800-207](https://nvlpubs.nist.gov/nistpubs/specialpublications/NIST.SP.800-207.pdf)
