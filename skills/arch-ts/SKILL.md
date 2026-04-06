---
name: arch-ts
description: |
  Skill de arquitetura TypeScript/Frontend — foco em design de sistemas, trade-offs arquiteturais, patterns estruturais e decisões técnicas de alto nível.
  Cobre: type system avançado, React patterns, Server Components, state management, testing, styling, performance, accessibility, e melhores práticas estado da arte.
  Use quando: (1) Projetar arquitetura de sistemas frontend, (2) Avaliar trade-offs e decisões técnicas, (3) Aplicar patterns arquiteturais e design de alto nível.
  Triggers: /arch-ts, /arch-frontend, arquitetura TypeScript, frontend system design, design decisions, architectural patterns.
---

# Arch-TS Skill - TypeScript/Frontend Architecture & Design

**Skill global** — carregada automaticamente por todos os agents.

## Princípios Fundamentais

**Arquitetura e Design de Sistemas:**
- Use arquitetura e design de sistemas TypeScript/Frontend estado da arte.
- Pense profundamente sobre trade-offs, boundaries e decisões técnicas de alto nível.

**Decomposição de Problemas:**
- Entenda o sistema como um todo antes de propor soluções.
- Avalie se faz sentido quebrar em módulos, camadas ou componentes menores.

**Idioma:**
- Escreva código e comentários sempre em inglês.
- Documentação técnica e nomes de variáveis em inglês.
- Discussões e explicações podem ser em português quando solicitado.

---

## Padrões TypeScript Básicos

### Tipagem Explícita

Utilize sempre tipagem explícita em todas as variáveis e funções:
```typescript
interface ProcessResult {
  readonly count: number;
  readonly items: readonly string[];
}

function processItems(items: string[], limit: number = 10): ProcessResult {
  const sliced = items.slice(0, limit);
  return { count: sliced.length, items: sliced };
}
```

### Strict Mode

Sempre habilite `strict: true` no `tsconfig.json`. Isso ativa:
- `strictNullChecks` — null/undefined como tipos distintos
- `noImplicitAny` — proibe any implícito
- `strictFunctionTypes` — checagem contravariante de parâmetros
- `noUncheckedIndexedAccess` — index access retorna `T | undefined`

### Formatação Biome

Formate todo código com Biome (substitui ESLint + Prettier):
- Indentação com tabs (padrão Biome)
- Aspas duplas para strings
- Trailing commas em estruturas multi-linha
- Ponto-e-vírgula obrigatório

```typescript
function createUser(
	name: string,
	email: string,
	options?: {
		role?: "admin" | "user";
		active?: boolean;
	},
): User {
	return {
		id: crypto.randomUUID(),
		name,
		email,
		role: options?.role ?? "user",
		active: options?.active ?? true,
	};
}
```

---

## Conceitos TypeScript/Frontend Modernos - Overview

Visão geral de cada conceito estado da arte. Para detalhes e exemplos avançados, consulte os arquivos de referencia indicados.

### 1. Type System Avançado
**Quando usar:** Contratos claros, utility types, discriminated unions, branded types.

TypeScript 5.7+ oferece: generics avançados, template literal types, `satisfies`, const assertions, conditional types, mapped types.
```typescript
// Discriminated union
type Result<T> =
	| { success: true; data: T }
	| { success: false; error: string };

// Branded type
type UserId = string & { readonly __brand: unique symbol };

function createUserId(id: string): UserId {
	if (!id.startsWith("usr_")) throw new Error("Invalid user ID");
	return id as UserId;
}

// satisfies operator
const config = {
	port: 3000,
	host: "localhost",
} satisfies Record<string, string | number>;
```

**Referência:** [references/typescript/type-system.md](references/typescript/type-system.md)

---

### 2. TypeScript Patterns
**Quando usar:** Organizacao de módulos, dependency injection, patterns estruturais.

Patterns modernos: barrel files (com cuidado), path aliases, factory pattern, strategy pattern, builder pattern.
```typescript
// Strategy pattern
interface CompressionStrategy {
	compress(data: Buffer): Promise<Buffer>;
	decompress(data: Buffer): Promise<Buffer>;
}

class ImageProcessor {
	constructor(private strategy: CompressionStrategy) {}

	async process(image: Buffer): Promise<Buffer> {
		return this.strategy.compress(image);
	}
}
```

**Referência:** [references/typescript/patterns.md](references/typescript/patterns.md)

---

### 3. Strict Config
**Quando usar:** Sempre. Configuração base para qualquer projeto TypeScript.

tsconfig.json best practices: strict mode completo, moduleResolution bundler, ESM-first.
```jsonc
{
	"compilerOptions": {
		"strict": true,
		"noUncheckedIndexedAccess": true,
		"exactOptionalPropertyTypes": true,
		"moduleResolution": "bundler",
		"module": "ESNext",
		"target": "ES2022"
	}
}
```

**Referência:** [references/typescript/strict-config.md](references/typescript/strict-config.md)

---

### 4. React Component Patterns
**Quando usar:** Construir componentes reutilizáveis, composição, polimorfismo.

React 19+: compound components, polymorphic components, render props, composition over inheritance.
```typescript
// Compound component
function Select({ children, value, onChange }: SelectProps) {
	return (
		<SelectContext value={{ value, onChange }}>
			<div role="listbox">{children}</div>
		</SelectContext>
	);
}

Select.Option = function Option({ value, children }: OptionProps) {
	const ctx = use(SelectContext);
	return (
		<div role="option" onClick={() => ctx.onChange(value)}>
			{children}
		</div>
	);
};
```

**Referência:** [references/react/component-patterns.md](references/react/component-patterns.md)

---

### 5. React Server Components
**Quando usar:** Next.js 15+, data fetching, reduzir bundle client-side.

RSC mental model: server vs client boundary, "use client", Server Actions, streaming, cache/revalidation.
```typescript
// Server Component (default in Next.js App Router)
async function UserProfile({ userId }: { userId: string }) {
	const user = await db.user.findUnique({ where: { id: userId } });

	return (
		<div>
			<h1>{user.name}</h1>
			<Suspense fallback={<Skeleton />}>
				<UserPosts userId={userId} />
			</Suspense>
		</div>
	);
}
```

**Referência:** [references/react/server-components.md](references/react/server-components.md)

---

### 6. Performance
**Quando usar:** Otimizar Core Web Vitals, bundle size, rendering performance.

React.memo, useMemo, useCallback (com criterio), code splitting, image optimization, Core Web Vitals.
```typescript
// Code splitting with lazy
const AdminPanel = lazy(() => import("./AdminPanel"));

function App() {
	return (
		<Suspense fallback={<Loading />}>
			<AdminPanel />
		</Suspense>
	);
}
```

**Referência:** [references/react/performance.md](references/react/performance.md)

---

### 7. Custom Hooks
**Quando usar:** Logica reutilizável, composição de comportamento, encapsulamento de side effects.

Custom hooks patterns, rules of hooks, useEffect cleanup, useReducer, hook composition.
```typescript
function useDebounce<T>(value: T, delay: number): T {
	const [debounced, setDebounced] = useState(value);

	useEffect(() => {
		const timer = setTimeout(() => setDebounced(value), delay);
		return () => clearTimeout(timer);
	}, [value, delay]);

	return debounced;
}
```

**Referência:** [references/react/hooks.md](references/react/hooks.md)

---

### 8. State Management Architecture
**Quando usar:** Sempre. Escolha a ferramenta certa para o tipo de estado.

Decision tree: server state (TanStack Query) vs client state (Zustand) vs local state (useState) vs form state (React Hook Form).
```typescript
// Zustand store
import { create } from "zustand";

interface CartStore {
	items: CartItem[];
	addItem: (item: CartItem) => void;
	total: () => number;
}

const useCartStore = create<CartStore>((set, get) => ({
	items: [],
	addItem: (item) => set((s) => ({ items: [...s.items, item] })),
	total: () => get().items.reduce((sum, i) => sum + i.price, 0),
}));
```

**Referência:** [references/state/architecture.md](references/state/architecture.md)

---

### 9. Tailwind CSS
**Quando usar:** Styling padrão para a maioria dos projetos.

Utility-first, responsive design, dark mode, cn() utility, component extraction.

**Referência:** [references/styling/tailwind.md](references/styling/tailwind.md)

---

### 10. Testing com Vitest
**Quando usar:** Sempre. Testes sao parte integral do desenvolvimento.

Setup, mocking, Testing Library integration, coverage, workspace mode.
```typescript
import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { UserCard } from "./UserCard";

describe("UserCard", () => {
	it("renders user name", () => {
		render(<UserCard name="Alice" email="alice@test.com" />);
		expect(screen.getByRole("heading")).toHaveTextContent("Alice");
	});
});
```

**Referência:** [references/testing/vitest.md](references/testing/vitest.md)

---

### 11. E2E Testing com Playwright
**Quando usar:** Fluxos críticos de usuário, regressao visual, integração.

Page object model, locators, assertions, visual regression, CI configuration.

**Referência:** [references/testing/playwright.md](references/testing/playwright.md)

---

## Ferramentas Essenciais

| Categoria | Ferramenta | Propósito | Comando |
|-----------|------------|-----------|---------|
| Lint+Format | **Biome** | Linter e formatter unificado | `biome check --write .` |
| Test | **Vitest** | Framework de testes | `vitest` |
| E2E | **Playwright** | Testes end-to-end | `playwright test` |
| Package | **pnpm** | Gerenciador de pacotes | `pnpm install` |
| Build | **Vite** | Build tool e dev server | `vite dev` |

**Referência:** [references/tooling/biome.md](references/tooling/biome.md)

---

## Workflow Recomendado
```
ANALISAR -> PROJETAR -> TIPAR -> IMPLEMENTAR -> VALIDAR -> REVISAR
```

1. **Analisar**: Entenda o sistema, mapeie dependências e constraints
2. **Projetar**: Defina boundaries, interfaces e trade-offs arquiteturais
3. **Tipar**: Interfaces e types antes da implementacao
4. **Implementar**: Codigo seguindo o design e os tipos
5. **Validar**: Biome check + Vitest + Playwright
6. **Revisar**: Code review focado em design e clareza

---

## Referências por Domínio

### TypeScript Core
- [references/typescript/type-system.md](references/typescript/type-system.md) - Generics, utility types, branded types, conditional types
- [references/typescript/patterns.md](references/typescript/patterns.md) - Module patterns, DI, structural patterns
- [references/typescript/strict-config.md](references/typescript/strict-config.md) - tsconfig.json best practices

### React
- [references/react/component-patterns.md](references/react/component-patterns.md) - Composition, compound, polymorphic components
- [references/react/server-components.md](references/react/server-components.md) - RSC, Server Actions, streaming
- [references/react/performance.md](references/react/performance.md) - Core Web Vitals, memoization, code splitting
- [references/react/hooks.md](references/react/hooks.md) - Custom hooks, composition, testing

### State Management
- [references/state/zustand.md](references/state/zustand.md) - Zustand stores, middleware, patterns
- [references/state/tanstack-query.md](references/state/tanstack-query.md) - Server state, caching, mutations
- [references/state/architecture.md](references/state/architecture.md) - Decision tree, anti-patterns

### Styling
- [references/styling/tailwind.md](references/styling/tailwind.md) - Tailwind CSS 4+, utility patterns
- [references/styling/css-modules.md](references/styling/css-modules.md) - CSS Modules, composition, typing

### Testing
- [references/testing/vitest.md](references/testing/vitest.md) - Vitest setup, mocking, coverage
- [references/testing/playwright.md](references/testing/playwright.md) - E2E, visual regression, CI
- [references/testing/testing-library.md](references/testing/testing-library.md) - Philosophy, queries, async testing

### Tooling
- [references/tooling/vite.md](references/tooling/vite.md) - Vite config, plugins, optimization
- [references/tooling/biome.md](references/tooling/biome.md) - Biome lint + format, migration from ESLint
- [references/tooling/pnpm.md](references/tooling/pnpm.md) - Workspaces, strict mode, best practices
