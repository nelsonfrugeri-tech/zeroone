# Implementation Discipline

## The RED-GREEN-REFACTOR Cycle in Practice

### RED Phase
```python
# Write a test that captures the desired behavior
def test_calculate_total_with_discount():
    order = Order(items=[Item(price=100), Item(price=50)])
    order.apply_discount(percent=10)
    assert order.total == 135.0  # (100 + 50) * 0.9
```

Run it. It fails. Good.

### GREEN Phase
```python
# Write the SIMPLEST code that passes
class Order:
    def __init__(self, items: list[Item]):
        self.items = items
        self._discount = 0

    def apply_discount(self, percent: int) -> None:
        self._discount = percent

    @property
    def total(self) -> float:
        subtotal = sum(item.price for item in self.items)
        return subtotal * (1 - self._discount / 100)
```

Run it. It passes. Good.

### REFACTOR Phase
- Is the code clean?
- Are names descriptive?
- Is there duplication?
- Can we simplify?

Only refactor when ALL tests are green.

## Commit Rhythm

```
Write test (RED)     → don't commit yet
Make it pass (GREEN) → COMMIT: "test: add discount calculation"
Refactor             → COMMIT: "refactor: extract subtotal method"
Next test (RED)      → repeat cycle
```

## Implementation Anti-Patterns

### The Big Bang
Writing all code first, then running tests.
Fix: one test at a time, run after each change.

### Gold Plating
Adding features not in the requirements.
Fix: only implement what the tests require.

### Premature Optimization
Optimizing before measuring.
Fix: make it work, make it right, make it fast (in that order).

### Shotgun Surgery
Changing many files for one feature.
Fix: design better abstractions, reduce coupling.
