# shadcn/ui Ecosystem — The Headless + Copy-Paste Architecture

## Philosophy

shadcn/ui is NOT a component library you install as a dependency.
It is a **collection of re-usable components** you copy into your project.

```
Architecture:

  Radix UI Primitives       (behavior + accessibility)
       +
  Tailwind CSS              (styling utilities)
       +
  class-variance-authority  (variant management)
       +
  clsx + tailwind-merge     (class composition)
       =
  shadcn/ui components      (copied into YOUR code)
```

### Why This Architecture Wins

| Traditional Library | shadcn/ui Approach |
|--------------------|-------------------|
| `npm install component-lib` | `npx shadcn@latest add button` |
| Black box — can't modify internals | Full source code in your project |
| Version conflicts, breaking upgrades | You own the code, update when you want |
| Global styles, CSS conflicts | Tailwind utilities, zero global CSS |
| Opinionated design | YOUR design tokens |

---

## Setup Guide

### 1. Initialize in an Existing Project

```bash
npx shadcn@latest init
```

This creates:
- `components/ui/` — where components live
- `lib/utils.ts` — the `cn()` utility
- Updates `tailwind.config` (or `app.css` for Tailwind v4)

### 2. The cn() Utility

```ts
// lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}
```

**Why both clsx AND twMerge?**
- `clsx` handles conditional classes: `clsx("base", isActive && "active")`
- `twMerge` resolves Tailwind conflicts: `twMerge("px-2 px-4")` → `"px-4"`
- Together: safe, conflict-free class composition

### 3. Add Components

```bash
# Add individual components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add input
npx shadcn@latest add label
npx shadcn@latest add select
npx shadcn@latest add sheet
npx shadcn@latest add tabs
npx shadcn@latest add toast
npx shadcn@latest add tooltip
```

Each command copies the component source into `components/ui/`.

---

## Customization Patterns

### Modifying Variants

shadcn/ui uses `class-variance-authority` (cva) for variants:

```tsx
// components/ui/button.tsx (YOUR code, fully customizable)
import { cva, type VariantProps } from "class-variance-authority";

const buttonVariants = cva(
  // Base styles
  "inline-flex items-center justify-center rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-border bg-transparent hover:bg-accent",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
        // ADD YOUR OWN variants
        brand: "bg-gradient-to-r from-primary to-secondary text-white hover:opacity-90",
        glass: "bg-white/10 backdrop-blur-lg border border-white/20 text-white hover:bg-white/20",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-lg px-8",
        xl: "h-14 rounded-xl px-10 text-base",
        icon: "size-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);
```

### Extending with Composition

```tsx
// Compose shadcn primitives into domain-specific components
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";

interface LoadingButtonProps extends React.ComponentProps<typeof Button> {
  loading?: boolean;
}

export function LoadingButton({ loading, children, disabled, ...props }: LoadingButtonProps) {
  return (
    <Button disabled={loading || disabled} {...props}>
      {loading && <Loader2 className="mr-2 size-4 animate-spin" />}
      {children}
    </Button>
  );
}
```

---

## Color Theme System

shadcn/ui uses CSS custom properties for theming:

```css
/* Tailwind v4: @theme directive */
@import "tailwindcss";

@theme {
  --color-background: oklch(1 0 0);
  --color-foreground: oklch(0.15 0 0);
  --color-card: oklch(1 0 0);
  --color-card-foreground: oklch(0.15 0 0);
  --color-primary: oklch(0.55 0.25 264);
  --color-primary-foreground: oklch(0.98 0.01 264);
  --color-secondary: oklch(0.94 0.005 264);
  --color-secondary-foreground: oklch(0.15 0 0);
  --color-muted: oklch(0.94 0.005 264);
  --color-muted-foreground: oklch(0.45 0.02 264);
  --color-accent: oklch(0.94 0.005 264);
  --color-accent-foreground: oklch(0.15 0 0);
  --color-destructive: oklch(0.55 0.22 25);
  --color-destructive-foreground: oklch(0.98 0.01 25);
  --color-border: oklch(0.87 0 0);
  --color-input: oklch(0.87 0 0);
  --color-ring: oklch(0.55 0.25 264);
  --radius-sm: 0.375rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
}
```

---

## Animation Layers

Build on top of shadcn/ui with animated component libraries:

### Aceternity UI

Hero sections, landing page effects, complex animations:

```tsx
// Aceternity-style spotlight card
function SpotlightCard({ children }: { children: React.ReactNode }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  return (
    <div
      className="group relative rounded-xl border bg-surface p-8 overflow-hidden"
      onMouseMove={(e) => {
        const rect = e.currentTarget.getBoundingClientRect();
        setPosition({ x: e.clientX - rect.left, y: e.clientY - rect.top });
      }}
    >
      {/* Spotlight effect */}
      <div
        className="pointer-events-none absolute -inset-px opacity-0
          transition-opacity duration-300 group-hover:opacity-100"
        style={{
          background: `radial-gradient(400px circle at ${position.x}px ${position.y}px,
            oklch(0.65 0.25 264 / 0.1), transparent 40%)`,
        }}
      />
      {children}
    </div>
  );
}
```

### Magic UI

Micro-interactions, buttons, cards with subtle animation:

```tsx
// Shimmer button
function ShimmerButton({ children }: { children: React.ReactNode }) {
  return (
    <button className="group relative rounded-lg bg-primary px-6 py-3
      text-primary-foreground overflow-hidden">
      <span className="relative z-10">{children}</span>
      <div className="absolute inset-0 -translate-x-full animate-[shimmer_2s_infinite]
        bg-gradient-to-r from-transparent via-white/20 to-transparent
        group-hover:animate-[shimmer_1.5s_infinite]" />
    </button>
  );
}
```

---

## When to Use Mantine Instead

shadcn/ui is best for custom design systems. But **Mantine** is better when:

| Scenario | Use shadcn/ui | Use Mantine |
|----------|-------------|-------------|
| Custom brand design | Yes | Maybe |
| Speed of development | Moderate | Fast |
| Rich data components (tables, charts) | Limited | Extensive |
| Full design system | Build your own | Built-in |
| Control over every detail | Full control | Library controls |
| Admin dashboards | Works | Better suited |

Mantine provides: DatePicker, RichTextEditor, Notifications, Spotlight,
Charts, and many components shadcn/ui doesn't have.

---

## Essential Plugins

| Package | Purpose |
|---------|---------|
| `@radix-ui/react-*` | Underlying accessible primitives |
| `class-variance-authority` | Variant management for components |
| `clsx` | Conditional class joining |
| `tailwind-merge` | Tailwind class conflict resolution |
| `cmdk` | Command palette |
| `sonner` | Toast notifications |
| `@tanstack/react-table` | Data tables |
| `@tanstack/react-virtual` | List virtualization |
| `recharts` | Charts |
| `date-fns` | Date utilities |
| `react-day-picker` | Date picker |
| `vaul` | Drawer component |

---

## Rules

1. **Copy, don't install** — shadcn/ui components live in YOUR project
2. **cn() everywhere** — use for all class composition
3. **Customize via tokens** — change CSS custom properties, not component code
4. **Add variants, don't fork** — extend cva variants instead of duplicating
5. **Radix for behavior** — let Radix handle a11y, keyboard, focus
6. **Tailwind for styling** — utility classes, no custom CSS files
