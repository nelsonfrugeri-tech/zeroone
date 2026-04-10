# Validation Checklist

## Automated Validation

### Python Projects
```bash
# 1. Lint
ruff check . --fix

# 2. Format
black --check .

# 3. Type check
mypy src/

# 4. Unit tests
pytest tests/unit/ -v

# 5. Integration tests
pytest tests/integration/ -v

# 6. Full suite with coverage
pytest --cov=src --cov-report=term-missing
```

### TypeScript Projects
```bash
# 1. Lint + Format
biome check --write .

# 2. Type check
tsc --noEmit

# 3. Unit tests
vitest run

# 4. E2E tests
playwright test

# 5. Coverage
vitest run --coverage
```

## Manual Validation

When automated tests are not sufficient:

### API Endpoints
```bash
# Test the endpoint manually
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "email": "test@example.com"}'

# Verify response code, body, headers
# Test error cases: invalid input, duplicate, unauthorized
```

### UI Changes
- Verify in at least 2 browsers
- Test responsive breakpoints (mobile, tablet, desktop)
- Test keyboard navigation
- Test with screen reader (if accessibility-relevant)
- Check dark mode (if applicable)

## Regression Check

After validation, always ask:
- Did I break any existing functionality?
- Did I change any shared code that other features use?
- Are there integration points that need testing?
