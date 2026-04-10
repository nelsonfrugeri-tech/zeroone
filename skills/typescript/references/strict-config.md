# TypeScript Strict Config - tsconfig.json Best Practices

Configuracao recomendada para projetos TypeScript modernos (5.7+).

---

## Recommended tsconfig.json

```jsonc
{
	"compilerOptions": {
		// Type Checking — maximum strictness
		"strict": true,
		"noUncheckedIndexedAccess": true,
		"exactOptionalPropertyTypes": true,
		"noFallthroughCasesInSwitch": true,
		"noImplicitOverride": true,
		"noImplicitReturns": true,
		"noPropertyAccessFromIndexSignature": true,
		"noUnusedLocals": true,
		"noUnusedParameters": true,
		"forceConsistentCasingInFileNames": true,
		"verbatimModuleSyntax": true,

		// Module System
		"module": "ESNext",
		"moduleResolution": "bundler",
		"resolveJsonModule": true,
		"allowImportingTsExtensions": true,
		"noEmit": true,

		// Language & Environment
		"target": "ES2022",
		"lib": ["ES2023", "DOM", "DOM.Iterable"],
		"jsx": "react-jsx",

		// Path Aliases
		"baseUrl": ".",
		"paths": {
			"@/*": ["./src/*"]
		},

		// Interop
		"esModuleInterop": true,
		"isolatedModules": true,
		"skipLibCheck": true
	},
	"include": ["src/**/*.ts", "src/**/*.tsx"],
	"exclude": ["node_modules", "dist", "build"]
}
```

---

## Strict Mode Options Explained

### `strict: true`

Enables all strict flags at once:

| Flag | What it does |
|------|--------------|
| `strictNullChecks` | `null` and `undefined` are distinct types; must handle explicitly |
| `strictFunctionTypes` | Contravariant function parameter checking |
| `strictBindCallApply` | Type-check `bind`, `call`, `apply` |
| `strictPropertyInitialization` | Class properties must be initialized or declared as optional |
| `noImplicitAny` | Errors on implicit `any` type |
| `noImplicitThis` | Errors on `this` with implicit `any` type |
| `alwaysStrict` | Emits `"use strict"` in every file |
| `useUnknownInCatchVariables` | `catch(e)` gives `unknown` instead of `any` |

### `noUncheckedIndexedAccess`

Index access returns `T | undefined` instead of `T`:

```typescript
const arr = [1, 2, 3];
const item = arr[0]; // number | undefined (not number)

// Forces explicit checks
if (item !== undefined) {
	console.log(item.toFixed()); // OK
}

const map: Record<string, number> = { a: 1 };
const val = map["b"]; // number | undefined (not number)
```

**Always enable.** Catches real bugs with array/object index access.

### `exactOptionalPropertyTypes`

Distinguishes between "property is missing" and "property is undefined":

```typescript
interface Config {
	name: string;
	timeout?: number; // can be MISSING, but not explicitly undefined
}

const a: Config = { name: "app" }; // OK — timeout missing
// const b: Config = { name: "app", timeout: undefined }; // Error!
```

### `verbatimModuleSyntax`

Enforces explicit `type` keyword for type-only imports:

```typescript
// Must use 'type' for type-only imports
import type { User } from "./types";
import { createUser } from "./users";

// Or inline type imports
import { createUser, type User } from "./users";
```

This ensures bundlers can safely strip type imports without TypeScript analysis.

---

## ESM vs CJS

### Modern recommendation: ESM-first

```jsonc
// package.json
{
	"type": "module"
}
```

```jsonc
// tsconfig.json
{
	"compilerOptions": {
		"module": "ESNext",
		"moduleResolution": "bundler"
	}
}
```

### moduleResolution Options

| Value | When to use |
|-------|-------------|
| `"bundler"` | Frontend projects using Vite, webpack, esbuild. **Default choice.** |
| `"nodenext"` | Node.js libraries that need to emit ESM/CJS. Strict resolution. |
| `"node16"` | Same as nodenext but pinned to Node 16 behavior. |
| `"node"` | Legacy CJS resolution. **Avoid in new projects.** |

### `"bundler"` vs `"nodenext"`

- `bundler`: Relaxed — allows extensionless imports, works with Vite/webpack
- `nodenext`: Strict — requires `.js` extensions, respects package.json `exports`

Use `bundler` for apps, `nodenext` for published libraries.

---

## Target and Lib

### `target`

Which JS version to emit. With `noEmit: true` (bundler handles emit), set to your runtime minimum:

| Runtime | Recommended target |
|---------|-------------------|
| Modern browsers | `ES2022` |
| Node 20+ | `ES2022` |
| Node 18 | `ES2021` |

### `lib`

Which type definitions to include:

```jsonc
{
	"lib": [
		"ES2023",      // Latest stable ES features
		"DOM",          // Browser APIs (window, document, fetch)
		"DOM.Iterable"  // Iterable DOM collections (NodeList, etc.)
	]
}
```

- **Frontend:** `["ES2023", "DOM", "DOM.Iterable"]`
- **Node.js:** `["ES2023"]` (use `@types/node` instead of DOM)
- **Shared library:** `["ES2023"]` (no runtime-specific types)

---

## Project References (Monorepo)

For monorepos, use project references to keep builds fast:

```jsonc
// tsconfig.json (root)
{
	"references": [
		{ "path": "./packages/shared" },
		{ "path": "./packages/web" },
		{ "path": "./packages/api" }
	],
	"files": []
}
```

```jsonc
// packages/shared/tsconfig.json
{
	"compilerOptions": {
		"composite": true,
		"outDir": "./dist",
		"rootDir": "./src"
	},
	"include": ["src/**/*.ts"]
}
```

```jsonc
// packages/web/tsconfig.json
{
	"compilerOptions": {
		"composite": true,
		"noEmit": true
	},
	"references": [
		{ "path": "../shared" }
	],
	"include": ["src/**/*.ts", "src/**/*.tsx"]
}
```

---

## Framework-Specific Configs

### Next.js 15

```jsonc
{
	"compilerOptions": {
		"strict": true,
		"noUncheckedIndexedAccess": true,
		"exactOptionalPropertyTypes": true,
		"target": "ES2022",
		"lib": ["ES2023", "DOM", "DOM.Iterable"],
		"module": "ESNext",
		"moduleResolution": "bundler",
		"jsx": "preserve",
		"noEmit": true,
		"incremental": true,
		"esModuleInterop": true,
		"isolatedModules": true,
		"skipLibCheck": true,
		"resolveJsonModule": true,
		"verbatimModuleSyntax": true,
		"plugins": [{ "name": "next" }],
		"paths": {
			"@/*": ["./src/*"]
		}
	},
	"include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
	"exclude": ["node_modules"]
}
```

### Vite + React

```jsonc
{
	"compilerOptions": {
		"strict": true,
		"noUncheckedIndexedAccess": true,
		"target": "ES2022",
		"lib": ["ES2023", "DOM", "DOM.Iterable"],
		"module": "ESNext",
		"moduleResolution": "bundler",
		"jsx": "react-jsx",
		"noEmit": true,
		"isolatedModules": true,
		"esModuleInterop": true,
		"skipLibCheck": true,
		"verbatimModuleSyntax": true,
		"allowImportingTsExtensions": true,
		"paths": {
			"@/*": ["./src/*"]
		}
	},
	"include": ["src"],
	"exclude": ["node_modules"]
}
```

---

## Links

- [TypeScript — tsconfig reference](https://www.typescriptlang.org/tsconfig)
- [TypeScript — Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
- [Total TypeScript — tsconfig cheat sheet](https://www.totaltypescript.com/tsconfig-cheat-sheet)
