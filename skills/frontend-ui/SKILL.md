---
name: frontend-ui
description: |
  Frontend UI/UX design knowledge base (2026). Covers OKLCH color theory (perceptual uniformity,
  semantic tokens, dark mode design), fluid typography with clamp(), variable fonts, modern CSS
  layout (container queries, subgrid, :has()), 8px spacing grid, Motion animation library (spring
  physics, prefers-reduced-motion), UX patterns (skeleton screens, optimistic UI, command palette),
  accessibility (WCAG 2.2 AA, APCA contrast, focus-visible, semantic HTML), design system stack
  (Radix UI primitives + Tailwind CSS v4 + shadcn/ui), visual trends 2026 (bento grids,
  glassmorphism, grain texture), and icon/image optimization.
  Use when: (1) Designing interfaces, (2) Choosing color palettes and typography, (3) Implementing
  animations, (4) Ensuring WCAG 2.2 accessibility, (5) Building design system components.
  Triggers: /frontend-ui, /ui, /ux, design, color, typography, animation, accessibility, OKLCH.
type: knowledge
---

# Frontend UI — Knowledge Base

## Purpose

This skill is the knowledge base for frontend UI/UX design (2026).
It covers visual design, layout, motion, accessibility, and the design system stack.

**What this skill contains:**
- OKLCH color theory (perceptual uniformity, semantic tokens, dark mode)
- Fluid typography with `clamp()` and variable fonts
- Modern CSS layout (container queries, subgrid, `:has()`)
- 8px spacing grid
- Motion animations (Motion library, decision tree, reduced motion)
- UX patterns (skeleton screens, optimistic UI, command palette)
- Accessibility (WCAG 2.2, APCA, focus-visible, semantic HTML)
- Design system stack (Radix UI + Tailwind v4 + shadcn/ui)
- Visual trends 2026 (bento grids, glassmorphism, grain)
- Icons and image optimization

---

## Fundamental Principles

1. **Tokens, not magic values** — every color, spacing, and font-size comes from a design token
2. **OKLCH is the standard** — perceptually uniform, P3 gamut, built into Tailwind v4
3. **Headless primitives first** — Radix UI for behavior + accessibility, Tailwind for styling
4. **Motion with purpose** — animations communicate state, they are not decoration
5. **Accessibility is non-negotiable** — WCAG 2.2 AA minimum, test with keyboard and screen reader

---

## 1. OKLCH Color Theory

### Why OKLCH over HSL

| Aspect | HSL | OKLCH |
|--------|-----|-------|
| Perceptual uniformity | No — same L looks different across hues | Yes — L=0.5 always appears equally bright |
| Color gamut | sRGB only | P3 (more vivid on modern displays) |
| Dark mode | Adjust each color manually | Adjust L axis systematically |
| Tailwind v4 | Legacy | Native support |

### Token System (Two-Tier)

```css
/* Tier 1: Primitives (the full palette) */
:root {
  --blue-50:  oklch(0.97 0.01 264);
  --blue-100: oklch(0.93 0.03 264);
  --blue-200: oklch(0.87 0.07 264);
  --blue-500: oklch(0.65 0.25 264);
  --blue-700: oklch(0.45 0.20 264);
  --blue-900: oklch(0.30 0.12 264);

  --neutral-50:  oklch(0.98 0 0);
  --neutral-100: oklch(0.95 0 0);
  --neutral-900: oklch(0.13 0 0);
}

/* Tier 2: Semantic tokens (what the primitives mean) */
:root {
  --color-bg:           var(--neutral-50);
  --color-bg-elevated:  oklch(1 0 0);
  --color-surface:      oklch(0.97 0 0);
  --color-muted:        var(--neutral-100);
  --color-text:         var(--neutral-900);
  --color-text-muted:   oklch(0.45 0 0);
  --color-primary:      var(--blue-500);
  --color-primary-hover: var(--blue-700);
  --color-border:       oklch(0.88 0 0);
}

/* Dark mode: flip L axis */
[data-theme="dark"] {
  --color-bg:           var(--neutral-900);
  --color-bg-elevated:  oklch(0.18 0 0);
  --color-surface:      oklch(0.15 0 0);
  --color-muted:        oklch(0.22 0 0);
  --color-text:         oklch(0.93 0 0);
  --color-text-muted:   oklch(0.65 0 0);
  --color-border:       oklch(0.28 0 0);
}
```

### Tailwind v4 CSS-First Config

```css
@import "tailwindcss";

@theme {
  --color-primary:        oklch(0.65 0.25 264);
  --color-primary-hover:  oklch(0.60 0.25 264);
  --color-surface:        oklch(0.98 0 0);
  --font-sans: "Inter Variable", system-ui, sans-serif;
  --font-mono: "JetBrains Mono Variable", monospace;
  --radius-lg:  0.75rem;
  --radius-xl:  1rem;
}
```

**Reference:** [references/color-oklch.md](references/color-oklch.md)

---

## 2. Typography

### Fluid Type Scale (clamp)

```css
:root {
  /* clamp(min, preferred, max) — no breakpoints needed */
  --text-xs:   clamp(0.75rem,  0.70rem + 0.25vw, 0.8125rem);
  --text-sm:   clamp(0.875rem, 0.82rem + 0.28vw, 0.9375rem);
  --text-base: clamp(1rem,     0.93rem + 0.38vw, 1.125rem);
  --text-lg:   clamp(1.125rem, 1.02rem + 0.53vw, 1.3125rem);
  --text-xl:   clamp(1.25rem,  1.10rem + 0.75vw, 1.5625rem);
  --text-2xl:  clamp(1.5rem,   1.28rem + 1.10vw, 2rem);
  --text-3xl:  clamp(1.875rem, 1.50rem + 1.88vw, 2.75rem);
  --text-4xl:  clamp(2.25rem,  1.75rem + 2.50vw, 3.5rem);
}

/* Apply */
h1 { font-size: var(--text-4xl); font-weight: 700; line-height: 1.1; }
h2 { font-size: var(--text-3xl); font-weight: 600; line-height: 1.2; }
h3 { font-size: var(--text-2xl); font-weight: 600; line-height: 1.3; }
p  { font-size: var(--text-base); line-height: 1.6; }
```

### Variable Fonts

```css
@font-face {
  font-family: "Inter Variable";
  src: url("/fonts/InterVariable.woff2") format("woff2");
  font-weight: 100 900;
  font-display: swap;
}

/* Animate weight on hover (no layout shift) */
.nav-link {
  font-variation-settings: "wght" 400;
  transition: font-variation-settings 200ms ease;
}
.nav-link:hover { font-variation-settings: "wght" 600; }
```

### Font Pairings (2026)

| Heading | Body | Character |
|---------|------|-----------|
| Inter Variable | Inter Variable | Clean, neutral, SaaS |
| Instrument Serif | Inter Variable | Editorial, elegant |
| Space Grotesk | DM Sans | Tech, modern |
| Geist Sans | Geist Mono | Developer tools |
| Fraunces Variable | Source Sans 3 | Warm, friendly |

**Reference:** [references/typography.md](references/typography.md)

---

## 3. Modern CSS Layout

### Container Queries

```css
/* Components respond to their container, not the viewport */
.card-wrapper {
  container-type: inline-size;
  container-name: card;
}

@container card (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 1.5rem;
  }
}

@container card (max-width: 399px) {
  .card {
    display: flex;
    flex-direction: column;
  }
}
```

### Subgrid (aligned across siblings)

```css
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

.product-card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3; /* image | title | price — all aligned across cards */
}
```

### :has() Selector

```css
/* Parent selector — layout depends on children */
.card:has(img)       { grid-template-rows: 200px 1fr; }
.card:not(:has(img)) { grid-template-rows: 1fr; }

/* Form state styling */
.form-group:has(input:invalid) {
  --border-color: oklch(0.65 0.25 25);
}
```

### 8px Spacing Grid

```
4px   micro (gap inside icon, inline padding)
8px   xs (between inline elements)
12px  sm (tight component padding)
16px  md (standard component padding)
24px  lg (section gaps, card padding)
32px  xl (major spacing)
48px  2xl (section padding)
64px  3xl (hero sections)
```

**Reference:** [references/css-layout.md](references/css-layout.md)

---

## 4. Motion

### Library Decision Tree

```
Need animation?
  |
  +-- Simple state (show/hide, color, opacity) → CSS transition
  |
  +-- Keyframe sequence (loading spinner)      → CSS @keyframes
  |
  +-- Layout reorder / enter-exit / gesture    → Motion (Framer Motion)
  |
  +-- Complex timeline / scroll-driven         → GSAP
  |
  +-- Page transition                          → View Transitions API
```

### Motion Library (Spring Physics)

```tsx
import { motion, AnimatePresence } from "motion/react";

// Layout animation: smooth list reorder
function AnimatedList({ items }: { items: Item[] }): React.JSX.Element {
  return (
    <AnimatePresence initial={false}>
      {items.map((item) => (
        <motion.li
          key={item.id}
          layout
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: "auto" }}
          exit={{ opacity: 0, height: 0 }}
          transition={{ type: "spring", stiffness: 400, damping: 30 }}
          className="overflow-hidden"
        >
          {item.content}
        </motion.li>
      ))}
    </AnimatePresence>
  );
}

// Entrance animation
function FadeIn({ children }: { children: React.ReactNode }): React.JSX.Element {
  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ type: "spring", stiffness: 400, damping: 30, delay: 0.1 }}
    >
      {children}
    </motion.div>
  );
}
```

### Reduced Motion (Non-Negotiable)

```css
/* CSS: disable all animations for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

```tsx
// React hook
function useReducedMotion(): boolean {
  const [prefersReduced, setPrefersReduced] = useState(
    () => window.matchMedia("(prefers-reduced-motion: reduce)").matches,
  );
  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    const handler = (e: MediaQueryListEvent): void => setPrefersReduced(e.matches);
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, []);
  return prefersReduced;
}
```

**Reference:** [references/motion.md](references/motion.md)

---

## 5. UX Patterns

### Skeleton Screens

```tsx
function CardSkeleton(): React.JSX.Element {
  return (
    <div className="animate-pulse rounded-xl border bg-surface p-4 space-y-3">
      <div className="h-48 rounded-lg bg-muted" />
      <div className="h-4 w-3/4 rounded bg-muted" />
      <div className="h-4 w-1/2 rounded bg-muted" />
    </div>
  );
}

// Shimmer variant
function Shimmer({ className }: { className?: string }): React.JSX.Element {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded bg-muted",
        "after:absolute after:inset-0 after:-translate-x-full",
        "after:animate-[shimmer_1.5s_infinite]",
        "after:bg-gradient-to-r after:from-transparent after:via-white/20 after:to-transparent",
        className,
      )}
    />
  );
}
```

### Optimistic UI

```tsx
function useLikePost(postId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (liked: boolean) => toggleLike(postId, liked),
    onMutate: async (liked) => {
      await queryClient.cancelQueries({ queryKey: ["post", postId] });
      const previous = queryClient.getQueryData(["post", postId]);
      queryClient.setQueryData(["post", postId], (old: Post) => ({
        ...old,
        liked,
        likeCount: old.likeCount + (liked ? 1 : -1),
      }));
      return { previous };
    },
    onError: (_err, _liked, context) => {
      queryClient.setQueryData(["post", postId], context?.previous);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["post", postId] });
    },
  });
}
```

**Reference:** [references/ux-patterns.md](references/ux-patterns.md)

---

## 6. Accessibility (WCAG 2.2)

### Key WCAG 2.2 Criteria

| Criterion | Requirement | Implementation |
|-----------|-------------|----------------|
| 1.4.3 Contrast (Min) | Text contrast ratio | APCA Lc >= 60 for body text |
| 2.4.7 Focus Visible | Visible focus indicator | `:focus-visible` with 2px outline |
| 2.4.11 Focus Not Obscured | Focus not hidden | `scroll-margin`, z-index management |
| 2.5.8 Target Size (Min) | Touch target >= 24×24px | `min-w-6 min-h-6` |
| 4.1.2 Name, Role, Value | Semantic markup | Semantic HTML + ARIA only when needed |

### Focus Management

```css
/* Global focus style — keyboard navigation only */
:focus-visible {
  outline: 2px solid oklch(0.65 0.25 264);
  outline-offset: 2px;
  border-radius: var(--radius-sm, 0.25rem);
}

/* Remove default ring for mouse/touch */
:focus:not(:focus-visible) {
  outline: none;
}

/* Ensure sticky headers don't obscure focused elements */
:target,
:focus-visible {
  scroll-margin-top: 5rem;
}
```

### Semantic HTML First

```tsx
// GOOD: semantic HTML — built-in behavior and accessibility
<button type="submit" onClick={handleSubmit}>Submit</button>
<a href="/about">About</a>
<nav aria-label="Main navigation">...</nav>

// BAD: div soup — requires ARIA to compensate
<div role="button" tabIndex={0} onClick={handleSubmit}>Submit</div>

// Rule: First rule of ARIA — don't use ARIA if native HTML does the job

// When ARIA IS needed (custom widget)
<div
  role="slider"
  aria-valuemin={0}
  aria-valuemax={100}
  aria-valuenow={value}
  aria-label="Volume"
  tabIndex={0}
  onKeyDown={handleKeyDown}
/>
```

### Accessibility Testing

```typescript
// Playwright with axe-core
import AxeBuilder from "@axe-core/playwright";

test("homepage has no accessibility violations", async ({ page }) => {
  await page.goto("/");
  const results = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21aa", "wcag22aa"])
    .analyze();
  expect(results.violations).toEqual([]);
});
```

**Reference:** [references/accessibility.md](references/accessibility.md)

---

## 7. Design System Stack

### Recommended Stack

```
Radix UI (behavior + accessibility primitives)
  + Tailwind CSS v4 (utility-first styling, OKLCH, CSS-first config)
  + shadcn/ui (copy-paste components — you own the code)
  = Your Design System
```

### shadcn/ui Setup

```bash
npx shadcn@latest init
npx shadcn@latest add button card dialog dropdown-menu input label
```

### cn() Utility (Essential)

```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

// Usage
<button className={cn(
  "rounded-lg px-4 py-2 font-medium transition-colors",
  "bg-primary text-white hover:bg-primary-hover",
  isLoading && "cursor-not-allowed opacity-50",
  className,
)}>
```

### Radix UI Dialog

```tsx
import * as Dialog from "@radix-ui/react-dialog";
import { X } from "lucide-react";

interface ModalProps {
  trigger: React.ReactNode;
  title: string;
  children: React.ReactNode;
}

function Modal({ trigger, title, children }: ModalProps): React.JSX.Element {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>{trigger}</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/50 backdrop-blur-sm animate-in fade-in" />
        <Dialog.Content className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-lg rounded-xl bg-surface p-6 shadow-xl">
          <Dialog.Title className="text-lg font-semibold">{title}</Dialog.Title>
          {children}
          <Dialog.Close asChild>
            <button className="absolute right-4 top-4 rounded-sm opacity-70 hover:opacity-100" aria-label="Close">
              <X className="size-4" />
            </button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

**Reference:** [references/design-system.md](references/design-system.md)

---

## 8. Visual Trends 2026

### Bento Grid

```css
.bento {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 200px);
  gap: 1rem;
}
.bento-featured { grid-column: span 2; grid-row: span 2; }
.bento-item {
  border-radius: var(--radius-xl);
  background: oklch(0.97 0.005 264);
  padding: 1.5rem;
  overflow: hidden;
}
```

### Glassmorphism (used with taste)

```css
.glass {
  background: oklch(1 0 0 / 0.65);
  backdrop-filter: blur(16px) saturate(180%);
  border: 1px solid oklch(1 0 0 / 0.2);
  border-radius: var(--radius-xl);
  box-shadow: 0 8px 32px oklch(0 0 0 / 0.08);
}

[data-theme="dark"] .glass {
  background: oklch(0.2 0 0 / 0.5);
  border-color: oklch(1 0 0 / 0.08);
}
```

### Icons and Images

```tsx
// Icons: Lucide React (consistent, tree-shakeable)
import { Search, ChevronRight, X } from "lucide-react";
<Search className="size-4 shrink-0" strokeWidth={1.5} />

// Images: AVIF > WebP > JPEG
<picture>
  <source srcSet="/hero.avif" type="image/avif" />
  <source srcSet="/hero.webp" type="image/webp" />
  <img
    src="/hero.jpg"
    alt="Descriptive alt text — describe what the image shows"
    width={1200}
    height={630}
    loading="lazy"
    decoding="async"
    className="rounded-xl object-cover"
  />
</picture>
```

**Reference:** [references/visual-trends.md](references/visual-trends.md)

---

## Reference Files

- [references/color-oklch.md](references/color-oklch.md) — OKLCH color space, semantic tokens, dark mode
- [references/typography.md](references/typography.md) — Fluid type scale, variable fonts, font pairing
- [references/css-layout.md](references/css-layout.md) — Container queries, subgrid, :has(), spacing grid
- [references/motion.md](references/motion.md) — Animation decision tree, Motion library, reduced motion
- [references/ux-patterns.md](references/ux-patterns.md) — Skeleton screens, optimistic UI, command palette
- [references/accessibility.md](references/accessibility.md) — WCAG 2.2 implementation, APCA, axe-core
- [references/design-system.md](references/design-system.md) — Radix UI, shadcn/ui, cn() utility
- [references/visual-trends.md](references/visual-trends.md) — Bento grid, glassmorphism, grain, gradients
