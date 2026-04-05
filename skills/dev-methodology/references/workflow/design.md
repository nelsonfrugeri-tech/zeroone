# Design Documentation

## Scale to Task Size

### Trivial (< 1 hour)
No artifact needed. Mental model is sufficient.
Examples: rename variable, fix typo, update config value.

### Small (1-4 hours)
Comment in the issue or a brief note.
Examples: add a new endpoint, fix a bug, add validation.

```markdown
## Approach
- Add `DELETE /api/users/{id}` endpoint
- Soft delete (set `deleted_at` timestamp)
- Return 404 if user not found
- Return 204 on success
```

### Medium (1-3 days)
Brief design note with bullet points.
Examples: new feature, significant refactor, new integration.

```markdown
## Design: {Feature Name}

### Problem
{1-2 sentences}

### Approach
{bullet points}

### Interfaces
{key function signatures or API contracts}

### Data Model
{schema changes if any}

### Edge Cases
{list of edge cases and how to handle them}

### Open Questions
{anything unresolved}
```

### Large (1+ week)
Full design document with diagrams.
Examples: new service, architecture change, major feature.

Include everything from Medium plus:
- Architecture diagram
- Sequence diagrams for key flows
- Migration plan (if changing existing systems)
- Rollout plan (feature flags, gradual rollout)
- Monitoring and alerting plan

## Interface-First Design

Always define the public interface before implementation:

```python
# Define the contract first
class OrderService(Protocol):
    async def create_order(self, request: CreateOrderRequest) -> Order: ...
    async def get_order(self, order_id: str) -> Order: ...
    async def cancel_order(self, order_id: str) -> None: ...
```

```typescript
// Define the contract first
interface OrderService {
  createOrder(request: CreateOrderRequest): Promise<Order>;
  getOrder(orderId: string): Promise<Order>;
  cancelOrder(orderId: string): Promise<void>;
}
```

This forces you to think about consumers before implementation.
