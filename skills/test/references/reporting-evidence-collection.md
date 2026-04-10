# Test Reporting & Evidence Collection

## CI Test Reports
```yaml
# GitHub Actions
- name: Run tests
  run: pytest --junitxml=report.xml --cov=app --cov-report=html

- name: Upload test results
  uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: report.xml

- name: Upload coverage
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: htmlcov/
```

## Evidence Artifacts
| Type | Format | Tool |
|------|--------|------|
| Test results | JUnit XML | pytest, jest |
| Coverage | HTML, Cobertura XML | coverage.py, istanbul |
| Screenshots | PNG | Playwright |
| Performance | JSON, HTML | k6, Locust |
| Accessibility | JSON | axe-core |
| API contracts | JSON | Pact |

## Coverage Thresholds
```toml
# pyproject.toml
[tool.coverage.report]
fail_under = 80

[tool.coverage.run]
branch = true
```

## PR Comment Pattern
Auto-comment on PRs with:
- Test pass/fail summary
- Coverage delta (increased/decreased)
- Performance regression flags
- Screenshot diff links (if visual tests)

## Anti-patterns
- Coverage as the only quality metric
- Storing test artifacts forever (retain 30 days)
- Ignoring flaky test reports
