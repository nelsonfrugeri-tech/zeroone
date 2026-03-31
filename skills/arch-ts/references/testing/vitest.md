# Vitest 3+ - Testing Framework

Vitest e o framework de testes recomendado para projetos TypeScript/Vite.

---

## Setup

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import { resolve } from "node:path";

export default defineConfig({
	plugins: [react()],
	test: {
		globals: true,
		environment: "jsdom",
		setupFiles: ["./test/setup.ts"],
		include: ["src/**/*.{test,spec}.{ts,tsx}"],
		coverage: {
			provider: "v8",
			include: ["src/**/*.{ts,tsx}"],
			exclude: [
				"src/**/*.d.ts",
				"src/**/*.test.{ts,tsx}",
				"src/**/index.ts",
				"src/types/**",
			],
			thresholds: {
				branches: 80,
				functions: 80,
				lines: 80,
				statements: 80,
			},
		},
	},
	resolve: {
		alias: {
			"@": resolve(__dirname, "./src"),
		},
	},
});
```

```typescript
// test/setup.ts
import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { afterEach } from "vitest";

afterEach(() => {
	cleanup();
});
```

---

## Basic Tests

```typescript
import { describe, it, expect } from "vitest";

// Pure function tests
describe("formatCurrency", () => {
	it("formats positive numbers", () => {
		expect(formatCurrency(1234.56)).toBe("$1,234.56");
	});

	it("handles zero", () => {
		expect(formatCurrency(0)).toBe("$0.00");
	});

	it("formats negative numbers", () => {
		expect(formatCurrency(-42.5)).toBe("-$42.50");
	});
});

// Async tests
describe("fetchUser", () => {
	it("returns user data", async () => {
		const user = await fetchUser("123");
		expect(user).toMatchObject({
			id: "123",
			name: expect.any(String),
		});
	});

	it("throws on invalid ID", async () => {
		await expect(fetchUser("invalid")).rejects.toThrow("Not found");
	});
});
```

---

## Mocking

### vi.fn() — mock functions

```typescript
import { vi, describe, it, expect } from "vitest";

it("calls callback with correct args", () => {
	const callback = vi.fn();
	processItems(["a", "b"], callback);

	expect(callback).toHaveBeenCalledTimes(2);
	expect(callback).toHaveBeenCalledWith("a", 0);
	expect(callback).toHaveBeenCalledWith("b", 1);
});
```

### vi.mock() — mock modules

```typescript
import { vi, describe, it, expect, beforeEach } from "vitest";
import { createUser } from "./users";

// Mock the entire module
vi.mock("./api", () => ({
	post: vi.fn(),
}));

import { post } from "./api";

describe("createUser", () => {
	beforeEach(() => {
		vi.mocked(post).mockResolvedValue({ id: "1", name: "Alice" });
	});

	it("calls API with correct data", async () => {
		await createUser({ name: "Alice", email: "alice@test.com" });
		expect(post).toHaveBeenCalledWith("/users", {
			name: "Alice",
			email: "alice@test.com",
		});
	});
});
```

### vi.spyOn() — spy on methods

```typescript
it("logs errors", () => {
	const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});

	processInvalid();

	expect(consoleSpy).toHaveBeenCalledWith(
		expect.stringContaining("Invalid"),
	);
	consoleSpy.mockRestore();
});
```

### Mock fetch

```typescript
it("fetches data", async () => {
	const mockData = { id: "1", name: "Alice" };
	vi.spyOn(global, "fetch").mockResolvedValueOnce(
		new Response(JSON.stringify(mockData), {
			status: 200,
			headers: { "Content-Type": "application/json" },
		}),
	);

	const result = await fetchUser("1");
	expect(result).toEqual(mockData);
	expect(fetch).toHaveBeenCalledWith("/api/users/1");
});
```

---

## Testing React Components

```typescript
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect } from "vitest";
import { LoginForm } from "./LoginForm";

describe("LoginForm", () => {
	it("renders email and password fields", () => {
		render(<LoginForm onSubmit={vi.fn()} />);

		expect(screen.getByLabelText("Email")).toBeInTheDocument();
		expect(screen.getByLabelText("Password")).toBeInTheDocument();
		expect(screen.getByRole("button", { name: "Sign In" })).toBeInTheDocument();
	});

	it("submits form with values", async () => {
		const user = userEvent.setup();
		const onSubmit = vi.fn();
		render(<LoginForm onSubmit={onSubmit} />);

		await user.type(screen.getByLabelText("Email"), "test@test.com");
		await user.type(screen.getByLabelText("Password"), "secret123");
		await user.click(screen.getByRole("button", { name: "Sign In" }));

		expect(onSubmit).toHaveBeenCalledWith({
			email: "test@test.com",
			password: "secret123",
		});
	});

	it("shows validation error for invalid email", async () => {
		const user = userEvent.setup();
		render(<LoginForm onSubmit={vi.fn()} />);

		await user.type(screen.getByLabelText("Email"), "not-email");
		await user.click(screen.getByRole("button", { name: "Sign In" }));

		expect(screen.getByRole("alert")).toHaveTextContent("Invalid email");
	});
});
```

---

## Snapshot Testing

```typescript
it("renders correctly", () => {
	const { container } = render(<Badge color="green">Active</Badge>);
	expect(container.firstChild).toMatchSnapshot();
});

// Inline snapshot — stored in test file
it("formats output correctly", () => {
	expect(formatUser({ name: "Alice", role: "admin" }))
		.toMatchInlineSnapshot(`"Alice (admin)"`);
});
```

---

## Coverage

```bash
# Run with coverage
pnpm vitest run --coverage

# Watch mode with coverage UI
pnpm vitest --coverage --ui
```

---

## Workspace Mode (Monorepo)

```typescript
// vitest.workspace.ts
import { defineWorkspace } from "vitest/config";

export default defineWorkspace([
	"packages/*/vitest.config.ts",
	{
		test: {
			name: "unit",
			include: ["src/**/*.test.ts"],
			environment: "node",
		},
	},
	{
		test: {
			name: "browser",
			include: ["src/**/*.test.tsx"],
			environment: "jsdom",
		},
	},
]);
```

---

## Timers

```typescript
describe("debounce", () => {
	beforeEach(() => {
		vi.useFakeTimers();
	});

	afterEach(() => {
		vi.useRealTimers();
	});

	it("delays execution", () => {
		const fn = vi.fn();
		const debounced = debounce(fn, 300);

		debounced();
		expect(fn).not.toHaveBeenCalled();

		vi.advanceTimersByTime(300);
		expect(fn).toHaveBeenCalledOnce();
	});
});
```

---

## Links

- [Vitest Documentation](https://vitest.dev/)
- [Vitest — Mocking](https://vitest.dev/guide/mocking.html)
- [Vitest — Coverage](https://vitest.dev/guide/coverage.html)
