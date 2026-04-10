# Tailwind CSS 4+ - Utility-First Styling

Tailwind CSS e a biblioteca recomendada para styling na maioria dos projetos.

---

## Utility-First Philosophy

Write styles directly in markup instead of separate CSS files:

```typescript
// Instead of writing CSS classes
function Card({ title, children }: { title: string; children: ReactNode }) {
	return (
		<div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
			<h3 className="text-lg font-semibold text-gray-900">{title}</h3>
			<div className="mt-4 text-gray-600">{children}</div>
		</div>
	);
}
```

---

## Responsive Design

Mobile-first breakpoints:

```typescript
// sm: 640px, md: 768px, lg: 1024px, xl: 1280px, 2xl: 1536px
<div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
	{items.map((item) => (
		<Card key={item.id} item={item} />
	))}
</div>

// Stack on mobile, side-by-side on desktop
<div className="flex flex-col md:flex-row md:gap-8">
	<aside className="w-full md:w-64">Sidebar</aside>
	<main className="flex-1">Content</main>
</div>
```

---

## Dark Mode

```typescript
// Tailwind 4 — CSS-based dark mode (prefers-color-scheme by default)
<div className="bg-white text-gray-900 dark:bg-gray-900 dark:text-gray-100">
	<h1 className="text-2xl font-bold text-gray-800 dark:text-gray-200">
		Title
	</h1>
	<p className="text-gray-600 dark:text-gray-400">Description</p>
</div>

// Toggle dark mode with class strategy
// In Tailwind 4 CSS:
// @custom-variant dark (&:where(.dark, .dark *));
```

---

## Custom Theme

Tailwind 4 uses CSS-first configuration:

```css
/* app.css */
@import "tailwindcss";

@theme {
	/* Colors */
	--color-brand-50: #eff6ff;
	--color-brand-100: #dbeafe;
	--color-brand-500: #3b82f6;
	--color-brand-600: #2563eb;
	--color-brand-700: #1d4ed8;
	--color-brand-900: #1e3a5f;

	/* Fonts */
	--font-sans: "Inter", sans-serif;
	--font-mono: "JetBrains Mono", monospace;

	/* Spacing */
	--spacing-18: 4.5rem;

	/* Border Radius */
	--radius-btn: 0.5rem;

	/* Shadows */
	--shadow-card: 0 2px 8px rgb(0 0 0 / 0.08);
}
```

Usage:
```typescript
<button className="rounded-btn bg-brand-500 px-4 py-2 text-white hover:bg-brand-600">
	Click me
</button>

<div className="shadow-card rounded-lg p-6">
	Card content
</div>
```

---

## cn() Utility

Combine class names conditionally with `clsx` + `tailwind-merge`:

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]): string {
	return twMerge(clsx(inputs));
}
```

Usage:
```typescript
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
	variant?: "primary" | "secondary" | "danger";
	size?: "sm" | "md" | "lg";
}

function Button({
	variant = "primary",
	size = "md",
	className,
	...props
}: ButtonProps) {
	return (
		<button
			className={cn(
				// Base styles
				"inline-flex items-center justify-center rounded-lg font-medium transition-colors",
				"focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2",
				"disabled:pointer-events-none disabled:opacity-50",
				// Variant
				{
					"bg-brand-600 text-white hover:bg-brand-700":
						variant === "primary",
					"border border-gray-300 bg-white text-gray-700 hover:bg-gray-50":
						variant === "secondary",
					"bg-red-600 text-white hover:bg-red-700":
						variant === "danger",
				},
				// Size
				{
					"h-8 px-3 text-sm": size === "sm",
					"h-10 px-4 text-sm": size === "md",
					"h-12 px-6 text-base": size === "lg",
				},
				// Custom overrides
				className,
			)}
			{...props}
		/>
	);
}
```

---

## Component Extraction

When utility strings get repetitive, extract to components (not CSS):

```typescript
// GOOD — extract component
function Badge({
	children,
	color = "gray",
}: {
	children: ReactNode;
	color?: "gray" | "green" | "red" | "blue";
}) {
	return (
		<span
			className={cn(
				"inline-flex items-center rounded-full px-2 py-1 text-xs font-medium",
				{
					"bg-gray-100 text-gray-700": color === "gray",
					"bg-green-100 text-green-700": color === "green",
					"bg-red-100 text-red-700": color === "red",
					"bg-blue-100 text-blue-700": color === "blue",
				},
			)}
		>
			{children}
		</span>
	);
}

// BAD — extracting to @apply (defeats the purpose of utility-first)
// .badge { @apply inline-flex items-center rounded-full ... }
```

---

## Typography Plugin

For long-form content (markdown, CMS):

```css
/* app.css */
@plugin "@tailwindcss/typography";
```

```typescript
<article className="prose prose-lg dark:prose-invert max-w-none">
	<h1>Article Title</h1>
	<p>This content is styled automatically with good typography defaults.</p>
	<pre><code>const x = 1;</code></pre>
</article>
```

---

## Animation Utilities

```typescript
// Built-in animations
<div className="animate-spin" /> // Loading spinner
<div className="animate-pulse" /> // Skeleton loader
<div className="animate-bounce" /> // Bouncing element

// Transition utilities
<button className="transition-colors duration-200 hover:bg-brand-600">
	Hover me
</button>

<div className="transition-transform duration-300 hover:scale-105">
	Card
</div>

// Custom animation in theme
// @theme { --animate-fade-in: fade-in 0.3s ease-in-out; }
// @keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }

<div className="animate-fade-in">Fades in</div>
```

---

## Tailwind with RSC

Tailwind works seamlessly with React Server Components — no runtime JS needed:

```typescript
// Server Component — zero client JS, just CSS classes
async function ProductCard({ id }: { id: string }) {
	const product = await db.product.findUnique({ where: { id } });

	return (
		<div className="rounded-lg border p-4 shadow-sm">
			<h3 className="font-semibold text-gray-900">{product?.name}</h3>
			<p className="mt-1 text-gray-500">${product?.price}</p>
		</div>
	);
}
```

---

## Links

- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Tailwind CSS 4 — Whats New](https://tailwindcss.com/blog/tailwindcss-v4)
- [tailwind-merge](https://github.com/dcastil/tailwind-merge)
- [clsx](https://github.com/lukeed/clsx)
