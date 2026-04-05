# Test-First Principles

## Why Write Tests First

1. **Design feedback** — Tests force you to design testable interfaces
2. **Scope control** — You only implement what the tests require
3. **Living documentation** — Tests describe behavior, always up-to-date
4. **Confidence** — Refactor without fear
5. **Fewer defects** — IBM/Microsoft report up to 90% fewer defects

## The Test-First Mindset

```
BEFORE: "I wrote code, now I need to test it"
 (tests are afterthought, coverage padding, implementation-coupled)

AFTER:  "I wrote tests, now I need to make them pass"
 (tests drive design, encode behavior, catch regressions)
```

## Test Naming Convention

```
test_<behavior>_when_<condition>_then_<expected>
```

Good names:
```python
test_create_user_when_valid_email_then_returns_user
test_create_user_when_duplicate_email_then_raises_conflict
test_calculate_discount_when_premium_user_then_applies_10_percent
test_login_when_wrong_password_then_returns_401
```

Bad names:
```python
test_create_user           # too vague
test_create_user_1         # meaningless
test_happy_path            # no specificity
test_exception             # which exception?
```

## Test Structure: Arrange-Act-Assert

```python
def test_apply_discount_when_valid_code_then_reduces_total():
    # Arrange: set up the test scenario
    cart = Cart(items=[Item(price=100)])
    discount = DiscountCode("SAVE10", percent=10)

    # Act: perform the action under test
    cart.apply_discount(discount)

    # Assert: verify the expected outcome
    assert cart.total == 90.0
```

One test, one behavior. If you need multiple asserts, they should all verify the same behavior.

## What to Test

| Category | Test | Priority |
|----------|------|----------|
| Happy path | Normal use case works | P0 |
| Edge cases | Boundary conditions | P0 |
| Error cases | Invalid input, failures | P0 |
| Integration | Components work together | P1 |
| Performance | Meets latency requirements | P2 |
| Security | Auth, injection, access | P0 |

## What NOT to Test

- Private implementation details
- Framework/library internals
- Trivial getters/setters with no logic
- Third-party code (mock it instead)
