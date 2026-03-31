# CSS Modules

CSS Modules para quando Tailwind nao e a melhor escolha.

---

## When to Use CSS Modules Over Tailwind

- **Complex animations** with many keyframes/states
- **Third-party component styling** that requires CSS overrides
- **CSS Grid layouts** with named areas (cleaner in CSS)
- **Team preference** for traditional CSS workflow
- **Design system** with strict token-based approach in CSS

---

## Basic Usage

```css
/* Button.module.css */
.button {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 0.5rem;
	font-weight: 500;
	transition: background-color 0.2s;
}

.primary {
	background-color: var(--color-brand-600);
	color: white;
}

.primary:hover {
	background-color: var(--color-brand-700);
}

.secondary {
	border: 1px solid var(--color-gray-300);
	background-color: white;
	color: var(--color-gray-700);
}

.small {
	height: 2rem;
	padding-inline: 0.75rem;
	font-size: 0.875rem;
}

.medium {
	height: 2.5rem;
	padding-inline: 1rem;
	font-size: 0.875rem;
}
```

```typescript
// Button.tsx
import styles from "./Button.module.css";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
	variant?: "primary" | "secondary";
	size?: "small" | "medium";
}

function Button({
	variant = "primary",
	size = "medium",
	className,
	...props
}: ButtonProps) {
	const classes = [
		styles.button,
		styles[variant],
		styles[size],
		className,
	]
		.filter(Boolean)
		.join(" ");

	return <button className={classes} {...props} />;
}
```

---

## TypeScript Typing

Create type declarations for CSS modules:

```typescript
// global.d.ts (or css-modules.d.ts)
declare module "*.module.css" {
	const classes: Readonly<Record<string, string>>;
	export default classes;
}
```

For strict typing with known class names, use `typed-css-modules` or `vite-plugin-css-modules-typescript`:

```typescript
// Button.module.css.d.ts (auto-generated)
declare const styles: {
	readonly button: string;
	readonly primary: string;
	readonly secondary: string;
	readonly small: string;
	readonly medium: string;
};
export default styles;
```

---

## Composition with composes

```css
/* typography.module.css */
.heading {
	font-weight: 700;
	line-height: 1.2;
}

.body {
	font-weight: 400;
	line-height: 1.6;
}
```

```css
/* Card.module.css */
.title {
	composes: heading from "./typography.module.css";
	font-size: 1.25rem;
	color: var(--color-gray-900);
}

.description {
	composes: body from "./typography.module.css";
	font-size: 0.875rem;
	color: var(--color-gray-600);
}
```

---

## Naming Conventions

```css
/* Use camelCase for class names (easier to access in JS) */
.cardHeader { }
.cardBody { }
.isActive { }
.hasError { }

/* Or BEM-like with camelCase */
.card { }
.cardTitle { }
.cardContent { }
.cardFooter { }
```

---

## Global vs Local Scope

```css
/* By default, everything is locally scoped */
.button { } /* → .Button_button_a1b2c */

/* Explicitly global */
:global(.external-library-class) {
	/* Override third-party styles */
	color: red;
}

/* Mix local and global */
.wrapper :global(.react-select__control) {
	border-color: var(--color-brand-500);
}
```

---

## CSS Modules + CSS Variables

Combine CSS Modules with CSS custom properties for theming:

```css
/* theme.css (global) */
:root {
	--color-primary: #3b82f6;
	--color-primary-hover: #2563eb;
	--radius-md: 0.5rem;
	--shadow-sm: 0 1px 2px rgb(0 0 0 / 0.05);
}

:root.dark {
	--color-primary: #60a5fa;
	--color-primary-hover: #93bbfd;
}
```

```css
/* Card.module.css */
.card {
	border-radius: var(--radius-md);
	box-shadow: var(--shadow-sm);
	background: var(--color-surface);
}
```

---

## Links

- [Vite — CSS Modules](https://vite.dev/guide/features.html#css-modules)
- [CSS Modules Specification](https://github.com/css-modules/css-modules)
