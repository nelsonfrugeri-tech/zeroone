# Fluid Typography — clamp() In Depth

## Overview

Fluid typography uses CSS `clamp()` to smoothly scale font sizes between a minimum
and maximum, based on viewport width. No breakpoints needed.

```css
/* clamp(minimum, preferred, maximum) */
font-size: clamp(1rem, 0.925rem + 0.375vw, 1.125rem);
```

This single line replaces:
```css
/* Old approach: multiple breakpoints */
font-size: 1rem;
@media (min-width: 768px) { font-size: 1.05rem; }
@media (min-width: 1024px) { font-size: 1.125rem; }
```

---

## The Math

### Formula

```
preferred = min + (max - min) * (100vw - minViewport) / (maxViewport - minViewport)
```

Simplified for `rem` + `vw`:
```
Given: min = 1rem, max = 1.5rem, viewport range 320px-1440px
Rate = (1.5 - 1) / (1440 - 320) * 100 = 0.0446vw
Offset = 1 - 0.0446 * (320 / 16) = 0.1071rem

Result: clamp(1rem, 0.107rem + 0.0446vw, 1.5rem)
```

In practice, **use a calculator** (see Tools below).

---

## Complete Type Scale

A production-ready fluid type scale using rem:

```css
:root {
  /* Body sizes */
  --text-xs:   clamp(0.694rem, 0.662rem + 0.16vw, 0.8rem);
  --text-sm:   clamp(0.833rem, 0.787rem + 0.23vw, 0.96rem);
  --text-base: clamp(1rem, 0.935rem + 0.33vw, 1.2rem);
  --text-lg:   clamp(1.2rem, 1.111rem + 0.44vw, 1.44rem);

  /* Heading sizes */
  --text-xl:   clamp(1.44rem,  1.318rem + 0.61vw, 1.728rem);
  --text-2xl:  clamp(1.728rem, 1.562rem + 0.83vw, 2.074rem);
  --text-3xl:  clamp(2.074rem, 1.852rem + 1.11vw, 2.488rem);
  --text-4xl:  clamp(2.488rem, 2.196rem + 1.46vw, 2.986rem);
  --text-5xl:  clamp(2.986rem, 2.605rem + 1.91vw, 3.583rem);

  /* Line heights (tighter for headings) */
  --leading-tight:  1.15;
  --leading-snug:   1.3;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
}

/* Usage */
h1 {
  font-size: var(--text-5xl);
  line-height: var(--leading-tight);
  letter-spacing: -0.025em;
}

h2 {
  font-size: var(--text-4xl);
  line-height: var(--leading-tight);
  letter-spacing: -0.02em;
}

h3 {
  font-size: var(--text-3xl);
  line-height: var(--leading-snug);
}

h4 {
  font-size: var(--text-2xl);
  line-height: var(--leading-snug);
}

h5 {
  font-size: var(--text-xl);
  line-height: var(--leading-snug);
}

h6 {
  font-size: var(--text-lg);
  line-height: var(--leading-normal);
}

body {
  font-size: var(--text-base);
  line-height: var(--leading-normal);
}

small, .text-sm {
  font-size: var(--text-sm);
  line-height: var(--leading-normal);
}

.text-xs {
  font-size: var(--text-xs);
  line-height: var(--leading-normal);
}
```

---

## Scale Ratios

Choose a scale ratio that matches your design personality:

| Ratio | Name | Personality | Best For |
|-------|------|-------------|----------|
| 1.125 | Major Second | Subtle, dense | Data dashboards, admin |
| 1.200 | Minor Third | Balanced | SaaS, apps |
| 1.250 | Major Third | Clear hierarchy | Marketing, blogs |
| 1.333 | Perfect Fourth | Bold hierarchy | Landing pages |
| 1.414 | Augmented Fourth | Dramatic | Editorial, magazines |
| 1.500 | Perfect Fifth | Very dramatic | Hero sections |

The scale above uses **Minor Third (1.200)** — good for most apps.

---

## Why rem, Not px

```css
/* BAD: ignores user's font-size preference */
font-size: clamp(16px, 2vw, 20px);

/* GOOD: respects user's font-size preference */
font-size: clamp(1rem, 0.925rem + 0.375vw, 1.25rem);
```

Users who set their browser to 20px base font will get proportionally larger text
with rem. With px, their preference is ignored — an accessibility failure.

---

## Tailwind v4 Integration

```css
@import "tailwindcss";

@theme {
  --font-size-xs:   clamp(0.694rem, 0.662rem + 0.16vw, 0.8rem);
  --font-size-sm:   clamp(0.833rem, 0.787rem + 0.23vw, 0.96rem);
  --font-size-base: clamp(1rem, 0.935rem + 0.33vw, 1.2rem);
  --font-size-lg:   clamp(1.2rem, 1.111rem + 0.44vw, 1.44rem);
  --font-size-xl:   clamp(1.44rem, 1.318rem + 0.61vw, 1.728rem);
  --font-size-2xl:  clamp(1.728rem, 1.562rem + 0.83vw, 2.074rem);
  --font-size-3xl:  clamp(2.074rem, 1.852rem + 1.11vw, 2.488rem);
  --font-size-4xl:  clamp(2.488rem, 2.196rem + 1.46vw, 2.986rem);
  --font-size-5xl:  clamp(2.986rem, 2.605rem + 1.91vw, 3.583rem);
}
```

Usage: `<h1 className="text-5xl">` automatically uses the fluid value.

---

## Responsive Line Length (Measure)

Fluid type should be paired with a comfortable reading measure:

```css
.prose {
  max-width: clamp(45ch, 50vw, 75ch);
  font-size: var(--text-base);
  line-height: var(--leading-relaxed);
}
```

Optimal line length: **45-75 characters** for body text.

---

## Tools and Resources

| Tool | URL | Description |
|------|-----|-------------|
| **Fluid Type Scale** | https://www.fluid-type-scale.com | Generate complete fluid scales |
| **Utopia** | https://utopia.fyi/type/calculator | Advanced fluid type + space calculator |
| **Type Scale** | https://typescale.com | Visual type scale with ratios |
| **Modern Fluid Typography** | https://modern-fluid-typography.vercel.app | Interactive clamp() generator |
| **Every Layout** | https://every-layout.dev | Layout + typography patterns |

---

## Common Mistakes

1. **Using px in clamp()** — breaks user font-size preferences
2. **Too wide range** — `clamp(0.5rem, ..., 4rem)` creates jarring size jumps
3. **Forgetting line-height** — headings need tighter line-height than body
4. **No letter-spacing** — large headings need negative letter-spacing (-0.02em to -0.04em)
5. **Ignoring vertical rhythm** — spacing between elements should follow the type scale
