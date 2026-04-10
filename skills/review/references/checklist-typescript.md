# TypeScript/React Code Review Checklist

Detailed checklist for TypeScript/React/Next.js code review. 28 checks across 7 categories.

---

## How to Use

For each modified TypeScript/TSX file:
1. Go through the categories below sequentially
2. Mark [x] when item verified
3. If you find a violation, write a comment with: check violated, typical severity, code fix

Severity is indicative. Use judgment based on context.

---

## Security

### [ ] 1. Secrets and Env Vars
**Check:**
- No API keys, tokens, passwords in client-side code
- Env vars with `NEXT_PUBLIC_` only for genuinely public data
- Secrets used only in Server Components or API routes
- `.env.local` in `.gitignore`

**Typical severity:** BLOCKER

---

### [ ] 2. XSS Prevention
**Check:**
- `dangerouslySetInnerHTML` never used with user input without sanitization
- DOMPurify or equivalent used when dynamic HTML is necessary
- `href` with `javascript:` protocol blocked
- User-generated content escaped by default

**Typical severity:** BLOCKER

---

### [ ] 3. CSRF and Forms
**Check:**
- Forms with CSRF tokens when necessary
- Server Actions with origin validation
- Fetch requests with credentials correctly configured

**Typical severity:** MAJOR

---

### [ ] 4. Authentication and Authorization
**Check:**
- Protected routes with middleware or layout guards
- Tokens not stored in localStorage (prefer httpOnly cookies)
- Permission checks before showing sensitive data
- Server Components used for data requiring auth

**Typical severity:** BLOCKER (public routes) / MAJOR (internal)

---

### [ ] 5. Input Validation
**Check:**
- Form data validated with Zod or equivalent
- Server Actions validate input before processing
- Schemas shared between client and server when possible
- File uploads with type and size validation

**Typical severity:** MAJOR

---

## Accessibility

### [ ] 6. Semantic HTML
**Check:**
- `<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`, `<header>`, `<footer>` used correctly
- `<button>` for actions, `<a>` for navigation (never `<div onClick>`)
- Headings in hierarchical order (h1 > h2 > h3)
- Lists (`<ul>`, `<ol>`) for list content

**Typical severity:** MAJOR

---

### [ ] 7. ARIA Labels and Roles
**Check:**
- Custom interactive elements have `role` and `aria-label`
- Icon-only buttons have `aria-label`
- `aria-live` for dynamic content that changes
- `aria-hidden="true"` on decorative elements
- `aria-expanded`, `aria-selected` on menus and tabs

**Typical severity:** MAJOR (interactive elements) / MINOR (decorative)

---

### [ ] 8. Keyboard Navigation
**Check:**
- All interactive elements accessible via Tab
- Logical tab order (no `tabIndex` > 0)
- Escape closes modals/dropdowns
- Enter/Space activates buttons
- Arrow keys for menu/tab navigation
- Focus trap in modals

**Typical severity:** MAJOR

---

### [ ] 9. Focus Management
**Check:**
- Focus moved to modal when it opens
- Focus returns to trigger when modal closes
- Focus visible (outline not removed globally)
- Skip links for main content
- `autoFocus` used carefully

**Typical severity:** MAJOR (modals) / MINOR (general)

---

### [ ] 10. Color and Contrast
**Check:**
- Contrast ratio >= 4.5:1 for normal text (WCAG AA)
- Contrast ratio >= 3:1 for large text (>18px bold, >24px)
- Information not conveyed by color alone (icons, patterns, text)
- Dark mode with adequate contrast

**Typical severity:** MINOR

---

### [ ] 11. Images and Media
**Check:**
- All informative images have descriptive `alt`
- Decorative images have `alt=""`
- Videos have captions/subtitles when possible
- SVGs accessible with `role="img"` and `aria-label`

**Typical severity:** MAJOR (informative images) / NIT (decorative)

---

## Performance

### [ ] 12. Bundle Size
**Check:**
- No imports of entire libraries when only one function is needed
- Dynamic imports (`next/dynamic`, `React.lazy`) for heavy components
- Tree-shaking working (named imports, not default from barrel files)
- No duplicate dependencies

**Typical severity:** MAJOR (>50KB added) / MINOR (<50KB)

---

### [ ] 13. Render Optimization
**Check:**
- `React.memo` on pure components rendered frequently
- `useMemo` for expensive computations
- `useCallback` for callbacks passed as props
- Stable keys in lists (never array index if list changes)
- State at correct level (no unnecessary lifting)
- No cascading state updates causing multiple re-renders

**Typical severity:** MINOR / MAJOR (large lists, tables)

---

### [ ] 14. Images and Assets
**Check:**
- `next/image` used instead of `<img>` (automatic optimization)
- Modern formats (WebP, AVIF) when possible
- `loading="lazy"` for images below the fold
- `priority` on LCP images (hero, above fold)
- Correct `sizes` prop for responsive images

**Typical severity:** MINOR / MAJOR (LCP images)

---

### [ ] 15. Data Fetching
**Check:**
- Data fetching on server when possible (Server Components)
- `fetch` with `cache` and `revalidate` correctly configured
- No waterfalls (parallel data fetching with `Promise.all`)
- Loading states with Suspense boundaries
- Streaming with React Server Components when applicable

**Typical severity:** MAJOR (waterfalls on critical pages) / MINOR

---

### [ ] 16. Core Web Vitals
**Check:**
- LCP: main element renders fast (no blocking)
- CLS: stable layouts (sizes defined for images/ads/embeds)
- INP: interactions respond fast (<200ms)
- No layout shifts caused by fonts, images, or dynamic content

**Typical severity:** MAJOR

---

## Testing

### [ ] 17. Component Tests
**Check:**
- Critical components have tests with Testing Library
- Tests interact as user (click, type, not implementation details)
- Accessible queries used (`getByRole`, `getByLabelText`, not `getByTestId`)
- States tested (loading, error, empty, success)

**Typical severity:** BLOCKER (critical components without tests) / MAJOR (coverage <50%)

---

### [ ] 18. Hook Tests
**Check:**
- Custom hooks tested with `renderHook`
- Side effects tested (API calls, subscriptions)
- Cleanup verified (event listeners, timers)

**Typical severity:** MAJOR

---

### [ ] 19. E2E Tests
**Check:**
- Critical flows covered (login, checkout, main CRUD)
- Playwright or Cypress configured
- Tests not brittle (no hard waits, stable locators)
- CI pipeline runs E2E

**Typical severity:** MAJOR (critical flows) / MINOR

---

### [ ] 20. Accessibility Tests
**Check:**
- axe-core integrated in tests
- `toHaveNoViolations()` in component tests
- Keyboard navigation tests in interactive components

**Typical severity:** MINOR

---

## Code Quality

### [ ] 21. TypeScript Strict
**Check:**
- No `any` (use `unknown` if type is truly unknown)
- No `@ts-ignore` or `@ts-expect-error` without justification
- Generics used correctly
- Utility types used where appropriate (Partial, Pick, Omit, Record)
- Discriminated unions for state machines
- `satisfies` operator for type validation

**Typical severity:** MINOR (`any` in isolated places) / MAJOR (`any` in public interfaces)

---

### [ ] 22. Component Design
**Check:**
- Props typed with interface or type (not inline)
- Components < 200 lines (if more, decompose)
- Single Responsibility (one component, one responsibility)
- Composition over inheritance
- Default exports for pages, named exports for components

**Typical severity:** MINOR / MAJOR (components >300 lines)

---

### [ ] 23. Error Handling
**Check:**
- Error Boundaries on routes/layouts
- `error.tsx` files in App Router
- Fetch errors handled with try/catch
- Clear user-facing error messages
- Sentry or equivalent for error tracking

**Typical severity:** MAJOR (routes without error boundary) / MINOR

---

### [ ] 24. Naming and Conventions
**Check:**
- Components: PascalCase (`UserProfile`, not `userProfile`)
- Hooks: `use` prefix (`useAuth`, not `getAuth`)
- Files: kebab-case or match component name
- Constants: UPPER_SNAKE_CASE
- Boolean props: `is`, `has`, `should` prefix

**Typical severity:** MINOR

---

## Architecture

### [ ] 25. Server vs Client Components
**Check:**
- `"use client"` only where necessary (interactivity, hooks, browser APIs)
- Sensitive data only in Server Components
- Serializable props between Server and Client Components
- Not passing functions as props from Server to Client Components

**Typical severity:** MAJOR (`"use client"` unnecessarily in large tree) / MINOR

---

### [ ] 26. State Management
**Check:**
- Local state when possible (useState, useReducer)
- Context for shared state in small tree
- External store (Zustand, Jotai) for complex global state
- URL state for filters/pagination (nuqs, useSearchParams)
- No excessive prop drilling (>3 levels)

**Typical severity:** MINOR / MAJOR (wrong state management at scale)

---

### [ ] 27. Data Fetching Patterns
**Check:**
- Server Components for static/SSR data fetching
- React Server Actions for mutations
- SWR/TanStack Query for client-side data fetching with cache
- No fetch in useEffect when Server Component is possible
- Loading states (Suspense, loading.tsx)

**Typical severity:** MAJOR (unnecessary fetch in useEffect) / MINOR

---

## Styling

### [ ] 28. Tailwind and Design System
**Check:**
- Tailwind classes consistent (not mixing with CSS modules without reason)
- Design tokens used (theme colors, not hardcoded hex)
- Responsive design with correct breakpoints (sm, md, lg, xl)
- Dark mode using `dark:` variant when applicable
- Consistent spacing (use scale: 1, 2, 3, 4, not arbitrary values)

**Typical severity:** NIT (minor inconsistencies) / MINOR (design system violation)

---

## Automation Tools

```bash
# Type checking
npx tsc --noEmit

# Linting + formatting
npx biome check .

# Accessibility audit
npx axe-core-cli http://localhost:3000

# Bundle analysis
npx @next/bundle-analyzer

# Testing
npx vitest run

# E2E
npx playwright test

# Lighthouse CI
npx lhci autorun
```
