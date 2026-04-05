# System Decomposition Strategies

## Domain-Driven Design (DDD) — Strategic Patterns

### Bounded Contexts

A bounded context is a boundary within which a domain model is consistent and meaningful.
The same term (e.g., "Order") can mean different things in different bounded contexts.

```
Sales Context:          Order = quote + pricing + discounts
Fulfillment Context:    Order = items + shipping address + tracking
Billing Context:        Order = invoice + payment status + refunds
```

### Context Mapping Patterns

| Pattern | Description | When to use |
|---------|-------------|-------------|
| **Shared Kernel** | Two contexts share a subset of the model | Tightly coupled teams, shared core |
| **Customer-Supplier** | Upstream supplies, downstream consumes | Clear dependency direction |
| **Conformist** | Downstream conforms to upstream model | No negotiation power |
| **Anti-Corruption Layer** | Translation layer between contexts | Integrating with legacy/external |
| **Open Host Service** | Upstream provides stable published API | Multiple consumers |
| **Published Language** | Shared language (e.g., protocol, schema) | Cross-context communication |
| **Separate Ways** | No integration, duplicate if needed | Truly independent contexts |

### Decomposition Heuristics

```
1. Linguistic boundary
   Ask: Do the same terms mean different things to different teams?
   Signal: "Order" means different things to sales vs shipping

2. Data ownership
   Ask: Who is the source of truth for this entity?
   Signal: Two teams both write to the same table

3. Rate of change
   Ask: Do parts of the system change at different speeds?
   Signal: Auth changes yearly, product catalog changes daily

4. Team boundary (Conway's Law)
   Ask: Would different teams own different parts?
   Signal: Organization chart maps to architecture

5. Compliance boundary
   Ask: Are there regulatory requirements that isolate data?
   Signal: PCI-DSS for payments, GDPR for user data

6. Scalability boundary
   Ask: Do parts need to scale independently?
   Signal: Search needs 10x more compute than auth

7. Fault isolation
   Ask: Should a failure in X not affect Y?
   Signal: Payment failure should not block product browsing
```

## Strangler Fig Pattern

For migrating from monolith to services gradually:

```
Phase 1: Route all traffic through facade
  Client -> Facade -> Monolith

Phase 2: Extract one capability, route to new service
  Client -> Facade -> New Service (orders)
                   -> Monolith (everything else)

Phase 3: Extract more capabilities
  Client -> Facade -> Order Service
                   -> User Service
                   -> Monolith (shrinking)

Phase 4: Monolith fully replaced
  Client -> API Gateway -> Order Service
                        -> User Service
                        -> Payment Service
```

**Rules:**
1. Extract one bounded context at a time
2. Start with the least coupled context
3. Keep the monolith working throughout
4. Each extraction is a complete, tested migration
5. Never do big bang — always incremental

## Anti-patterns

### Distributed Monolith
Services that must be deployed together, defeating the purpose of microservices.
**Signal:** Changing service A requires changing service B and deploying both.
**Fix:** Review service boundaries, merge tightly coupled services.

### Shared Database
Multiple services reading/writing the same tables.
**Signal:** Schema changes require coordinating across teams.
**Fix:** Each service owns its data. Communicate via APIs or events.

### Chatty Services
Too many synchronous calls between services for a single operation.
**Signal:** One user request triggers 10+ inter-service HTTP calls.
**Fix:** Merge services, use async events, or denormalize data.

### Nano-services
Services so small that the operational overhead exceeds the value.
**Signal:** A service has one endpoint and 50 lines of code.
**Fix:** Merge into a larger bounded context.

## Sources

- Eric Evans, "Domain-Driven Design" (2003)
- Vaughn Vernon, "Implementing Domain-Driven Design" (2013)
- Sam Newman, "Building Microservices" (2nd ed, 2021)
- Martin Fowler, "StranglerFigApplication" (2004)
