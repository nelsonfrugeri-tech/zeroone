# CI Discipline

## Core Rules
1. **Main is always green** — broken main blocks everyone
2. **Small commits** — each commit is a logical unit, independently reviewable
3. **Fast feedback** — CI runs in < 10 minutes (optimize: parallelize, cache, split)
4. **Fix broken builds immediately** — top priority, no new work until fixed

## Commit Hygiene
```
feat: add user registration endpoint     ← new feature
fix: handle null email in validation      ← bug fix  
refactor: extract auth middleware         ← no behavior change
test: add integration tests for payments  ← tests only
docs: update API documentation            ← docs only
chore: upgrade dependencies               ← maintenance
```

## Trunk-Based Development
- Short-lived branches (< 2 days)
- Small PRs (< 400 lines diff)
- Feature flags for incomplete features
- Merge to main frequently

## CI Pipeline Stages
```
1. Lint + Format check (< 30s)
2. Unit tests (< 2min)
3. Integration tests (< 5min)
4. Build artifact (< 2min)
5. Deploy to staging (automated)
6. E2E smoke tests (< 5min)
```

## Anti-patterns
- "I'll fix it later" commits to main
- Large PRs that sit in review for days
- Skipping CI with [skip ci] to "save time"
- Running only unit tests (no integration)
