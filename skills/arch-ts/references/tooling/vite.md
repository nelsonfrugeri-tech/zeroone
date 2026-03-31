# Vite 6+ - Build Tool & Dev Server

Vite e a build tool recomendada para projetos frontend.

---

## Config

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "node:path";

export default defineConfig({
	plugins: [react()],
	resolve: {
		alias: {
			"@": resolve(__dirname, "./src"),
		},
	},
	server: {
		port: 3000,
		strictPort: true,
		open: true,
	},
	build: {
		target: "es2022",
		sourcemap: true,
		rollupOptions: {
			output: {
				manualChunks: {
					vendor: ["react", "react-dom"],
					router: ["react-router-dom"],
				},
			},
		},
	},
});
```

---

## Plugin System

```typescript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { visualizer } from "rollup-plugin-visualizer";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig(({ mode }) => ({
	plugins: [
		react(),

		// Bundle analysis (only in build)
		mode === "analyze" &&
			visualizer({
				open: true,
				gzipSize: true,
				filename: "dist/stats.html",
			}),

		// PWA support
		VitePWA({
			registerType: "autoUpdate",
			workbox: {
				globPatterns: ["**/*.{js,css,html,ico,png,svg}"],
			},
		}),
	].filter(Boolean),
}));
```

---

## Environment Variables

```bash
# .env
VITE_API_URL=http://localhost:8080
VITE_APP_TITLE=My App

# .env.production
VITE_API_URL=https://api.example.com

# .env.local (not committed)
VITE_API_KEY=secret123
```

```typescript
// Only variables prefixed with VITE_ are exposed to client code
const apiUrl = import.meta.env.VITE_API_URL;
const mode = import.meta.env.MODE; // "development" | "production"
const isDev = import.meta.env.DEV; // boolean
const isProd = import.meta.env.PROD; // boolean
```

Type definitions:
```typescript
// env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
	readonly VITE_API_URL: string;
	readonly VITE_APP_TITLE: string;
}

interface ImportMeta {
	readonly env: ImportMetaEnv;
}
```

---

## Proxy Setup

```typescript
// vite.config.ts
export default defineConfig({
	server: {
		proxy: {
			// /api/users -> http://localhost:8080/api/users
			"/api": {
				target: "http://localhost:8080",
				changeOrigin: true,
			},
			// /ws -> ws://localhost:8080/ws
			"/ws": {
				target: "ws://localhost:8080",
				ws: true,
			},
			// /external/data -> https://external-api.com/data
			"/external": {
				target: "https://external-api.com",
				changeOrigin: true,
				rewrite: (path) => path.replace(/^\/external/, ""),
			},
		},
	},
});
```

---

## Build Optimization

### Manual Chunks

```typescript
build: {
	rollupOptions: {
		output: {
			manualChunks(id) {
				// Vendor chunk for node_modules
				if (id.includes("node_modules")) {
					// Split large deps into separate chunks
					if (id.includes("@tanstack/react-query")) return "query";
					if (id.includes("zustand")) return "zustand";
					if (id.includes("react")) return "vendor";
					return "deps";
				}
			},
		},
	},
}
```

### Tree Shaking

Vite uses Rollup which tree-shakes by default. Ensure:
- Use named imports: `import { map } from "lodash-es"` not `import _ from "lodash"`
- Use ESM packages (check package.json `"module"` field)
- Avoid side-effectful imports when possible

### CSS Code Splitting

```typescript
build: {
	cssCodeSplit: true, // Default: true — CSS is split per async chunk
}
```

---

## HMR (Hot Module Replacement)

HMR works out of the box with `@vitejs/plugin-react`. Custom HMR:

```typescript
// Manual HMR for non-React modules
if (import.meta.hot) {
	import.meta.hot.accept("./config", (newConfig) => {
		// Handle updated config
		updateConfig(newConfig);
	});

	import.meta.hot.dispose(() => {
		// Cleanup before module is replaced
		cleanup();
	});
}
```

---

## Library Mode

Build a library (not an app):

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import { resolve } from "node:path";
import dts from "vite-plugin-dts";

export default defineConfig({
	plugins: [dts({ rollupTypes: true })],
	build: {
		lib: {
			entry: resolve(__dirname, "src/index.ts"),
			name: "MyLib",
			fileName: "my-lib",
			formats: ["es", "cjs"],
		},
		rollupOptions: {
			external: ["react", "react-dom"],
			output: {
				globals: {
					react: "React",
					"react-dom": "ReactDOM",
				},
			},
		},
	},
});
```

---

## SSR Mode

```typescript
// vite.config.ts
export default defineConfig({
	ssr: {
		noExternal: ["my-non-esm-package"], // Bundle these for SSR
		external: ["database-driver"], // Keep external for SSR
	},
});

// Entry point for SSR
// src/entry-server.tsx
import { renderToString } from "react-dom/server";
import { App } from "./App";

export function render(url: string) {
	const html = renderToString(<App url={url} />);
	return { html };
}
```

---

## Links

- [Vite Documentation](https://vite.dev/)
- [Vite — Config Reference](https://vite.dev/config/)
- [Vite — Environment Variables](https://vite.dev/guide/env-and-mode.html)
- [Vite — Build Optimization](https://vite.dev/guide/build.html)
