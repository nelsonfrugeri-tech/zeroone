# Bug Fix Systematic Process

## REPRODUCE > ISOLATE > WRITE TEST > FIX > VALIDATE > PREVENT

### Step 1: REPRODUCE

**Goal:** Reliably trigger the bug.

Document:
```markdown
## Bug Reproduction

### Environment
- OS: {os}
- Version: {app version}
- Database: {state}

### Steps
1. {step 1}
2. {step 2}
3. {step 3}

### Expected
{what should happen}

### Actual
{what actually happens}

### Frequency
{always / intermittent / specific conditions}
```

**If you cannot reproduce:**
- Check logs for the error
- Check if it is environment-specific
- Check if data-dependent
- Ask for more details from the reporter
- Do NOT guess-fix without reproduction

### Step 2: ISOLATE

**Techniques:**

**Binary search in code:**
```python
# Comment out half the code path
# Does the bug still happen?
# If yes: bug is in the remaining half
# If no: bug is in the commented-out half
# Repeat until found
```

**git bisect:**
```bash
git bisect start
git bisect bad HEAD          # current: has bug
git bisect good v1.2.0       # known good version
# Git checks out a middle commit
# Test it, then:
git bisect good  # or git bisect bad
# Repeat until found
git bisect reset
```

**Logging:**
```python
# Add strategic logging to narrow down
logger.debug("checkpoint_1", data=data)
# ... code ...
logger.debug("checkpoint_2", result=result)
```

### Step 3: WRITE TEST

```python
def test_order_total_does_not_overflow_with_large_quantities():
    """Regression test for BUG-1234: overflow on large orders."""
    order = Order(items=[Item(price=99999, quantity=99999)])
    # This MUST fail on the current code (before fix)
    assert order.total == Decimal("9999800001")
```

### Step 4: FIX

- Fix the ROOT CAUSE, not the symptom
- Minimum change required
- Do NOT mix with refactoring or features
- If the fix is complex, add a code comment explaining why

### Step 5: VALIDATE

```bash
# 1. Run the regression test
pytest tests/test_order.py::test_order_total_does_not_overflow -v

# 2. Run the full suite
pytest

# 3. Test the original reproduction case manually
```

### Step 6: PREVENT

- Is this a class of bug that can be caught by a linter rule?
- Should we add a type constraint to prevent this?
- Are there similar patterns elsewhere that need the same fix?
- Should we add monitoring/alerting for this condition?
