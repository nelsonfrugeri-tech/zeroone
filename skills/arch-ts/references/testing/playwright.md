# Playwright 1.50+ - E2E Testing

Playwright e o framework recomendado para testes end-to-end.

---

## Setup

```typescript
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
	testDir: "./e2e",
	fullyParallel: true,
	forbidOnly: !!process.env.CI,
	retries: process.env.CI ? 2 : 0,
	workers: process.env.CI ? 1 : undefined,
	reporter: [
		["html", { open: "never" }],
		["list"],
	],
	use: {
		baseURL: "http://localhost:3000",
		trace: "on-first-retry",
		screenshot: "only-on-failure",
	},
	projects: [
		{
			name: "chromium",
			use: { ...devices["Desktop Chrome"] },
		},
		{
			name: "firefox",
			use: { ...devices["Desktop Firefox"] },
		},
		{
			name: "webkit",
			use: { ...devices["Desktop Safari"] },
		},
		{
			name: "mobile-chrome",
			use: { ...devices["Pixel 5"] },
		},
	],
	webServer: {
		command: "pnpm dev",
		url: "http://localhost:3000",
		reuseExistingServer: !process.env.CI,
	},
});
```

---

## Page Object Model

```typescript
// e2e/pages/login.page.ts
import type { Locator, Page } from "@playwright/test";

export class LoginPage {
	readonly emailInput: Locator;
	readonly passwordInput: Locator;
	readonly submitButton: Locator;
	readonly errorMessage: Locator;

	constructor(private readonly page: Page) {
		this.emailInput = page.getByLabel("Email");
		this.passwordInput = page.getByLabel("Password");
		this.submitButton = page.getByRole("button", { name: "Sign In" });
		this.errorMessage = page.getByRole("alert");
	}

	async goto() {
		await this.page.goto("/login");
	}

	async login(email: string, password: string) {
		await this.emailInput.fill(email);
		await this.passwordInput.fill(password);
		await this.submitButton.click();
	}

	async expectError(message: string) {
		await expect(this.errorMessage).toHaveText(message);
	}
}
```

```typescript
// e2e/pages/dashboard.page.ts
import type { Locator, Page } from "@playwright/test";

export class DashboardPage {
	readonly heading: Locator;
	readonly userMenu: Locator;

	constructor(private readonly page: Page) {
		this.heading = page.getByRole("heading", { level: 1 });
		this.userMenu = page.getByTestId("user-menu");
	}

	async expectLoaded() {
		await expect(this.heading).toHaveText("Dashboard");
	}

	async logout() {
		await this.userMenu.click();
		await this.page.getByRole("menuitem", { name: "Logout" }).click();
	}
}
```

---

## Locators

Use semantic locators (accessibility-first):

```typescript
import { test, expect } from "@playwright/test";

test("locator examples", async ({ page }) => {
	// BEST — by role (accessibility)
	await page.getByRole("button", { name: "Submit" }).click();
	await page.getByRole("link", { name: "Home" }).click();
	await page.getByRole("heading", { level: 1 });
	await page.getByRole("textbox", { name: "Email" });
	await page.getByRole("checkbox", { name: "Remember me" });

	// GOOD — by label (forms)
	await page.getByLabel("Email").fill("test@test.com");

	// GOOD — by text (visible content)
	await page.getByText("Welcome back");

	// OK — by placeholder
	await page.getByPlaceholder("Search...");

	// FALLBACK — by test ID
	await page.getByTestId("complex-widget");

	// AVOID — CSS selectors
	// await page.locator(".btn-primary"); // Fragile
});
```

---

## Assertions

```typescript
test("assertions", async ({ page }) => {
	await page.goto("/products");

	// Visibility
	await expect(page.getByText("Products")).toBeVisible();
	await expect(page.getByText("Loading")).not.toBeVisible();

	// Text content
	await expect(page.getByRole("heading")).toHaveText("Products");
	await expect(page.getByRole("heading")).toContainText("Prod");

	// Count
	await expect(page.getByRole("listitem")).toHaveCount(10);

	// Attribute
	await expect(page.getByRole("link", { name: "Home" })).toHaveAttribute(
		"href",
		"/",
	);

	// URL
	await expect(page).toHaveURL("/products");
	await expect(page).toHaveTitle("Products | MyApp");

	// Input value
	await expect(page.getByLabel("Email")).toHaveValue("test@test.com");
});
```

---

## Test Examples

```typescript
// e2e/auth.spec.ts
import { test, expect } from "@playwright/test";
import { LoginPage } from "./pages/login.page";
import { DashboardPage } from "./pages/dashboard.page";

test.describe("Authentication", () => {
	test("successful login redirects to dashboard", async ({ page }) => {
		const loginPage = new LoginPage(page);
		const dashboardPage = new DashboardPage(page);

		await loginPage.goto();
		await loginPage.login("admin@test.com", "password123");

		await dashboardPage.expectLoaded();
		await expect(page).toHaveURL("/dashboard");
	});

	test("invalid credentials show error", async ({ page }) => {
		const loginPage = new LoginPage(page);

		await loginPage.goto();
		await loginPage.login("wrong@test.com", "wrong");

		await loginPage.expectError("Invalid credentials");
		await expect(page).toHaveURL("/login");
	});
});
```

---

## Visual Regression

```typescript
test("homepage visual regression", async ({ page }) => {
	await page.goto("/");

	// Full page screenshot
	await expect(page).toHaveScreenshot("homepage.png", {
		fullPage: true,
		maxDiffPixels: 100,
	});

	// Component screenshot
	const card = page.getByTestId("hero-card");
	await expect(card).toHaveScreenshot("hero-card.png");
});
```

Update snapshots:
```bash
pnpm playwright test --update-snapshots
```

---

## API Testing

```typescript
import { test, expect } from "@playwright/test";

test.describe("API", () => {
	test("GET /api/users returns users", async ({ request }) => {
		const response = await request.get("/api/users");
		expect(response.ok()).toBeTruthy();

		const users = await response.json();
		expect(users).toBeInstanceOf(Array);
		expect(users.length).toBeGreaterThan(0);
		expect(users[0]).toHaveProperty("name");
	});

	test("POST /api/users creates user", async ({ request }) => {
		const response = await request.post("/api/users", {
			data: {
				name: "Test User",
				email: "test@test.com",
			},
		});

		expect(response.status()).toBe(201);
		const user = await response.json();
		expect(user.name).toBe("Test User");
	});
});
```

---

## Authentication Setup

```typescript
// e2e/auth.setup.ts
import { test as setup, expect } from "@playwright/test";

const authFile = "e2e/.auth/user.json";

setup("authenticate", async ({ page }) => {
	await page.goto("/login");
	await page.getByLabel("Email").fill("admin@test.com");
	await page.getByLabel("Password").fill("password123");
	await page.getByRole("button", { name: "Sign In" }).click();

	await page.waitForURL("/dashboard");

	// Save auth state
	await page.context().storageState({ path: authFile });
});
```

```typescript
// playwright.config.ts — use auth state
{
	projects: [
		{ name: "setup", testMatch: /.*\.setup\.ts/ },
		{
			name: "chromium",
			dependencies: ["setup"],
			use: {
				storageState: "e2e/.auth/user.json",
			},
		},
	],
}
```

---

## CI Configuration

```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install
      - run: pnpm exec playwright install --with-deps chromium
      - run: pnpm exec playwright test --project=chromium
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Links

- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright — Locators](https://playwright.dev/docs/locators)
- [Playwright — Best Practices](https://playwright.dev/docs/best-practices)
