# Integration Testing Patterns

## Real Dependencies vs Mocks -- Decision Matrix

| Dependency | Real | Mock | Rationale |
|------------|------|------|-----------|
| PostgreSQL | testcontainers | -- | Query behavior differs between real DB and mock |
| Redis | testcontainers | -- | TTL, pub/sub behavior needs real Redis |
| MongoDB | testcontainers | -- | Aggregation pipeline needs real engine |
| RabbitMQ/Kafka | testcontainers | -- | Message ordering, ack behavior |
| Stripe/PayPal | -- | respx/httpx mock | Rate limits, cost, determinism |
| Email (SMTP) | -- | mock | No real email in tests |
| S3 | localstack | -- | File operations need real-ish storage |
| External REST APIs | -- | respx/wiremock | You do not control them |

## Testcontainers Patterns

### PostgreSQL

```python
import pytest
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg

@pytest.fixture(scope="session")
def db_url(postgres):
    return postgres.get_connection_url()
```

### Redis

```python
from testcontainers.redis import RedisContainer

@pytest.fixture(scope="session")
def redis():
    with RedisContainer("redis:7-alpine") as r:
        yield r

@pytest.fixture
def redis_client(redis):
    import redis as r
    client = r.from_url(redis.get_connection_url())
    yield client
    client.flushdb()
```

## HTTP Mocking with respx

```python
import httpx
import respx

@pytest.fixture
def mock_stripe():
    with respx.mock:
        respx.post("https://api.stripe.com/v1/charges").mock(
            return_value=httpx.Response(200, json={
                "id": "ch_test_123",
                "status": "succeeded",
                "amount": 5000,
            })
        )
        yield

async def test_payment_success(client, mock_stripe, sample_order):
    response = await client.post(f"/orders/{sample_order.id}/pay")
    assert response.status_code == 200
    assert response.json()["payment_status"] == "succeeded"
```

## FastAPI Integration Testing

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.fixture
async def client(db_session):
    """Test client with real database, mocked external services."""
    app.dependency_overrides[get_db] = lambda: db_session
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()

async def test_create_user(client):
    response = await client.post("/users", json={
        "name": "Alice",
        "email": "alice@test.com",
    })
    assert response.status_code == 201
    assert response.json()["name"] == "Alice"

async def test_create_user_duplicate_email(client, existing_user):
    response = await client.post("/users", json={
        "name": "Bob",
        "email": existing_user.email,  # duplicate
    })
    assert response.status_code == 409
```

## Scope Rules

Each integration test validates **one integration point**:

```
GOOD: API endpoint + database
GOOD: Service + cache
GOOD: Service + message queue
GOOD: Service + external API (mocked)

BAD:  API + database + cache + queue + external API  (that is E2E)
```

## Assertions

```python
# Assert on HTTP response
assert response.status_code == 200
assert response.json()["id"] is not None

# Assert on database side effect
user = db_session.query(User).filter_by(email="alice@test.com").one()
assert user.name == "Alice"

# Assert on cache side effect
cached = redis_client.get(f"user:{user.id}")
assert cached is not None

# Assert on mock interactions
assert mock_stripe.calls.call_count == 1
```
