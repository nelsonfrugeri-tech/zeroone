# Dark Mode — Design-First Approach

## Philosophy: Dark-First

Design for dark mode FIRST, then adapt to light. Why?
- Dark is harder to get right (contrast, readability, eye strain)
- If it looks great in dark, adapting to light is straightforward
- Most developer tools, creative apps, and modern SaaS default to dark
- OKLCH makes the adaptation trivial via L-axis inversion

---

## OKLCH Lightness Inversion

The core technique: in dark mode, invert the L (lightness) axis of your tokens.

```
Light mode: L = 0.95 (light bg)    -> Dark mode: L = 0.13 (dark bg)
Light mode: L = 0.15 (dark text)   -> Dark mode: L = 0.93 (light text)
Light mode: L = 0.65 (primary)     -> Dark mode: L = 0.70 (slightly brighter primary)
```

### Implementation

```css
:root {
  /* Light mode (default) */
  --color-bg: oklch(0.99 0 0);
  --color-bg-subtle: oklch(0.96 0 0);
  --color-surface: oklch(1 0 0);
  --color-text: oklch(0.15 0 0);
  --color-text-secondary: oklch(0.40 0 0);
  --color-border: oklch(0.87 0 0);

  /* Primary stays similar but may brighten slightly */
  --color-primary: oklch(0.55 0.25 264);
}

[data-theme="dark"] {
  /* Invert L axis */
  --color-bg: oklch(0.13 0 0);
  --color-bg-subtle: oklch(0.16 0 0);
  --color-surface: oklch(0.18 0 0);
  --color-text: oklch(0.93 0 0);
  --color-text-secondary: oklch(0.65 0 0);
  --color-border: oklch(0.25 0 0);

  /* Primary: bump L up for visibility on dark bg */
  --color-primary: oklch(0.70 0.22 264);
}
```

---

## Tailwind dark: Variant

Tailwind provides the `dark:` variant. Combine with CSS custom properties:

```css
/* app.css */
@import "tailwindcss";

@custom-variant dark (&:where([data-theme="dark"], [data-theme="dark"] *));
```

```tsx
// Component usage
<div className="bg-white dark:bg-gray-950">
  <h1 className="text-gray-900 dark:text-gray-50">Title</h1>
  <p className="text-gray-600 dark:text-gray-400">Description</p>
</div>

// Better approach: use semantic tokens so you don't need dark: at all
<div className="bg-background text-foreground">
  <h1 className="text-foreground">Title</h1>
  <p className="text-muted-foreground">Description</p>
</div>
```

### Theme Toggle Implementation

```tsx
"use client";

import { useEffect, useState } from "react";
import { Moon, Sun, Monitor } from "lucide-react";

type Theme = "light" | "dark" | "system";

function useTheme() {
  const [theme, setTheme] = useState<Theme>("system");

  useEffect(() => {
    const stored = localStorage.getItem("theme") as Theme | null;
    if (stored) setTheme(stored);
  }, []);

  useEffect(() => {
    const root = document.documentElement;

    if (theme === "system") {
      const mq = window.matchMedia("(prefers-color-scheme: dark)");
      root.dataset.theme = mq.matches ? "dark" : "light";

      const handler = (e: MediaQueryListEvent) => {
        root.dataset.theme = e.matches ? "dark" : "light";
      };
      mq.addEventListener("change", handler);
      return () => mq.removeEventListener("change", handler);
    }

    root.dataset.theme = theme;
    localStorage.setItem("theme", theme);
  }, [theme]);

  return { theme, setTheme };
}

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  const icons: Record<Theme, typeof Sun> = {
    light: Sun,
    dark: Moon,
    system: Monitor,
  };

  const next: Record<Theme, Theme> = {
    light: "dark",
    dark: "system",
    system: "light",
  };

  const Icon = icons[theme];

  return (
    <button
      onClick={() => setTheme(next[theme])}
      className="rounded-lg p-2 hover:bg-surface-hover"
      aria-label={`Current theme: ${theme}. Click to change.`}
    >
      <Icon className="size-5" />
    </button>
  );
}
```

---

## Common Dark Mode Mistakes

### 1. Pure Black Background

```css
/* BAD: pure black is harsh and unnatural */
[data-theme="dark"] {
  --color-bg: oklch(0 0 0); /* #000000 */
}

/* GOOD: very dark gray is easier on the eyes */
[data-theme="dark"] {
  --color-bg: oklch(0.13 0 0); /* approximately #1a1a1a */
}
```

### 2. Too Much Contrast

```css
/* BAD: white text on black is fatiguing */
[data-theme="dark"] {
  --color-text: oklch(1 0 0);   /* pure white */
  --color-bg: oklch(0.07 0 0);  /* near black */
}

/* GOOD: slightly muted text reduces eye strain */
[data-theme="dark"] {
  --color-text: oklch(0.93 0 0); /* soft white */
  --color-bg: oklch(0.13 0 0);   /* dark gray */
}
```

### 3. Forgetting Elevation

In light mode, elevation is shown via shadows. In dark mode, shadows are invisible
against dark backgrounds. Use lighter surfaces instead:

```css
/* Light mode: elevation via shadow */
.card {
  background: oklch(1 0 0);
  box-shadow: 0 4px 6px oklch(0 0 0 / 0.07);
}

/* Dark mode: elevation via lighter surface */
[data-theme="dark"] .card {
  background: oklch(0.20 0 0); /* lighter than bg */
  box-shadow: 0 4px 6px oklch(0 0 0 / 0.3); /* subtle depth */
}
```

### 4. Colored Backgrounds Too Saturated

```css
/* BAD: saturated colors are blinding on dark backgrounds */
[data-theme="dark"] {
  --color-primary-bg: oklch(0.65 0.25 264);
}

/* GOOD: desaturate and darken for dark mode */
[data-theme="dark"] {
  --color-primary-bg: oklch(0.20 0.05 264); /* low L, low C */
}
```

### 5. Not Testing Images and Illustrations

Images designed for light mode can look jarring on dark. Solutions:
- Add subtle borders around images
- Reduce brightness of illustrations with a CSS filter
- Provide dark-mode variants for key illustrations

```css
[data-theme="dark"] img:not([data-theme-aware]) {
  filter: brightness(0.9) contrast(1.05);
}
```

---

## Contrast in Dark Mode

### APCA (Advanced Perceptual Contrast Algorithm)

APCA is replacing WCAG 2 contrast ratios. Key differences:
- Polarity-aware: light-on-dark has different thresholds than dark-on-light
- More accurate for real-world perception
- Recommended minimums:
  - Body text: Lc 60 (light-on-dark) or Lc -60 (dark-on-light)
  - Large text: Lc 45
  - Non-text UI: Lc 30

```css
/* Test your dark mode tokens */
/* --color-text (L=0.93) on --color-bg (L=0.13) */
/* Contrast: roughly Lc 80 — excellent */

/* --color-text-secondary (L=0.65) on --color-bg (L=0.13) */
/* Contrast: roughly Lc 50 — good for secondary text */

/* --color-text-tertiary (L=0.45) on --color-bg (L=0.13) */
/* Contrast: roughly Lc 30 — minimum for non-essential text */
```

---

## Flash Prevention (SSR)

Prevent the "flash of wrong theme" on page load:

```html
<!-- In <head>, BEFORE any CSS loads -->
<script>
  (function() {
    const theme = localStorage.getItem("theme");
    if (theme === "dark" || (!theme && matchMedia("(prefers-color-scheme:dark)").matches)) {
      document.documentElement.dataset.theme = "dark";
    } else {
      document.documentElement.dataset.theme = "light";
    }
  })();
</script>
```

For Next.js, use the `next-themes` library which handles this automatically.

---

## Complete Light/Dark Token Setup

See [semantic-tokens.md](semantic-tokens.md) for the full two-tier token system
with both light and dark mode definitions.
