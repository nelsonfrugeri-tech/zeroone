---
name: qa
description: |
  Baseline de conhecimento para Quality Assurance moderno (2026). Cobre estrategia de testes
  (pyramid vs trophy), E2E testing (Playwright, pytest), test data management (fixtures, factories,
  seeding), integration testing (real deps vs mocks), API contract testing (Pact), performance testing
  (k6, Locust), accessibility testing (axe-core, Lighthouse, WCAG 2.2), visual regression testing
  (Playwright screenshots, Percy, Chromatic), environment setup/teardown, test reporting, smoke testing,
  Definition of Done validation, e production readiness checklist.
  Use quando: (1) Definir estrategia de testes, (2) Configurar ambientes isolados de teste,
  (3) Implementar E2E/integration/contract/performance/a11y/visual tests, (4) Validar Definition of Done,
  (5) Avaliar production readiness.
  Triggers: /qa, QA, quality assurance, testing strategy, test plan, Definition of Done, smoke test.
---

# QA — Quality Assurance

## Propósito

Esta skill é a **knowledge base** for modern Quality Assurance (2026).
It complements `arch-py` and `arch-ts` skills with QA-specific patterns and strategies.

**Global skill** — loaded automatically by all agents.

- Agent `review-py` / `review-ts` -> when evaluating test coverage and quality
- You directly -> when defining test strategy or validating readiness

**What this skill contains:**
- Test strategy (pyramid vs trophy, what to test at each layer)
- E2E testing (Playwright, pytest, isolation, flakiness prevention)
- Test data management (fixtures, factories, seeding, cleanup)
- Integration testing (real dependencies vs mocks, testcontainers)
- API contract testing (Pact, consumer-driven contracts)
- Performance testing (k6, Locust, load/stress/soak)
- Accessibility testing (axe-core, Lighthouse, WCAG 2.2)
- Visual regression testing (Playwright screenshots, Percy, Chromatic)
- Environment setup and teardown
- Test reporting and evidence collection
- Smoke testing patterns
- Definition of Done validation checklist
- Production readiness checklist

**What this skill does NOT contain:**
- Language-specific coding patterns (those live in `arch-py` / `arch-ts`)
- CI/CD pipeline configuration (infrastructure concern)
- Execution workflow (agents handle that)

---

## Filosofia

### Testes são Engenharia, Não Afterthought

**Quality is built in, not tested in.**
Tests are first-class artifacts with the same standards as production code:
typed, reviewed, maintained, and refactored.

### Princípios Fundamentais

**1. Test what matters, not what is easy**
- Focus on user-facing behavior and business-critical paths
- A passing test suite that misses critical bugs is worse than no tests
- Coverage percentage is a signal, not a goal

**2. Deterministic tests or no tests**
- Every test must produce the same result on every run
- Flaky tests erode trust and must be fixed or deleted immediately
- Time-dependent, order-dependent, and network-dependent tests are bugs

**3. Fast feedback loops**
- Unit tests: < 1 second per test
- Integration tests: < 5 seconds per test
- E2E tests: < 30 seconds per test
- Total suite: < 10 minutes in CI

**4. Isolation is non-negotiable**
- Each test starts with clean state
- Tests never depend on other tests' side effects
- Parallel execution must be safe by default

**5. Test the contract, not the implementation**
- Assert on observable behavior, not internal state
- Changing implementation without changing behavior should not break tests
- "The more your tests resemble the way your software is used, the more confidence they can give you" -- Kent C. Dodds

---

## 1. Estratégia de Testes -- Pyramid vs Trophy

### A Pirâmide de Testes (Martin Fowler)

```
        /  E2E  \          Few, slow, expensive
       /----------\
      / Integration \      Some, moderate speed
     /----------------\
    /    Unit Tests     \  Many, fast, cheap
   /____________________\
```

**When to use:** Backend services, libraries, utilities with clear function boundaries.

### O Troféu de Testes (Kent C. Dodds)

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

### Framework de Decisão

| Signal | Prefer Pyramid | Prefer Trophy |
|--------|---------------|---------------|
| Pure business logic | Yes | |
| Complex algorithms | Yes | |
| UI-heavy application | | Yes |
| API with many integrations | | Yes |
| Library / SDK | Yes | |
| Microservices | | Yes |
| Data pipeline | Yes | |

### O que Testar em Cada Camada

**Static Analysis (base layer):**
- Type checking (mypy, TypeScript strict)
- Linting (ruff, Biome)
- Security scanning (bandit, semgrep)

**Unit Tests:**
- Pure functions with no side effects
- Business logic calculations
- Data transformations
- Validation rules
- Edge cases and boundary conditions

**Integration Tests:**
- API endpoint behavior (request -> response)
- Database queries and mutations
- External service interactions (with testcontainers or mocks)
- Message queue producers/consumers
- Authentication and authorization flows

**E2E Tests:**
- Critical user journeys (signup, purchase, core workflows)
- Cross-service flows
- Browser-specific behavior
- Accessibility compliance

**Reference:** [references/e2e/strategy.md](references/e2e/strategy.md)

---

## 2. Configuração de Ambiente

### Princípios

1. **Reproducible** -- same environment every time, no "works on my machine"
2. **Isolated** -- tests cannot interfere with each other or with production
3. **Ephemeral** -- created before tests, destroyed after
4. **Fast** -- environment setup should take seconds, not minutes

### Docker Compose para Dependências de Teste

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

### Checklist de Teardown

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

**Reference:** [references/environment/setup-teardown.md](references/environment/setup-teardown.md)

---

## 3. Testes E2E

### Tool Selection

| Tool | Language | Best For |
|------|----------|----------|
| **Playwright** | Python, JS/TS, .NET, Java | Cross-browser, API + UI, modern web |
| **pytest** | Python | Backend E2E, API testing |
| **Vitest** | TypeScript | Frontend unit + integration |

### Playwright Best Practices (2026)

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

# Test using POM
async def test_login_success(page: Page) -> None:
    login_page = LoginPage(page)
    await page.goto("/login")
    await login_page.login("user@test.com", "password123")
    await expect(page).to_have_url("/dashboard")
```

### Locator Strategy (Priority Order)

1. `get_by_role()` -- semantic, accessible, resilient
2. `get_by_label()` -- form elements
3. `get_by_text()` -- visible text content
4. `get_by_test_id()` -- last resort, explicit data-testid

**Never use:**
- CSS selectors tied to styling (`.btn-primary`)
- XPath
- Auto-generated class names

### Flakiness Prevention

```python
# BAD: arbitrary sleep
await page.wait_for_timeout(3000)

# GOOD: wait for specific condition
await page.wait_for_selector("[data-loaded='true']")
await expect(page.get_by_role("heading")).to_be_visible()

# GOOD: Playwright auto-waiting (default behavior)
await page.get_by_role("button", name="Submit").click()  # auto-waits
```

### Test Isolation in Playwright

```python
@pytest.fixture
def context(browser: Browser) -> BrowserContext:
    """Fresh browser context per test -- no shared cookies/storage."""
    context = browser.new_context()
    yield context
    context.close()
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

**Reference:** [references/e2e/playwright.md](references/e2e/playwright.md)

---

## 4. Gestão de Dados de Teste

### Approaches

| Approach | When to Use | Pros | Cons |
|----------|-------------|------|------|
| **Fixtures** | Static reference data | Simple, readable | Brittle if schema changes |
| **Factories** | Dynamic test objects | Flexible, DRY | Requires setup code |
| **Seeding** | Database pre-population | Realistic data | Slower, harder to maintain |
| **Builders** | Complex object graphs | Fluent API, composable | More code to maintain |

### Factory Pattern (Python -- factory_boy)

```python
import factory
from factory import fuzzy

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

### Fixtures (pytest)

```python
@pytest.fixture
def sample_order(db_session) -> Order:
    user = UserFactory()
    product = ProductFactory(price=99.99)
    order = OrderFactory(user=user, items=[product])
    db_session.add(order)
    db_session.flush()
    return order
```

### Data Cleanup Rules

1. **Each test creates its own data** -- never rely on pre-existing data
2. **Each test cleans up after itself** -- use transaction rollback or truncation
3. **Never use production data in tests** -- generate synthetic data
4. **Avoid auto-increment ID assumptions** -- use UUIDs or query by attributes
5. **Seed data is for shared reference only** -- countries, currencies, roles

**Reference:** [references/test-data/management.md](references/test-data/management.md)

---

## 5. Testes de Integração

### Dependências Reais vs Mocks

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

### Testing with Mocked External Services

```python
@pytest.fixture
def mock_payment_gateway(respx_mock):
    respx_mock.post("https://api.stripe.com/v1/charges").mock(
        return_value=httpx.Response(200, json={"id": "ch_test", "status": "succeeded"})
    )
    return respx_mock

async def test_checkout_charges_card(client, mock_payment_gateway, sample_order):
    response = await client.post(f"/orders/{sample_order.id}/checkout")
    assert response.status_code == 200
    assert mock_payment_gateway.calls.call_count == 1
```

### Integration Test Scope

Each integration test validates ONE integration point:
- API endpoint + database
- Service + message queue
- Service + cache
- Service + external API (mocked)

Never test the full system in an integration test -- that is E2E.

**Reference:** [references/integration/patterns.md](references/integration/patterns.md)

---

## 6. Testes de Contrato de API

### Consumer-Driven Contracts with Pact

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
import atexit
from pact import Consumer, Provider

pact = Consumer("frontend").has_pact_with(
    Provider("user-service"),
    pact_dir="./pacts",
)
pact.start_service()
atexit.register(pact.stop_service)

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

### Boas Práticas

1. **Test consumer needs, not provider capabilities** -- only assert fields the consumer uses
2. **Use matchers, not exact values** -- `Like(42)` instead of `42` for flexibility
3. **One Pact per consumer-provider pair** -- keep contracts focused
4. **Publish to Pact Broker** -- central source of truth for all contracts
5. **Never use random data** -- deterministic contracts prevent false positives
6. **Integrate in CI** -- provider verification blocks deployment if contract breaks

### When to Use Contract Testing

- Microservices communicating via HTTP/gRPC
- Frontend consuming a backend API
- Multiple teams maintaining separate services
- API versioning concerns

### When NOT to Use Contract Testing

- Monolithic applications
- Single team owning both consumer and provider
- Prototyping / early-stage projects

**Reference:** [references/contract-testing/pact.md](references/contract-testing/pact.md)

---

## 7. Testes de Performance

### Test Types

| Type | Purpose | Duration | Load Pattern |
|------|---------|----------|--------------|
| **Smoke** | Verify system works under minimal load | 1-5 min | 1-5 VUs |
| **Load** | Validate under expected traffic | 15-30 min | Ramp to target VUs |
| **Stress** | Find breaking point | 30-60 min | Ramp beyond target |
| **Soak** | Detect memory leaks, resource exhaustion | 2-8 hours | Sustained target load |
| **Spike** | Test sudden traffic bursts | 5-10 min | Sudden ramp up/down |

### Tool Selection

| Tool | Language | Best For |
|------|----------|----------|
| **k6** | JavaScript | Developer-friendly, CI integration, Grafana ecosystem |
| **Locust** | Python | Python teams, custom user behavior |
| **Gatling** | Scala/Java | JVM ecosystems, detailed reports |

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

| Metric | Target | Tool |
|--------|--------|------|
| p95 response time | < 500ms | k6, Locust |
| p99 response time | < 1000ms | k6, Locust |
| Error rate | < 0.1% | k6, Locust |
| Throughput | > N RPS | k6, Locust |
| LCP (frontend) | < 2.5s | Lighthouse |
| FID (frontend) | < 100ms | Lighthouse |
| CLS (frontend) | < 0.1 | Lighthouse |

**Reference:** [references/performance/load-testing.md](references/performance/load-testing.md)

---

## 8. Testes de Acessibilidade

### Automated Testing (catches ~57% of WCAG issues)

**axe-core** is the standard engine, powering Lighthouse and most a11y tools.

### Playwright + axe-core

```python
from playwright.sync_api import Page
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

### Lighthouse CI

```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/", "http://localhost:3000/login"],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:accessibility": ["error", { "minScore": 0.9 }],
        "categories:performance": ["warn", { "minScore": 0.8 }]
      }
    }
  }
}
```

### What Automation Catches

- Missing alt text on images
- Missing form labels
- Insufficient color contrast
- Missing ARIA attributes
- Invalid ARIA roles
- Missing document language
- Duplicate IDs

### What Requires Manual Testing

- Keyboard navigation flow (logical tab order)
- Screen reader experience (announcements make sense)
- Focus management in dynamic content (modals, drawers)
- Meaningful alt text (not just present, but useful)
- Touch target size on mobile
- Animation respects `prefers-reduced-motion`
- Content reflow at 400% zoom

### WCAG 2.2 Key Criteria

| Level | Criterion | What |
|-------|-----------|------|
| A | 2.4.7 | Focus visible on keyboard navigation |
| AA | 1.4.3 | Contrast ratio >= 4.5:1 for text |
| AA | 2.5.8 | Touch target >= 24x24px |
| AA | 2.4.11 | Focus not obscured by sticky elements |
| AAA | 1.4.6 | Contrast ratio >= 7:1 for text |

**Reference:** [references/accessibility/automated-testing.md](references/accessibility/automated-testing.md)

---

## 9. Testes de Regressão Visual

### Approaches

| Approach | Tool | Pros | Cons |
|----------|------|------|------|
| **Pixel comparison** | Playwright built-in | Free, no external deps | Sensitive to rendering diffs |
| **Cloud-based** | Percy, Chromatic | Cross-browser, smart diffing | Paid, external dependency |
| **Component-level** | Storybook + Chromatic | Isolated, fast | Only components, not pages |

### Playwright Screenshot Comparison

```python
async def test_homepage_visual(page: Page) -> None:
    await page.goto("/")
    await expect(page).to_have_screenshot("homepage.png", max_diff_pixels=100)

async def test_card_component_visual(page: Page) -> None:
    await page.goto("/components/card")
    card = page.get_by_test_id("product-card")
    await expect(card).to_have_screenshot("product-card.png")
```

### Boas Práticas

1. **Mask dynamic content** -- timestamps, avatars, ads
2. **Use consistent viewport** -- always test at specific resolutions
3. **Disable animations** -- prevent flaky screenshots
4. **Review diffs carefully** -- not all visual changes are regressions
5. **Separate visual tests from functional tests** -- different cadence

```python
# Disable animations for stable screenshots
await page.emulate_media(reduced_motion="reduce")
await page.add_style_tag(content="*, *::before, *::after { animation-duration: 0s !important; }")
```

### When to Use Visual Regression

- Design system components (every component, every variant)
- Landing pages and marketing pages
- After CSS/Tailwind refactors
- Cross-browser rendering validation

### When NOT to Use Visual Regression

- Data-heavy pages with dynamic content
- Pages behind complex authentication (hard to stabilize)
- Early prototyping phase (too many intentional changes)

**Reference:** [references/visual-regression/screenshot-testing.md](references/visual-regression/screenshot-testing.md)

---

## 10. Smoke Testing

### Definition

Smoke tests are the **minimum viable test suite** that validates the system is alive and core functionality works. Run after every deployment.

### Smoke Test Characteristics

- **Fast:** < 2 minutes total
- **Critical paths only:** login, main feature, health endpoints
- **No edge cases:** happy path only
- **Idempotent:** safe to run multiple times
- **Environment-aware:** adapt to staging vs production

### Pattern

```python
class SmokeTests:
    """Run after deployment to validate system health."""

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

    def test_core_feature_accessible(self, client, auth_token) -> None:
        response = client.get("/api/dashboard", headers={
            "Authorization": f"Bearer {auth_token}"
        })
        assert response.status_code == 200
```

### Smoke vs Sanity vs Regression

| Type | Scope | When | Duration |
|------|-------|------|----------|
| **Smoke** | Core paths only | After deploy | < 2 min |
| **Sanity** | Changed features | After bug fix | 5-15 min |
| **Regression** | Full suite | Before release | 30-120 min |

---

## 11. Test Reporting and Evidence Collection

### What to Capture

| Artifact | Format | When |
|----------|--------|------|
| Test results | JUnit XML, JSON | Every run |
| Coverage report | HTML, Cobertura XML | Every run |
| Screenshots (failures) | PNG | On failure |
| Videos (E2E) | WebM | On failure |
| Performance metrics | JSON, Grafana dashboard | Performance runs |
| Accessibility report | HTML, JSON | A11y runs |
| Pact contracts | JSON | Contract runs |
| Lighthouse report | HTML | Scheduled |

### pytest Configuration

```toml
# pyproject.toml
[tool.pytest.ini_options]
addopts = [
    "--junitxml=reports/junit.xml",
    "--cov=src",
    "--cov-report=html:reports/coverage",
    "--cov-report=xml:reports/coverage.xml",
    "--cov-fail-under=80",
]
```

### Playwright Reporting

```python
# pytest.ini or conftest.py
# Playwright captures screenshots and videos on failure by default
# Configure via playwright.config or pytest-playwright options

@pytest.fixture(scope="session")
def browser_context_args():
    return {
        "record_video_dir": "reports/videos/",
        "record_video_size": {"width": 1280, "height": 720},
    }
```

### Evidence for Production Readiness

Before any release, collect and store:
- [ ] Full regression test results (pass/fail)
- [ ] Code coverage report (meets threshold)
- [ ] Performance test results (meets SLOs)
- [ ] Accessibility audit report (WCAG AA compliant)
- [ ] Visual regression review (approved diffs)
- [ ] Contract verification results (all green)

---

## 12. Definition of Done -- Validation Checklist

A feature is **Done** when ALL of the following are true:

### Code Quality
- [ ] Code reviewed and approved
- [ ] Type checking passes (mypy / TypeScript strict)
- [ ] Linting passes (ruff / Biome)
- [ ] No new warnings introduced

### Testing
- [ ] Unit tests written for business logic
- [ ] Integration tests for API endpoints / service interactions
- [ ] E2E tests for critical user journeys (if UI involved)
- [ ] Edge cases and error paths tested
- [ ] All tests pass locally AND in CI
- [ ] Coverage meets team threshold (typically >= 80%)

### Accessibility (if UI)
- [ ] axe-core automated checks pass (0 violations)
- [ ] Keyboard navigation verified manually
- [ ] Screen reader tested on primary flow
- [ ] Color contrast meets WCAG AA (4.5:1)

### Performance
- [ ] No N+1 queries introduced
- [ ] API response time within budget (p95 < 500ms)
- [ ] Bundle size delta acceptable (if frontend)
- [ ] Lighthouse performance score >= 80 (if frontend)

### Documentation
- [ ] CHANGELOG.md updated
- [ ] README.md updated (if user-facing changes)
- [ ] API documentation updated (if endpoints changed)
- [ ] Inline code comments for non-obvious logic

### Deployment
- [ ] Feature flag configured (if gradual rollout)
- [ ] Monitoring and alerting configured
- [ ] Rollback plan documented
- [ ] Smoke tests pass in staging

---

## 13. Checklist de Production Readiness

Before any service goes to production:

### Reliability
- [ ] Health check endpoint (`/health`) returns 200
- [ ] Graceful shutdown handles in-flight requests
- [ ] Circuit breakers on external dependencies
- [ ] Retry with exponential backoff on transient failures
- [ ] Timeouts configured on all external calls

### Observability
- [ ] Structured logging (JSON) with correlation IDs
- [ ] Request/response metrics (latency, error rate, throughput)
- [ ] Alerting rules for SLO breaches
- [ ] Distributed tracing configured (OpenTelemetry)
- [ ] Dashboard for key metrics

### Security
- [ ] No secrets in code or config files
- [ ] API authentication and authorization enforced
- [ ] Input validation on all external inputs
- [ ] Rate limiting configured
- [ ] CORS configured correctly
- [ ] Dependency vulnerability scan clean

### Performance
- [ ] Load test results meet SLOs under expected traffic
- [ ] Stress test identifies breaking point (with margin)
- [ ] Database queries optimized (no N+1, proper indexes)
- [ ] Cache strategy defined and configured
- [ ] Connection pooling configured

### Data
- [ ] Database migrations are backward-compatible
- [ ] Backup and restore procedure tested
- [ ] PII handling compliant with regulations
- [ ] Data retention policy defined

### Deployment
- [ ] CI/CD pipeline green
- [ ] Rollback procedure tested
- [ ] Feature flags for risky changes
- [ ] Smoke tests automated post-deploy
- [ ] Runbook for common failure scenarios

---

## Tools Summary

| Category | Tool | Purpose |
|----------|------|---------|
| Unit Test | **pytest** | Python test framework |
| Unit Test | **Vitest** | TypeScript test framework |
| E2E | **Playwright** | Cross-browser E2E testing |
| Integration | **testcontainers** | Programmatic test dependencies |
| Integration | **respx** / **httpx** | HTTP mocking for Python |
| Contract | **Pact** | Consumer-driven contract testing |
| Performance | **k6** | Load testing (JS-based) |
| Performance | **Locust** | Load testing (Python-based) |
| A11y | **axe-core** | Automated accessibility engine |
| A11y | **Lighthouse** | Performance + a11y auditing |
| Visual | **Playwright screenshots** | Built-in visual comparison |
| Visual | **Percy** / **Chromatic** | Cloud visual regression |
| Data | **factory_boy** | Python test data factories |
| Coverage | **pytest-cov** | Python coverage |
| Reporting | **JUnit XML** | Standard test report format |

---

## References by Domain

### Environment
- [references/environment/setup-teardown.md](references/environment/setup-teardown.md) - Environment lifecycle

### E2E Testing
- [references/e2e/strategy.md](references/e2e/strategy.md) - What to test, pyramid vs trophy
- [references/e2e/playwright.md](references/e2e/playwright.md) - Playwright patterns and POM

### Test Data
- [references/test-data/management.md](references/test-data/management.md) - Fixtures, factories, seeding

### Integration Testing
- [references/integration/patterns.md](references/integration/patterns.md) - Real deps vs mocks

### Contract Testing
- [references/contract-testing/pact.md](references/contract-testing/pact.md) - Pact consumer-driven contracts

### Performance Testing
- [references/performance/load-testing.md](references/performance/load-testing.md) - k6, Locust, test types

### Accessibility
- [references/accessibility/automated-testing.md](references/accessibility/automated-testing.md) - axe-core, Lighthouse, WCAG 2.2

### Visual Regression
- [references/visual-regression/screenshot-testing.md](references/visual-regression/screenshot-testing.md) - Playwright, Percy, Chromatic

### Reporting
- [references/reporting/evidence-collection.md](references/reporting/evidence-collection.md) - Reports, artifacts, CI config
