# Test Strategy -- Pyramid vs Trophy

## The Testing Pyramid

Originally proposed by Mike Cohn, popularized by Martin Fowler.

```
        /  E2E  \          5-10% of tests
       /----------\
      / Integration \      20-30% of tests
     /----------------\
    /    Unit Tests     \  60-70% of tests
   /____________________\
```

### Rationale
- Unit tests are fast, cheap, and isolated
- Integration tests are moderate cost
- E2E tests are slow, expensive, and brittle
- More tests at the base = faster feedback

### Best For
- Libraries with pure functions
- Backend services with complex business logic
- Data processing pipelines
- Algorithms and mathematical computations

## The Testing Trophy

Proposed by Kent C. Dodds as a modern alternative.

```
        ___E2E___          10% of tests
       /         \
      | Integration |      40-50% of tests (MOST)
      |_____________|
       \  Unit   /         20-30% of tests
        \_______/
       |  Static  |        Continuous (type checker, linter)
       |__________|
```

### Rationale
- Integration tests give the highest confidence-per-test
- Modern tooling makes integration tests fast enough
- Unit tests on trivial code add maintenance without confidence
- Static analysis catches entire categories of bugs for free

### Best For
- Frontend applications (React, Vue, Angular)
- REST/GraphQL APIs
- Microservices with many integration points
- Full-stack applications

## The Testing Diamond (Hybrid)

For teams that need both:

```
        /  E2E  \          Critical paths only
       /----------\
      | Integration |      Most tests here
      |_____________|
      | Integration |      (yes, double-wide)
      |_____________|
       \  Unit   /         Pure logic only
        \_______/
```

## What to Test Where

### Static Analysis
```
mypy / TypeScript strict     -> type errors
ruff / Biome                 -> code smells, unused imports
bandit / semgrep             -> security vulnerabilities
```

### Unit Tests
- Pure functions (no I/O, no side effects)
- Validation logic
- Data transformations
- Business rule calculations
- Error message formatting
- Utility functions

### Integration Tests
- HTTP endpoint request/response cycle
- Database CRUD operations
- Cache read/write behavior
- Queue message produce/consume
- Authentication flow
- Authorization checks
- File upload/download

### E2E Tests
- User signup -> login -> use feature -> logout
- Purchase flow (add to cart -> checkout -> payment -> confirmation)
- Admin operations (create user -> assign role -> verify access)
- Error recovery (network failure -> retry -> success)

## Anti-Patterns

### Testing Ice Cream Cone (inverted pyramid)
```
   /________________________\
  /       E2E Tests          \    <- too many, slow, flaky
 /--------------------------\
|     Integration Tests      |
 \--------------------------/
  \    Unit Tests    /            <- too few
   \________________/
```

**Problem:** Slow CI, flaky tests, low developer confidence.

### Testing Hourglass
```
        /  E2E  \              <- many
       /----------\
      |            |
      |            |           <- few integration tests
      |            |
       \__________/
    /    Unit Tests     \      <- many
   /____________________\
```

**Problem:** Unit + E2E without integration = gaps in the middle where most bugs live.
