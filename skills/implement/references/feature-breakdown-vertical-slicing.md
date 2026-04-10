# Vertical Slicing & Walking Skeleton

## Vertical Slice
A slice that touches ALL layers (UI → API → domain → DB) but delivers ONE narrow piece of functionality.

### Example
Instead of: "Build user management" (horizontal — all CRUD at once)
Do: "User can register with email" → "User can login" → "User can reset password"

Each slice is independently deployable and testable.

## INVEST Criteria for Slices
- **I**ndependent — no dependencies on other slices
- **N**egotiable — scope can be adjusted
- **V**aluable — delivers user value
- **E**stimable — small enough to estimate
- **S**mall — completable in 1-3 days
- **T**estable — clear acceptance criteria

## Walking Skeleton
Minimal end-to-end implementation that proves the architecture works.

```
Day 1: Empty endpoint → returns hardcoded response
Day 2: Endpoint → service → repository → real DB
Day 3: Basic error handling + health check
Day 4: CI/CD deploys skeleton to staging
```

Now you have: proven architecture, deployable pipeline, foundation to build on.

## Decomposition Strategy
1. Map the user journey (story map)
2. Identify the thinnest possible first slice
3. Build the walking skeleton for that slice
4. Iterate: each slice adds functionality to the skeleton
