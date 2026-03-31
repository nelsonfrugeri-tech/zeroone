# Visual Trends 2026 — Bento, Glass, Grain & Beyond

## Bento Grids

The dominant layout pattern for feature showcases and landing pages.
Inspired by Apple's product pages and Japanese bento lunch boxes.

### Basic Implementation

```css
.bento {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 200px);
  gap: 1rem;
  padding: 1rem;
}

/* Named areas for semantic layout */
.bento-layout {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 200px);
  grid-template-areas:
    "featured featured  small-1  small-2"
    "featured featured  wide     wide"
    "tall     medium    medium   small-3";
  gap: 1rem;
}

.bento-featured { grid-area: featured; }
.bento-small-1  { grid-area: small-1; }
.bento-small-2  { grid-area: small-2; }
.bento-wide     { grid-area: wide; }
.bento-tall     { grid-area: tall; }
.bento-medium   { grid-area: medium; }
.bento-small-3  { grid-area: small-3; }
```

### Bento Item Styling

```css
.bento-item {
  border-radius: var(--radius-xl);
  background: oklch(0.97 0.005 264);
  border: 1px solid oklch(0.90 0 0);
  padding: 1.5rem;
  overflow: hidden;
  position: relative;

  /* Subtle hover */
  transition: transform 200ms ease, box-shadow 200ms ease;
}

.bento-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 24px oklch(0 0 0 / 0.06);
}

/* Dark mode */
[data-theme="dark"] .bento-item {
  background: oklch(0.17 0.005 264);
  border-color: oklch(0.25 0 0);
}
```

### React Component

```tsx
interface BentoGridProps {
  children: React.ReactNode;
  className?: string;
}

function BentoGrid({ children, className }: BentoGridProps) {
  return (
    <div className={cn(
      "grid grid-cols-2 gap-4 md:grid-cols-4 md:grid-rows-3",
      className
    )}>
      {children}
    </div>
  );
}

interface BentoItemProps {
  children: React.ReactNode;
  className?: string;
  colSpan?: 1 | 2;
  rowSpan?: 1 | 2;
}

function BentoItem({ children, className, colSpan = 1, rowSpan = 1 }: BentoItemProps) {
  return (
    <div className={cn(
      "rounded-xl border bg-card p-6 overflow-hidden transition-all",
      "hover:-translate-y-0.5 hover:shadow-lg",
      colSpan === 2 && "col-span-2",
      rowSpan === 2 && "row-span-2",
      className
    )}>
      {children}
    </div>
  );
}

// Usage
<BentoGrid>
  <BentoItem colSpan={2} rowSpan={2} className="bg-primary/5">
    <h3 className="text-xl font-bold">Featured</h3>
    <p className="text-muted-foreground">Main feature description</p>
  </BentoItem>
  <BentoItem>
    <h3 className="font-semibold">Fast</h3>
  </BentoItem>
  <BentoItem>
    <h3 className="font-semibold">Secure</h3>
  </BentoItem>
  <BentoItem colSpan={2}>
    <h3 className="font-semibold">Analytics</h3>
  </BentoItem>
</BentoGrid>
```

### Responsive Bento

```css
.bento {
  display: grid;
  gap: 1rem;

  /* Mobile: 1 column */
  grid-template-columns: 1fr;

  /* Tablet: 2 columns */
  @media (min-width: 640px) {
    grid-template-columns: repeat(2, 1fr);
  }

  /* Desktop: 4 columns */
  @media (min-width: 1024px) {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

---

## Glassmorphism — Done Right

Glassmorphism is the frosted glass effect. After years of overuse, the 2026
approach is **subtle and purposeful**.

### The Tasteful Approach

```css
.glass {
  /* Light mode */
  background: oklch(1 0 0 / 0.6);
  backdrop-filter: blur(16px) saturate(180%);
  -webkit-backdrop-filter: blur(16px) saturate(180%);
  border: 1px solid oklch(1 0 0 / 0.2);
  border-radius: var(--radius-xl);
  box-shadow:
    0 0 0 1px oklch(1 0 0 / 0.05),
    0 8px 32px oklch(0 0 0 / 0.08);
}

/* Dark mode glass */
[data-theme="dark"] .glass {
  background: oklch(0.15 0 0 / 0.5);
  border-color: oklch(1 0 0 / 0.08);
  box-shadow:
    0 0 0 1px oklch(1 0 0 / 0.03),
    0 8px 32px oklch(0 0 0 / 0.3);
}
```

### When to Use Glassmorphism

| Good For | Avoid For |
|----------|-----------|
| Navigation bars over hero images | Every card on the page |
| Floating action panels | Body content areas |
| Modal overlays | Data tables |
| Notification toasts | Form inputs |

### Apple Liquid Glass Influence (2025-2026)

Apple's visionOS and iOS introduced "Liquid Glass" — a more dynamic, depth-aware
glass effect. Key characteristics:
- Tint that adapts to background content
- Specular highlights that respond to "light source"
- Deeper blur with visible refraction

```css
/* Approximating Liquid Glass with CSS */
.liquid-glass {
  background: oklch(1 0 0 / 0.15);
  backdrop-filter: blur(40px) saturate(200%) brightness(1.1);
  border: 1px solid oklch(1 0 0 / 0.25);
  border-radius: var(--radius-2xl);
  box-shadow:
    inset 0 1px 1px oklch(1 0 0 / 0.2),
    inset 0 -1px 1px oklch(0 0 0 / 0.05),
    0 8px 40px oklch(0 0 0 / 0.1);
}
```

---

## Neubrutalism

Bold, raw, unapologetic design. Visible borders, solid shadows, bright colors.

```css
.neubrutalist-card {
  background: oklch(0.97 0.04 75);  /* warm off-white */
  border: 2px solid oklch(0.15 0 0);
  border-radius: 0; /* sharp corners! */
  padding: 1.5rem;
  box-shadow: 4px 4px 0px oklch(0.15 0 0);
  transition: transform 100ms ease, box-shadow 100ms ease;
}

.neubrutalist-card:hover {
  transform: translate(-2px, -2px);
  box-shadow: 6px 6px 0px oklch(0.15 0 0);
}

.neubrutalist-button {
  background: oklch(0.75 0.20 150);  /* bright green */
  color: oklch(0.15 0 0);
  border: 2px solid oklch(0.15 0 0);
  padding: 0.75rem 1.5rem;
  font-weight: 800;
  text-transform: uppercase;
  box-shadow: 3px 3px 0px oklch(0.15 0 0);
  cursor: pointer;
}

.neubrutalist-button:active {
  transform: translate(3px, 3px);
  box-shadow: none;
}
```

Use sparingly. Works for: portfolio sites, creative agencies, dev tools with personality.

---

## Grain Textures

Subtle noise adds depth and texture, especially on gradients and solid backgrounds.

### SVG Filter Approach (Performant)

```css
.grain {
  position: relative;
}

.grain::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.04'/%3E%3C/svg%3E");
  pointer-events: none;
  z-index: 1;
  mix-blend-mode: overlay;
  border-radius: inherit;
}
```

### Grain + Gradient

```css
.hero-gradient {
  position: relative;
  background: linear-gradient(
    135deg,
    oklch(0.55 0.25 264),
    oklch(0.55 0.20 290),
    oklch(0.50 0.22 320)
  );
  color: oklch(0.98 0 0);
}

/* Add grain on top of gradient */
.hero-gradient::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,..."); /* same SVG as above */
  pointer-events: none;
  opacity: 0.5;
  mix-blend-mode: soft-light;
}
```

---

## Gradient Techniques

### Mesh Gradients

```css
.mesh-gradient {
  background:
    radial-gradient(at 20% 30%, oklch(0.70 0.20 264) 0%, transparent 50%),
    radial-gradient(at 80% 20%, oklch(0.75 0.18 320) 0%, transparent 50%),
    radial-gradient(at 50% 80%, oklch(0.80 0.15 150) 0%, transparent 50%),
    oklch(0.97 0 0); /* base color */
}
```

### Animated Gradient Border

```css
.gradient-border {
  position: relative;
  border-radius: var(--radius-xl);
  padding: 1px; /* border width */
  background: linear-gradient(135deg, oklch(0.65 0.25 264), oklch(0.65 0.20 320));
}

.gradient-border > .content {
  background: var(--color-bg);
  border-radius: calc(var(--radius-xl) - 1px);
  padding: 1.5rem;
}

/* Animated border */
@keyframes rotate-gradient {
  from { --gradient-angle: 0deg; }
  to { --gradient-angle: 360deg; }
}

@property --gradient-angle {
  syntax: "<angle>";
  initial-value: 0deg;
  inherits: false;
}

.animated-border {
  background: conic-gradient(
    from var(--gradient-angle),
    oklch(0.65 0.25 264),
    oklch(0.65 0.20 320),
    oklch(0.65 0.25 264)
  );
  animation: rotate-gradient 3s linear infinite;
}
```

---

## Variable Font Animation

Using variable fonts for interactive text effects:

```css
/* Weight animation on scroll/hover */
.kinetic-text {
  font-family: "Inter Variable", system-ui, sans-serif;
  font-variation-settings: "wght" 400;
  transition: font-variation-settings 300ms ease;
}

.kinetic-text:hover {
  font-variation-settings: "wght" 900;
}

/* Per-character animation */
.wave-text span {
  display: inline-block;
  font-variation-settings: "wght" 400;
  animation: wave 2s ease infinite;
}

.wave-text span:nth-child(1) { animation-delay: 0s; }
.wave-text span:nth-child(2) { animation-delay: 0.1s; }
.wave-text span:nth-child(3) { animation-delay: 0.2s; }
/* ... etc */

@keyframes wave {
  0%, 100% { font-variation-settings: "wght" 400; }
  50% { font-variation-settings: "wght" 800; }
}

@media (prefers-reduced-motion: reduce) {
  .wave-text span {
    animation: none;
    font-variation-settings: "wght" 400;
  }
}
```

---

## Dark Mode as Default

2026 trend: dark mode is the PRIMARY design, light mode is the adaptation.

```css
/* Design tokens: dark-first */
:root {
  color-scheme: dark light;

  /* Dark is default */
  --color-bg: oklch(0.13 0 0);
  --color-text: oklch(0.93 0 0);
  --color-surface: oklch(0.18 0 0);
}

/* Light mode is the override */
[data-theme="light"] {
  --color-bg: oklch(0.99 0 0);
  --color-text: oklch(0.15 0 0);
  --color-surface: oklch(1 0 0);
}

/* System preference fallback */
@media (prefers-color-scheme: light) {
  :root:not([data-theme]) {
    --color-bg: oklch(0.99 0 0);
    --color-text: oklch(0.15 0 0);
    --color-surface: oklch(1 0 0);
  }
}
```

---

## Rules for Visual Trends

1. **Trends are tools, not goals** — use them when they serve the design
2. **Subtlety wins** — a hint of glass > full frost on everything
3. **Performance matters** — backdrop-filter is expensive, use sparingly
4. **Accessibility first** — grain must not reduce text contrast
5. **Dark mode first** — design for dark, adapt for light
6. **Test on real devices** — effects look different on cheap monitors
