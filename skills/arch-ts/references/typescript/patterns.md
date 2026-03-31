# TypeScript Patterns

Patterns estruturais e organizacionais para projetos TypeScript modernos.

---

## Module Patterns

### Barrel Files (index.ts)

Barrel files re-export from a directory to simplify imports:

```typescript
// components/Button/Button.tsx
export function Button(props: ButtonProps) { ... }
export type ButtonProps = { ... };

// components/Button/index.ts
export { Button } from "./Button";
export type { ButtonProps } from "./Button";

// Usage
import { Button } from "@/components/Button";
```

**Pros:**
- Clean import paths
- Encapsulation of internal structure

**Cons — and why to be careful:**
- Can cause massive bundle sizes (tree-shaking issues)
- Circular dependency risk in large codebases
- Slower TypeScript compilation in monorepos

**Rule:** Use barrel files at feature/component boundaries, NOT at every directory level. Never barrel the entire `src/`.

### Recommended Structure

```
src/
├── features/
│   ├── auth/
│   │   ├── index.ts          ← barrel for public API only
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── api.ts
│   │   └── types.ts
│   └── dashboard/
│       ├── index.ts
│       ├── components/
│       └── hooks/
├── shared/
│   ├── components/
│   │   └── index.ts          ← barrel for shared components
│   ├── hooks/
│   │   └── index.ts
│   └── utils/
│       └── index.ts
└── app/                       ← no barrel, framework routes
```

---

## Path Aliases

Configure path aliases in tsconfig.json for clean imports:

```jsonc
{
	"compilerOptions": {
		"baseUrl": ".",
		"paths": {
			"@/*": ["./src/*"],
			"@/features/*": ["./src/features/*"],
			"@/shared/*": ["./src/shared/*"],
			"@/test/*": ["./test/*"]
		}
	}
}
```

Vite config must mirror these:
```typescript
// vite.config.ts
import { resolve } from "node:path";
import { defineConfig } from "vite";

export default defineConfig({
	resolve: {
		alias: {
			"@": resolve(__dirname, "./src"),
		},
	},
});
```

---

## Dependency Injection

### Constructor Injection

```typescript
interface Logger {
	info(message: string, context?: Record<string, unknown>): void;
	error(message: string, error?: Error): void;
}

interface UserRepository {
	findById(id: string): Promise<User | null>;
	save(user: User): Promise<void>;
}

class UserService {
	constructor(
		private readonly repo: UserRepository,
		private readonly logger: Logger,
	) {}

	async getUser(id: string): Promise<User> {
		this.logger.info("Fetching user", { id });
		const user = await this.repo.findById(id);
		if (!user) throw new NotFoundError(`User ${id} not found`);
		return user;
	}
}

// Composition root
const logger = new ConsoleLogger();
const repo = new PrismaUserRepository(prisma);
const service = new UserService(repo, logger);
```

### Function Injection (Lighter Weight)

```typescript
interface Dependencies {
	fetchUser: (id: string) => Promise<User>;
	sendEmail: (to: string, subject: string, body: string) => Promise<void>;
	logger: Logger;
}

function createUserActions(deps: Dependencies) {
	return {
		async resetPassword(userId: string): Promise<void> {
			const user = await deps.fetchUser(userId);
			const token = crypto.randomUUID();
			await deps.sendEmail(
				user.email,
				"Password Reset",
				`Token: ${token}`,
			);
			deps.logger.info("Password reset sent", { userId });
		},
	};
}

// Easy to test — just pass mocks
const actions = createUserActions({
	fetchUser: vi.fn().mockResolvedValue({ email: "test@test.com" }),
	sendEmail: vi.fn().mockResolvedValue(undefined),
	logger: { info: vi.fn(), error: vi.fn() },
});
```

---

## Factory Pattern

```typescript
interface Notification {
	send(to: string, message: string): Promise<void>;
}

class EmailNotification implements Notification {
	async send(to: string, message: string): Promise<void> {
		// send email
	}
}

class SlackNotification implements Notification {
	constructor(private webhookUrl: string) {}
	async send(to: string, message: string): Promise<void> {
		// send slack message
	}
}

class SMSNotification implements Notification {
	async send(to: string, message: string): Promise<void> {
		// send SMS
	}
}

// Factory
type NotificationType = "email" | "slack" | "sms";

function createNotification(
	type: NotificationType,
	config: Record<string, string> = {},
): Notification {
	switch (type) {
		case "email":
			return new EmailNotification();
		case "slack":
			return new SlackNotification(config.webhookUrl ?? "");
		case "sms":
			return new SMSNotification();
		default: {
			const _exhaustive: never = type;
			throw new Error(`Unknown notification type: ${_exhaustive}`);
		}
	}
}

// Generic factory with registry
class NotificationFactory {
	private registry = new Map<string, () => Notification>();

	register(type: string, creator: () => Notification): void {
		this.registry.set(type, creator);
	}

	create(type: string): Notification {
		const creator = this.registry.get(type);
		if (!creator) throw new Error(`Unknown type: ${type}`);
		return creator();
	}
}
```

---

## Builder Pattern

```typescript
class QueryBuilder<T> {
	private filters: Array<(item: T) => boolean> = [];
	private sortKey: keyof T | null = null;
	private sortOrder: "asc" | "desc" = "asc";
	private limitCount: number | null = null;
	private offsetCount = 0;

	where(predicate: (item: T) => boolean): this {
		this.filters.push(predicate);
		return this;
	}

	orderBy(key: keyof T, order: "asc" | "desc" = "asc"): this {
		this.sortKey = key;
		this.sortOrder = order;
		return this;
	}

	limit(count: number): this {
		this.limitCount = count;
		return this;
	}

	offset(count: number): this {
		this.offsetCount = count;
		return this;
	}

	execute(data: T[]): T[] {
		let result = data.filter((item) =>
			this.filters.every((f) => f(item)),
		);

		if (this.sortKey) {
			const key = this.sortKey;
			const dir = this.sortOrder === "asc" ? 1 : -1;
			result.sort((a, b) => {
				if (a[key] < b[key]) return -1 * dir;
				if (a[key] > b[key]) return 1 * dir;
				return 0;
			});
		}

		result = result.slice(
			this.offsetCount,
			this.limitCount
				? this.offsetCount + this.limitCount
				: undefined,
		);

		return result;
	}
}

// Usage
const results = new QueryBuilder<User>()
	.where((u) => u.active)
	.where((u) => u.age >= 18)
	.orderBy("name", "asc")
	.limit(10)
	.offset(20)
	.execute(users);
```

---

## Strategy Pattern

```typescript
interface PricingStrategy {
	calculate(basePrice: number, quantity: number): number;
}

const standardPricing: PricingStrategy = {
	calculate: (basePrice, quantity) => basePrice * quantity,
};

const bulkPricing: PricingStrategy = {
	calculate: (basePrice, quantity) => {
		const discount = quantity >= 100 ? 0.2 : quantity >= 50 ? 0.1 : 0;
		return basePrice * quantity * (1 - discount);
	},
};

const premiumPricing: PricingStrategy = {
	calculate: (basePrice, quantity) => basePrice * quantity * 1.5,
};

class OrderProcessor {
	constructor(private pricing: PricingStrategy) {}

	processOrder(items: Array<{ price: number; quantity: number }>): number {
		return items.reduce(
			(total, item) =>
				total + this.pricing.calculate(item.price, item.quantity),
			0,
		);
	}

	setPricing(strategy: PricingStrategy): void {
		this.pricing = strategy;
	}
}

// Usage
const processor = new OrderProcessor(standardPricing);
processor.setPricing(bulkPricing); // Switch at runtime
```

---

## Error Handling Pattern

```typescript
// Base error class
class AppError extends Error {
	constructor(
		message: string,
		public readonly code: string,
		public readonly statusCode: number = 500,
		public readonly cause?: Error,
	) {
		super(message);
		this.name = this.constructor.name;
	}
}

class NotFoundError extends AppError {
	constructor(resource: string, id: string, cause?: Error) {
		super(`${resource} '${id}' not found`, "NOT_FOUND", 404, cause);
	}
}

class ValidationError extends AppError {
	constructor(
		public readonly fields: Record<string, string>,
		cause?: Error,
	) {
		const msg = Object.entries(fields)
			.map(([k, v]) => `${k}: ${v}`)
			.join(", ");
		super(`Validation failed: ${msg}`, "VALIDATION_ERROR", 400, cause);
	}
}

class UnauthorizedError extends AppError {
	constructor(message = "Authentication required", cause?: Error) {
		super(message, "UNAUTHORIZED", 401, cause);
	}
}

// Type-safe error handling
function isAppError(error: unknown): error is AppError {
	return error instanceof AppError;
}

function handleError(error: unknown): { status: number; body: object } {
	if (isAppError(error)) {
		return {
			status: error.statusCode,
			body: { code: error.code, message: error.message },
		};
	}
	console.error("Unexpected error:", error);
	return {
		status: 500,
		body: { code: "INTERNAL_ERROR", message: "Something went wrong" },
	};
}
```

---

## Links

- [TypeScript Handbook — Modules](https://www.typescriptlang.org/docs/handbook/modules.html)
- [Patterns.dev](https://www.patterns.dev/)
- [TypeScript Design Patterns](https://refactoring.guru/design-patterns/typescript)
