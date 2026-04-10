# Biome 2+ - Linter & Formatter

Biome substitui ESLint + Prettier com uma unica ferramenta ultrarapida.

---

## Config

```jsonc
// biome.json
{
	"$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
	"organizeImports": {
		"enabled": true
	},
	"formatter": {
		"enabled": true,
		"indentStyle": "tab",
		"indentWidth": 2,
		"lineWidth": 100
	},
	"linter": {
		"enabled": true,
		"rules": {
			"recommended": true,
			"complexity": {
				"noBannedTypes": "error",
				"noExcessiveCognitiveComplexity": {
					"level": "warn",
					"options": { "maxAllowedComplexity": 15 }
				}
			},
			"correctness": {
				"noUnusedImports": "error",
				"noUnusedVariables": "warn",
				"useExhaustiveDependencies": "warn"
			},
			"style": {
				"noNonNullAssertion": "warn",
				"useConst": "error",
				"useImportType": "error"
			},
			"suspicious": {
				"noExplicitAny": "warn",
				"noConsole": {
					"level": "warn",
					"options": {
						"allow": ["warn", "error"]
					}
				}
			},
			"a11y": {
				"recommended": true
			}
		}
	},
	"javascript": {
		"formatter": {
			"quoteStyle": "double",
			"trailingCommas": "all",
			"semicolons": "always"
		}
	},
	"files": {
		"ignore": [
			"node_modules",
			"dist",
			"build",
			".next",
			"coverage",
			"*.min.js"
		]
	}
}
```

---

## Commands

```bash
# Check everything (lint + format + imports)
biome check .

# Check and auto-fix
biome check --write .

# Format only
biome format --write .

# Lint only
biome lint .

# CI mode (exits with error code)
biome ci .
```

---

## Migration from ESLint + Prettier

```bash
# Auto-migrate ESLint config
biome migrate eslint --write

# Auto-migrate Prettier config
biome migrate prettier --write
```

After migration:
1. Remove `.eslintrc`, `.prettierrc`, `.eslintignore`, `.prettierignore`
2. Remove `eslint`, `prettier`, and all plugins from `package.json`
3. Update scripts:
   ```json
   {
     "scripts": {
       "lint": "biome ci .",
       "format": "biome check --write ."
     }
   }
   ```

---

## Editor Integration

### VS Code

Install `biomejs.biome` extension.

```jsonc
// .vscode/settings.json
{
	"editor.defaultFormatter": "biomejs.biome",
	"editor.formatOnSave": true,
	"editor.codeActionsOnSave": {
		"quickfix.biome": "explicit",
		"source.organizeImports.biome": "explicit"
	},
	// Disable conflicting formatters
	"prettier.enable": false,
	"eslint.enable": false
}
```

---

## CI Setup

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]
jobs:
  biome:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: biomejs/setup-biome@v2
        with:
          version: latest
      - run: biome ci .
```

---

## Ignore Patterns

```jsonc
// biome.json
{
	"files": {
		"ignore": [
			"node_modules",
			"dist",
			"*.generated.ts",
			"**/*.d.ts"
		]
	}
}
```

Inline suppression:
```typescript
// biome-ignore lint/suspicious/noExplicitAny: legacy API requires any
const data: any = legacyApi.getData();

// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: parser logic
function parseComplex() { ... }
```

---

## Key Lint Rules

| Rule | Category | What it catches |
|------|----------|-----------------|
| `noExplicitAny` | suspicious | Using `any` type |
| `noUnusedImports` | correctness | Dead imports |
| `noUnusedVariables` | correctness | Dead variables |
| `useExhaustiveDependencies` | correctness | Missing hook deps |
| `noNonNullAssertion` | style | Unsafe `!` operator |
| `useConst` | style | `let` that should be `const` |
| `useImportType` | style | Missing `type` in type-only imports |
| `noConsole` | suspicious | Console statements in prod code |
| `noBannedTypes` | complexity | `{}`, `Object`, `Function` types |
| `a11y/*` | a11y | Accessibility issues in JSX |

---

## Links

- [Biome Documentation](https://biomejs.dev/)
- [Biome — Rules](https://biomejs.dev/linter/rules/)
- [Biome — Formatter](https://biomejs.dev/formatter/)
- [Biome — Migration Guide](https://biomejs.dev/guides/migrate-eslint-prettier/)
