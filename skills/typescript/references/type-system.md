# Type System Avancado - TypeScript 5.7+

Referencia tecnica completa do sistema de tipos moderno em TypeScript. Para decisoes de quando aplicar cada padrao, consulte a skill principal.

---

## Generics

### Funcoes Genericas

Generics permitem funcoes e classes que operam sobre multiplos tipos mantendo type safety:
```typescript
function first<T>(items: T[]): T | undefined {
	return items[0];
}

// TypeScript infere T automaticamente
const num = first([1, 2, 3]); // number | undefined
const str = first(["a", "b"]); // string | undefined
```

### Generic Constraints

Use `extends` para restringir generics:
```typescript
interface HasId {
	id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
	return items.find((item) => item.id === id);
}

// Funciona com qualquer tipo que tenha 'id: string'
interface User extends HasId {
	name: string;
}
const user = findById<User>([{ id: "1", name: "Alice" }], "1");
```

### Multiple Type Parameters

```typescript
function zip<A, B>(as: A[], bs: B[]): [A, B][] {
	const length = Math.min(as.length, bs.length);
	const result: [A, B][] = [];
	for (let i = 0; i < length; i++) {
		result.push([as[i]!, bs[i]!]);
	}
	return result;
}

const pairs = zip([1, 2], ["a", "b"]); // [number, string][]
```

### Generic Classes

```typescript
class Result<T, E extends Error = Error> {
	private constructor(
		private readonly value: T | null,
		private readonly error: E | null,
	) {}

	static ok<T>(value: T): Result<T, never> {
		return new Result(value, null);
	}

	static err<E extends Error>(error: E): Result<never, E> {
		return new Result(null, error);
	}

	isOk(): this is Result<T, never> {
		return this.error === null;
	}

	unwrap(): T {
		if (this.value === null) throw this.error;
		return this.value;
	}

	map<U>(fn: (value: T) => U): Result<U, E> {
		if (this.value !== null) return Result.ok(fn(this.value));
		return Result.err(this.error!);
	}
}
```

---

## Utility Types

### Built-in Utility Types

```typescript
interface User {
	id: string;
	name: string;
	email: string;
	role: "admin" | "user";
	createdAt: Date;
}

// Partial — all properties optional
type UpdateUser = Partial<User>;

// Required — all properties required
type RequiredUser = Required<User>;

// Pick — select specific properties
type UserPreview = Pick<User, "id" | "name">;

// Omit — exclude specific properties
type CreateUser = Omit<User, "id" | "createdAt">;

// Record — dictionary type
type UserRoles = Record<string, "admin" | "user">;

// Readonly — all properties readonly
type FrozenUser = Readonly<User>;

// ReturnType — extract return type of function
function getUser(): User {
	return {} as User;
}
type UserFromFn = ReturnType<typeof getUser>; // User

// Parameters — extract parameter types
function createUser(name: string, email: string): User {
	return {} as User;
}
type CreateUserParams = Parameters<typeof createUser>; // [string, string]

// Awaited — unwrap Promise type
type ResolvedUser = Awaited<Promise<User>>; // User

// NonNullable — exclude null and undefined
type DefiniteUser = NonNullable<User | null | undefined>; // User

// Extract / Exclude — filter union types
type AdminRole = Extract<User["role"], "admin">; // "admin"
type NonAdminRole = Exclude<User["role"], "admin">; // "user"
```

### Composing Utility Types

```typescript
// Create a type for API response that makes 'id' required but everything else partial
type ApiUpdate<T extends { id: string }> = Pick<T, "id"> & Partial<Omit<T, "id">>;

type UserUpdate = ApiUpdate<User>;
// { id: string; name?: string; email?: string; role?: "admin" | "user"; createdAt?: Date }
```

---

## Discriminated Unions

Discriminated unions use a shared literal property to distinguish between variants:

```typescript
// Event system with discriminated unions
type AppEvent =
	| { type: "USER_LOGIN"; userId: string; timestamp: Date }
	| { type: "USER_LOGOUT"; userId: string; timestamp: Date }
	| { type: "PAGE_VIEW"; path: string; referrer: string | null }
	| { type: "ERROR"; code: number; message: string };

function handleEvent(event: AppEvent): void {
	switch (event.type) {
		case "USER_LOGIN":
			console.log(`User ${event.userId} logged in`);
			break;
		case "USER_LOGOUT":
			console.log(`User ${event.userId} logged out`);
			break;
		case "PAGE_VIEW":
			console.log(`Page viewed: ${event.path}`);
			break;
		case "ERROR":
			console.error(`Error ${event.code}: ${event.message}`);
			break;
		default:
			// Exhaustiveness check — TypeScript errors if a case is missing
			const _exhaustive: never = event;
			throw new Error(`Unhandled event: ${_exhaustive}`);
	}
}
```

### Pattern: Result Type

```typescript
type Result<T, E = string> =
	| { ok: true; value: T }
	| { ok: false; error: E };

function divide(a: number, b: number): Result<number> {
	if (b === 0) return { ok: false, error: "Division by zero" };
	return { ok: true, value: a / b };
}

const result = divide(10, 3);
if (result.ok) {
	console.log(result.value); // TypeScript knows value exists
} else {
	console.error(result.error); // TypeScript knows error exists
}
```

---

## Template Literal Types

```typescript
// CSS units
type CSSUnit = "px" | "rem" | "em" | "vh" | "vw" | "%";
type CSSValue = `${number}${CSSUnit}`;

const padding: CSSValue = "16px"; // OK
const margin: CSSValue = "2rem"; // OK
// const bad: CSSValue = "abc"; // Error

// Event handler names
type EventName = "click" | "focus" | "blur";
type HandlerName = `on${Capitalize<EventName>}`;
// "onClick" | "onFocus" | "onBlur"

// Route parameters
type Route = `/users/${string}` | `/posts/${string}/comments/${string}`;

function navigate(route: Route): void {
	// ...
}
navigate("/users/123"); // OK
navigate("/posts/456/comments/789"); // OK

// Object key patterns
type DataAttribute = `data-${string}`;
type AriaAttribute = `aria-${string}`;

interface DivProps {
	[key: DataAttribute]: string;
	[key: AriaAttribute]: string;
}
```

---

## satisfies Operator

`satisfies` validates a type WITHOUT widening it — you keep the narrow literal type:

```typescript
// Without satisfies — type is widened
const routes1: Record<string, { path: string }> = {
	home: { path: "/" },
	about: { path: "/about" },
};
// routes1.home.path is string — no autocomplete on keys

// With satisfies — keeps literal types
const routes2 = {
	home: { path: "/" },
	about: { path: "/about" },
} satisfies Record<string, { path: string }>;
// routes2.home.path is "/" — exact literal type preserved
// TypeScript knows exactly which keys exist

// Practical: config objects
const config = {
	apiUrl: "https://api.example.com",
	timeout: 5000,
	retries: 3,
} satisfies Record<string, string | number>;

// config.apiUrl is "https://api.example.com" (not string)
// config.timeout is 5000 (not number)
```

---

## const Assertions

`as const` makes values deeply readonly and preserves literal types:

```typescript
// Without as const
const colors1 = ["red", "green", "blue"]; // string[]

// With as const
const colors2 = ["red", "green", "blue"] as const; // readonly ["red", "green", "blue"]
type Color = (typeof colors2)[number]; // "red" | "green" | "blue"

// Object as const
const HTTP_STATUS = {
	OK: 200,
	NOT_FOUND: 404,
	INTERNAL_ERROR: 500,
} as const;

type StatusCode = (typeof HTTP_STATUS)[keyof typeof HTTP_STATUS]; // 200 | 404 | 500

// Enum alternative with as const
const Direction = {
	Up: "UP",
	Down: "DOWN",
	Left: "LEFT",
	Right: "RIGHT",
} as const;

type Direction = (typeof Direction)[keyof typeof Direction];
// "UP" | "DOWN" | "LEFT" | "RIGHT"
```

---

## Branded Types

Branded types prevent accidental mixing of structurally identical types:

```typescript
// Declare brand symbols
declare const UserIdBrand: unique symbol;
declare const OrderIdBrand: unique symbol;

type UserId = string & { readonly [UserIdBrand]: typeof UserIdBrand };
type OrderId = string & { readonly [OrderIdBrand]: typeof OrderIdBrand };

// Constructor functions
function UserId(id: string): UserId {
	// Validate format
	if (!/^usr_[a-z0-9]{12}$/.test(id)) {
		throw new Error(`Invalid UserId: ${id}`);
	}
	return id as UserId;
}

function OrderId(id: string): OrderId {
	if (!/^ord_[a-z0-9]{12}$/.test(id)) {
		throw new Error(`Invalid OrderId: ${id}`);
	}
	return id as OrderId;
}

// Usage
function getUser(id: UserId): Promise<User> {
	return fetch(`/api/users/${id}`).then((r) => r.json());
}

const userId = UserId("usr_abc123def456");
const orderId = OrderId("ord_xyz789abc012");

getUser(userId); // OK
// getUser(orderId); // Error — OrderId is not assignable to UserId
// getUser("raw-string"); // Error — string is not assignable to UserId
```

---

## Conditional Types

```typescript
// Basic conditional type
type IsString<T> = T extends string ? true : false;

type A = IsString<string>; // true
type B = IsString<number>; // false

// infer keyword — extract types from structures
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;

type C = UnwrapPromise<Promise<string>>; // string
type D = UnwrapPromise<number>; // number

// Extract array element type
type ElementOf<T> = T extends readonly (infer U)[] ? U : never;

type E = ElementOf<string[]>; // string
type F = ElementOf<[number, string]>; // number | string

// Function return type extraction
type AsyncReturnType<T extends (...args: unknown[]) => Promise<unknown>> =
	T extends (...args: unknown[]) => Promise<infer R> ? R : never;

async function fetchUsers(): Promise<User[]> {
	return [];
}
type Users = AsyncReturnType<typeof fetchUsers>; // User[]

// Distributive conditional types
type ToArray<T> = T extends unknown ? T[] : never;
type G = ToArray<string | number>; // string[] | number[]

// Non-distributive (wrap in tuple)
type ToArrayND<T> = [T] extends [unknown] ? T[] : never;
type H = ToArrayND<string | number>; // (string | number)[]
```

---

## Mapped Types

```typescript
// Make all properties optional and nullable
type Nullable<T> = {
	[K in keyof T]: T[K] | null;
};

// Make all properties read-write (remove readonly)
type Mutable<T> = {
	-readonly [K in keyof T]: T[K];
};

// Create getter interface from object type
type Getters<T> = {
	[K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
	name: string;
	age: number;
}

type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number }

// Filter properties by type
type StringKeysOf<T> = {
	[K in keyof T as T[K] extends string ? K : never]: T[K];
};

type UserStrings = StringKeysOf<User>;
// { id: string; name: string; email: string }

// Create event map from state
interface AppState {
	count: number;
	name: string;
	active: boolean;
}

type StateEvents = {
	[K in keyof AppState as `${string & K}Changed`]: (
		value: AppState[K],
	) => void;
};
// { countChanged: (value: number) => void; nameChanged: (value: string) => void; ... }
```

---

## Referencia Rapida

| Conceito | Quando usar | Exemplo |
|----------|-------------|---------|
| Generics | Codigo reutilizavel com type safety | `function map<T, U>(items: T[], fn: (t: T) => U): U[]` |
| Utility types | Transformar tipos existentes | `Partial<User>`, `Pick<User, "id">` |
| Discriminated unions | Modelar estados/variantes | `{ type: "success"; data: T } \| { type: "error"; msg: string }` |
| Template literals | String patterns tipados | `type Route = \`/api/${string}\`` |
| satisfies | Validar sem alargar tipo | `const x = { ... } satisfies Schema` |
| as const | Literal types imutaveis | `const x = ["a", "b"] as const` |
| Branded types | Prevenir mix de tipos identicos | `type UserId = string & { __brand: ... }` |
| Conditional types | Tipos computados | `T extends string ? A : B` |
| Mapped types | Transformar propriedades | `{ [K in keyof T]: ... }` |

---

## Links

- [TypeScript Handbook — Generics](https://www.typescriptlang.org/docs/handbook/2/generics.html)
- [TypeScript Handbook — Utility Types](https://www.typescriptlang.org/docs/handbook/utility-types.html)
- [TypeScript Handbook — Conditional Types](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html)
- [TypeScript Handbook — Mapped Types](https://www.typescriptlang.org/docs/handbook/2/mapped-types.html)
- [TypeScript Handbook — Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
