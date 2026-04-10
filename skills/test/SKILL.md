---
name: test
description: |
  Modern Quality Assurance knowledge base (2026). Covers testing strategy (pyramid vs trophy),
  E2E testing (Playwright, pytest), test data management (fixtures, factories, seeding),
  integration testing (real deps vs mocks, testcontainers), API contract testing (Pact),
  performance testing (k6, Locust), accessibility testing (axe-core, WCAG 2.2),
  visual regression testing, smoke testing, test reporting, Definition of Done validation,
  and production readiness checklist.
  Use when: (1) Defining testing strategy, (2) Setting up isolated test environments,
  (3) Implementing E2E/integration/contract/performance/a11y/visual tests, (4) Validating
  Definition of Done, (5) Evaluating production readiness.
  Triggers: /test, /qa, QA, quality assurance, testing strategy, test plan, smoke test.
type: capability
---

# Test — Quality Assurance Methodology

## Purpose

This skill is the knowledge base for modern Quality Assurance (2026).
It complements language skills (`python`, `typescript`) with QA-specific patterns and strategies.

**What this skill contains:**
- Testing strategy (pyramid vs trophy, what to test at each layer)
- E2E testing (Playwright, pytest, isolation, flakiness prevention)
- Test data management (fixtures, factories, seeding, cleanup)
- Integration testing (real dependencies vs mocks, testcontainers)
- API contract testing (Pact, consumer-driven contracts)
- Performance testing (k6, Locust, load/stress/soak)
- Accessibility testing (axe-core, Lighthouse, WCAG 2.2)
- Visual regression testing
- Environment setup and teardown
- Smoke testing
- Definition of Done validation checklist
- Production readiness checklist

**What this skill does NOT contain:**
- Language-specific coding patterns (those live in `python` / `typescript`)
- CI/CD pipeline configuration (that lives in `ci-cd`)
- Execution workflow (agents handle that)

---

## Philosophy

### Tests are Engineering, Not an Afterthought

Quality is built in, not tested in. Tests are first-class artifacts with the same standards
as production code: typed, reviewed, maintained, and refactored.

### Fundamental Principles

1. **Test what matters, not what is easy** — focus on user-facing behavior and critical business paths
2. **Deterministic tests or no tests** — every test must produce the same result on every run
3. **Fast feedback loops** — unit: <1s, integration: <5s, E2E: <30s, total suite: <10 min in CI
4. **Isolation is non-negotiable** — each test starts with clean state
5. **Test the contract, not the implementation** — assert on observable behavior, not internal state

---

## 1. Test Strategy — Pyramid vs Trophy

### The Test Pyramid (Martin Fowler)

```
        /  E2E  \          Few, slow, expensive
       /----------\
      / Integration \      Some, moderate speed
     /----------------\
    /    Unit Tests     \  Many, fast, cheap
   /____________________\
```

**When to use:** Backend services, libraries, utilities with clear function boundaries.

### The Test Trophy (Kent C. Dodds)

```
        ___E2E___          Few, high confidence
       /         \
      | Integration |      MOST tests here
      |_____________|
       \  Unit   /         Some, pure logic only
        \_______/
       |  Static  |        TypeScript, ESLint, mypy
       |__________|
```

**When to use:** Frontend applications, APIs, systems where integration points are the primary risk.

### Decision Framework

| Signal | Prefer Pyramid | Prefer Trophy |
|--------|---------------|---------------|
| Pure business logic | Yes | |
| Complex algorithms | Yes | |
| UI-heavy application | | Yes |
| API with many integrations | | Yes |
| Library / SDK | Yes | |
| Microservices | | Yes |
| Data pipeline | Yes | |

### What to Test at Each Layer

**Static Analysis (base):**
- Type checking (mypy, TypeScript strict)
- Linting (ruff, Biome)
- Security scanning (bandit, semgrep)

**Unit Tests:**
- Pure functions with no side effects
- Business logic calculations
- Data transformations, validation rules
- Edge cases and boundary conditions

**Integration Tests:**
- API endpoint behavior (request -> response)
- Database queries and mutations
- External service interactions
- Authentication and authorization flows

**E2E Tests:**
- Critical user journeys (signup, purchase, core workflows)
- Cross-service flows
- Browser-specific behavior
- Accessibility compliance

---

## 2. Test Environment Setup

### Principles

1. **Reproducible** — same environment every time
2. **Isolated** — tests cannot interfere with each other
3. **Ephemeral** — created before tests, destroyed after
4. **Fast** — environment setup takes seconds, not minutes

### Docker Compose for Test Dependencies

```yaml
# docker-compose.test.yml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports:
      - "5433:5432"
    tmpfs:
      - /var/lib/postgresql/data  # RAM disk for speed

  redis:
    image: redis:7-alpine
    ports:
      - "6380:6379"

  localstack:
    image: localstack/localstack:3
    ports:
      - "4566:4566"
    environment:
      SERVICES: s3,sqs,sns
```

### Testcontainers (Programmatic)

```python
import pytest
from testcontainers.postgres import PostgresContainer
from testcontainers.redis import RedisContainer

@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg.get_connection_url()

@pytest.fixture(scope="session")
def redis():
    with RedisContainer("redis:7-alpine") as r:
        yield r.get_connection_url()
```

### Teardown Checklist

After every test run:
- [ ] Database tables truncated or dropped
- [ ] Redis keys flushed
- [ ] Temporary files deleted
- [ ] Docker containers stopped and removed
- [ ] Ports released
- [ ] Environment variables restored

### conftest.py Pattern (pytest)

```python
import pytest

@pytest.fixture(autouse=True)
def clean_database(db_session):
    """Roll back all changes after each test."""
    yield
    db_session.rollback()

@pytest.fixture(autouse=True)
def reset_redis(redis_client):
    """Flush Redis after each test."""
    yield
    redis_client.flushdb()
```

---

## 3. E2E Testing

### Tool Selection

| Tool | Language | Best For |
|------|----------|----------|
| **Playwright** | Python, JS/TS, .NET, Java | Cross-browser, API + UI, modern web |
| **pytest** | Python | Backend E2E, API testing |
| **Vitest** | TypeScript | Frontend unit + integration |

### Playwright Best Practices

```python
# Page Object Model
class LoginPage:
    def __init__(self, page: Page) -> None:
        self.page = page
        self.email = page.get_by_label("Email")
        self.password = page.get_by_label("Password")
        self.submit = page.get_by_role("button", name="Sign in")

    async def login(self, email: str, password: str) -> None:
        await self.email.fill(email)
        await self.password.fill(password)
        await self.submit.click()

async def test_login_success(page: Page) -> None:
    login_page = LoginPage(page)
    await page.goto("/login")
    await login_page.login("user@test.com", "password123")
    await expect(page).to_have_url("/dashboard")
```

### Locator Strategy (Priority Order)

1. `get_by_role()` — semantic, accessible, resilient
2. `get_by_label()` — form elements
3. `get_by_text()` — visible text content
4. `get_by_test_id()` — last resort, explicit data-testid

**Never use:** CSS selectors tied to styling, XPath, auto-generated class names

### Flakiness Prevention

```python
# BAD: arbitrary sleep
await page.wait_for_timeout(3000)

# GOOD: wait for specific condition
await page.wait_for_selector("[data-loaded='true']")
await expect(page.get_by_role("heading")).to_be_visible()
```

### What to E2E Test

- [ ] User registration and login
- [ ] Core business workflow (the one that makes money)
- [ ] Payment/checkout flow
- [ ] Permission boundaries (admin vs user)
- [ ] Error recovery (network failure, invalid input)

### What NOT to E2E Test

- Individual component rendering (use unit tests)
- CSS styling details (use visual regression)
- API response schemas (use contract tests)
- Performance under load (use performance tests)

---

## 4. Test Data Management

### Approaches

| Approach | When to Use | Pros | Cons |
|----------|-------------|------|------|
| **Fixtures** | Static reference data | Simple, readable | Brittle if schema changes |
| **Factories** | Dynamic test objects | Flexible, DRY | Requires setup code |
| **Seeding** | Database pre-population | Realistic data | Slower, harder to maintain |
| **Builders** | Complex object graphs | Fluent API, composable | More code to maintain |

### Factory Pattern (Python — factory_boy)

```python
import factory

class UserFactory(factory.Factory):
    class Meta:
        model = User

    name = factory.Faker("name")
    email = factory.LazyAttribute(lambda o: f"{o.name.lower().replace(' ', '.')}@test.com")
    role = "user"
    is_active = True

class AdminFactory(UserFactory):
    role = "admin"

# Usage
user = UserFactory()
admin = AdminFactory(name="Admin User")
users = UserFactory.create_batch(10)
```

### Data Cleanup Rules

1. **Each test creates its own data** — never rely on pre-existing data
2. **Each test cleans up after itself** — use transaction rollback or truncation
3. **Never use production data in tests** — generate synthetic data
4. **Avoid auto-increment ID assumptions** — use UUIDs or query by attributes
5. **Seed data is for shared reference only** — countries, currencies, roles

---

## 5. Integration Testing

### Real Dependencies vs Mocks

| Use Real Deps | Use Mocks |
|---------------|-----------|
| Database queries (testcontainers) | Third-party APIs (Stripe, Twilio) |
| Redis cache behavior | Email sending |
| Message queue integration | SMS sending |
| File system operations | External services with rate limits |
| Auth provider (local Keycloak) | Services you do not control |

### Testing with Real Database

```python
@pytest.fixture(scope="session")
def db_engine(postgres_url: str):
    engine = create_engine(postgres_url)
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)

@pytest.fixture
def db_session(db_engine):
    connection = db_engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)
    yield session
    session.close()
    transaction.rollback()
    connection.close()
```

### Integration Test Scope

Each integration test validates ONE integration point:
- API endpoint + database
- Service + message queue
- Service + cache
- Service + external API (mocked)

Never test the full system in an integration test — that is E2E.

---

## 6. API Contract Testing (Pact)

### Consumer-Driven Contracts

```
Consumer (frontend/client)          Provider (backend/API)
        |                                   |
        |  1. Write consumer test           |
        |  2. Generate Pact file            |
        |                                   |
        |  --------- Pact file --------->   |
        |                                   |
        |                    3. Verify Pact against real API
        |                    4. Publish verification result
```

### Consumer Test (Python)

```python
from pact import Consumer, Provider

pact = Consumer("frontend").has_pact_with(
    Provider("user-service"),
    pact_dir="./pacts",
)

def test_get_user():
    expected = {"id": 1, "name": "Alice", "email": "alice@test.com"}

    (pact
     .given("a user with ID 1 exists")
     .upon_receiving("a request for user 1")
     .with_request("GET", "/users/1")
     .will_respond_with(200, body=expected))

    with pact:
        result = get_user(pact.uri, 1)
        assert result["name"] == "Alice"
```

### When to Use Contract Testing

- Microservices communicating via HTTP/gRPC
- Frontend consuming a backend API
- Multiple teams maintaining separate services

### When NOT to Use

- Monolithic applications
- Single team owning both consumer and provider
- Early prototyping phase

---

## 7. Performance Testing

### Test Types

| Type | Purpose | Duration | Load Pattern |
|------|---------|----------|--------------|
| **Smoke** | Verify system works under minimal load | 1-5 min | 1-5 VUs |
| **Load** | Validate under expected traffic | 15-30 min | Ramp to target VUs |
| **Stress** | Find breaking point | 30-60 min | Ramp beyond target |
| **Soak** | Detect memory leaks | 2-8 hours | Sustained target load |
| **Spike** | Test sudden traffic bursts | 5-10 min | Sudden ramp up/down |

### k6 Example

```javascript
import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "2m", target: 50 },   // ramp up
    { duration: "5m", target: 50 },   // sustain
    { duration: "2m", target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<500"],  // 95th percentile < 500ms
    http_req_failed: ["rate<0.01"],    // error rate < 1%
  },
};

export default function () {
  const res = http.get("https://api.example.com/users");
  check(res, {
    "status is 200": (r) => r.status === 200,
    "response time < 500ms": (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

### Locust Example

```python
from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 3)

    @task(3)
    def list_users(self) -> None:
        self.client.get("/users")

    @task(1)
    def create_user(self) -> None:
        self.client.post("/users", json={"name": "Test", "email": "t@t.com"})
```

### Performance Budgets

| Metric | Target |
|--------|--------|
| p95 response time | < 500ms |
| p99 response time | < 1000ms |
| Error rate | < 0.1% |
| LCP (frontend) | < 2.5s |
| FID (frontend) | < 100ms |
| CLS (frontend) | < 0.1 |

---

## 8. Accessibility Testing

### Automated Testing (catches ~57% of WCAG issues)

```python
# Playwright + axe-core (Python)
from axe_playwright_python.sync_playwright import Axe

def test_homepage_accessibility(page: Page) -> None:
    page.goto("/")
    axe = Axe()
    results = axe.run(page)
    assert results.violations_count == 0, results.generate_report()
```

```typescript
// TypeScript variant
import AxeBuilder from "@axe-core/playwright";

test("homepage has no a11y violations", async ({ page }) => {
  await page.goto("/");
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

### WCAG 2.2 Key Criteria

| Level | Criterion | What |
|-------|-----------|------|
| A | 2.4.7 | Focus visible on keyboard navigation |
| AA | 1.4.3 | Contrast ratio >= 4.5:1 for text |
| AA | 2.5.8 | Touch target >= 24x24px |
| AA | 2.4.11 | Focus not obscured by sticky elements |

### What Automation Catches

- Missing alt text on images
- Missing form labels
- Insufficient color contrast
- Missing ARIA attributes

### What Requires Manual Testing

- Keyboard navigation flow (logical tab order)
- Screen reader experience
- Focus management in dynamic content (modals, drawers)
- Content reflow at 400% zoom

---

## 9. Visual Regression Testing

### Approaches

| Approach | Tool | Pros | Cons |
|----------|------|------|------|
| **Pixel comparison** | Playwright built-in | Free, no external deps | Sensitive to rendering diffs |
| **Cloud-based** | Percy, Chromatic | Cross-browser, smart diffing | Paid |
| **Component-level** | Storybook + Chromatic | Isolated, fast | Only components, not pages |

### Playwright Screenshot Comparison

```python
async def test_homepage_visual(page: Page) -> None:
    await page.goto("/")
    await expect(page).to_have_screenshot("homepage.png", max_diff_pixels=100)

# Disable animations for stable screenshots
await page.emulate_media(reduced_motion="reduce")
await page.add_style_tag(
    content="*, *::before, *::after { animation-duration: 0s !important; }"
)
```

### When to Use

- Design system components
- Landing pages and marketing pages
- After CSS/Tailwind refactors

---

## 10. Smoke Testing

Smoke tests are the **minimum viable test suite** that validates the system is alive.
Run after every deployment.

### Characteristics

- **Fast:** < 2 minutes total
- **Critical paths only:** login, main feature, health endpoints
- **No edge cases:** happy path only
- **Idempotent:** safe to run multiple times

```python
class SmokeTests:
    def test_health_endpoint(self, client) -> None:
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_database_connectivity(self, client) -> None:
        response = client.get("/health/db")
        assert response.status_code == 200

    def test_login_works(self, client) -> None:
        response = client.post("/auth/login", json={
            "email": "smoke-test@example.com",
            "password": "smoke-test-password",
        })
        assert response.status_code == 200
        assert "token" in response.json()
```

### Smoke vs Sanity vs Regression

| Type | Scope | When | Duration |
|------|-------|------|----------|
| **Smoke** | Core paths only | After deploy | < 2 min |
| **Sanity** | Changed features | After bug fix | 5-15 min |
| **Regression** | Full suite | Before release | 30-120 min |

---

## 11. Definition of Done — Test Validation

A delivery is done ONLY when all of these are verified:

### Code Quality
- [ ] Static analysis clean (mypy, TypeScript, ruff, biome — zero warnings)
- [ ] No new lint warnings
- [ ] Type hints complete

### Test Coverage
- [ ] Unit tests written for new business logic
- [ ] Integration tests for new API endpoints
- [ ] E2E tests for new user-facing flows
- [ ] Test coverage meets project threshold

### Test Quality
- [ ] All tests deterministic (no flaky tests introduced)
- [ ] Tests cover happy path AND error paths
- [ ] Test names describe behavior
- [ ] No commented-out tests

### Environment
- [ ] Tests run in isolated environment
- [ ] Environment tears down cleanly after tests
- [ ] No port conflicts

### Evidence
- [ ] Test results documented
- [ ] Coverage report generated

---

## 12. Production Readiness Checklist

Before any release:

### Testing
- [ ] Full regression test results (pass/fail/skip counts)
- [ ] Coverage report (>80% threshold met)
- [ ] Performance test results (p95, p99, error rate)
- [ ] Accessibility audit results (WCAG 2.2 AA)
- [ ] Smoke tests passing in staging
- [ ] No open BLOCKER issues from review

### Operations
- [ ] Health check endpoints implemented
- [ ] Structured logging configured
- [ ] Metrics exposed (RED method)
- [ ] Alerting configured for error rate and latency
- [ ] Runbook exists for known failure modes
- [ ] Rollback procedure documented and tested

### Security
- [ ] SAST scan clean (bandit, semgrep)
- [ ] Dependency audit clean (pip-audit, npm audit)
- [ ] No secrets in codebase
- [ ] Authentication/authorization reviewed

---

## Reference Files

- [references/e2e-strategy.md](references/e2e-strategy.md) — E2E strategy, test isolation, flakiness patterns
- [references/playwright.md](references/playwright.md) — Playwright configuration, POM pattern, assertions
- [references/test-data.md](references/test-data.md) — Factory patterns, fixtures, data cleanup
- [references/contract-testing.md](references/contract-testing.md) — Pact setup, consumer/provider tests
- [references/performance.md](references/performance.md) — k6 scripts, Locust patterns, benchmarks
- [references/accessibility.md](references/accessibility.md) — axe-core, WCAG 2.2, manual testing guide
