---
name: ci-cd
description: |
  CI/CD pipeline knowledge base (2026). Covers pipeline design principles (fail fast, trunk-based
  development), GitHub Actions workflow patterns (reusable workflows, matrix builds, environments),
  automated quality gates (SAST, dependency scanning, coverage thresholds, contract tests),
  deployment strategies (blue/green, canary, feature flags, rolling), rollback procedures,
  artifact management (Docker image tagging, registry hygiene), environment promotion (dev →
  staging → production), release management (semantic versioning, conventional commits, changelog
  generation), and CI discipline (commit standards, branch protection, merge strategies).
  Use when: (1) Designing CI/CD pipelines, (2) Writing GitHub Actions workflows, (3) Choosing
  deployment strategies, (4) Setting up quality gates, (5) Implementing release automation.
  Triggers: /ci-cd, /ci, /cd, GitHub Actions, pipeline, deployment, release, blue/green, canary.
type: knowledge
---

# CI/CD — Knowledge Base

## Purpose

This skill is the knowledge base for CI/CD pipeline design (2026).
It covers pipeline architecture, quality gates, deployment strategies, and release automation.

**What this skill contains:**
- Pipeline design principles (fail fast, parallelism, caching)
- GitHub Actions patterns (reusable workflows, matrix, environments, OIDC)
- Quality gates (SAST, dependency scan, coverage, contract tests)
- Deployment strategies (blue/green, canary, rolling, feature flags)
- Rollback procedures
- Artifact management (Docker images, versioning, registry)
- Environment promotion (dev → staging → production)
- Release management (semantic versioning, changelog, GitHub releases)
- CI discipline (commit standards, branch protection)

---

## Philosophy

### The Three Laws of CI/CD

1. **The build is always green** — a failing build blocks everyone; fix it immediately
2. **Fast feedback wins** — developers should know if their change is broken in < 5 minutes
3. **Automation over ceremony** — if a human does it manually on every merge, automate it

### Trunk-Based Development

```
main (trunk)  ←— short-lived feature branches (< 2 days)
               ←— hotfix branches (< hours)

Deployments from main only.
Feature branches merged via PR, never survive more than 2 days.
Feature flags for in-progress work that's merged but not released.
```

---

## 1. Pipeline Design Principles

### Stage Ordering (Fail Fast)

```
1. Lint + Format check     (30s)    — fail immediately on style violations
2. Unit tests              (2-5m)   — fast, isolated, no external dependencies
3. Build                   (2-5m)   — compile, bundle, Docker build
4. Integration tests       (5-10m)  — requires real or mocked services
5. Security scan           (2-5m)   — SAST, dependency vulnerabilities
6. Contract tests          (1-2m)   — API contract validation
7. Performance tests       (5-15m)  — k6/locust, only on staging
8. E2E tests               (10-20m) — Playwright, only on staging
9. Deploy staging          (2-5m)   — automatic on main
10. Smoke tests on staging (1-2m)   — verify deployment health
11. Deploy production      (2-5m)   — manual approval gate
12. Smoke tests production (1-2m)   — verify production health
```

### Parallelism

```yaml
# Run independent jobs in parallel to reduce total pipeline time
jobs:
  lint:           { ... }  # runs in parallel with tests
  unit-tests:     { ... }  # runs in parallel with lint
  type-check:     { ... }  # runs in parallel with lint and tests
  security-scan:  { needs: [lint, unit-tests] }
  build:          { needs: [lint, unit-tests, type-check] }
  integration:    { needs: [build] }
  deploy-staging: { needs: [integration, security-scan] }
```

---

## 2. GitHub Actions Patterns

### Base Python CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  quality:
    name: Code Quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: "pip"

      - name: Install dependencies
        run: |
          pip install poetry==2.3.3
          poetry install --no-interaction

      - name: Lint (ruff)
        run: poetry run ruff check .

      - name: Format check (black)
        run: poetry run black --check .

      - name: Type check (mypy)
        run: poetry run mypy src/

      - name: Unit tests
        run: poetry run pytest tests/unit -v --cov=src --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage.xml
          fail_ci_if_error: true
          threshold: 80

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: pip-audit
        run: |
          pip install pip-audit==2.7.3
          pip-audit --requirement requirements.txt --strict

      - name: Semgrep SAST
        uses: semgrep/semgrep-action@v1
        with:
          config: "p/python p/owasp-top-ten"
```

### TypeScript CI Workflow

```yaml
# .github/workflows/ci-ts.yml
name: CI TypeScript

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v3
        with:
          version: 10.33.0

      - uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: "pnpm"

      - run: pnpm install --frozen-lockfile

      - run: pnpm run type-check
      - run: pnpm run lint          # biome check
      - run: pnpm run test          # vitest run
      - run: pnpm run build

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
```

### Reusable Workflows

```yaml
# .github/workflows/deploy.yml (reusable)
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image_tag:
        required: true
        type: string
    secrets:
      DEPLOY_TOKEN:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: ${{ inputs.environment }}
      url: https://${{ inputs.environment }}.example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: ./scripts/deploy.sh ${{ inputs.environment }} ${{ inputs.image_tag }}
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}

# Caller workflow
jobs:
  deploy-staging:
    needs: [build]
    uses: ./.github/workflows/deploy.yml
    with:
      environment: staging
      image_tag: ${{ needs.build.outputs.image_tag }}
    secrets:
      DEPLOY_TOKEN: ${{ secrets.STAGING_DEPLOY_TOKEN }}
```

### OIDC Authentication (No Long-Lived Secrets)

```yaml
jobs:
  deploy:
    permissions:
      id-token: write   # required for OIDC
      contents: read

    steps:
      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions-deploy
          aws-region: us-east-1
          # No AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY needed
```

**Reference:** [references/github-actions.md](references/github-actions.md)

---

## 3. Quality Gates

### Coverage Thresholds

```yaml
# pytest — fail if coverage drops below threshold
- name: Unit tests with coverage
  run: |
    poetry run pytest tests/unit \
      --cov=src \
      --cov-fail-under=80 \
      --cov-report=xml \
      --cov-report=term-missing

# vitest — same for TypeScript
- name: Tests with coverage
  run: |
    pnpm vitest run --coverage \
      --coverage.thresholds.lines=80 \
      --coverage.thresholds.branches=80
```

### Contract Testing in CI

```yaml
- name: Run Pact contract tests
  run: |
    poetry run pytest tests/contract -v
    # Publish pacts to Pact Broker
    poetry run pact-broker publish ./pacts \
      --broker-base-url ${{ vars.PACT_BROKER_URL }} \
      --consumer-app-version ${{ github.sha }}

- name: Verify provider contracts
  run: |
    PACT_BROKER_BASE_URL=${{ vars.PACT_BROKER_URL }} \
    GIT_COMMIT=${{ github.sha }} \
    poetry run pytest tests/provider -v
```

### Branch Protection Rules

```yaml
# Repository settings (via GitHub UI or terraform)
Branch protection for main:
  required_status_checks:
    - CI / Code Quality
    - CI / Security Scan
  required_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
  restrictions:
    push: []  # nobody pushes directly to main
  enforce_admins: true
  require_linear_history: true  # squash or rebase only
```

---

## 4. Docker Build and Registry

### Multi-Stage Build in CI

```yaml
- name: Build Docker image
  id: build
  run: |
    IMAGE_TAG="$REGISTRY/$SERVICE_NAME:${{ github.sha }}"
    LATEST_TAG="$REGISTRY/$SERVICE_NAME:latest"

    docker build \
      --target runtime \
      --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
      --build-arg GIT_COMMIT=${{ github.sha }} \
      --tag "$IMAGE_TAG" \
      --tag "$LATEST_TAG" \
      --cache-from "$REGISTRY/$SERVICE_NAME:cache" \
      .

    echo "image_tag=$IMAGE_TAG" >> $GITHUB_OUTPUT

- name: Scan image for vulnerabilities
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ steps.build.outputs.image_tag }}
    severity: CRITICAL,HIGH
    exit-code: 1

- name: Push image
  run: |
    docker push ${{ steps.build.outputs.image_tag }}
    docker push "$REGISTRY/$SERVICE_NAME:latest"
```

### Image Tagging Strategy

```
Development:   registry/service:sha-abc1234
Staging:       registry/service:staging-sha-abc1234
Production:    registry/service:v1.2.3
Latest:        registry/service:latest  (always production)

Never tag with "latest" for non-production images.
Never mutate an existing tag (except "latest").
Use SHA tags for auditability and rollback.
```

---

## 5. Deployment Strategies

### Blue/Green Deployment

```yaml
# Blue/Green: two identical environments, traffic switch
deploy-blue-green:
  steps:
    - name: Deploy to inactive environment
      run: |
        ACTIVE=$(get_active_env)
        INACTIVE=$([ "$ACTIVE" = "blue" ] && echo "green" || echo "blue")

        # Deploy to inactive
        deploy_to_env $INACTIVE $IMAGE_TAG

        # Run smoke tests on inactive
        run_smoke_tests $INACTIVE

    - name: Switch traffic
      run: |
        switch_traffic_to $INACTIVE  # atomic, < 1s downtime

    - name: Wait and verify
      run: |
        sleep 60
        verify_error_rate $INACTIVE
        if [ $? -ne 0 ]; then
          switch_traffic_to $ACTIVE  # automatic rollback
          exit 1
        fi
```

### Canary Deployment

```yaml
# Canary: gradual traffic shift
deploy-canary:
  steps:
    - name: Deploy canary (5% traffic)
      run: kubectl set image deployment/api api=$IMAGE_TAG --namespace=production
      # Canary gets 5% of traffic via load balancer weights

    - name: Monitor canary metrics (15 min)
      run: |
        for i in {1..15}; do
          ERROR_RATE=$(get_error_rate canary)
          LATENCY=$(get_p99_latency canary)
          if [ "$ERROR_RATE" -gt 5 ] || [ "$LATENCY" -gt 1000 ]; then
            echo "Canary degraded: error_rate=$ERROR_RATE latency=$LATENCY"
            rollback_canary
            exit 1
          fi
          sleep 60
        done

    - name: Promote to 100%
      run: promote_canary_to_stable
```

### Feature Flags

```python
# Use feature flags for risky features merged to main
from typing import Any

class FeatureFlags:
    def __init__(self, posthog_client: Any) -> None:
        self.client = posthog_client

    def is_enabled(self, flag: str, user_id: str) -> bool:
        return self.client.feature_enabled(flag, user_id)

# In code
if feature_flags.is_enabled("new_checkout_flow", request.user.id):
    return new_checkout(cart)
return legacy_checkout(cart)
```

**Reference:** [references/deployment-strategies.md](references/deployment-strategies.md)

---

## 6. Rollback Procedures

### Rollback Decision Matrix

| Scenario | Rollback Method | Time |
|----------|----------------|------|
| Code bug (no DB migration) | Redeploy previous image | < 5 min |
| Code bug (reversible migration) | Redeploy + run down migration | 5-15 min |
| Data corruption | Database restore from backup | 15-60 min |
| External service failure | Feature flag disable | < 2 min |
| Blue/green active | Traffic switch back to blue | < 1 min |

### Automated Rollback Triggers

```yaml
- name: Post-deploy health check
  run: |
    # Check error rate for 5 minutes after deploy
    for i in {1..5}; do
      ERROR_RATE=$(curl -s "$METRICS_URL/error_rate" | jq .value)
      if (( $(echo "$ERROR_RATE > 5" | bc -l) )); then
        echo "ERROR: Error rate $ERROR_RATE% exceeds 5% threshold"
        # Trigger rollback
        kubectl rollout undo deployment/api
        exit 1
      fi
      sleep 60
    done
    echo "Deploy healthy: error rate $ERROR_RATE%"
```

---

## 7. Release Management

### Conventional Commits

```
Format: <type>(<scope>): <description>

Types:
  feat:     New feature                  → MINOR version bump
  fix:      Bug fix                      → PATCH version bump
  perf:     Performance improvement      → PATCH version bump
  refactor: Code change (no feature/fix) → No version bump
  docs:     Documentation only           → No version bump
  test:     Tests only                   → No version bump
  chore:    Build, CI, config changes    → No version bump
  BREAKING CHANGE: (footer)              → MAJOR version bump

Examples:
  feat(auth): add OAuth2 login with Google
  fix(api): handle null response from payment gateway
  feat(checkout)!: replace cart API — BREAKING CHANGE in response format
  chore(ci): upgrade Actions runners to ubuntu-24.04
```

### Automated Release Workflow

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # full history for changelog

      - name: Create release
        uses: googleapis/release-please-action@v4
        id: release
        with:
          release-type: python  # or node
          # Reads conventional commits, bumps version, generates CHANGELOG

      - name: Build and push release image
        if: steps.release.outputs.release_created
        run: |
          VERSION=${{ steps.release.outputs.tag_name }}
          docker build -t "$REGISTRY/$SERVICE:$VERSION" .
          docker push "$REGISTRY/$SERVICE:$VERSION"
          docker tag "$REGISTRY/$SERVICE:$VERSION" "$REGISTRY/$SERVICE:latest"
          docker push "$REGISTRY/$SERVICE:latest"
```

### Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR: Breaking API change, incompatible change for consumers
MINOR: New backward-compatible feature
PATCH: Backward-compatible bug fix

Pre-release: 1.2.0-alpha.1, 1.2.0-rc.1
Build metadata: 1.2.0+20260401.sha1234

Rules:
- Never release from a branch other than main
- Tag releases with git tags (v1.2.3)
- CHANGELOG.md updated in every release commit
- GitHub Release created automatically from tag
```

---

## 8. CI Discipline

### Commit Standards

```
Rules:
1. Use conventional commit format (feat:, fix:, etc.)
2. One logical change per commit
3. Tests pass before committing (enforced by pre-commit hooks)
4. No merge commits on main (squash or rebase)
5. Commit message explains WHY, not just WHAT

Pre-commit hooks (pre-commit framework):
  - Lint check (ruff / biome)
  - Type check (mypy / tsc)
  - Test evidence check (no commits without test file changes)
  - Secret scanning (detect-secrets)
  - Conventional commit message format
```

### Branch Strategy

```
main          ← always deployable, always green
  └── feat/issue-42-user-oauth    (short-lived, < 2 days)
  └── fix/payment-null-response   (same day)
  └── chore/upgrade-python-3-12   (same day)

Rules:
- Never commit directly to main
- PRs require 1 approval + all CI green
- Squash merges: clean git history on main
- Delete branches after merge
```

---

## Reference Files

- [references/github-actions.md](references/github-actions.md) — Actions patterns, OIDC, reusable workflows
- [references/deployment-strategies.md](references/deployment-strategies.md) — Blue/green, canary, rolling, feature flags
- [references/quality-gates.md](references/quality-gates.md) — Coverage, SAST, contract tests, thresholds
- [references/docker-registry.md](references/docker-registry.md) — Image tagging, multi-stage builds, scanning
- [references/release-management.md](references/release-management.md) — Semantic versioning, conventional commits, changelog
- [references/rollback.md](references/rollback.md) — Rollback procedures, automated triggers, decision matrix
