# BDD — Behavior-Driven Development

## Given-When-Then Format

```gherkin
Feature: Shopping cart discount

  Scenario: Apply percentage discount to cart
    Given a cart with items totaling $100
    When I apply a 10% discount code "SAVE10"
    Then the cart total should be $90

  Scenario: Reject expired discount code
    Given a cart with items totaling $100
    And a discount code "OLD20" that expired yesterday
    When I apply the discount code "OLD20"
    Then the discount is rejected
    And the cart total remains $100
```

## BDD vs TDD

| Aspect | TDD | BDD |
|--------|-----|-----|
| Audience | Developers | Developers + Product + QA |
| Language | Code | Natural language (Gherkin) |
| Scope | Unit | Feature/behavior |
| Focus | Implementation correctness | Business value delivery |
| Artifacts | Unit tests | Executable specifications |

## When to Use BDD

- User-facing features with clear acceptance criteria
- Features that need stakeholder validation
- API contracts that multiple teams consume
- Onboarding: BDD specs serve as living documentation

## When NOT to Use BDD

- Internal implementation details
- Utility functions
- Performance optimizations
- Infrastructure code

## BDD Implementation

### Python (pytest-bdd)
```python
from pytest_bdd import scenario, given, when, then, parsers

@scenario("cart.feature", "Apply percentage discount to cart")
def test_apply_discount():
    pass

@given("a cart with items totaling $100")
def cart():
    return Cart(items=[Item(price=100)])

@when(parsers.parse('I apply a {percent:d}% discount code "{code}"'))
def apply_discount(cart, percent, code):
    cart.apply_discount(DiscountCode(code, percent=percent))

@then(parsers.parse("the cart total should be ${total:d}"))
def check_total(cart, total):
    assert cart.total == total
```

### TypeScript (Cucumber)
```typescript
import { Given, When, Then } from "@cucumber/cucumber";

Given("a cart with items totaling ${int}", function (total: number) {
  this.cart = new Cart([new Item({ price: total })]);
});

When("I apply a {int}% discount code {string}", function (percent: number, code: string) {
  this.cart.applyDiscount(new DiscountCode(code, percent));
});

Then("the cart total should be ${int}", function (expected: number) {
  expect(this.cart.total).toBe(expected);
});
```

## Writing Good Scenarios

**Rules:**
- One scenario = one behavior
- Use business language, not technical terms
- Avoid implementation details in scenarios
- Keep scenarios short (3-7 steps)
- Use Background for shared Given steps
