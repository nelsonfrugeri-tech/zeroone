---
name: typescript
description: |
  TypeScript/Frontend knowledge base (2026). Covers the advanced type system (discriminated unions,
  branded types, template literals, satisfies, conditional and mapped types), strict tsconfig,
  TypeScript structural patterns, React 19+ (compound components, polymorphic, Server Components,
  Server Actions, streaming), custom hooks, state management decision tree (TanStack Query vs Zustand
  vs useState vs React Hook Form), Tailwind CSS v4, Vitest, Playwright E2E, performance optimization
  (Core Web Vitals, code splitting), and tooling (Biome, pnpm, Vite).
  Use when: (1) Writing or reviewing TypeScript/React code, (2) Choosing state management strategy,
  (3) Designing React component architecture, (4) Setting up frontend tooling.
  Triggers: /typescript, typescript, react, nextjs, frontend, vitest, tailwind, zustand, tanstack.
type: knowledge
---

# TypeScript — Knowledge Base

## Purpose

This skill is the knowledge base for modern TypeScript and frontend engineering (2026).
It covers the type system, React architecture, state management, testing, and tooling.

**What this skill contains:**
- TypeScript type system (discriminated unions, branded types, utility types)
- Strict tsconfig configuration
- React 19+ patterns (compound components, polymorphic, Server Components)
- Custom hooks and hook composition
- State management architecture (decision tree)
- Tailwind CSS v4 (utility-first, OKLCH, CSS-first config)
- Vitest + Testing Library (unit and component tests)
- Playwright (E2E, visual regression)
- Performance (Core Web Vitals, code splitting, memoization)
- Tooling (Biome, pnpm, Vite)

---

## Fundamental Principles

1. **Always `strict: true`** — no implicit Any, null safety, contravariante function checks
2. **Types are contracts** — discriminated unions over nullable fields, branded types at boundaries
3. **Composition over inheritance** — compound components, hooks, not class hierarchies
4. **Server-first in Next.js** — default to Server Components, add "use client" only when needed
5. **Format: Biome** — tabs, double quotes, semicolons, trailing commas (replaces ESLint + Prettier)

---

## 1. Type System

### Discriminated Unions

```typescript
// Model states explicitly — never "maybe" fields
type LoadingState<T> =
	| { status: "idle" }
	| { status: "loading" }
	| { status: "success"; data: T }
	| { status: "error"; error: string };

function render<T>(state: LoadingState<T>): React.ReactNode {
	switch (state.status) {
		case "idle":
			return null;
		case "loading":
			return <Spinner />;
		case "success":
			return <Data value={state.data} />;
		case "error":
			return <ErrorMessage message={state.error} />;
	}
}
```

### Branded Types

```typescript
// Prevent passing wrong ID types at compile time
type UserId = string & { readonly __brand: unique symbol };
type OrderId = string & { readonly __brand: unique symbol };

function createUserId(raw: string): UserId {
	if (!raw.startsWith("usr_")) throw new Error(`Invalid user ID: ${raw}`);
	return raw as UserId;
}

function getUser(id: UserId): Promise<User> { ... }
function getOrder(id: OrderId): Promise<Order> { ... }

const userId = createUserId("usr_123");
getUser(userId);          // OK
getOrder(userId);         // TypeScript error: UserId ≠ OrderId
```

### Template Literal Types

```typescript
type HTTPMethod = "GET" | "POST" | "PUT" | "DELETE" | "PATCH";
type APIRoute = `/api/${string}`;
type EventName<T extends string> = `on${Capitalize<T>}`;

// Mapped types
type ReadOnly<T> = { readonly [K in keyof T]: T[K] };
type Optional<T> = { [K in keyof T]?: T[K] };
type Nullable<T> = { [K in keyof T]: T[K] | null };

// Conditional types
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
type FlattenArray<T> = T extends Array<infer U> ? U : T;
```

### `satisfies` Operator

```typescript
// satisfies: validate shape WITHOUT widening the type
const palette = {
	red: [255, 0, 0],
	green: "#00ff00",
	blue: [0, 0, 255],
} satisfies Record<string, string | number[]>;

// TypeScript knows red is number[] (not string | number[])
palette.red.map((x) => x * 2); // OK
palette.green.toUpperCase();    // OK
```

**Reference:** [references/type-system.md](references/type-system.md)

---

## 2. Strict tsconfig

```jsonc
// tsconfig.json
{
	"compilerOptions": {
		// Strict mode (required)
		"strict": true,
		"noUncheckedIndexedAccess": true,
		"exactOptionalPropertyTypes": true,
		"noImplicitOverride": true,

		// Module resolution
		"moduleResolution": "bundler",
		"module": "ESNext",
		"target": "ES2022",
		"lib": ["ES2022", "DOM", "DOM.Iterable"],

		// Output
		"outDir": "./dist",
		"rootDir": "./src",
		"declaration": true,

		// Developer experience
		"verbatimModuleSyntax": true,
		"forceConsistentCasingInFileNames": true,
		"skipLibCheck": true,

		// Path aliases
		"paths": {
			"@/*": ["./src/*"]
		}
	},
	"include": ["src"],
	"exclude": ["node_modules", "dist"]
}
```

**Reference:** [references/strict-config.md](references/strict-config.md)

---

## 3. React Component Patterns

### Compound Components

```typescript
interface SelectContextValue {
	value: string;
	onChange: (value: string) => void;
}

const SelectContext = createContext<SelectContextValue | null>(null);

function useSelect(): SelectContextValue {
	const ctx = useContext(SelectContext);
	if (!ctx) throw new Error("useSelect must be used within <Select>");
	return ctx;
}

interface SelectProps {
	value: string;
	onChange: (value: string) => void;
	children: React.ReactNode;
}

function Select({ value, onChange, children }: SelectProps): React.JSX.Element {
	return (
		<SelectContext value={{ value, onChange }}>
			<div role="listbox">{children}</div>
		</SelectContext>
	);
}

interface OptionProps {
	value: string;
	children: React.ReactNode;
}

Select.Option = function Option({ value, children }: OptionProps): React.JSX.Element {
	const { value: selected, onChange } = useSelect();
	return (
		<div
			role="option"
			aria-selected={selected === value}
			onClick={() => onChange(value)}
			className="cursor-pointer px-3 py-2 hover:bg-muted"
		>
			{children}
		</div>
	);
};
```

### Polymorphic Components

```typescript
type PolymorphicProps<T extends React.ElementType> = {
	as?: T;
	children?: React.ReactNode;
} & Omit<React.ComponentPropsWithRef<T>, "as" | "children">;

function Text<T extends React.ElementType = "span">({
	as,
	...props
}: PolymorphicProps<T>): React.JSX.Element {
	const Component = as ?? "span";
	return <Component {...props} />;
}

// Usage: infers the right props
<Text as="h1" className="text-4xl">Heading</Text>     // h1 props
<Text as="label" htmlFor="input">Label</Text>         // label props
<Text as="button" onClick={() => {}}>Button</Text>    // button props
```

**Reference:** [references/component-patterns.md](references/component-patterns.md)

---

## 4. React Server Components

```typescript
// Server Component (default in Next.js App Router — no "use client")
// Can: async/await, direct DB access, access server secrets
// Cannot: useState, useEffect, browser APIs, event handlers

async function UserProfile({ userId }: { userId: string }): Promise<React.JSX.Element> {
	// Direct DB call — no API needed
	const user = await db.user.findUniqueOrThrow({ where: { id: userId } });
	const posts = await db.post.count({ where: { authorId: userId } });

	return (
		<div>
			<h1>{user.name}</h1>
			<p>{posts} posts</p>
			<Suspense fallback={<ActivitySkeleton />}>
				<UserActivity userId={userId} />
			</Suspense>
		</div>
	);
}

// Client Component — only when you need interactivity
"use client";

interface LikeButtonProps {
	postId: string;
	initialCount: number;
}

function LikeButton({ postId, initialCount }: LikeButtonProps): React.JSX.Element {
	const [count, setCount] = useState(initialCount);
	const [liked, setLiked] = useState(false);

	return (
		<button
			onClick={() => {
				setCount((c) => c + (liked ? -1 : 1));
				setLiked((l) => !l);
			}}
			aria-pressed={liked}
		>
			{liked ? "♥" : "♡"} {count}
		</button>
	);
}
```

### Server Actions

```typescript
// app/actions.ts
"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";

const createPostSchema = z.object({
	title: z.string().min(1).max(200),
	content: z.string().min(1),
});

export async function createPost(formData: FormData): Promise<{ error?: string }> {
	const parsed = createPostSchema.safeParse({
		title: formData.get("title"),
		content: formData.get("content"),
	});

	if (!parsed.success) {
		return { error: parsed.error.message };
	}

	await db.post.create({ data: parsed.data });
	revalidatePath("/posts");
	return {};
}
```

**Reference:** [references/server-components.md](references/server-components.md)

---

## 5. Custom Hooks

```typescript
// Generic debounce hook
function useDebounce<T>(value: T, delay: number): T {
	const [debounced, setDebounced] = useState<T>(value);

	useEffect(() => {
		const timer = setTimeout(() => setDebounced(value), delay);
		return () => clearTimeout(timer);
	}, [value, delay]);

	return debounced;
}

// Async operation hook with loading/error state
interface AsyncState<T> {
	data: T | null;
	loading: boolean;
	error: string | null;
}

function useAsync<T>(fn: () => Promise<T>, deps: React.DependencyList): AsyncState<T> {
	const [state, setState] = useState<AsyncState<T>>({
		data: null,
		loading: true,
		error: null,
	});

	useEffect(() => {
		let cancelled = false;
		setState({ data: null, loading: true, error: null });

		fn()
			.then((data) => {
				if (!cancelled) setState({ data, loading: false, error: null });
			})
			.catch((err: unknown) => {
				if (!cancelled) {
					setState({ data: null, loading: false, error: String(err) });
				}
			});

		return () => {
			cancelled = true;
		};
	}, deps); // eslint-disable-line react-hooks/exhaustive-deps

	return state;
}
```

**Reference:** [references/hooks.md](references/hooks.md)

---

## 6. State Management

### Decision Tree

```
What kind of state?
  |
  +-- Server/async data (API calls, DB) --> TanStack Query
  |
  +-- URL / navigation state           --> Next.js router, nuqs
  |
  +-- Form state                       --> React Hook Form
  |
  +-- Complex client state             --> Zustand
  |
  +-- Simple local state               --> useState / useReducer
```

### TanStack Query (Server State)

```typescript
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

function useUser(userId: string) {
	return useQuery({
		queryKey: ["users", userId],
		queryFn: () => fetchUser(userId),
		staleTime: 5 * 60 * 1000, // 5 minutes
		enabled: Boolean(userId),
	});
}

function useUpdateUser() {
	const queryClient = useQueryClient();
	return useMutation({
		mutationFn: updateUser,
		onSuccess: (updatedUser) => {
			queryClient.setQueryData(["users", updatedUser.id], updatedUser);
			queryClient.invalidateQueries({ queryKey: ["users"] });
		},
	});
}
```

### Zustand (Client State)

```typescript
import { create } from "zustand";
import { devtools, persist } from "zustand/middleware";

interface CartItem {
	id: string;
	name: string;
	price: number;
	quantity: number;
}

interface CartStore {
	items: CartItem[];
	addItem: (item: Omit<CartItem, "quantity">) => void;
	removeItem: (id: string) => void;
	updateQuantity: (id: string, quantity: number) => void;
	clear: () => void;
	total: () => number;
	itemCount: () => number;
}

const useCartStore = create<CartStore>()(
	devtools(
		persist(
			(set, get) => ({
				items: [],
				addItem: (item) =>
					set((s) => {
						const existing = s.items.find((i) => i.id === item.id);
						if (existing) {
							return {
								items: s.items.map((i) =>
									i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i,
								),
							};
						}
						return { items: [...s.items, { ...item, quantity: 1 }] };
					}),
				removeItem: (id) => set((s) => ({ items: s.items.filter((i) => i.id !== id) })),
				updateQuantity: (id, quantity) =>
					set((s) => ({
						items: s.items
							.map((i) => (i.id === id ? { ...i, quantity } : i))
							.filter((i) => i.quantity > 0),
					})),
				clear: () => set({ items: [] }),
				total: () => get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
				itemCount: () => get().items.reduce((sum, i) => sum + i.quantity, 0),
			}),
			{ name: "cart" },
		),
	),
);
```

**Reference:** [references/state-management.md](references/state-management.md)

---

## 7. Tailwind CSS v4

```css
/* app.css — v4: CSS-first config, no tailwind.config.js */
@import "tailwindcss";

@theme {
	/* Colors in OKLCH */
	--color-surface: oklch(0.98 0 0);
	--color-surface-elevated: oklch(1 0 0);
	--color-primary: oklch(0.65 0.25 264);
	--color-primary-hover: oklch(0.60 0.25 264);
	--color-muted: oklch(0.90 0 0);
	--color-text: oklch(0.15 0 0);
	--color-text-muted: oklch(0.45 0 0);

	/* Typography */
	--font-sans: "Inter Variable", system-ui, sans-serif;
	--font-mono: "JetBrains Mono Variable", monospace;

	/* Spacing */
	--radius-sm: 0.375rem;
	--radius-md: 0.5rem;
	--radius-lg: 0.75rem;
	--radius-xl: 1rem;
}

/* Dark mode */
[data-theme="dark"] {
	--color-surface: oklch(0.13 0 0);
	--color-surface-elevated: oklch(0.18 0 0);
	--color-muted: oklch(0.25 0 0);
	--color-text: oklch(0.93 0 0);
	--color-text-muted: oklch(0.65 0 0);
}
```

**Reference:** [references/tailwind.md](references/tailwind.md)

---

## 8. Testing with Vitest

```typescript
import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { UserCard } from "./UserCard";

describe("UserCard", () => {
	const user = userEvent.setup();

	it("renders user name and email", () => {
		render(<UserCard name="Alice" email="alice@test.com" />);
		expect(screen.getByRole("heading", { name: "Alice" })).toBeInTheDocument();
		expect(screen.getByText("alice@test.com")).toBeInTheDocument();
	});

	it("calls onEdit when edit button is clicked", async () => {
		const onEdit = vi.fn();
		render(<UserCard name="Alice" email="alice@test.com" onEdit={onEdit} />);
		await user.click(screen.getByRole("button", { name: /edit/i }));
		expect(onEdit).toHaveBeenCalledOnce();
	});

	it("shows loading state", () => {
		render(<UserCard name="Alice" email="alice@test.com" loading />);
		expect(screen.getByRole("progressbar")).toBeInTheDocument();
		expect(screen.queryByRole("heading")).not.toBeInTheDocument();
	});
});

// vitest.config.ts
export default defineConfig({
	test: {
		environment: "jsdom",
		globals: true,
		setupFiles: "./src/test/setup.ts",
		coverage: {
			provider: "v8",
			reporter: ["text", "lcov"],
			thresholds: { branches: 80, functions: 80, lines: 80 },
		},
	},
});
```

**Reference:** [references/vitest.md](references/vitest.md)

---

## 9. Performance

### Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5–4s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | 200–500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 | > 0.25 |

### Code Splitting

```typescript
// Lazy-load heavy components
const AdminDashboard = lazy(() => import("./AdminDashboard"));
const ReportViewer = lazy(() => import("./ReportViewer"));

function App(): React.JSX.Element {
	return (
		<Suspense fallback={<PageSkeleton />}>
			<Routes>
				<Route path="/admin" element={<AdminDashboard />} />
				<Route path="/reports" element={<ReportViewer />} />
			</Routes>
		</Suspense>
	);
}
```

### Memoization (use with measurement)

```typescript
// memo: prevent re-render when props unchanged
const ExpensiveList = memo(function ExpensiveList({ items }: { items: Item[] }) {
	return <ul>{items.map((item) => <ListItem key={item.id} item={item} />)}</ul>;
}, (prev, next) => prev.items === next.items);

// useMemo: cache expensive computation
const sortedItems = useMemo(
	() => [...items].sort((a, b) => a.name.localeCompare(b.name)),
	[items],
);

// useCallback: stable reference for callbacks passed to children
const handleDelete = useCallback(
	(id: string) => dispatch({ type: "DELETE", payload: id }),
	[dispatch],
);
```

**Reference:** [references/performance.md](references/performance.md)

---

## 10. Essential Tooling

| Category | Tool | Purpose | Command |
|----------|------|---------|---------|
| Lint + Format | **Biome** | Unified linter and formatter | `biome check --write .` |
| Test | **Vitest** | Unit/component tests | `vitest run` |
| E2E | **Playwright** | End-to-end tests | `playwright test` |
| Package | **pnpm** | Dependency management | `pnpm install` |
| Build | **Vite** | Build tool and dev server | `vite dev` |
| Types | **TypeScript** | Static type checking | `tsc --noEmit` |

### biome.json

```json
{
	"$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
	"organizeImports": { "enabled": true },
	"linter": {
		"enabled": true,
		"rules": {
			"recommended": true,
			"complexity": { "noExcessiveCognitiveComplexity": "warn" },
			"suspicious": { "noExplicitAny": "error" }
		}
	},
	"formatter": {
		"enabled": true,
		"indentStyle": "tab",
		"indentWidth": 1,
		"lineWidth": 100
	},
	"javascript": {
		"formatter": {
			"quoteStyle": "double",
			"semicolons": "always",
			"trailingCommas": "all"
		}
	}
}
```

**Reference:** [references/tooling.md](references/tooling.md)

---

## Reference Files

- [references/type-system.md](references/type-system.md) — Generics, utility types, branded types, conditional types
- [references/strict-config.md](references/strict-config.md) — tsconfig.json best practices
- [references/component-patterns.md](references/component-patterns.md) — Compound, polymorphic, render props
- [references/server-components.md](references/server-components.md) — RSC, Server Actions, streaming
- [references/hooks.md](references/hooks.md) — Custom hooks, composition, testing
- [references/state-management.md](references/state-management.md) — Decision tree, Zustand, TanStack Query
- [references/tailwind.md](references/tailwind.md) — Tailwind CSS v4, OKLCH, CSS-first config
- [references/vitest.md](references/vitest.md) — Vitest setup, mocking, coverage
- [references/performance.md](references/performance.md) — Core Web Vitals, memoization, code splitting
- [references/tooling.md](references/tooling.md) — Biome, pnpm, Vite configuration
