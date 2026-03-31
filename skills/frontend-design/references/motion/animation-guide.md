# Animation Guide — Decision Tree, Performance & Implementation

## Decision Tree

```
Need to animate?
│
├── Is it a simple property transition? (opacity, color, transform)
│   └── YES → CSS transition
│       transition: opacity 200ms ease, transform 300ms ease;
│
├── Is it a multi-step sequence? (fade in → slide → pulse)
│   └── YES → CSS @keyframes
│       @keyframes fadeSlide { 0% {...} 50% {...} 100% {...} }
│
├── Is it layout animation, gestures, or orchestrated?
│   └── YES → Motion (Framer)
│       <motion.div layout animate={{ x: 100 }} />
│
├── Is it a complex timeline with scroll triggers?
│   └── YES → GSAP (heavyweight, use sparingly)
│
├── Is it a page/route transition?
│   └── YES → View Transitions API
│       document.startViewTransition(() => updateDOM())
│
└── Is it scroll-driven? (parallax, progress bars)
    └── YES → CSS Scroll-Driven Animations
        animation-timeline: scroll();
```

---

## CSS Transitions — The Default Choice

Use for simple state changes. Always the first option.

```css
.button {
  background: var(--color-primary);
  transform: translateY(0);
  box-shadow: var(--shadow-sm);
  transition:
    background 150ms ease,
    transform 150ms ease,
    box-shadow 150ms ease;
}

.button:hover {
  background: var(--color-primary-hover);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.button:active {
  transform: translateY(0);
  box-shadow: var(--shadow-sm);
}
```

### Timing Guidelines

| Duration | Use Case |
|----------|----------|
| 100-150ms | Micro-interactions: button hover, toggle |
| 200-300ms | Component transitions: accordion, tab switch |
| 300-500ms | Layout transitions: sidebar, modal enter |
| 500ms+ | Rarely. Page transitions, complex sequences |

### Easing

```css
/* Prefer these over linear or ease */
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);      /* enter/appear */
--ease-in: cubic-bezier(0.55, 0, 1, 0.45);        /* exit/leave */
--ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);    /* move/resize */
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1); /* playful bounce */
```

---

## CSS @keyframes — Multi-Step Sequences

```css
/* Skeleton shimmer effect */
@keyframes shimmer {
  0%   { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.skeleton {
  position: relative;
  overflow: hidden;
  background: oklch(0.92 0 0);
}

.skeleton::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(
    90deg,
    transparent,
    oklch(1 0 0 / 0.4),
    transparent
  );
  animation: shimmer 1.5s infinite;
}

/* Fade in + slide up */
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-in {
  animation: fade-in-up 400ms var(--ease-out) both;
}

/* Staggered children */
.stagger > :nth-child(1) { animation-delay: 0ms; }
.stagger > :nth-child(2) { animation-delay: 50ms; }
.stagger > :nth-child(3) { animation-delay: 100ms; }
.stagger > :nth-child(4) { animation-delay: 150ms; }
```

---

## Motion (Framer) — The React Standard

Motion (formerly Framer Motion) is the go-to for React animations that need
layout awareness, gestures, or orchestration.

### Basic Animations

```tsx
import { motion } from "motion/react";

// Animate on mount
function FadeIn({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ type: "spring", stiffness: 400, damping: 25 }}
    >
      {children}
    </motion.div>
  );
}
```

### Layout Animations

The killer feature: animate layout changes smoothly.

```tsx
function ExpandableCard({ isExpanded }: { isExpanded: boolean }) {
  return (
    <motion.div
      layout
      className="rounded-xl border bg-surface overflow-hidden"
      transition={{ type: "spring", stiffness: 500, damping: 30 }}
    >
      <motion.h2 layout="position" className="p-4 font-semibold">
        Card Title
      </motion.h2>
      {isExpanded && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="px-4 pb-4"
        >
          <p>Expanded content appears smoothly...</p>
        </motion.div>
      )}
    </motion.div>
  );
}
```

### AnimatePresence — Exit Animations

```tsx
import { motion, AnimatePresence } from "motion/react";

function NotificationList({ items }: { items: Notification[] }) {
  return (
    <AnimatePresence mode="popLayout">
      {items.map((item) => (
        <motion.div
          key={item.id}
          layout
          initial={{ opacity: 0, x: 50, scale: 0.95 }}
          animate={{ opacity: 1, x: 0, scale: 1 }}
          exit={{ opacity: 0, x: -50, scale: 0.95 }}
          transition={{ type: "spring", stiffness: 500, damping: 30 }}
          className="rounded-lg border p-4"
        >
          {item.message}
        </motion.div>
      ))}
    </AnimatePresence>
  );
}
```

### Gesture Animations

```tsx
<motion.button
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
  className="rounded-lg bg-primary px-4 py-2 text-primary-foreground"
>
  Click me
</motion.button>
```

### Staggered Children

```tsx
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.05 },
  },
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 },
};

function StaggeredList({ items }: { items: string[] }) {
  return (
    <motion.ul variants={container} initial="hidden" animate="show">
      {items.map((text) => (
        <motion.li key={text} variants={item}>
          {text}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

---

## Spring Physics

Springs are preferred over duration-based easing because they feel natural.

### Key Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `stiffness` | How taut the spring (higher = faster) | 100-1000 |
| `damping` | How much friction (higher = less bounce) | 10-50 |
| `mass` | Weight of the object (higher = slower) | 0.5-3 |

### Common Presets

```tsx
// Snappy (buttons, toggles)
transition={{ type: "spring", stiffness: 500, damping: 30 }}

// Smooth (layout, modals)
transition={{ type: "spring", stiffness: 300, damping: 25 }}

// Bouncy (playful elements)
transition={{ type: "spring", stiffness: 400, damping: 15 }}

// Gentle (page transitions)
transition={{ type: "spring", stiffness: 200, damping: 20 }}
```

### Material 3 Expressive Spring System

Google's Material 3 Expressive introduces a spring system based on spatial hierarchy:

| Spatial | Stiffness | Damping | Use |
|---------|-----------|---------|-----|
| Spatial Default | 500 | 0.9 | Most UI elements |
| Spatial Large | 380 | 0.85 | Large surfaces (sheets, dialogs) |
| Spatial Small | 700 | 0.93 | Small elements (chips, FAB) |
| Effects | 200 | 0.6 | Decorative, background |

---

## View Transitions API

Page-level transitions without a framework:

```tsx
// Basic usage
function navigateTo(url: string) {
  if (!document.startViewTransition) {
    updateDOM(url);
    return;
  }

  document.startViewTransition(() => updateDOM(url));
}

// Custom animation
::view-transition-old(root) {
  animation: fade-out 200ms ease-out;
}

::view-transition-new(root) {
  animation: fade-in 300ms ease-in;
}

// Named transitions for specific elements
.hero-image {
  view-transition-name: hero;
}
```

---

## Performance Tiers

| Tier | Properties | Cost | Notes |
|------|-----------|------|-------|
| **Cheap** | `transform`, `opacity` | GPU-composited | Always prefer these |
| **Medium** | `filter`, `clip-path` | Repaint only | OK for occasional use |
| **Expensive** | `width`, `height`, `padding`, `margin` | Layout + repaint | Avoid animating |
| **Very Expensive** | `box-shadow`, `border-radius` (on change) | Full repaint | Use transform: scale() instead |

```css
/* BAD: animates layout properties */
.card:hover {
  width: 320px; /* triggers layout */
  padding: 2rem; /* triggers layout */
}

/* GOOD: animates only transform/opacity */
.card:hover {
  transform: scale(1.02); /* GPU-composited */
  opacity: 0.95; /* GPU-composited */
}
```

### will-change Hint

```css
/* Tell browser to prepare GPU layer */
.frequently-animated {
  will-change: transform, opacity;
}

/* Remove when animation is done (don't leave permanently) */
```

---

## prefers-reduced-motion — Non-Negotiable

### CSS Implementation

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

### React Implementation

```tsx
import { useReducedMotion } from "motion/react";

function AnimatedCard({ children }: { children: React.ReactNode }) {
  const prefersReduced = useReducedMotion();

  return (
    <motion.div
      initial={prefersReduced ? false : { opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={
        prefersReduced
          ? { duration: 0 }
          : { type: "spring", stiffness: 400, damping: 25 }
      }
    >
      {children}
    </motion.div>
  );
}
```

### What to Do When Motion is Reduced

| Normal | Reduced Motion |
|--------|---------------|
| Slide in | Instant appear (opacity only, 0ms) |
| Bouncy entrance | Fade in (200ms max) |
| Parallax scroll | Static |
| Auto-playing animation | Static frame |
| Loading spinner | Static progress bar or text |

---

## Rules

1. **CSS transitions first** — only reach for Motion/GSAP when CSS can't do it
2. **Spring physics > easing curves** — springs feel more natural
3. **Transform and opacity only** — avoid animating layout properties
4. **prefers-reduced-motion always** — every animation must have a reduced alternative
5. **150ms for micro, 300ms for components, 500ms max for page** — duration guidelines
6. **Animation communicates state** — loading, success, error, navigation. Never decoration alone
