# ATDD — Acceptance Test-Driven Development

## The ATDD Workflow

```
1. DISCUSS   — Team discusses the feature (devs + product + QA)
2. DISTILL   — Write acceptance criteria as Given/When/Then
3. DEVELOP   — Implement using TDD, driven by acceptance tests
4. DEMO      — Show the passing acceptance tests to stakeholders
```

## How ATDD Combines BDD + TDD

```
Acceptance Test (BDD layer — fails)
  |
  +-- Unit Test 1 (TDD — fails → pass)
  +-- Unit Test 2 (TDD — fails → pass)
  +-- Unit Test 3 (TDD — fails → pass)
  |
Acceptance Test (now passes — feature done)
```

**Example workflow:**

1. Write acceptance test:
```gherkin
Scenario: User places an order
  Given a logged-in user with items in cart
  When they submit the order
  Then the order is created with status "pending"
  And the user receives a confirmation email
```

2. This fails (no implementation). Now use TDD:
   - TDD cycle 1: `OrderService.create_order()` — basic creation
   - TDD cycle 2: `OrderService.create_order()` — sets status "pending"
   - TDD cycle 3: `EmailService.send_confirmation()` — sends email
   - TDD cycle 4: Integration — order creation triggers email

3. Acceptance test passes. Feature done.

## When to Use ATDD

- Complex features with multiple components
- Features crossing service boundaries
- Features requiring stakeholder sign-off
- Critical business flows (payments, auth, data processing)

## ATDD vs Pure TDD vs Pure BDD

| Approach | Best for |
|----------|----------|
| Pure TDD | Libraries, utilities, algorithms |
| Pure BDD | Simple features, API contracts |
| ATDD | Complex features, multi-component, stakeholder-visible |

## The Three Amigos

Before writing acceptance tests, hold a "Three Amigos" session:
- **Developer:** Technical feasibility, edge cases
- **Product:** Business value, acceptance criteria
- **QA:** Test scenarios, error conditions

Duration: 15-30 minutes per feature.
Output: Acceptance criteria in Given/When/Then format.
