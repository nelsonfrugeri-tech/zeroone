# Modern CSS Layout — Container Queries, Subgrid, :has() & More

## Container Queries

Container queries let components respond to their container's size, not the viewport.
This is the single biggest CSS advancement for component-based design.

### Basic Usage

```css
/* Define a containment context */
.card-wrapper {
  container-type: inline-size;
  container-name: card;
}

/* Query the container */
@container card (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 1rem;
  }
}

@container card (max-width: 399px) {
  .card {
    display: flex;
    flex-direction: column;
  }
}
```

### Container Query Units

```css
/* cqw = 1% of container width, cqh = 1% of container height */
.card-title {
  font-size: clamp(1rem, 3cqw, 1.5rem);
  /* Scales with container width, bounded */
}

.card-image {
  height: 40cqw; /* Proportional to container */
}
```

### Real Example: Responsive Product Card

```css
.product-wrapper {
  container-type: inline-size;
}

/* Narrow: stacked layout (sidebar, mobile) */
.product-card {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding: 1rem;
}

.product-image { aspect-ratio: 16 / 9; }
.product-actions { flex-direction: column; }

/* Medium: horizontal layout */
@container (min-width: 400px) {
  .product-card {
    display: grid;
    grid-template-columns: 180px 1fr;
    gap: 1.25rem;
    padding: 1.25rem;
  }

  .product-image { aspect-ratio: 1; }
  .product-actions { flex-direction: row; }
}

/* Wide: expanded layout */
@container (min-width: 600px) {
  .product-card {
    grid-template-columns: 240px 1fr;
    gap: 1.5rem;
    padding: 1.5rem;
  }

  .product-title { font-size: 1.25rem; }
}
```

---

## CSS Subgrid

Subgrid lets child elements inherit their parent's grid tracks, enabling
alignment ACROSS sibling elements.

### The Problem Subgrid Solves

```
Without subgrid:                  With subgrid:
+--------+ +--------+            +--------+ +--------+
| Image  | | Image  |            | Image  | | Image  |
+--------+ +--------+            +--------+ +--------+
| Long   | | Title  |            | Long   | | Title  |
| Title  | +--------+            | Title  | |        |  <- aligned!
+--------+ | $19.99 |            +--------+ +--------+
| $29.99 | +--------+            | $29.99 | | $19.99 |  <- aligned!
+--------+                       +--------+ +--------+
```

### Implementation

```css
/* Parent grid */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

/* Each card inherits parent's row tracks */
.product-card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3; /* image + title + price */
  gap: 0.75rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--color-border);
  padding: 1rem;
}

.product-card img {
  border-radius: var(--radius-lg);
  width: 100%;
  aspect-ratio: 4 / 3;
  object-fit: cover;
}

/* Price always aligns to the last row */
.product-price {
  align-self: end;
  font-weight: 600;
}
```

---

## :has() Selector

The most powerful CSS selector: style parents based on their children.

### Form Validation

```css
/* Highlight form group when input is invalid */
.form-group:has(input:invalid) {
  --field-border: oklch(0.65 0.22 25);
  --field-bg: oklch(0.97 0.02 25);
}

.form-group:has(input:valid) {
  --field-border: oklch(0.65 0.20 150);
}

/* Show error message only when invalid */
.form-group .error-message {
  display: none;
}

.form-group:has(input:invalid) .error-message {
  display: block;
  color: oklch(0.55 0.22 25);
}
```

### Conditional Layout

```css
/* Card layout depends on whether it has an image */
.card:has(> img) {
  grid-template-rows: 200px 1fr;
}

.card:not(:has(> img)) {
  grid-template-rows: 1fr;
}

/* Navigation expands when it contains a search input */
nav:has(input[type="search"]:focus) {
  grid-template-columns: auto 1fr auto;
}

nav:not(:has(input[type="search"]:focus)) {
  grid-template-columns: auto auto auto;
}
```

### State-Based Styling

```css
/* Style sidebar differently when any dialog is open */
body:has(dialog[open]) .sidebar {
  filter: blur(2px);
  pointer-events: none;
}

/* Page layout changes when aside is present */
main:has(+ aside) {
  grid-column: span 2;
}

main:not(:has(+ aside)) {
  grid-column: span 3;
}
```

---

## CSS Nesting

Native CSS nesting — no preprocessor needed:

```css
.card {
  border-radius: var(--radius-xl);
  border: 1px solid var(--color-border);
  padding: 1.5rem;

  & .title {
    font-size: var(--text-lg);
    font-weight: 600;
    margin-bottom: 0.5rem;
  }

  & .description {
    color: var(--color-text-secondary);
    line-height: var(--leading-relaxed);
  }

  &:hover {
    border-color: var(--color-border-hover);
    box-shadow: var(--shadow-md);
  }

  /* Compound selectors */
  &.featured {
    border-color: var(--color-primary);
  }

  /* Media queries nest too */
  @container (min-width: 400px) {
    display: grid;
    grid-template-columns: 200px 1fr;
  }
}
```

---

## Cascade Layers (@layer)

Control specificity without `!important`:

```css
/* Define layer order — later layers win */
@layer reset, base, components, utilities;

@layer reset {
  *, *::before, *::after {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
}

@layer base {
  body {
    font-family: var(--font-sans);
    color: var(--color-text);
    background: var(--color-bg);
  }
}

@layer components {
  .btn {
    padding: 0.5rem 1rem;
    border-radius: var(--radius-md);
  }
}

@layer utilities {
  /* Utilities always win over components */
  .hidden { display: none; }
  .sr-only { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0,0,0,0); }
}
```

Tailwind v4 uses `@layer` internally: `@layer base, components, utilities`.

---

## Scroll-Driven Animations

Animate based on scroll position — no JavaScript:

```css
/* Progress bar that fills as you scroll */
.reading-progress {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 3px;
  background: var(--color-primary);
  transform-origin: left;
  animation: grow-progress linear;
  animation-timeline: scroll();
}

@keyframes grow-progress {
  from { transform: scaleX(0); }
  to   { transform: scaleX(1); }
}

/* Fade in elements as they scroll into view */
.scroll-reveal {
  animation: fade-in linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 100%;
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .scroll-reveal {
    animation: none;
    opacity: 1;
  }
}
```

---

## Complete Example: Responsive Card Grid

Combining container queries + subgrid + :has() + nesting:

```css
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  padding: 1.5rem;
}

.product-card {
  container-type: inline-size;
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-xl);
  overflow: hidden;
  transition: box-shadow 200ms ease;

  &:hover {
    box-shadow: var(--shadow-lg);
  }

  &:has(.badge-sale) {
    border-color: oklch(0.65 0.22 25);
  }

  & img {
    width: 100%;
    aspect-ratio: 4 / 3;
    object-fit: cover;
  }

  & .content {
    padding: 1rem;
  }

  & .price {
    padding: 0 1rem 1rem;
    align-self: end;
    font-weight: 700;
    font-size: var(--text-lg);
  }

  @container (min-width: 500px) {
    grid-template-rows: auto;
    grid-template-columns: 200px 1fr;
    grid-row: span 1;

    & img {
      aspect-ratio: 1;
      height: 100%;
    }
  }
}
```
