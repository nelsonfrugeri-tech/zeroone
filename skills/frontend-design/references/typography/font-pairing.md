# Font Pairing — Principles & Proven Combinations

## Principles of Pairing

### 1. Contrast, Not Conflict

Good pairings have clear contrast in ONE dimension while sharing others:

```
GOOD: Serif heading + Sans body  (contrast: category)
GOOD: Geometric heading + Humanist body  (contrast: construction)
BAD:  Two similar sans-serifs  (no contrast, looks like a mistake)
BAD:  Decorative heading + decorative body  (competing for attention)
```

### 2. The Rule of Two

Use at most **two** font families. If you need a third, use the same family
in a different weight or style.

```css
:root {
  --font-heading: "Instrument Serif", Georgia, serif;
  --font-body: "Inter Variable", system-ui, sans-serif;
  --font-mono: "JetBrains Mono Variable", monospace; /* OK: mono is functional */
}
```

### 3. Match the x-height

Fonts that pair well tend to have similar x-heights (the height of lowercase letters).
If x-heights differ significantly, the fonts look mismatched at the same font-size.

### 4. Historical Harmony

Fonts from the same era or design tradition tend to pair naturally:
- **Humanist serif + Humanist sans** (e.g., Garamond + Gill Sans)
- **Geometric sans + Geometric slab** (e.g., Futura + Rockwell)
- **Modern serif + Grotesk sans** (e.g., Didot + Helvetica)

---

## 5 Proven Combinations for 2026

### 1. The SaaS Standard — Inter Variable

```css
:root {
  --font-heading: "Inter Variable", system-ui, sans-serif;
  --font-body: "Inter Variable", system-ui, sans-serif;
}

h1 { font-weight: 700; letter-spacing: -0.025em; }
h2 { font-weight: 600; letter-spacing: -0.02em; }
body { font-weight: 400; }
```

**Vibe:** Clean, neutral, professional. Works for everything.
**Used by:** Linear, Vercel, Raycast, countless SaaS products.
**When to use:** When you want the design to be invisible, letting content shine.

### 2. The Editorial — Instrument Serif + Inter

```css
:root {
  --font-heading: "Instrument Serif", Georgia, serif;
  --font-body: "Inter Variable", system-ui, sans-serif;
}

h1 {
  font-family: var(--font-heading);
  font-style: italic;
  font-size: var(--text-5xl);
  letter-spacing: -0.02em;
}

body {
  font-family: var(--font-body);
}
```

**Vibe:** Elegant, editorial, premium. Strong personality.
**Used by:** Notion marketing site, editorial blogs, luxury brands.
**When to use:** Landing pages, blogs, portfolios, when you want warmth.

### 3. The Tech Modern — Space Grotesk + DM Sans

```css
:root {
  --font-heading: "Space Grotesk", system-ui, sans-serif;
  --font-body: "DM Sans", system-ui, sans-serif;
}

h1 {
  font-family: var(--font-heading);
  font-weight: 700;
  letter-spacing: -0.03em;
}

body {
  font-family: var(--font-body);
  font-weight: 400;
}
```

**Vibe:** Tech-forward, geometric, modern. Confident.
**Used by:** Developer tools, crypto/web3, startup landing pages.
**When to use:** When you want to signal innovation and technical sophistication.

### 4. The Warm Friendly — Fraunces + Source Sans 3

```css
:root {
  --font-heading: "Fraunces Variable", Georgia, serif;
  --font-body: "Source Sans 3 Variable", system-ui, sans-serif;
}

h1 {
  font-family: var(--font-heading);
  font-weight: 700;
  font-variation-settings: "SOFT" 100, "WONK" 1;
}

body {
  font-family: var(--font-body);
}
```

**Vibe:** Warm, friendly, approachable. Human touch.
**Used by:** Community platforms, education, non-profits.
**When to use:** When you want to feel welcoming and trustworthy.

### 5. The Developer Stack — Geist Sans + Geist Mono

```css
:root {
  --font-heading: "Geist Sans", system-ui, sans-serif;
  --font-body: "Geist Sans", system-ui, sans-serif;
  --font-mono: "Geist Mono", ui-monospace, monospace;
}

h1 {
  font-weight: 700;
  letter-spacing: -0.025em;
}

code, pre {
  font-family: var(--font-mono);
  font-size: 0.9em;
}
```

**Vibe:** Technical, precise, Vercel-native. Clean developer aesthetic.
**Used by:** Vercel, Next.js docs, developer tools.
**When to use:** Developer-facing products, documentation, technical blogs.

---

## System Font Stacks — When Custom Fonts Are Not Needed

### The GitHub Stack

```css
--font-body: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans",
             Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
```

### The Modern Stack

```css
--font-body: system-ui, -apple-system, sans-serif;
```

**When to use system fonts:**
- Admin panels and internal tools (speed > branding)
- Performance-critical applications (zero font loading)
- Content-heavy apps where familiarity matters
- Progressive enhancement: system font as base, custom as enhancement

---

## Loading Optimization for Pairings

### Strategy: Load Primary First

```html
<head>
  <!-- Preload the font used above the fold (heading or body) -->
  <link rel="preload" href="/fonts/InterVariable.woff2" as="font" type="font/woff2" crossorigin />

  <!-- Secondary font loads normally (body text has fallback) -->
  <link rel="preload" href="/fonts/InstrumentSerif-Italic.woff2" as="font" type="font/woff2" crossorigin />
</head>
```

### Matching Fallback Metrics

Use `@font-face` `size-adjust` to minimize layout shift when swapping:

```css
/* System fallback with adjusted metrics to match Inter */
@font-face {
  font-family: "Inter Fallback";
  src: local("Arial");
  size-adjust: 107%;
  ascent-override: 90%;
  descent-override: 22%;
  line-gap-override: 0%;
}

:root {
  --font-body: "Inter Variable", "Inter Fallback", system-ui, sans-serif;
}
```

Tools for calculating fallback metrics:
- https://screenspan.net/fallback
- `next/font` does this automatically in Next.js

---

## Rules

1. **Maximum two families** — mono is a functional exception
2. **Heading + body must contrast** — serif/sans, geometric/humanist, or weight
3. **Self-host when possible** — fontsource packages, zero third-party dependency
4. **Always set font-display: swap** — text should never be invisible
5. **Preload above-the-fold font** — the font visible on first render
6. **Test on real devices** — fonts render differently on macOS vs Windows vs Android
