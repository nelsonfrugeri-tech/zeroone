# Playwright E2E Testing Patterns

## Setup

### Python
```bash
pip install pytest-playwright==0.6.2
playwright install --with-deps chromium
```

### TypeScript
```bash
pnpm add -D @playwright/test
npx playwright install --with-deps
```

## Page Object Model (POM)

### Python POM

```python
from playwright.async_api import Page, expect

class LoginPage:
    URL = "/login"

    def __init__(self, page: Page) -> None:
        self.page = page
        self.email_input = page.get_by_label("Email")
        self.password_input = page.get_by_label("Password")
        self.submit_button = page.get_by_role("button", name="Sign in")
        self.error_message = page.get_by_role("alert")

    async def goto(self) -> None:
        await self.page.goto(self.URL)

    async def login(self, email: str, password: str) -> None:
        await self.email_input.fill(email)
        await self.password_input.fill(password)
        await self.submit_button.click()

    async def expect_error(self, message: str) -> None:
        await expect(self.error_message).to_contain_text(message)
```

### TypeScript POM

```typescript
import { type Page, type Locator, expect } from "@playwright/test";

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(private readonly page: Page) {
    this.emailInput = page.getByLabel("Email");
    this.passwordInput = page.getByLabel("Password");
    this.submitButton = page.getByRole("button", { name: "Sign in" });
  }

  async goto(): Promise<void> {
    await this.page.goto("/login");
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

## Locator Best Practices

### Priority Order (most resilient first)

```python
# 1. Role-based (best -- semantic, accessible)
page.get_by_role("button", name="Submit")
page.get_by_role("heading", name="Dashboard")
page.get_by_role("link", name="Sign up")

# 2. Label-based (great for forms)
page.get_by_label("Email address")
page.get_by_label("Password")

# 3. Text-based (good for content)
page.get_by_text("Welcome back")
page.get_by_text("No results found")

# 4. Placeholder (acceptable for search)
page.get_by_placeholder("Search...")

# 5. Test ID (last resort)
page.get_by_test_id("checkout-button")
```

### Never Use
```python
# BAD: CSS class (breaks on styling changes)
page.locator(".btn-primary")

# BAD: XPath (fragile, hard to read)
page.locator("//div[@class='container']/button[2]")

# BAD: nth-child (breaks on DOM changes)
page.locator("button:nth-child(3)")
```

## Waiting and Assertions

### Auto-Waiting (Playwright default)

```python
# Playwright auto-waits for elements to be actionable
await page.get_by_role("button", name="Submit").click()  # waits until clickable
await page.get_by_label("Email").fill("test@test.com")   # waits until editable
```

### Explicit Assertions

```python
from playwright.async_api import expect

# Element state
await expect(page.get_by_role("button")).to_be_visible()
await expect(page.get_by_role("button")).to_be_enabled()
await expect(page.get_by_role("button")).to_be_disabled()

# Content
await expect(page.get_by_role("heading")).to_have_text("Dashboard")
await expect(page.get_by_role("alert")).to_contain_text("Error")

# Navigation
await expect(page).to_have_url("/dashboard")
await expect(page).to_have_title("My App - Dashboard")

# Count
await expect(page.get_by_role("listitem")).to_have_count(5)
```

### Anti-Patterns

```python
# BAD: arbitrary sleep
await page.wait_for_timeout(3000)

# BAD: checking with time.sleep
import time
time.sleep(2)
assert page.locator(".result").is_visible()

# GOOD: wait for specific state
await page.wait_for_load_state("networkidle")
await expect(page.get_by_text("Loaded")).to_be_visible()
```

## Test Isolation

```python
@pytest.fixture
def context(browser):
    """Fresh context per test -- clean cookies, storage, cache."""
    ctx = browser.new_context(
        viewport={"width": 1280, "height": 720},
        locale="en-US",
    )
    yield ctx
    ctx.close()

@pytest.fixture
def page(context):
    pg = context.new_page()
    yield pg
    pg.close()
```

## API Testing with Playwright

```python
async def test_api_create_user(request_context):
    """Playwright can also test APIs directly."""
    response = await request_context.post("/api/users", data={
        "name": "Alice",
        "email": "alice@test.com",
    })
    assert response.status == 201
    body = await response.json()
    assert body["name"] == "Alice"
```

## Network Interception

```python
async def test_handles_api_failure(page):
    """Mock API responses for error testing."""
    await page.route("**/api/users", lambda route: route.fulfill(
        status=500,
        body="Internal Server Error",
    ))
    await page.goto("/users")
    await expect(page.get_by_text("Something went wrong")).to_be_visible()
```

## Parallel Execution

```toml
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
addopts = "--numprocesses=auto"  # pytest-xdist
```

```typescript
// playwright.config.ts
export default defineConfig({
  workers: process.env.CI ? 2 : undefined,  // auto in local
  fullyParallel: true,
});
```

## CI Configuration

```yaml
# GitHub Actions
- name: Install Playwright
  run: pip install pytest-playwright && playwright install --with-deps chromium

- name: Run E2E tests
  run: pytest tests/e2e/ --junitxml=reports/e2e.xml
  env:
    BASE_URL: http://localhost:3000
```
