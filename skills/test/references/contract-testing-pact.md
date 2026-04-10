# Consumer-Driven Contract Testing with Pact

## Conceito
Consumer defines expected interactions → generates contract (pact file) → provider verifies against it.

## Fluxo
```
1. Consumer writes test defining expected request/response
2. Pact generates contract file (JSON)
3. Contract published to Pact Broker
4. Provider runs verification against contract
5. Can-I-Deploy check before releasing
```

## Python Consumer Example
```python
# consumer_test.py
from pact import Consumer, Provider

pact = Consumer("OrderService").has_pact_with(Provider("PaymentService"))

def test_get_payment():
    expected = {"id": "pay-123", "status": "completed", "amount": 99.99}
    
    pact.given("payment exists")
    pact.upon_receiving("a request for payment")
    pact.with_request("GET", "/payments/pay-123")
    pact.will_respond_with(200, body=expected)
    
    with pact:
        result = payment_client.get_payment("pay-123")
        assert result["status"] == "completed"
```

## When to Use
- Microservices with REST/GraphQL APIs
- Multiple teams own different services
- Need confidence that API changes don't break consumers

## When NOT to Use
- Monolith (use integration tests)
- Single team owns all services
- Async/event-driven (use schema registry instead)

## Tools: Pact 5.x (2026), Pact Broker, can-i-deploy CLI
