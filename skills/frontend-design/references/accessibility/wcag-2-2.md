# WCAG 2.2 — Frontend Implementation Guide

## Overview

WCAG 2.2 (published October 2023) adds 9 new success criteria to WCAG 2.1.
Target: **Level AA** compliance as baseline.

---

## New in WCAG 2.2

### 2.4.11 Focus Not Obscured (Minimum) — Level AA

Focused elements must not be fully hidden by sticky headers, floating bars, etc.

```css
/* Ensure focused elements scroll into visible area */
:target,
:focus {
  scroll-margin-top: 5rem;  /* height of sticky header + buffer */
  scroll-margin-bottom: 5rem;
}

/* Sticky header must not cover focused content */
.sticky-header {
  position: sticky;
  top: 0;
  z-index: 40;
}

/* Ensure dialogs don't obscure focus behind them */
dialog::backdrop {
  pointer-events: auto; /* trap focus inside dialog */
}
```

### 2.4.12 Focus Not Obscured (Enhanced) — Level AAA

No part of the focused element is hidden (stricter than 2.4.11).

### 2.4.13 Focus Appearance — Level AAA

Focus indicator must be at least 2px outline with 3:1 contrast ratio.

```css
:focus-visible {
  outline: 2px solid oklch(0.65 0.25 264);
  outline-offset: 2px;
}
```

### 2.5.7 Dragging Movements — Level AA

Any operation that uses dragging must also work with a single pointer (click/tap).

```tsx
// BAD: only drag-and-drop to reorder
<SortableList onDragEnd={reorder} />

// GOOD: drag-and-drop WITH up/down buttons
<SortableList onDragEnd={reorder}>
  {items.map((item) => (
    <SortableItem key={item.id}>
      {item.name}
      <button onClick={() => moveUp(item.id)} aria-label={`Move ${item.name} up`}>
        <ChevronUp className="size-4" />
      </button>
      <button onClick={() => moveDown(item.id)} aria-label={`Move ${item.name} down`}>
        <ChevronDown className="size-4" />
      </button>
    </SortableItem>
  ))}
</SortableList>
```

### 2.5.8 Target Size (Minimum) — Level AA

Interactive targets must be at least **24x24 CSS pixels**.

```css
/* Ensure all clickable elements meet minimum target size */
button, a, [role="button"], input[type="checkbox"], input[type="radio"] {
  min-width: 24px;   /* 1.5rem */
  min-height: 24px;
}

/* For inline links in text, spacing provides the target */
p a {
  /* Inline text links are exempt IF there's enough spacing */
  padding-block: 2px;
}

/* Icon buttons need explicit sizing */
.icon-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 2.5rem;  /* 40px — comfortable touch */
  min-height: 2.5rem;
}
```

### 3.2.6 Consistent Help — Level A

Help mechanisms (contact, FAQ links) must appear in the same relative location.

### 3.3.7 Redundant Entry — Level A

Don't ask users to re-enter info they already provided in the same session.

### 3.3.8 Accessible Authentication (Minimum) — Level AA

Don't require cognitive tests (CAPTCHA, remembering passwords) without alternatives.

```tsx
// BAD: CAPTCHA with no alternative
<ReCAPTCHA />

// GOOD: invisible reCAPTCHA or passkey authentication
<input type="hidden" name="captcha" />
// Or better: passkey / WebAuthn
<button onClick={authenticateWithPasskey}>Sign in with Passkey</button>
```

### 3.3.9 Accessible Authentication (Enhanced) — Level AAA

No cognitive tests at all, including object recognition.

---

## Core WCAG Principles in Code

### Focus Management

```css
/* The correct focus approach: focus-visible */
/* Shows focus ring only on keyboard navigation, not mouse clicks */

/* Global focus style */
:focus-visible {
  outline: 2px solid oklch(0.65 0.25 264);
  outline-offset: 2px;
  border-radius: 4px;
}

/* Remove the default outline that shows on mouse click */
:focus:not(:focus-visible) {
  outline: none;
}

/* Custom focus for specific elements */
button:focus-visible {
  outline: 2px solid oklch(0.65 0.25 264);
  outline-offset: 2px;
  box-shadow: 0 0 0 4px oklch(0.65 0.25 264 / 0.2);
}

/* Input focus */
input:focus-visible,
textarea:focus-visible,
select:focus-visible {
  outline: none;
  border-color: var(--color-focus-ring);
  box-shadow: 0 0 0 3px oklch(0.65 0.25 264 / 0.2);
}
```

### Focus Trapping in Modals

Radix Dialog handles this automatically. If building custom:

```tsx
function useFocusTrap(ref: React.RefObject<HTMLElement>) {
  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const focusable = element.querySelectorAll<HTMLElement>(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    const first = focusable[0];
    const last = focusable[focusable.length - 1];

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key !== "Tab") return;

      if (e.shiftKey) {
        if (document.activeElement === first) {
          e.preventDefault();
          last.focus();
        }
      } else {
        if (document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    }

    element.addEventListener("keydown", handleKeyDown);
    first?.focus();

    return () => element.removeEventListener("keydown", handleKeyDown);
  }, [ref]);
}
```

---

## APCA Contrast

APCA (Advanced Perceptual Contrast Algorithm) is the next-generation contrast
standard, designed to replace WCAG 2 contrast ratios.

### Key Differences from WCAG 2

| Aspect | WCAG 2 | APCA |
|--------|--------|------|
| Metric | Contrast ratio (e.g., 4.5:1) | Lc value (e.g., Lc 60) |
| Polarity | Same threshold light/dark | Different thresholds by polarity |
| Font-size aware | Partially (large text exception) | Fully (thresholds vary by size+weight) |
| Accuracy | Over-reports some, under-reports others | More perceptually accurate |

### APCA Minimums

| Content | Minimum Lc | Notes |
|---------|-----------|-------|
| Body text (16px, 400) | Lc 75 | Primary content |
| Large text (24px+, 700) | Lc 45 | Headings |
| Non-text UI | Lc 30 | Borders, icons |
| Placeholder text | Lc 40 | Muted helper text |
| Disabled elements | No minimum | Visually distinct is enough |

### Testing with OKLCH

OKLCH makes contrast intuitive:

```css
/* Light mode: text L=0.15 on bg L=0.99 */
/* Delta L = 0.84 — excellent contrast */
--color-text: oklch(0.15 0 0);
--color-bg: oklch(0.99 0 0);

/* Dark mode: text L=0.93 on bg L=0.13 */
/* Delta L = 0.80 — excellent contrast */
--color-text: oklch(0.93 0 0);
--color-bg: oklch(0.13 0 0);

/* Secondary text: L=0.55 on bg L=0.99 */
/* Delta L = 0.44 — good for secondary content */
--color-text-secondary: oklch(0.55 0 0);
```

---

## Semantic HTML > ARIA

**The first rule of ARIA: don't use ARIA if native HTML works.**

```tsx
// BAD: div soup with ARIA
<div role="navigation" aria-label="Main">
  <div role="list">
    <div role="listitem">
      <div role="link" tabIndex={0} onClick={go}>Home</div>
    </div>
  </div>
</div>

// GOOD: semantic HTML
<nav aria-label="Main">
  <ul>
    <li><a href="/">Home</a></li>
  </ul>
</nav>
```

### Common Semantic Mappings

| Instead of | Use |
|-----------|-----|
| `<div role="button">` | `<button>` |
| `<div role="link">` | `<a href="...">` |
| `<div role="navigation">` | `<nav>` |
| `<div role="main">` | `<main>` |
| `<div role="banner">` | `<header>` |
| `<div role="contentinfo">` | `<footer>` |
| `<div role="heading">` | `<h1>`-`<h6>` |
| `<div role="img">` | `<img>` or `<figure>` |
| `<div role="list">` | `<ul>` or `<ol>` |
| `<span role="status">` | `<output>` |

### When ARIA IS Needed

```tsx
// Tabs (no native HTML element)
<div role="tablist">
  <button role="tab" aria-selected={activeTab === 0} aria-controls="panel-0">
    Tab 1
  </button>
</div>
<div role="tabpanel" id="panel-0" aria-labelledby="tab-0">
  Content
</div>

// Live regions (dynamic content updates)
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

// Disclosure (expandable sections)
<button aria-expanded={isOpen} aria-controls="content">
  Show Details
</button>
<div id="content" hidden={!isOpen}>
  Details here
</div>
```

---

## Accessible Component Patterns

### Accessible Form

```tsx
function SignupForm() {
  return (
    <form aria-label="Sign up" noValidate onSubmit={handleSubmit}>
      <div className="space-y-4">
        {/* Label + input always linked */}
        <div>
          <label htmlFor="email" className="text-sm font-medium">
            Email <span aria-hidden="true">*</span>
            <span className="sr-only">(required)</span>
          </label>
          <input
            id="email"
            type="email"
            required
            aria-describedby="email-hint email-error"
            aria-invalid={errors.email ? "true" : undefined}
            className="mt-1 block w-full rounded-lg border px-3 py-2"
          />
          <p id="email-hint" className="mt-1 text-xs text-muted-foreground">
            We'll never share your email.
          </p>
          {errors.email && (
            <p id="email-error" role="alert" className="mt-1 text-xs text-destructive">
              {errors.email}
            </p>
          )}
        </div>

        <button type="submit" className="w-full rounded-lg bg-primary py-2 text-primary-foreground">
          Sign Up
        </button>
      </div>
    </form>
  );
}
```

### Screen Reader Only Text

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

```tsx
// Icon button with screen reader label
<button className="icon-button">
  <X className="size-4" aria-hidden="true" />
  <span className="sr-only">Close dialog</span>
</button>
```

---

## Testing Tools

| Tool | Type | When to Use |
|------|------|-------------|
| **axe-core** | Automated | CI pipeline, catch common issues |
| **Playwright a11y** | Automated | E2E a11y testing |
| **axe DevTools** | Browser extension | Manual dev testing |
| **VoiceOver** (macOS) | Screen reader | Manual testing |
| **NVDA** (Windows) | Screen reader | Manual testing |
| **Lighthouse** | Audit | Quick overview scoring |
| **WAVE** | Browser extension | Visual a11y overlay |

### Automated Testing with Playwright

```ts
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("home page has no a11y violations", async ({ page }) => {
  await page.goto("/");

  const results = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag22aa"])
    .analyze();

  expect(results.violations).toEqual([]);
});

test("modal is accessible", async ({ page }) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Open dialog" }).click();

  const results = await new AxeBuilder({ page })
    .include('[role="dialog"]')
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### axe-core in Unit Tests

```tsx
import { render } from "@testing-library/react";
import { axe } from "jest-axe";

test("Button is accessible", async () => {
  const { container } = render(
    <button>Click me</button>
  );
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

---

## Checklist

- [ ] All interactive elements reachable via keyboard (Tab)
- [ ] Focus indicator visible (`:focus-visible`)
- [ ] Focus never obscured by sticky/fixed elements
- [ ] Touch targets >= 24x24px
- [ ] Color contrast meets APCA Lc 60+ for text
- [ ] Images have descriptive alt text (or `alt=""` for decorative)
- [ ] Forms have linked labels (`htmlFor` / `id`)
- [ ] Error messages linked via `aria-describedby`
- [ ] Dynamic content uses `aria-live` regions
- [ ] Modals trap focus
- [ ] `prefers-reduced-motion` respected
- [ ] Skip navigation link present
- [ ] Heading hierarchy is logical (h1 > h2 > h3)
- [ ] Language attribute set (`<html lang="en">`)
- [ ] No CAPTCHA without alternative
