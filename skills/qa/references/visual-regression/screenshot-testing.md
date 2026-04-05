# Visual Regression Testing

## Playwright Screenshots
```javascript
test('homepage visual', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixelRatio: 0.01,
    fullPage: true,
  });
});

// Component-level
test('button states', async ({ page }) => {
  const button = page.locator('.primary-button');
  await expect(button).toHaveScreenshot('button-default.png');
  await button.hover();
  await expect(button).toHaveScreenshot('button-hover.png');
});
```

## Update Baselines
```bash
npx playwright test --update-snapshots
```

## Tools Comparison
| Tool | Type | Best for |
|------|------|----------|
| Playwright screenshots | Built-in | Simple, no extra infra |
| Percy (BrowserStack) | Cloud SaaS | Cross-browser, team review UI |
| Chromatic (Storybook) | Cloud SaaS | Component libraries |
| reg-suit | Self-hosted | Open-source, CI integration |

## Best Practices
- Test at component level (less flaky than full pages)
- Consistent viewport size and fonts
- Hide dynamic content (timestamps, ads)
- Review diffs in CI before merging
- Don't screenshot everything — focus on critical UI
