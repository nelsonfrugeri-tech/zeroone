# Variable Fonts — Axes, Performance & Animation

## What Are Variable Fonts?

A variable font is a single font file that contains the entire range of variations
(weight, width, slant, etc.) instead of separate files for each style.

```
Traditional:                    Variable:
Inter-Regular.woff2    (30KB)   InterVariable.woff2  (310KB)
Inter-Medium.woff2     (30KB)   = ALL weights + widths in ONE file
Inter-SemiBold.woff2   (30KB)
Inter-Bold.woff2       (30KB)
Inter-ExtraBold.woff2  (30KB)
...10 files = 300KB+           Actually SMALLER for 3+ styles
```

### Performance Benefits

- **Fewer HTTP requests** — 1 file vs 10+
- **Smaller total size** — when using 3+ weights (very common)
- **Smooth animations** — interpolate between any weight value
- **No FOUT between weights** — no flash when switching styles

---

## Variation Axes

### Standard Axes (registered)

| Axis | Tag | Range | Description |
|------|-----|-------|-------------|
| Weight | `wght` | 100-900 | Thin to Black |
| Width | `wdth` | 75-125 | Condensed to Expanded |
| Slant | `slnt` | -90-90 | Oblique angle |
| Italic | `ital` | 0-1 | Roman to Italic |
| Optical Size | `opsz` | 8-144 | Optimized for display size |

### Using Axes

```css
@font-face {
  font-family: "Inter Variable";
  src: url("/fonts/InterVariable.woff2") format("woff2");
  font-weight: 100 900;
  font-display: swap;
}

/* High-level properties (preferred when available) */
.heading {
  font-family: "Inter Variable", system-ui, sans-serif;
  font-weight: 700;
}

/* Low-level axis control */
.custom {
  font-variation-settings:
    "wght" 650,    /* between SemiBold and Bold */
    "wdth" 90;     /* slightly condensed */
}

/* Optical size: browser sets automatically based on font-size */
.auto-optical {
  font-size: 48px;
  font-optical-sizing: auto; /* browser selects optimal opsz */
}
```

---

## Animation with Variable Fonts

Variable fonts enable smooth weight/width transitions:

```css
/* Smooth weight transition on hover */
.nav-link {
  font-family: "Inter Variable", system-ui, sans-serif;
  font-variation-settings: "wght" 400;
  transition: font-variation-settings 200ms ease-out;
}

.nav-link:hover {
  font-variation-settings: "wght" 600;
}

.nav-link[aria-current="page"] {
  font-variation-settings: "wght" 700;
}
```

```css
/* Breathing animation for loading state */
@keyframes breathe {
  0%, 100% { font-variation-settings: "wght" 300; }
  50% { font-variation-settings: "wght" 700; }
}

.loading-text {
  animation: breathe 2s ease-in-out infinite;
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .loading-text {
    animation: none;
    font-variation-settings: "wght" 400;
  }
}
```

---

## Recommended Variable Fonts (2026)

### Sans-Serif

| Font | Axes | Vibe | Source |
|------|------|------|--------|
| **Inter Variable** | wght 100-900 | Clean, neutral, SaaS | Google Fonts / fontsource |
| **Geist Sans** | wght 100-900 | Modern, developer | Vercel / fontsource |
| **DM Sans** | wght 100-1000, ital, opsz | Geometric, friendly | Google Fonts |
| **Space Grotesk** | wght 300-700 | Tech, modern | Google Fonts |
| **Plus Jakarta Sans** | wght 200-800 | Geometric, warm | Google Fonts |
| **Outfit** | wght 100-900 | Geometric, clean | Google Fonts |

### Serif

| Font | Axes | Vibe | Source |
|------|------|------|--------|
| **Instrument Serif** | (static only) | Editorial, elegant | Google Fonts |
| **Fraunces** | wght, opsz, SOFT, WONK | Warm, old-style | Google Fonts |
| **Lora** | wght 400-700, ital | Classic, readable | Google Fonts |
| **Source Serif 4** | wght 200-900, opsz, ital | Versatile, professional | Google Fonts |

### Monospace

| Font | Axes | Vibe | Source |
|------|------|------|--------|
| **JetBrains Mono** | wght 100-800 | Developer-focused | fontsource |
| **Geist Mono** | wght 100-900 | Modern, Vercel | fontsource |
| **Fira Code** | wght 300-700 | Ligatures, popular | Google Fonts |

---

## Self-Hosting with fontsource

fontsource provides npm packages for self-hosting fonts with optimal loading:

```bash
npm install @fontsource-variable/inter
npm install @fontsource-variable/jetbrains-mono
```

```tsx
// app/layout.tsx or main entry
import "@fontsource-variable/inter";
import "@fontsource-variable/jetbrains-mono";
```

```css
@theme {
  --font-sans: "Inter Variable", system-ui, sans-serif;
  --font-mono: "JetBrains Mono Variable", monospace;
}
```

Benefits over Google Fonts CDN:
- No third-party requests (privacy, GDPR)
- No DNS lookup latency
- Full control over font-display
- Works offline

---

## font-display Strategies

| Strategy | Behavior | When to use |
|----------|----------|-------------|
| `swap` | Show fallback immediately, swap when loaded | Body text (default choice) |
| `optional` | Show fallback, swap only if loaded very fast | Performance-critical pages |
| `block` | Hide text briefly, then show with font | Icons, decorative text only |
| `fallback` | Brief block, then fallback, swap if fast | Compromise between swap/optional |

```css
@font-face {
  font-family: "Inter Variable";
  src: url("/fonts/InterVariable.woff2") format("woff2");
  font-weight: 100 900;
  font-display: swap; /* Recommended default */
}
```

---

## Loading Optimization

```html
<!-- Preload the primary font (in <head>) -->
<link
  rel="preload"
  href="/fonts/InterVariable.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>

<!-- Preconnect if using Google Fonts (not recommended, prefer self-hosting) -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
```

### Subsetting

For fonts with large character sets, subset to reduce file size:

```bash
# Using pyftsubset (fonttools)
pyftsubset InterVariable.woff2 \
  --output-file=InterVariable-latin.woff2 \
  --flavor=woff2 \
  --layout-features="kern,liga,calt" \
  --unicodes="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+2074,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD"
```

fontsource packages are already subsetted by default.

---

## System Font Stacks

When custom fonts are not needed, system stacks are instant:

```css
/* System sans-serif stack */
--font-system-sans:
  system-ui,
  -apple-system,
  BlinkMacSystemFont,
  "Segoe UI",
  Roboto,
  "Helvetica Neue",
  Arial,
  sans-serif;

/* System monospace stack */
--font-system-mono:
  ui-monospace,
  SFMono-Regular,
  "SF Mono",
  Menlo,
  Consolas,
  "Liberation Mono",
  monospace;
```

Use system fonts for: admin panels, internal tools, performance-critical apps.
Use custom fonts for: brand identity, marketing, editorial, premium feel.
