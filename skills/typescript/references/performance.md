# React Performance - Core Web Vitals & Optimization

Guia completo de performance para React 19+ e Next.js 15+.

---

## Core Web Vitals

| Metric | Target | What it measures |
|--------|--------|------------------|
| **LCP** (Largest Contentful Paint) | < 2.5s | When the largest content element becomes visible |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Visual stability — how much content shifts during load |
| **INP** (Interaction to Next Paint) | < 200ms | Responsiveness — delay between interaction and visual update |

---

## React.memo

Prevents re-renders when props haven't changed:

```typescript
import { memo } from "react";

// GOOD use case: list item rendered many times
const ProductCard = memo(function ProductCard({
	product,
}: {
	product: Product;
}) {
	return (
		<div className="rounded border p-4">
			<img src={product.image} alt={product.name} />
			<h3>{product.name}</h3>
			<p>${product.price}</p>
		</div>
	);
});

// With custom comparison
const DataGrid = memo(
	function DataGrid({ rows, columns }: DataGridProps) {
		// expensive render
		return <table>{/* ... */}</table>;
	},
	(prev, next) =>
		prev.rows.length === next.rows.length &&
		prev.columns === next.columns,
);
```

---

## useMemo and useCallback

### When to actually use useMemo

```typescript
// GOOD — expensive computation
function Analytics({ data }: { data: DataPoint[] }) {
	const processed = useMemo(() => {
		return data
			.filter((d) => d.value > 0)
			.map((d) => ({ ...d, normalized: d.value / maxValue }))
			.sort((a, b) => b.normalized - a.normalized);
	}, [data]);

	return <Chart data={processed} />;
}

// BAD — trivial computation (overhead > savings)
function Greeting({ name }: { name: string }) {
	const message = useMemo(() => `Hello, ${name}!`, [name]);
	return <p>{message}</p>;
}
```

### When to actually use useCallback

```typescript
// GOOD — callback passed to memoized child
function Parent() {
	const [items, setItems] = useState<Item[]>([]);

	const handleDelete = useCallback((id: string) => {
		setItems((prev) => prev.filter((item) => item.id !== id));
	}, []);

	return <MemoizedList items={items} onDelete={handleDelete} />;
}

// BAD — callback not passed to memoized child
function Form() {
	const handleSubmit = useCallback(() => {
		// doesn't matter — child isn't memoized
	}, []);

	return <button onClick={handleSubmit}>Submit</button>;
}
```

### Rule of thumb
- **useMemo**: Only for expensive computations or referential equality needed by deps
- **useCallback**: Only when passing to `memo`-wrapped children or as dependency

---

## Code Splitting

### React.lazy

```typescript
import { lazy, Suspense } from "react";

// Split by route
const Dashboard = lazy(() => import("./pages/Dashboard"));
const Settings = lazy(() => import("./pages/Settings"));
const AdminPanel = lazy(() => import("./pages/AdminPanel"));

function App() {
	return (
		<Suspense fallback={<PageSkeleton />}>
			<Routes>
				<Route path="/dashboard" element={<Dashboard />} />
				<Route path="/settings" element={<Settings />} />
				<Route path="/admin" element={<AdminPanel />} />
			</Routes>
		</Suspense>
	);
}

// Split by feature
const HeavyEditor = lazy(() => import("./components/HeavyEditor"));

function DocumentPage() {
	const [editing, setEditing] = useState(false);

	return (
		<div>
			<button onClick={() => setEditing(true)}>Edit</button>
			{editing && (
				<Suspense fallback={<EditorSkeleton />}>
					<HeavyEditor />
				</Suspense>
			)}
		</div>
	);
}
```

### Named exports with lazy

```typescript
// utils/lazyNamed.ts
export function lazyNamed<T extends Record<string, React.ComponentType>>(
	factory: () => Promise<T>,
	name: keyof T,
) {
	return lazy(() =>
		factory().then((module) => ({ default: module[name] as React.ComponentType })),
	);
}

// Usage
const UserAvatar = lazyNamed(
	() => import("./components/User"),
	"UserAvatar",
);
```

---

## Image Optimization

### Next.js Image

```typescript
import Image from "next/image";

function Hero() {
	return (
		<Image
			src="/hero.jpg"
			alt="Hero banner"
			width={1200}
			height={630}
			priority // LCP image — preload
			sizes="100vw"
			quality={85}
		/>
	);
}

function ProductImage({ src, name }: { src: string; name: string }) {
	return (
		<Image
			src={src}
			alt={name}
			width={400}
			height={400}
			sizes="(max-width: 768px) 100vw, 400px"
			loading="lazy" // Below the fold
			placeholder="blur"
			blurDataURL="data:image/jpeg;base64,..."
		/>
	);
}
```

### Rules
- **LCP images**: Always add `priority`
- **Below fold**: Use `loading="lazy"` (default)
- **Always set sizes**: Prevents layout shift
- **Use responsive sizes**: `(max-width: 768px) 100vw, 50vw`

---

## Font Optimization

```typescript
// app/layout.tsx
import { Inter } from "next/font/google";

const inter = Inter({
	subsets: ["latin"],
	display: "swap", // Prevent FOIT
	variable: "--font-inter",
});

export default function RootLayout({
	children,
}: {
	children: React.ReactNode;
}) {
	return (
		<html lang="en" className={inter.variable}>
			<body>{children}</body>
		</html>
	);
}
```

---

## Bundle Analysis

### Vite

```typescript
// vite.config.ts
import { visualizer } from "rollup-plugin-visualizer";

export default defineConfig({
	plugins: [
		visualizer({
			open: true,
			gzipSize: true,
		}),
	],
	build: {
		rollupOptions: {
			output: {
				manualChunks: {
					vendor: ["react", "react-dom"],
					router: ["react-router-dom"],
					query: ["@tanstack/react-query"],
				},
			},
		},
	},
});
```

### Next.js

```bash
ANALYZE=true pnpm build
```

```typescript
// next.config.ts
import bundleAnalyzer from "@next/bundle-analyzer";

const withBundleAnalyzer = bundleAnalyzer({
	enabled: process.env.ANALYZE === "true",
});

export default withBundleAnalyzer({
	// config
});
```

---

## Virtualization

For long lists, only render visible items:

```typescript
import { useVirtualizer } from "@tanstack/react-virtual";

function VirtualList({ items }: { items: Item[] }) {
	const parentRef = useRef<HTMLDivElement>(null);

	const virtualizer = useVirtualizer({
		count: items.length,
		getScrollElement: () => parentRef.current,
		estimateSize: () => 50, // estimated row height
		overscan: 5,
	});

	return (
		<div ref={parentRef} style={{ height: "400px", overflow: "auto" }}>
			<div
				style={{
					height: `${virtualizer.getTotalSize()}px`,
					position: "relative",
				}}
			>
				{virtualizer.getVirtualItems().map((virtualRow) => (
					<div
						key={virtualRow.key}
						style={{
							position: "absolute",
							top: 0,
							left: 0,
							width: "100%",
							height: `${virtualRow.size}px`,
							transform: `translateY(${virtualRow.start}px)`,
						}}
					>
						{items[virtualRow.index]!.name}
					</div>
				))}
			</div>
		</div>
	);
}
```

---

## React DevTools Profiler

### How to profile

1. Open React DevTools > Profiler tab
2. Click Record, interact with the app, click Stop
3. Analyze:
   - **Flamegraph**: Shows component render tree with timing
   - **Ranked**: Components sorted by render time
   - **Why did this render?**: Enable in settings

### Common findings
- Component re-renders with same props → add `memo`
- Parent re-render cascading to children → push state down
- Context change re-renders everything → split contexts
- Expensive render on every frame → add `useMemo`

---

## Performance Checklist

- [ ] LCP image has `priority` attribute
- [ ] Images have explicit `width`/`height` or `sizes`
- [ ] Fonts use `display: "swap"`
- [ ] Heavy components are code-split with `lazy`
- [ ] Long lists use virtualization
- [ ] `React.memo` on expensive, frequently re-rendered components
- [ ] Bundle analyzed — no unnecessary large dependencies
- [ ] Server Components used where possible (zero client JS)
- [ ] Parallel data fetching with `Promise.all`
- [ ] No layout shift (CLS) from dynamic content

---

## Links

- [web.dev — Core Web Vitals](https://web.dev/articles/vitals)
- [React — Optimizing Performance](https://react.dev/learn/render-and-commit)
- [Next.js — Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)
- [TanStack Virtual](https://tanstack.com/virtual/latest)
