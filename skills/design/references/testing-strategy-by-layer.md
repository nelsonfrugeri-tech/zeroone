# Testing Strategy by Architectural Layer

## Test Pyramid per Layer
```
          /  E2E  \           ← Few: critical user journeys
         / Integration \      ← Medium: service boundaries, DB
        /    Unit Tests   \   ← Many: domain logic, pure functions
```

| Layer | Test Type | What | Tools |
|-------|-----------|------|-------|
| Domain/Core | Unit | Business rules, value objects | pytest, jest |
| Application | Unit + Integration | Use cases, orchestration | pytest + test DB |
| Infrastructure | Integration | Repository, API client | testcontainers |
| API | Contract + Integration | Endpoints, serialization | Pact, pytest |
| E2E | E2E | Critical flows | Playwright, pytest |

## Testing Rules per Layer
- **Domain**: 100% unit tested, no mocks (pure logic)
- **Application**: test with real domain, mock infrastructure
- **Infrastructure**: test with real dependencies (testcontainers)
- **API**: contract tests for public APIs, integration for internal

## Anti-patterns
- Testing implementation details instead of behavior
- Mocking everything (tests pass, production fails)
- E2E tests for edge cases (slow, flaky)
- No tests for error paths
