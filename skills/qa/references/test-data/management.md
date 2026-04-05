# Test Data Management

## Approaches

### 1. Fixtures (Static Data)

Best for: reference data, configuration, known-good examples.

```python
import pytest
import json
from pathlib import Path

FIXTURES_DIR = Path(__file__).parent / "fixtures"

@pytest.fixture
def valid_user_payload() -> dict:
    return {
        "name": "Alice Smith",
        "email": "alice@test.com",
        "role": "user",
    }

@pytest.fixture
def sample_products() -> list[dict]:
    return json.loads((FIXTURES_DIR / "products.json").read_text())
```

### 2. Factories (Dynamic Data)

Best for: tests needing many variations of the same entity.

```python
import factory
from factory import fuzzy

class UserFactory(factory.Factory):
    class Meta:
        model = User

    id = factory.LazyFunction(uuid4)
    name = factory.Faker("name")
    email = factory.LazyAttribute(
        lambda o: f"{o.name.lower().replace(' ', '.')}@test.com"
    )
    role = "user"
    is_active = True
    created_at = factory.LazyFunction(datetime.utcnow)

class AdminFactory(UserFactory):
    role = "admin"

class InactiveUserFactory(UserFactory):
    is_active = False

# SQLAlchemy integration
class UserModelFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = UserModel
        sqlalchemy_session_persistence = "commit"

    # same fields as above
```

### 3. Builders (Complex Graphs)

Best for: entities with many relationships.

```python
class OrderBuilder:
    def __init__(self) -> None:
        self._user = UserFactory()
        self._items: list[Product] = []
        self._discount = 0.0
        self._status = "pending"

    def with_user(self, user: User) -> "OrderBuilder":
        self._user = user
        return self

    def with_item(self, product: Product, qty: int = 1) -> "OrderBuilder":
        self._items.extend([product] * qty)
        return self

    def with_discount(self, pct: float) -> "OrderBuilder":
        self._discount = pct
        return self

    def with_status(self, status: str) -> "OrderBuilder":
        self._status = status
        return self

    def build(self) -> Order:
        return Order(
            user=self._user,
            items=self._items,
            discount=self._discount,
            status=self._status,
        )

# Usage
order = (OrderBuilder()
    .with_user(AdminFactory())
    .with_item(ProductFactory(price=50.0), qty=2)
    .with_discount(0.1)
    .build())
```

### 4. Seeding (Database Pre-Population)

Best for: shared reference data needed by many tests.

```python
@pytest.fixture(scope="session")
def seed_reference_data(db_engine):
    """Seed data that all tests need (countries, currencies, roles)."""
    with Session(db_engine) as session:
        session.add_all([
            Role(name="admin"), Role(name="user"), Role(name="viewer"),
            Currency(code="USD"), Currency(code="EUR"), Currency(code="BRL"),
        ])
        session.commit()
```

## Cleanup Strategies

### Transaction Rollback (fastest)
```python
@pytest.fixture(autouse=True)
def auto_rollback(db_session):
    yield
    db_session.rollback()
```

### Truncation (when rollback not possible)
```python
@pytest.fixture(autouse=True)
def truncate(db_engine):
    yield
    with db_engine.connect() as conn:
        conn.execute(text("TRUNCATE TABLE orders, users CASCADE"))
        conn.commit()
```

## Rules

1. **Each test creates its own data** -- never rely on state from another test
2. **Use factories over raw SQL** -- factories respect model validation
3. **Avoid sequential IDs in assertions** -- use UUIDs or query by attribute
4. **Never use production data** -- synthetic data only
5. **Seed only reference/lookup data** -- countries, roles, currencies
6. **Clean up after each test** -- transaction rollback preferred
