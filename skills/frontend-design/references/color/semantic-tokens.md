# Semantic Token System — Two-Tier Architecture

## Overview

A robust design system uses **two tiers** of tokens:
1. **Primitive tokens** — the raw palette (blue-500, gray-100, etc.)
2. **Semantic tokens** — what the primitives mean in context (--color-primary, --color-bg)

This decoupling allows you to change the entire visual identity by swapping
primitive assignments without touching component code.

---

## Architecture

```
Primitive Tokens          Semantic Tokens            Components
(the palette)             (the meaning)              (the UI)

--blue-500    ------>    --color-primary    ------>   bg-primary
--blue-100    ------>    --color-primary-bg           text-primary
--gray-900    ------>    --color-text                 bg-surface
--gray-50     ------>    --color-surface
--red-500     ------>    --color-destructive
```

Components NEVER reference primitives directly. Always go through semantic tokens.

---

## Naming Conventions

### Primitive Token Naming

Use `{color}-{shade}` pattern with OKLCH values:

```css
:root {
  /* Primitive: brand blue */
  --blue-50:  oklch(0.97 0.01 264);
  --blue-100: oklch(0.93 0.03 264);
  --blue-200: oklch(0.87 0.07 264);
  --blue-300: oklch(0.78 0.12 264);
  --blue-400: oklch(0.70 0.18 264);
  --blue-500: oklch(0.65 0.22 264);
  --blue-600: oklch(0.55 0.22 264);
  --blue-700: oklch(0.47 0.19 264);
  --blue-800: oklch(0.38 0.15 264);
  --blue-900: oklch(0.30 0.12 264);
  --blue-950: oklch(0.22 0.08 264);

  /* Primitive: neutral gray */
  --gray-50:  oklch(0.98 0 0);
  --gray-100: oklch(0.94 0 0);
  --gray-200: oklch(0.87 0 0);
  --gray-300: oklch(0.78 0 0);
  --gray-400: oklch(0.65 0 0);
  --gray-500: oklch(0.55 0 0);
  --gray-600: oklch(0.45 0 0);
  --gray-700: oklch(0.37 0 0);
  --gray-800: oklch(0.27 0 0);
  --gray-900: oklch(0.20 0 0);
  --gray-950: oklch(0.13 0 0);

  /* Primitive: feedback colors */
  --red-500:    oklch(0.55 0.22 25);
  --green-500:  oklch(0.65 0.22 150);
  --amber-500:  oklch(0.75 0.18 75);
}
```

### Semantic Token Naming

Use `{category}-{element}-{modifier}` pattern:

```css
:root {
  /* --- Background --- */
  --color-bg:           var(--gray-50);
  --color-bg-subtle:    oklch(0.99 0 0);
  --color-bg-muted:     var(--gray-100);
  --color-bg-elevated:  oklch(1 0 0);     /* cards, popovers */
  --color-bg-overlay:   oklch(0 0 0 / 0.5); /* modal backdrop */

  /* --- Surface (interactive containers) --- */
  --color-surface:      oklch(1 0 0);
  --color-surface-hover: var(--gray-50);
  --color-surface-active: var(--gray-100);

  /* --- Text --- */
  --color-text:         var(--gray-900);
  --color-text-secondary: var(--gray-600);
  --color-text-tertiary:  var(--gray-400);
  --color-text-inverse:   oklch(0.98 0 0);
  --color-text-link:      var(--blue-600);
  --color-text-link-hover: var(--blue-700);

  /* --- Border --- */
  --color-border:       var(--gray-200);
  --color-border-hover: var(--gray-300);
  --color-border-focus: var(--blue-500);

  /* --- Primary (brand action) --- */
  --color-primary:            var(--blue-500);
  --color-primary-hover:      var(--blue-600);
  --color-primary-active:     var(--blue-700);
  --color-primary-bg:         var(--blue-50);
  --color-primary-foreground: oklch(0.98 0.01 264);

  /* --- Destructive --- */
  --color-destructive:            var(--red-500);
  --color-destructive-hover:      oklch(0.50 0.22 25);
  --color-destructive-bg:         oklch(0.96 0.02 25);
  --color-destructive-foreground: oklch(0.98 0.01 25);

  /* --- Success --- */
  --color-success:      var(--green-500);
  --color-success-bg:   oklch(0.96 0.03 150);

  /* --- Warning --- */
  --color-warning:      var(--amber-500);
  --color-warning-bg:   oklch(0.96 0.04 75);

  /* --- Focus ring --- */
  --color-focus-ring:   var(--blue-500);

  /* --- Shadow --- */
  --shadow-sm:   0 1px 2px oklch(0 0 0 / 0.05);
  --shadow-md:   0 4px 6px oklch(0 0 0 / 0.07);
  --shadow-lg:   0 10px 15px oklch(0 0 0 / 0.1);
  --shadow-xl:   0 20px 25px oklch(0 0 0 / 0.1);
}
```

---

## Dark Mode via Semantic Tokens

The power of semantic tokens: dark mode is just re-assigning the same token names.

```css
[data-theme="dark"] {
  /* --- Background --- */
  --color-bg:           var(--gray-950);
  --color-bg-subtle:    oklch(0.15 0 0);
  --color-bg-muted:     var(--gray-900);
  --color-bg-elevated:  var(--gray-900);
  --color-bg-overlay:   oklch(0 0 0 / 0.7);

  /* --- Surface --- */
  --color-surface:       var(--gray-900);
  --color-surface-hover: var(--gray-800);
  --color-surface-active: var(--gray-700);

  /* --- Text --- */
  --color-text:           var(--gray-50);
  --color-text-secondary: var(--gray-400);
  --color-text-tertiary:  var(--gray-500);
  --color-text-inverse:   var(--gray-900);
  --color-text-link:      var(--blue-400);
  --color-text-link-hover: var(--blue-300);

  /* --- Border --- */
  --color-border:       var(--gray-800);
  --color-border-hover: var(--gray-700);
  --color-border-focus: var(--blue-400);

  /* --- Primary (slightly lighter in dark mode) --- */
  --color-primary:            var(--blue-400);
  --color-primary-hover:      var(--blue-300);
  --color-primary-active:     var(--blue-500);
  --color-primary-bg:         oklch(0.20 0.05 264);
  --color-primary-foreground: oklch(0.13 0.02 264);

  /* --- Destructive --- */
  --color-destructive:            oklch(0.65 0.22 25);
  --color-destructive-hover:      oklch(0.70 0.20 25);
  --color-destructive-bg:         oklch(0.20 0.05 25);
  --color-destructive-foreground: oklch(0.13 0.02 25);

  /* --- Success --- */
  --color-success:    oklch(0.70 0.20 150);
  --color-success-bg: oklch(0.20 0.05 150);

  /* --- Warning --- */
  --color-warning:    oklch(0.80 0.16 75);
  --color-warning-bg: oklch(0.22 0.05 75);

  /* --- Shadow (stronger in dark mode for visibility) --- */
  --shadow-sm:   0 1px 2px oklch(0 0 0 / 0.2);
  --shadow-md:   0 4px 6px oklch(0 0 0 / 0.3);
  --shadow-lg:   0 10px 15px oklch(0 0 0 / 0.4);
  --shadow-xl:   0 20px 25px oklch(0 0 0 / 0.5);
}
```

---

## W3C Design Tokens Color Module

The W3C Design Tokens Community Group defines a JSON format for token exchange:

```json
{
  "color": {
    "primary": {
      "$type": "color",
      "$value": "oklch(0.65 0.25 264)",
      "$description": "Primary brand color"
    },
    "bg": {
      "$type": "color",
      "$value": "{color.gray.50}",
      "$description": "Default background"
    }
  }
}
```

This standard enables tool interop between Figma, Style Dictionary, and code.

---

## Tailwind v4 Integration

Map semantic tokens in your `@theme` directive:

```css
@import "tailwindcss";

@theme {
  /* Map semantic tokens to Tailwind classes */
  --color-background: var(--color-bg);
  --color-foreground: var(--color-text);
  --color-primary: var(--color-primary);
  --color-primary-foreground: var(--color-primary-foreground);
  --color-secondary: var(--color-bg-muted);
  --color-secondary-foreground: var(--color-text);
  --color-destructive: var(--color-destructive);
  --color-destructive-foreground: var(--color-destructive-foreground);
  --color-muted: var(--color-bg-muted);
  --color-muted-foreground: var(--color-text-secondary);
  --color-accent: var(--color-surface-hover);
  --color-accent-foreground: var(--color-text);
  --color-border: var(--color-border);
  --color-ring: var(--color-focus-ring);
}
```

Usage in components:
```tsx
<div className="bg-background text-foreground">
  <button className="bg-primary text-primary-foreground">
    Action
  </button>
  <p className="text-muted-foreground">Helper text</p>
</div>
```

---

## Rules

1. **Components never reference primitives** — always use semantic tokens
2. **One source of truth** — tokens defined in CSS custom properties
3. **Dark mode = re-assignment** — same semantic names, different primitive values
4. **Name by purpose, not appearance** — `--color-destructive`, not `--color-red`
5. **Foreground always accompanies background** — every bg token has a foreground pair
6. **Test both themes** — every component must look correct in light and dark
