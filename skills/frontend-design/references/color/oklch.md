# OKLCH Color Space — In Depth

## What is OKLCH?

OKLCH (Oklab Lightness Chroma Hue) is a perceptually uniform color space designed by
Bjorn Ottosson in 2020. It fixes the fundamental problems of HSL/HSV and has been adopted
as the default color model in Tailwind CSS v4.

### Syntax

```css
/* oklch(Lightness Chroma Hue / Alpha) */
color: oklch(0.65 0.25 264);
color: oklch(0.65 0.25 264 / 0.5); /* 50% opacity */
```

### Parameters

| Parameter | Range | Description |
|-----------|-------|-------------|
| **L** (Lightness) | 0 - 1 | 0 = black, 1 = white. Perceptually linear. |
| **C** (Chroma) | 0 - ~0.4 | 0 = gray, higher = more vivid. Max depends on gamut. |
| **H** (Hue) | 0 - 360 | Color wheel angle. 0=pink, 90=yellow, 180=cyan, 264=blue |

---

## Why OKLCH is Better Than HSL

### The Perceptual Uniformity Problem

HSL claims `lightness: 50%` means "medium brightness" for any hue. This is a lie.

```css
/* HSL: these are both "50% lightness" but look completely different */
.yellow { color: hsl(60, 100%, 50%); }  /* Extremely bright */
.blue   { color: hsl(240, 100%, 50%); } /* Very dark */

/* OKLCH: L=0.65 actually looks the same brightness regardless of hue */
.yellow { color: oklch(0.65 0.25 90); }  /* Medium brightness */
.blue   { color: oklch(0.65 0.25 264); } /* Same medium brightness */
```

This matters enormously for:
- **Generating palettes**: shade scales are visually consistent
- **Dark mode**: lightness inversion actually works
- **Accessibility**: contrast calculations are meaningful

### P3 Gamut Support

OKLCH can represent colors outside sRGB, in the wider P3 gamut that modern
Apple displays, newer Android phones, and many monitors support.

```css
/* sRGB max blue — this is the most vivid blue HSL can do */
.srgb-blue { color: hsl(240, 100%, 50%); }

/* P3 blue — 25% more vivid, visible on modern displays */
.p3-blue { color: oklch(0.45 0.31 264); }

/* Graceful fallback for older displays */
.vivid-blue {
  color: oklch(0.65 0.25 264); /* sRGB-safe */
}

@media (color-gamut: p3) {
  .vivid-blue {
    color: oklch(0.65 0.31 264); /* P3 vivid */
  }
}
```

### Comparison Table

| Feature | RGB/Hex | HSL | OKLCH |
|---------|---------|-----|-------|
| Human readable | No | Somewhat | Yes |
| Perceptually uniform | No | No | Yes |
| P3 gamut | No | No | Yes |
| Dark mode friendly | No | No | Yes |
| Palette generation | Hard | Inconsistent | Consistent |
| Browser support (2026) | Full | Full | Full (96%+) |
| Tailwind v4 native | No | Legacy | Default |

---

## Generating Palettes with OKLCH

### The Simple Method: Fix C and H, Vary L

To create a shade scale (50-950), keep Chroma and Hue constant, vary Lightness:

```css
:root {
  /* Blue palette — H=264, C=0.15 (moderate) */
  --blue-50:  oklch(0.97 0.01 264);
  --blue-100: oklch(0.93 0.03 264);
  --blue-200: oklch(0.87 0.07 264);
  --blue-300: oklch(0.78 0.12 264);
  --blue-400: oklch(0.70 0.18 264);
  --blue-500: oklch(0.65 0.22 264);  /* primary */
  --blue-600: oklch(0.55 0.22 264);
  --blue-700: oklch(0.47 0.19 264);
  --blue-800: oklch(0.38 0.15 264);
  --blue-900: oklch(0.30 0.12 264);
  --blue-950: oklch(0.22 0.08 264);
}
```

### Advanced: Chroma Curve

In reality, the most vivid chroma happens at mid-lightness. For a natural-looking
palette, increase chroma in the middle and decrease at extremes:

```css
:root {
  /* Green palette with chroma curve */
  --green-50:  oklch(0.97 0.02 150);  /* low C: almost white */
  --green-100: oklch(0.93 0.05 150);
  --green-200: oklch(0.87 0.10 150);
  --green-300: oklch(0.78 0.16 150);
  --green-400: oklch(0.70 0.20 150);
  --green-500: oklch(0.65 0.22 150);  /* peak chroma */
  --green-600: oklch(0.55 0.20 150);
  --green-700: oklch(0.47 0.17 150);
  --green-800: oklch(0.38 0.13 150);
  --green-900: oklch(0.30 0.10 150);
  --green-950: oklch(0.22 0.06 150);  /* low C: almost black */
}
```

### Complete Brand Palette Template

```css
:root {
  /* Brand primary: pick your hue */
  --hue-primary: 264;   /* blue */
  --hue-success: 150;   /* green */
  --hue-warning: 75;    /* amber */
  --hue-danger: 25;     /* red */

  /* Neutral: zero chroma */
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
}
```

---

## Tailwind v4 OKLCH Integration

Tailwind v4 uses OKLCH internally for its default palette. Your `@theme` directive
should use OKLCH for consistency:

```css
@import "tailwindcss";

@theme {
  /* These are OKLCH values that Tailwind v4 understands natively */
  --color-primary: oklch(0.65 0.25 264);
  --color-primary-foreground: oklch(0.98 0.01 264);

  --color-secondary: oklch(0.55 0.15 150);
  --color-secondary-foreground: oklch(0.98 0.01 150);

  --color-destructive: oklch(0.55 0.22 25);
  --color-destructive-foreground: oklch(0.98 0.01 25);

  --color-muted: oklch(0.94 0.005 264);
  --color-muted-foreground: oklch(0.55 0.02 264);
}
```

In components:
```tsx
<button className="bg-primary text-primary-foreground hover:bg-primary/90">
  Click me
</button>
```

---

## Tools and Resources

| Tool | URL | Purpose |
|------|-----|---------|
| **OKLCH Color Picker** | https://oklch.com | Interactive OKLCH picker with gamut visualization |
| **Realtime Colors** | https://www.realtimecolors.com | Full palette generator with dark mode preview |
| **Radix Colors** | https://www.radix-ui.com/colors | Pre-made OKLCH-compatible palettes |
| **Huetone** | https://huetone.ardov.me | Design palette scales with perceptual uniformity |
| **Color.js** | https://colorjs.io | JavaScript library for OKLCH manipulation |
| **Open Props** | https://open-props.style | CSS custom properties including OKLCH colors |

---

## Browser Support

As of 2026, OKLCH has **96%+ global support**:
- Chrome 111+ (March 2023)
- Firefox 113+ (May 2023)
- Safari 15.4+ (March 2022)
- Edge 111+ (March 2023)

For the rare case you need a fallback:
```css
.element {
  /* Fallback for ancient browsers */
  color: #3b82f6;
  /* Modern browsers use this */
  color: oklch(0.65 0.25 264);
}
```

---

## Common Hue Values Reference

| Hue | Color | Common Use |
|-----|-------|-----------|
| 0 | Pink/Red | Danger, love |
| 25 | Red/Orange | Error, destructive |
| 50 | Orange | Warning |
| 75 | Amber/Yellow | Caution, highlight |
| 90 | Yellow | Attention |
| 120 | Lime | Growth |
| 150 | Green | Success, positive |
| 180 | Teal/Cyan | Info, fresh |
| 210 | Sky Blue | Calm, links |
| 240 | Blue | Primary, trust |
| 264 | Indigo/Blue | Primary, brand |
| 290 | Purple | Creative, premium |
| 320 | Magenta | Accent |
| 340 | Pink | Playful, feminine |
