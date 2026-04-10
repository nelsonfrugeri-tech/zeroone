# API Design — REST vs GraphQL vs gRPC

## REST Best Practices

### URL Design
```
GET    /v1/users              # List users
GET    /v1/users/123          # Get user by ID
POST   /v1/users              # Create user
PUT    /v1/users/123          # Replace user
PATCH  /v1/users/123          # Partial update
DELETE /v1/users/123          # Delete user

# Nested resources
GET    /v1/users/123/orders   # User's orders

# Filtering, sorting, pagination
GET    /v1/users?status=active&sort=-created_at&page[cursor]=abc&page[size]=20
```

### Pagination: Cursor-based vs Offset

| Approach | Pros | Cons | Use when |
|----------|------|------|----------|
| Cursor-based | Stable results, performant at scale | Opaque cursor, no "jump to page" | Large datasets, real-time data |
| Offset | Simple, "jump to page" | Inconsistent results, slow at high offset | Small datasets, admin UIs |

**Cursor-based response:**
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTIzfQ==",
    "has_more": true
  }
}
```

### Error Handling (RFC 9457 — Problem Details)

```json
{
  "type": "https://api.example.com/errors/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 422,
  "detail": "Account balance is $30.00, but transfer requires $50.00",
  "instance": "/transfers/abc-123",
  "balance": 30.00,
  "required": 50.00
}
```

### Idempotency

```
POST /v1/payments
Idempotency-Key: unique-client-generated-uuid

# Server stores result keyed by Idempotency-Key
# Repeated requests with same key return cached result
# Key expires after 24h
```

### Versioning Strategies

| Strategy | Example | Pros | Cons |
|----------|---------|------|------|
| URL path | `/v1/users` | Simple, explicit | URL changes |
| Header | `Accept: application/vnd.api.v1+json` | Clean URLs | Less discoverable |
| Query param | `/users?version=1` | Simple | Pollutes params |

**Recommendation:** URL path versioning for simplicity. Most APIs only need 2-3 versions.

## GraphQL Best Practices

### Schema Design

```graphql
type Query {
  user(id: ID!): User
  users(first: Int, after: String, filter: UserFilter): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}

# Relay-style pagination
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  cursor: String!
  node: User!
}

# Input/Payload pattern
input CreateUserInput {
  name: String!
  email: String!
}

type CreateUserPayload {
  user: User
  errors: [UserError!]!
}
```

### N+1 Prevention with DataLoader

```python
# Without DataLoader: N+1 queries
# users query -> 1 query
# for each user, fetch orders -> N queries

# With DataLoader: 2 queries total
from aiodataloader import DataLoader

async def batch_load_orders(user_ids: list[str]) -> list[list[Order]]:
    orders = await db.orders.find({"user_id": {"$in": user_ids}})
    # Group by user_id and return in same order as input
    ...

order_loader = DataLoader(batch_load_orders)
```

### Security

```
1. Depth limiting       — max query depth of 10
2. Complexity analysis   — assign cost to each field, limit total
3. Persisted queries     — client sends hash, server looks up query
4. Rate limiting         — per-query complexity, not just per-request
5. Introspection         — disable in production
```

## gRPC Best Practices

### Proto File Design

```protobuf
syntax = "proto3";
package ecommerce.v1;

service OrderService {
  rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse);
  rpc GetOrder(GetOrderRequest) returns (Order);
  rpc ListOrders(ListOrdersRequest) returns (ListOrdersResponse);
  rpc StreamOrderUpdates(StreamOrderUpdatesRequest) returns (stream OrderUpdate);
}

message CreateOrderRequest {
  string user_id = 1;
  repeated OrderItem items = 2;
  string idempotency_key = 3;
}

message CreateOrderResponse {
  Order order = 1;
}

message ListOrdersRequest {
  int32 page_size = 1;
  string page_token = 2;  // cursor-based pagination
  string filter = 3;       // e.g., "status=PENDING"
}

message ListOrdersResponse {
  repeated Order orders = 1;
  string next_page_token = 2;
}
```

### Backward Compatibility Rules

```
SAFE:
- Add new fields (with new field numbers)
- Add new RPC methods
- Add new enum values

UNSAFE (breaking):
- Remove or rename fields
- Change field numbers
- Change field types
- Remove RPC methods
- Change RPC signatures

Use `reserved` for removed fields:
message Order {
  reserved 4, 8;           // field numbers no longer in use
  reserved "old_field";     // field names no longer in use
}
```

### Deadlines and Timeouts

```
Always set deadlines:
- Client sets deadline for the entire call
- Server checks remaining time, propagates to downstream calls
- Default: 5s for simple queries, 30s for complex operations
- Never: infinite timeout (will leak resources)
```

## Hybrid Approach (Common in 2026)

```
                    Internet
                       |
                  API Gateway
                  /    |    \
           REST      GraphQL    (public APIs)
           /v1/*      /graphql
                       |
              Internal Services
              /        |        \
         gRPC       gRPC       gRPC     (internal communication)
        Service A   Service B   Service C
```

**Pattern:** REST for public simplicity, GraphQL for frontend flexibility,
gRPC for internal performance.

## Sources

- https://dev.to/cryptosandy/api-design-best-practices-in-2025-rest-graphql-and-grpc-234h
- https://www.designgurus.io/blog/rest-graphql-grpc-system-design
- RFC 9457 (Problem Details for HTTP APIs)
- https://relay.dev/graphql/connections.htm (Relay Cursor Connections Spec)
