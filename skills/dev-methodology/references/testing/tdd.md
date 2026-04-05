# TDD Deep Dive

## The Three Laws of TDD (Robert C. Martin)

1. You may not write production code until you have written a failing unit test
2. You may not write more of a unit test than is sufficient to fail
3. You may not write more production code than is sufficient to pass the currently failing test

## RED-GREEN-REFACTOR in Detail

### RED: Write a Failing Test

```python
# Start with the simplest behavior
def test_new_cart_has_zero_total():
    cart = Cart()
    assert cart.total == 0
```

Run it. It fails (Cart doesn't exist yet). Good.

### GREEN: Make It Pass (Simplest Way)

```python
class Cart:
    @property
    def total(self) -> float:
        return 0  # hardcoded — that's fine!
```

Yes, hardcoding is OK in the GREEN phase. The next test will force generalization.

### REFACTOR: Clean Up

Is there anything to clean? Not yet. Move to the next test.

### Next cycle: Force generalization

```python
def test_cart_with_one_item_has_item_price_as_total():
    cart = Cart()
    cart.add(Item(price=42.0))
    assert cart.total == 42.0
```

Now the hardcoded `return 0` fails. Implement for real:

```python
class Cart:
    def __init__(self):
        self._items: list[Item] = []

    def add(self, item: Item) -> None:
        self._items.append(item)

    @property
    def total(self) -> float:
        return sum(item.price for item in self._items)
```

## TDD Rhythm

```
Test 1: Degenerate case (empty, zero, null)
Test 2: Simplest non-trivial case
Test 3: Another case that forces generalization
Test 4: Edge case or error case
Test 5+: Additional behaviors
```

## Common Mistakes

### Testes implementation, not behavior
```python
# BAD: tests the internal structure
def test_cart_stores_items_in_list():
    cart = Cart()
    cart.add(Item(price=10))
    assert len(cart._items) == 1  # testing private state

# GOOD: tests the observable behavior
def test_cart_with_one_item_reports_correct_count():
    cart = Cart()
    cart.add(Item(price=10))
    assert cart.item_count == 1
```

### Too many tests at once
Write ONE test, make it pass, refactor. Then the next. Never batch.

### Skipping the refactor step
The refactor step is where design emerges. Skipping it leads to messy code
that happens to pass tests.

## When TDD is Hard

- **UI code:** Use BDD/integration tests instead of unit TDD
- **Third-party integrations:** Mock the boundary, TDD the logic
- **Exploratory/spike work:** Skip TDD, but write tests before merging
- **Legacy code without tests:** Add characterization tests first, then TDD new changes
