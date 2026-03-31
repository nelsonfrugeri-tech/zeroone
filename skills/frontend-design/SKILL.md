---
name: frontend-design
description: |
  Skill de design frontend, UI/UX e visual design — foco em elegancia, usabilidade, acessibilidade e estetica estado da arte.
  Cobre: design systems, color theory (OKLCH), typography, layout, motion/animation, UX patterns, accessibility (WCAG 2.2), visual trends, component libraries, e iconografia.
  Use quando: (1) Projetar interfaces elegantes e acessíveis, (2) Escolher paletas, tipografia e spacing, (3) Aplicar patterns de UX modernos, (4) Garantir acessibilidade WCAG 2.2.
  Triggers: /frontend-design, /design, /ux, UI design, visual design, color palette, typography, accessibility, UX patterns.
---

# Frontend Design Skill - UI/UX & Visual Design Knowledge Base

## Propósito

Esta skill é a **biblioteca de conhecimento** para design frontend estado da arte (2026).
Ela complementa a `arch-ts` skill (arquitetura tecnica) com a camada de **taste e elegancia**.

**Quem usa esta skill:**
- Agent `dev-ts` -> ao construir interfaces bonitas e acessíveis
- Agent `review-ts` -> ao revisar qualidade visual e UX
- Voce diretamente -> quando precisar de referencia de design

**O que esta skill contem:**
- Design systems (headless + Tailwind + shadcn/ui)
- Color theory (OKLCH, semantic tokens, dark mode)
- Typography (fluid clamp(), variable fonts, font pairing)
- Layout (container queries, subgrid, :has(), 8px grid)
- Motion (Motion library, View Transitions, prefers-reduced-motion)
- UX patterns (skeleton screens, optimistic UI, command palettes)
- Accessibility (WCAG 2.2, APCA, focus-visible, aria)
- Visual trends 2026 (bento grids, glassmorphism, grain)
- Icons & images (Lucide, AVIF/WebP, picture element)
- Component libraries (shadcn/ui ecosystem)

**O que esta skill NÃO contem:**
- Arquitetura tecnica TypeScript/React (isso esta em `arch-ts`)
- State management, data fetching (isso esta em `arch-ts`)
- Workflow de execução — isso esta nos agents

---

## Filosofia

### Design e Engineering sao inseparaveis

**Belo NÃO e suficiente.** Uma interface deve ser:
1. **Acessivel** — WCAG 2.2 AA minimo, APCA para contraste
2. **Performante** — 60fps animations, lazy loading, optimized images
3. **Consistente** — design tokens, not ad-hoc values
4. **Responsiva** — container queries > media queries
5. **Inclusiva** — prefers-reduced-motion, prefers-color-scheme, focus-visible

### Princípios Fundamentais

**1. Tokens, não valores magicos**
- Toda cor, spacing, font-size vem de um token
- Nunca `color: #3b82f6` — sempre `color: var(--color-primary)`
- Nunca `padding: 12px` — sempre `p-3` (Tailwind) ou `var(--space-3)`

**2. OKLCH é o novo padrao**
- Perceptualmente uniforme (L=50 e sempre o mesmo brilho visual)
- P3 gamut (cores mais vibrantes que sRGB)
- Tailwind v4 ja usa OKLCH internamente
- HSL esta morto para design systems serios

**3. Headless primeiro**
- Radix UI / Base UI para comportamento e acessibilidade
- Tailwind para styling
- shadcn/ui como acelerador (copy-paste, não dependencia)
- Voce controla tudo, não luta contra o framework

**4. Motion com proposito**
- Animacao não e decoração — comunica estado, guia atenção
- Spring physics > linear/ease — se comporta como o mundo real
- SEMPRE respeite `prefers-reduced-motion`
- Menos e mais: micro-interactions > animações grandiosas

**5. Dark mode não e afterthought**
- Design dark-first, adapte para light
- OKLCH simplifica: ajuste L (lightness) axis
- Teste AMBOS temas em cada componente

---

## 1. Design Systems

**Abordagem:** Headless primitives + utility styling + copy-paste components.

A stack canonica em 2026:

```
Radix UI (primitives: Dialog, Dropdown, Tooltip, etc.)
   +
Tailwind CSS v4 (styling: utility-first, CSS-first config)
   +
shadcn/ui (pre-built components: copy into your project)
   =
Your Design System (customizado, acessível, bonito)
```

### Por que headless?

```tsx
// Radix Dialog: comportamento + a11y built-in, você controla o visual
import * as Dialog from "@radix-ui/react-dialog";

export function Modal({ children, trigger }: ModalProps) {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>{trigger}</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/50 backdrop-blur-sm" />
        <Dialog.Content className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-xl bg-surface p-6 shadow-xl">
          <Dialog.Title className="text-lg font-semibold">Title</Dialog.Title>
          {children}
          <Dialog.Close asChild>
            <button className="absolute right-4 top-4" aria-label="Close">
              <X className="size-4" />
            </button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

### Tailwind v4 — CSS-first config

```css
/* app.css — Tailwind v4: no more tailwind.config.js */
@import "tailwindcss";

@theme {
  --color-surface: oklch(0.98 0 0);
  --color-surface-dark: oklch(0.15 0 0);
  --color-primary: oklch(0.65 0.25 264);
  --color-primary-hover: oklch(0.60 0.25 264);

  --font-sans: "Inter Variable", system-ui, sans-serif;
  --font-mono: "JetBrains Mono Variable", monospace;

  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
}
```

**Referência:** [references/components/shadcn-ecosystem.md](references/components/shadcn-ecosystem.md)

---

## 2. Color Theory — OKLCH

**OKLCH** é o color space perceptualmente uniforme adotado pelo Tailwind v4.

```css
/* OKLCH syntax: oklch(Lightness Chroma Hue) */
/* L: 0-1 (dark to light), C: 0-0.4 (gray to vivid), H: 0-360 (hue wheel) */

:root {
  /* Primitivos: a paleta completa */
  --blue-50: oklch(0.97 0.01 264);
  --blue-100: oklch(0.93 0.03 264);
  --blue-500: oklch(0.65 0.25 264);
  --blue-900: oklch(0.30 0.12 264);

  /* Semanticos: o que os primitivos significam */
  --color-primary: var(--blue-500);
  --color-bg: oklch(0.99 0 0);
  --color-text: oklch(0.15 0 0);
}

/* Dark mode: inverta o L axis */
[data-theme="dark"] {
  --color-bg: oklch(0.13 0 0);
  --color-text: oklch(0.93 0 0);
}
```

### Por que OKLCH > HSL?

| Aspecto | HSL | OKLCH |
|---------|-----|-------|
| Uniformidade perceptual | Não (hsl(60,100%,50%) parece mais claro que hsl(240,100%,50%)) | Sim (L=0.5 e sempre o mesmo brilho) |
| Gamut | sRGB apenas | P3 (mais cores em displays modernos) |
| Dark mode | Trabalhoso (ajustar cada cor) | Simples (ajustar L axis) |
| Tailwind v4 | Legado | Nativo |

**Referência:** [references/color/oklch.md](references/color/oklch.md)
**Referência:** [references/color/semantic-tokens.md](references/color/semantic-tokens.md)
**Referência:** [references/color/dark-mode.md](references/color/dark-mode.md)

---

## 3. Typography

**Fluid typography** com `clamp()` elimina breakpoints para font-size.

```css
:root {
  /* clamp(min, preferred, max) */
  --text-sm: clamp(0.8rem, 0.75rem + 0.25vw, 0.875rem);
  --text-base: clamp(1rem, 0.925rem + 0.375vw, 1.125rem);
  --text-lg: clamp(1.125rem, 1rem + 0.625vw, 1.375rem);
  --text-xl: clamp(1.25rem, 1.1rem + 0.75vw, 1.5rem);
  --text-2xl: clamp(1.5rem, 1.25rem + 1.25vw, 2rem);
  --text-3xl: clamp(1.875rem, 1.5rem + 1.875vw, 2.5rem);
  --text-4xl: clamp(2.25rem, 1.75rem + 2.5vw, 3.5rem);
}

h1 { font-size: var(--text-4xl); }
h2 { font-size: var(--text-3xl); }
p  { font-size: var(--text-base); }
```

### Variable fonts

```css
@font-face {
  font-family: "Inter Variable";
  src: url("/fonts/InterVariable.woff2") format("woff2");
  font-weight: 100 900; /* full axis range */
  font-display: swap;
}

/* Animate font-weight on hover */
.nav-link {
  font-variation-settings: "wght" 400;
  transition: font-variation-settings 200ms ease;
}
.nav-link:hover {
  font-variation-settings: "wght" 600;
}
```

### Proven pairings (2026)

| Heading | Body | Vibe |
|---------|------|------|
| Inter Variable | Inter Variable | Clean, neutral, SaaS |
| Instrument Serif | Inter Variable | Editorial, elegant |
| Space Grotesk | DM Sans | Tech, modern |
| Fraunces Variable | Source Sans 3 | Warm, friendly |
| Geist Sans | Geist Mono | Developer tools |

**Referência:** [references/typography/fluid-typography.md](references/typography/fluid-typography.md)
**Referência:** [references/typography/variable-fonts.md](references/typography/variable-fonts.md)
**Referência:** [references/typography/font-pairing.md](references/typography/font-pairing.md)

---

## 4. Layout

**Container queries** sao a revolução: componentes responsivos ao seu container, não ao viewport.

```css
/* Container query: card adapta ao espaco disponível */
.card-wrapper {
  container-type: inline-size;
  container-name: card;
}

@container card (min-width: 400px) {
  .card { display: grid; grid-template-columns: 200px 1fr; }
}

@container card (max-width: 399px) {
  .card { display: flex; flex-direction: column; }
}
```

### Subgrid

```css
/* Subgrid: filhos herdam o grid do pai */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

.product-card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3; /* image, title, price aligned across all cards */
}
```

### :has() selector

```css
/* :has() — parent selector, CSS's most wanted feature */
.form-group:has(input:invalid) {
  --border-color: oklch(0.65 0.25 25); /* red */
}

.card:has(img) {
  grid-template-rows: 200px 1fr; /* layout with image */
}

.card:not(:has(img)) {
  grid-template-rows: 1fr; /* layout without image */
}
```

### 8px grid

```
4px  = micro spacing (icon padding, inline gaps)
8px  = base unit (p-2 in Tailwind)
16px = component padding (p-4)
24px = section gaps (gap-6)
32px = major spacing (p-8)
48px = section padding (p-12)
64px = hero spacing (p-16)
```

**Referência:** [references/layout/modern-css-layout.md](references/layout/modern-css-layout.md)
**Referência:** [references/layout/spacing-system.md](references/layout/spacing-system.md)

---

## 5. Motion

**Motion** (formerly Framer Motion) é a biblioteca padrão para animações React.

```tsx
import { motion, AnimatePresence } from "motion/react";

// Layout animation: smooth reorder
function TodoList({ items }: { items: Todo[] }) {
  return (
    <AnimatePresence>
      {items.map((item) => (
        <motion.div
          key={item.id}
          layout
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, x: -100 }}
          transition={{ type: "spring", stiffness: 500, damping: 30 }}
          className="rounded-lg border bg-surface p-4"
        >
          {item.text}
        </motion.div>
      ))}
    </AnimatePresence>
  );
}
```

### prefers-reduced-motion (NON-NEGOTIABLE)

```css
/* CSS approach */
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
// React hook approach
function useReducedMotion(): boolean {
  const [prefersReduced, setPrefersReduced] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setPrefersReduced(mq.matches);
    const handler = (e: MediaQueryListEvent) => setPrefersReduced(e.matches);
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, []);

  return prefersReduced;
}
```

### Decision tree

```
Need animation?
  |
  +-- Simple state transition? --> CSS transition
  |
  +-- Keyframe sequence? --> CSS @keyframes
  |
  +-- Layout animation / gesture / orchestration? --> Motion (Framer)
  |
  +-- Complex timeline / scroll-driven? --> GSAP
  |
  +-- Page transition? --> View Transitions API
```

**Referência:** [references/motion/animation-guide.md](references/motion/animation-guide.md)

---

## 6. UX Patterns

### Skeleton screens

```tsx
function CardSkeleton() {
  return (
    <div className="animate-pulse rounded-xl border bg-surface p-4">
      <div className="mb-4 h-48 rounded-lg bg-muted" />
      <div className="mb-2 h-4 w-3/4 rounded bg-muted" />
      <div className="h-4 w-1/2 rounded bg-muted" />
    </div>
  );
}

// Shimmer variant with Tailwind
function Shimmer({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded bg-muted",
        "before:absolute before:inset-0",
        "before:-translate-x-full before:animate-[shimmer_1.5s_infinite]",
        "before:bg-gradient-to-r before:from-transparent before:via-white/20 before:to-transparent",
        className
      )}
    />
  );
}
```

### Optimistic UI

```tsx
// TanStack Query optimistic update
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ["todos"] });
    const previous = queryClient.getQueryData(["todos"]);
    queryClient.setQueryData(["todos"], (old: Todo[]) =>
      old.map((t) => (t.id === newTodo.id ? { ...t, ...newTodo } : t))
    );
    return { previous };
  },
  onError: (_err, _newTodo, context) => {
    queryClient.setQueryData(["todos"], context?.previous);
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ["todos"] });
  },
});
```

### Command palette (cmdk)

```tsx
import { Command } from "cmdk";

function CommandPalette() {
  return (
    <Command className="rounded-xl border shadow-2xl">
      <Command.Input placeholder="Type a command or search..." className="border-b px-4 py-3" />
      <Command.List className="max-h-80 overflow-y-auto p-2">
        <Command.Empty>No results found.</Command.Empty>
        <Command.Group heading="Actions">
          <Command.Item onSelect={() => navigate("/new")}>
            <Plus className="mr-2 size-4" /> New Document
          </Command.Item>
          <Command.Item onSelect={() => setTheme("dark")}>
            <Moon className="mr-2 size-4" /> Toggle Dark Mode
          </Command.Item>
        </Command.Group>
      </Command.List>
    </Command>
  );
}
```

**Referência:** [references/ux-patterns/loading-states.md](references/ux-patterns/loading-states.md)
**Referência:** [references/ux-patterns/interaction-patterns.md](references/ux-patterns/interaction-patterns.md)

---

## 7. Accessibility — WCAG 2.2

**Baseline:** WCAG 2.2 Level AA. Não e opcional.

### Key criteria

| Criterion | What | Implementation |
|-----------|------|----------------|
| 2.4.7 Focus Visible | Focus indicator visível | `:focus-visible` outline |
| 2.4.11 Focus Not Obscured (Min) | Focus não escondido | `scroll-margin`, z-index |
| 2.5.8 Target Size (Min) | Touch target >= 24x24px | `min-w-6 min-h-6` |
| 1.4.3 Contrast (Min) | Texto legivel | APCA >= Lc 60 |
| 4.1.2 Name, Role, Value | Semântica correta | Semantic HTML + ARIA |

### Focus-visible (the correct approach)

```css
/* Global focus style */
:focus-visible {
  outline: 2px solid oklch(0.65 0.25 264);
  outline-offset: 2px;
  border-radius: var(--radius-sm);
}

/* Remove default focus ring (only shows on keyboard nav) */
:focus:not(:focus-visible) {
  outline: none;
}

/* Ensure focus is never obscured by sticky headers */
:target {
  scroll-margin-top: 5rem;
}
```

### Semantic HTML > ARIA

```tsx
// BAD: div soup with ARIA
<div role="button" tabIndex={0} onClick={handleClick} aria-label="Submit">
  Submit
</div>

// GOOD: semantic HTML
<button onClick={handleClick}>Submit</button>

// RULE: The first rule of ARIA is don't use ARIA
// if a native HTML element can do the job.
```

**Referência:** [references/accessibility/wcag-2-2.md](references/accessibility/wcag-2-2.md)

---

## 8. Visual Trends 2026

### Bento grids

```css
.bento {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 200px);
  gap: 1rem;
}

.bento-featured {
  grid-column: span 2;
  grid-row: span 2;
}

.bento-item {
  border-radius: var(--radius-xl);
  background: oklch(0.97 0.005 264);
  padding: 1.5rem;
  overflow: hidden;
}
```

### Glassmorphism (with taste)

```css
.glass {
  background: oklch(1 0 0 / 0.6);
  backdrop-filter: blur(16px) saturate(180%);
  border: 1px solid oklch(1 0 0 / 0.2);
  border-radius: var(--radius-xl);
  box-shadow: 0 8px 32px oklch(0 0 0 / 0.08);
}

/* Dark mode glass */
[data-theme="dark"] .glass {
  background: oklch(0.2 0 0 / 0.5);
  border-color: oklch(1 0 0 / 0.1);
}
```

### Grain texture

```css
.grain::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.05'/%3E%3C/svg%3E");
  pointer-events: none;
  z-index: 1;
  border-radius: inherit;
}
```

**Referência:** [references/visual/trends-2026.md](references/visual/trends-2026.md)

---

## 9. Icons & Images

### Icons: Lucide (default)

```tsx
import { Search, Menu, X, ChevronRight } from "lucide-react";

// Consistent icon component
function Icon({ icon: IconComponent, size = 16, ...props }: IconProps) {
  return <IconComponent size={size} strokeWidth={1.5} {...props} />;
}
```

### Images: AVIF > WebP > JPEG

```tsx
<picture>
  <source srcSet="/hero.avif" type="image/avif" />
  <source srcSet="/hero.webp" type="image/webp" />
  <img
    src="/hero.jpg"
    alt="Descriptive alt text"
    width={1200}
    height={630}
    loading="lazy"
    decoding="async"
    className="rounded-xl object-cover"
  />
</picture>
```

**Referência:** [references/components/icons-images.md](references/components/icons-images.md)

---

## 10. Component Libraries — shadcn/ui

shadcn/ui não é uma dependencia — é um **acelerador**. Voce copia os componentes, eles sao seus.

```bash
# Initialize shadcn/ui
npx shadcn@latest init

# Add components (copies to your project)
npx shadcn@latest add button card dialog dropdown-menu
```

### cn() utility (essential)

```ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}
```

### Animation layers on top of shadcn/ui

| Library | Purpose | When to use |
|---------|---------|-------------|
| shadcn/ui | Base components | Always (foundation) |
| Aceternity UI | Animated components | Hero sections, landing pages |
| Magic UI | Micro-interactions | Buttons, cards, effects |
| Motion (Framer) | Custom animations | Complex sequences |

**Referência:** [references/components/shadcn-ecosystem.md](references/components/shadcn-ecosystem.md)

---

## Ferramentas Essenciais

| Categoria | Ferramenta | Propósito |
|-----------|------------|-----------|
| Styling | **Tailwind CSS v4** | Utility-first CSS, OKLCH nativo |
| Primitives | **Radix UI** | Headless accessible components |
| Components | **shadcn/ui** | Copy-paste component library |
| Icons | **Lucide** | Beautiful consistent icon set |
| Motion | **Motion (Framer)** | React animation library |
| Color | **oklch.com** | OKLCH color picker |
| Color | **Realtime Colors** | Full palette generator |
| Typography | **Fluid Type Scale** | clamp() calculator |
| A11y | **axe-core** | Accessibility testing |
| A11y | **Playwright a11y** | CI accessibility tests |
| Images | **sharp** | Image optimization (AVIF/WebP) |
| Fonts | **fontsource** | Self-hosted fonts |
| Command | **cmdk** | Command palette component |
| Toast | **Sonner** | Toast notifications |

---

## Workflow Recomendado

```
TOKENS -> LAYOUT -> COMPONENTS -> MOTION -> A11Y -> POLISH
```

1. **Tokens**: Definir paleta OKLCH, typography scale, spacing system
2. **Layout**: Container queries, grid system, responsive structure
3. **Components**: shadcn/ui base, customize com tokens, compose
4. **Motion**: Adicionar animações com proposito (state, feedback, delight)
5. **A11y**: Testar focus, contrast, screen reader, target size
6. **Polish**: Grain, gradients, shadows, micro-interactions, dark mode

---

## Referências por Domínio

### Color
- [references/color/oklch.md](references/color/oklch.md) - OKLCH color space em profundidade
- [references/color/semantic-tokens.md](references/color/semantic-tokens.md) - Token system two-tier
- [references/color/dark-mode.md](references/color/dark-mode.md) - Dark mode design-first

### Typography
- [references/typography/fluid-typography.md](references/typography/fluid-typography.md) - clamp() e fluid type
- [references/typography/variable-fonts.md](references/typography/variable-fonts.md) - Variable fonts
- [references/typography/font-pairing.md](references/typography/font-pairing.md) - Font pairing

### Layout
- [references/layout/modern-css-layout.md](references/layout/modern-css-layout.md) - Container queries, subgrid, :has()
- [references/layout/spacing-system.md](references/layout/spacing-system.md) - 8px grid, spacing tokens

### Motion
- [references/motion/animation-guide.md](references/motion/animation-guide.md) - Animation decision tree

### UX Patterns
- [references/ux-patterns/loading-states.md](references/ux-patterns/loading-states.md) - Skeletons, optimistic UI
- [references/ux-patterns/interaction-patterns.md](references/ux-patterns/interaction-patterns.md) - cmdk, Sonner, modals

### Accessibility
- [references/accessibility/wcag-2-2.md](references/accessibility/wcag-2-2.md) - WCAG 2.2 implementation guide

### Components
- [references/components/shadcn-ecosystem.md](references/components/shadcn-ecosystem.md) - shadcn/ui full ecosystem
- [references/components/icons-images.md](references/components/icons-images.md) - Lucide, AVIF, optimization

### Visual
- [references/visual/trends-2026.md](references/visual/trends-2026.md) - Bento, glass, grain, gradients
