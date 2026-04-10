# Python Code Review Checklist

Detailed checklist for Python code review. 25 checks across 7 categories.

---

## How to Use

For each modified Python file:
1. Go through the categories below sequentially
2. Mark [x] when item verified
3. If you find a violation, write a comment with: check violated, typical severity, code fix

Severity is indicative. Use judgment based on context.

---

## Security

### [ ] 1. Secrets and Configuration
**Check:**
- No API keys, tokens, passwords hardcoded
- Configuration comes from environment variables
- Use pydantic-settings or similar

**Typical severity:** BLOCKER

---

### [ ] 2. External Input Validation
**Check:**
- Data from APIs, requests, files is validated
- Use Pydantic for schemas
- Required fields, types, custom validations

**Typical severity:** MAJOR

---

### [ ] 3. SQL Injection Prevention
**Check:**
- Parameterized queries (not string concatenation)
- Use ORM or prepared statements
- No f-strings in SQL

**Typical severity:** BLOCKER

---

### [ ] 4. Authentication and Authorization
**Check:**
- Endpoints protected when required
- Ownership/permissions checked
- Token validation adequate

**Typical severity:** BLOCKER (public endpoints) / MAJOR (internal)

---

### [ ] 5. Sensitive Data in Logs
**Check:**
- No passwords, tokens, PII in logs
- Structured logging without sensitive data
- Request/response bodies sanitized

**Typical severity:** BLOCKER

---

## Performance

### [ ] 6. N+1 Queries
**Check:**
- No loops with DB queries inside
- Eager loading of relationships
- JOINs instead of multiple queries

**Typical severity:** MAJOR

---

### [ ] 7. Efficient Algorithms
**Check:**
- Algorithmic complexity (avoid O(n²) or worse in hot paths)
- Appropriate data structures
- Expensive operations outside loops

**Typical severity:** MINOR / MAJOR (if in hot path)

---

### [ ] 8. Resource Management
**Check:**
- Context managers for files, connections, locks
- No memory leaks (bounded caches, cleaned references)
- Resources released properly

**Typical severity:** BLOCKER (confirmed leaks) / MAJOR (suspected)

---

## Testing

### [ ] 9. Test Coverage
**Check:**
- Critical code has tests (auth, payment, data)
- New endpoints/features have tests
- Coverage >60% (general), >80% (core), 100% (critical)

**Typical severity:** BLOCKER (critical code without tests) / MAJOR (coverage <50%)

---

### [ ] 10. Test Quality
**Check:**
- Tests are not brittle (no sleep, no hardcoded IDs/timestamps)
- Edge cases tested
- Specific and clear assertions

**Typical severity:** MINOR

---

## Code Quality

### [ ] 11. Type Hints
**Check:**
- Function parameters typed
- Function returns typed
- Complex variables typed
- Modern types used (`list[str]` not `List[str]`)

**Typical severity:** MINOR (private functions) / MAJOR (public APIs)

---

### [ ] 12. Error Handling
**Check:**
- Try/except on operations that can fail
- Specific exceptions (not generic `Exception`)
- Errors logged adequately
- Cleanup in `finally` or context managers

**Typical severity:** BLOCKER (critical operations) / MAJOR (APIs) / MINOR (general)

---

### [ ] 13. Structured Logging
**Check:**
- Logs on critical operations
- Context included (user_id, request_id, order_id)
- Appropriate levels (info/warning/error)
- Structured logging (JSON) preferred

**Typical severity:** MAJOR (APIs and services) / MINOR (internal code)

---

### [ ] 14. Docstrings
**Check:**
- Public APIs documented
- Complex functions explained
- Parameters and returns described
- Examples when necessary

**Typical severity:** MAJOR (public APIs) / MINOR (complex) / NIT (simple)

---

### [ ] 15. Naming
**Check:**
- Names reveal intent
- Conventions followed (snake_case functions, PascalCase classes)
- No obscure abbreviations
- Consistency within module

**Typical severity:** MINOR (variables) / MAJOR (public APIs)

---

### [ ] 16. Single Responsibility Principle
**Check:**
- Function does one thing
- <20-30 lines ideally
- Can be tested in isolation
- Name doesn't contain "and" (process_AND_send_AND_update)

**Typical severity:** MINOR / MAJOR (if very complex)

---

### [ ] 17. DRY (Don't Repeat Yourself)
**Check:**
- No duplicated code
- Repeated logic extracted to functions
- Patterns identified and abstracted

**Typical severity:** MINOR

---

### [ ] 18. Cyclomatic Complexity
**Check:**
- Decision points reasonable (<10 ideal, <15 acceptable)
- Nested if/loops minimized
- Function can be split if too complex

**Typical severity:** MINOR (>10) / MAJOR (>15)
**Tool:** `radon cc --min C`

---

### [ ] 19. Imports Organized
**Check:**
- Order: stdlib → third-party → local
- No unused imports
- No star imports (`import *`)
- One import per line

**Typical severity:** NIT
**Tool:** `ruff check --select I`

---

## Architecture

### [ ] 20. Separation of Concerns
**Check:**
- Models don't have business logic
- Controllers/endpoints are thin
- Services contain logic
- Repositories isolate data access

**Typical severity:** MINOR / MAJOR (serious violation)

---

### [ ] 21. Dependency Injection
**Check:**
- Dependencies injected, not imported directly
- Easy to test with mocks
- Configuration comes from outside

**Typical severity:** MINOR

---

## Configuration and Dependencies

### [ ] 22. Pinned Dependencies
**Check:**
- Versions pinned (requirements.txt or poetry.lock)
- No overly broad version ranges
- Dev dependencies separated

**Typical severity:** MAJOR (production) / MINOR (dev)

---

### [ ] 23. Correct Async/Await
**Check:**
- I/O-bound operations use async
- Does not block event loop
- Await on asynchronous operations

**Typical severity:** MAJOR (if blocking event loop) / MINOR (performance)

---

## Documentation

### [ ] 24. README Updated
**Check:**
- Setup instructions reflect changes
- New dependencies documented
- New endpoints/features described

**Typical severity:** MINOR

---

### [ ] 25. CHANGELOG Updated
**Check:**
- Breaking changes documented
- New features listed
- Consistent format

**Typical severity:** NIT

---

## Automation Tools

```bash
# Type checking
mypy src/

# Linting
ruff check .

# Security
bandit -r src/

# Complexity
radon cc src/ --min C

# Coverage
pytest --cov=src --cov-report=term-missing

# Imports
ruff check --select I
```
