# Automated Accessibility Testing

## axe-core Integration
```javascript
// Playwright + axe-core
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('page has no a11y violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});

// Exclude known issues
const results = await new AxeBuilder({ page })
  .exclude('.third-party-widget')
  .withTags(['wcag2a', 'wcag2aa', 'wcag22aa'])
  .analyze();
```

## Lighthouse CI
```yaml
# lighthouserc.js
module.exports = {
  ci: {
    collect: { url: ['http://localhost:3000/'] },
    assert: {
      assertions: {
        'categories:accessibility': ['error', { minScore: 0.9 }],
      },
    },
  },
};
```

## WCAG 2.2 Key Checks (Automated)
- Images have alt text
- Form inputs have labels
- Color contrast ratios (4.5:1 normal, 3:1 large text)
- Focus order is logical
- ARIA attributes are valid
- Heading hierarchy is correct (h1 → h2 → h3)

## What Automation Misses (Manual Required)
- Keyboard navigation flow
- Screen reader experience
- Meaningful alt text (not just present)
- Focus management in SPAs
- Dynamic content announcements
