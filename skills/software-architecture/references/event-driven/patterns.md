# Event-Driven Architecture Patterns

## CQRS (Command Query Responsibility Segregation)
- Separate read and write models
- Write model: normalized, optimized for consistency
- Read model: denormalized, optimized for queries
- Use when: read/write patterns differ significantly, need independent scaling

## Event Sourcing
- Store events (facts), not current state
- Rebuild state by replaying events
- Benefits: full audit trail, time-travel debugging, event-driven integration
- Trade-offs: complexity, eventual consistency, event versioning challenges
- Use when: audit requirements, complex domain logic, need event replay

## Saga Patterns
### Choreography
- Services react to events from other services
- No central coordinator — loose coupling
- Harder to understand full flow, compensating transactions distributed
- Use when: simple flows, few services

### Orchestration  
- Central orchestrator coordinates the saga steps
- Easier to understand, centralized error handling
- Single point of failure risk, tighter coupling to orchestrator
- Use when: complex flows, many services, need visibility

## Event Design
```json
{
  "event_id": "uuid",
  "event_type": "OrderPlaced",
  "aggregate_id": "order-123",
  "timestamp": "2026-01-01T00:00:00Z",
  "version": 1,
  "data": { "items": [...], "total": 99.99 },
  "metadata": { "user_id": "u-456", "correlation_id": "corr-789" }
}
```

## Event Versioning
- Schema registry (Confluent, AWS Glue)
- Upcasters: transform old events to new schema on read
- Never delete event types — deprecate and stop producing
