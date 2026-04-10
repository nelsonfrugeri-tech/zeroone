---
name: api-design
description: |
  API design knowledge base (2026). Covers REST (resource naming, HTTP methods, status codes,
  pagination, versioning, HATEOAS), GraphQL (schema-first, resolvers, DataLoader, persisted queries),
  gRPC (Protocol Buffers, streaming, deadline propagation), OpenAPI contract-first workflow,
  idempotency patterns, error response standards, rate limiting, backward compatibility rules,
  and API design checklists.
  Use when: (1) Designing REST, GraphQL, or gRPC APIs, (2) Writing OpenAPI/Protobuf contracts,
  (3) Evaluating versioning strategy, (4) Defining error response formats, (5) Reviewing API design.
  Triggers: /api-design, /api, REST, GraphQL, gRPC, OpenAPI, API design, pagination, versioning.
type: knowledge
---

# API Design — Knowledge Base

## Purpose

This skill is the knowledge base for designing APIs (2026).
It covers REST, GraphQL, gRPC, contract-first workflow, and the patterns that make APIs
predictable, evolvable, and safe.

**What this skill contains:**
- REST design (resources, HTTP methods, status codes, versioning, pagination)
- GraphQL (schema-first, N+1 prevention, persisted queries)
- gRPC (Protocol Buffers, streaming types, deadlines)
- OpenAPI / Protobuf contract-first workflow
- Error response standards
- Idempotency patterns
- Rate limiting and throttling
- Backward compatibility rules
- API design checklist

---

## Philosophy

### Contract First

Define the contract before implementation. Code without a contract is an implementation
detail masquerading as an API.

1. Write the OpenAPI spec (or Protobuf / GraphQL schema) first
2. Generate stubs, mocks, and client SDKs from the contract
3. Implement against the spec
4. Validate implementation against the spec in CI

### Least Surprise Principle

An API is a user interface for developers. Every design decision should minimize surprise:
- Consistent naming conventions across all endpoints
- Consistent error formats regardless of what failed
- Consistent behavior for edge cases (empty lists, null fields, timestamps)

---

## 1. REST API Design

### Resource Naming

```
# GOOD — nouns, plural, hierarchical
GET    /users                   # list users
POST   /users                   # create user
GET    /users/{id}              # get user
PATCH  /users/{id}              # partial update
DELETE /users/{id}              # delete user
GET    /users/{id}/orders       # list user orders
POST   /users/{id}/orders       # create order for user

# BAD — verbs in path
GET    /getUser/{id}            # no verbs
POST   /createOrder             # no verbs
POST   /users/{id}/activate     # exception: actions on resources
```

### HTTP Methods

| Method | Idempotent | Safe | Use Case |
|--------|-----------|------|---------|
| GET | Yes | Yes | Read resource |
| HEAD | Yes | Yes | Read headers only |
| POST | No | No | Create resource, non-idempotent actions |
| PUT | Yes | No | Replace resource entirely |
| PATCH | No | No | Partial update |
| DELETE | Yes | No | Remove resource |

### HTTP Status Codes

```
2xx — Success
  200 OK              GET, PATCH, DELETE success
  201 Created         POST success (include Location header)
  202 Accepted        Async operation accepted
  204 No Content      DELETE success, no body

4xx — Client Error
  400 Bad Request     Validation failed, malformed request
  401 Unauthorized    Authentication required
  403 Forbidden       Authenticated but not authorized
  404 Not Found       Resource does not exist
  409 Conflict        State conflict (duplicate, version mismatch)
  410 Gone            Resource permanently deleted
  422 Unprocessable   Semantic validation failed
  429 Too Many Reqs   Rate limit exceeded

5xx — Server Error
  500 Internal Error  Unexpected server failure
  502 Bad Gateway     Upstream service failed
  503 Unavailable     Service temporarily down
  504 Gateway Timeout Upstream timed out
```

### Standard Error Response

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "value": "not-an-email"
      }
    ],
    "request_id": "req_abc123",
    "documentation_url": "https://api.example.com/docs/errors#VALIDATION_FAILED"
  }
}
```

### Versioning Strategies

| Strategy | Example | Pros | Cons |
|----------|---------|------|------|
| URL path | `/v1/users` | Simple, cacheable, explicit | URL pollution |
| Header | `Accept: application/vnd.api+json;version=1` | Clean URLs | Less visible |
| Query param | `/users?version=1` | Easy to test | Cache issues |

**Recommendation:** URL path versioning for public APIs. Header versioning for internal APIs.

### Pagination

```
# Cursor-based (recommended for large datasets)
GET /items?cursor=eyJpZCI6MTAwfQ==&limit=20
Response:
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTIwfQ==",
    "has_more": true
  }
}

# Page-based (acceptable for small datasets with UI pagination)
GET /items?page=2&per_page=20
Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "per_page": 20,
    "total": 450,
    "total_pages": 23
  }
}
```

**Cursor-based pagination rules:**
- Cursor is opaque (base64-encoded, not guessable)
- Stable under concurrent writes (no offset drift)
- Required for infinite scroll, real-time feeds

### Filtering and Sorting

```
# Filtering
GET /products?category=electronics&min_price=100&max_price=500
GET /orders?status=pending&created_after=2025-01-01T00:00:00Z

# Sorting
GET /products?sort=price&order=asc
GET /products?sort=-price          # minus prefix = descending

# Field selection (sparse fieldsets)
GET /users?fields=id,name,email    # return only specified fields
```

**Reference:** [references/rest-patterns.md](references/rest-patterns.md)

---

## 2. GraphQL

### When to Use GraphQL

| Use GraphQL | Use REST |
|-------------|---------|
| Data-intensive UI (multiple resources per screen) | Simple CRUD APIs |
| Clients need flexible field selection | File upload/download |
| Multiple consumer types (mobile, web, 3rd party) | Simple public APIs |
| Rapid UI iteration (frontend changes fields freely) | Webhook receivers |

### Schema-First Workflow

```graphql
# schema.graphql — define contract first
type User {
  id: ID!
  name: String!
  email: String!
  orders(first: Int = 10, after: String): OrderConnection!
  createdAt: DateTime!
}

type Order {
  id: ID!
  status: OrderStatus!
  total: Float!
  items: [OrderItem!]!
}

type OrderConnection {
  edges: [OrderEdge!]!
  pageInfo: PageInfo!
}

type OrderEdge {
  node: Order!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}

enum OrderStatus {
  PENDING
  CONFIRMED
  SHIPPED
  DELIVERED
  CANCELLED
}

type Query {
  user(id: ID!): User
  users(first: Int = 10, after: String, filter: UserFilter): UserConnection!
}

type Mutation {
  createOrder(input: CreateOrderInput!): CreateOrderPayload!
  cancelOrder(id: ID!): CancelOrderPayload!
}
```

### DataLoader — N+1 Prevention

```typescript
import DataLoader from "dataloader";

// Without DataLoader: N+1 queries
// For 100 orders, 100 separate DB calls to load each user

// With DataLoader: batch and cache
const userLoader = new DataLoader<string, User>(async (userIds) => {
	const users = await db.user.findMany({ where: { id: { in: [...userIds] } } });
	const userMap = new Map(users.map((u) => [u.id, u]));
	return userIds.map((id) => userMap.get(id) ?? new Error(`User ${id} not found`));
});

// Resolver uses DataLoader — automatically batched
const orderResolvers = {
	Order: {
		user: (order: Order, _args: unknown, ctx: Context) =>
			ctx.loaders.user.load(order.userId),
	},
};
```

### Persisted Queries (Production)

```typescript
// Prevents arbitrary query execution in production
// Client sends hash, server looks up the full query

const persistedQueries = new Map<string, string>();

function persistedQueryPlugin(): ApolloServerPlugin {
	return {
		requestDidStart: async () => ({
			async didResolveOperation({ request, document }) {
				if (process.env.NODE_ENV === "production") {
					const hash = request.extensions?.persistedQuery?.sha256Hash;
					if (!hash || !persistedQueries.has(hash)) {
						throw new ForbiddenError("Unpersisted query not allowed in production");
					}
				}
			},
		}),
	};
}
```

**Reference:** [references/graphql-patterns.md](references/graphql-patterns.md)

---

## 3. gRPC

### When to Use gRPC

| Use gRPC | Use REST/GraphQL |
|----------|-----------------|
| Internal service-to-service | External/public API |
| High-throughput, low-latency | Browser clients (without grpc-web) |
| Bidirectional streaming | Simple request-response |
| Strongly typed contracts critical | Flexible schema evolution |

### Protocol Buffers

```protobuf
// user.proto
syntax = "proto3";

package user.v1;

import "google/protobuf/timestamp.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (stream User);
  rpc CreateUser(CreateUserRequest) returns (User);
  rpc UpdateUser(UpdateUserRequest) returns (User);
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  google.protobuf.Timestamp created_at = 4;
  UserStatus status = 5;
}

enum UserStatus {
  USER_STATUS_UNSPECIFIED = 0;
  USER_STATUS_ACTIVE = 1;
  USER_STATUS_SUSPENDED = 2;
}

message GetUserRequest {
  string id = 1;
}

message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
  string filter = 3;
}
```

### Streaming Types

| Type | Pattern | Use Case |
|------|---------|---------|
| Unary | 1 req → 1 resp | Standard RPC call |
| Server streaming | 1 req → many resp | File download, live feed |
| Client streaming | many req → 1 resp | File upload, batch write |
| Bidirectional | many req ↔ many resp | Chat, real-time collaboration |

### Deadline Propagation (Always)

```python
import grpc

channel = grpc.insecure_channel("localhost:50051")
stub = UserServiceStub(channel)

# ALWAYS set a deadline
try:
    user = stub.GetUser(
        GetUserRequest(id="usr_123"),
        timeout=5.0,  # seconds — never omit this
    )
except grpc.RpcError as e:
    if e.code() == grpc.StatusCode.DEADLINE_EXCEEDED:
        raise TimeoutError(f"GetUser timed out after 5s")
    if e.code() == grpc.StatusCode.NOT_FOUND:
        raise NotFoundError("User", "usr_123")
    raise ExternalServiceError("user-service", e)
```

**Reference:** [references/grpc-patterns.md](references/grpc-patterns.md)

---

## 4. OpenAPI Contract-First

### OpenAPI 3.1 Structure

```yaml
openapi: "3.1.0"
info:
  title: User API
  version: "1.0.0"
  description: |
    API for user management.
    See [authentication guide](https://docs.example.com/auth) for details.

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging

paths:
  /users/{id}:
    get:
      operationId: getUser
      summary: Get a user by ID
      tags: [users]
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            pattern: "^usr_[a-zA-Z0-9]{20}$"
      responses:
        "200":
          description: User found
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/User"
        "404":
          $ref: "#/components/responses/NotFound"

components:
  schemas:
    User:
      type: object
      required: [id, name, email, created_at]
      properties:
        id:
          type: string
          example: "usr_abc123"
        name:
          type: string
          minLength: 1
          maxLength: 100
        email:
          type: string
          format: email
        created_at:
          type: string
          format: date-time
  responses:
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

### Contract-First CI Validation

```yaml
# GitHub Actions
- name: Validate OpenAPI spec
  uses: actions/setup-node@v4
- run: npx @redocly/cli lint openapi.yaml
- run: npx @redocly/cli check-config openapi.yaml

- name: Check for breaking changes
  uses: oasdiff/oasdiff-action@main
  with:
    base: origin/main:openapi.yaml
    revision: openapi.yaml
    fail-on-diff: breaking
```

**Reference:** [references/openapi-workflow.md](references/openapi-workflow.md)

---

## 5. Idempotency

```
Idempotent: calling the same operation multiple times has the same effect as calling it once.

Why it matters:
- Network failures → clients retry → server processes duplicate
- Without idempotency: double charges, duplicate records, data corruption

Strategies:
1. Client-provided idempotency key (header: Idempotency-Key: <uuid>)
2. Server stores result for 24h–7 days
3. Return stored result for duplicate requests
4. Response includes: X-Idempotent-Replayed: true
```

```yaml
# OpenAPI: document idempotency key
paths:
  /payments:
    post:
      parameters:
        - name: Idempotency-Key
          in: header
          required: true
          schema:
            type: string
            format: uuid
          description: |
            Unique key to ensure idempotency. Generate a UUID per operation attempt.
            Duplicate requests with the same key return the cached response.
```

---

## 6. Rate Limiting

### Response Headers

```
X-RateLimit-Limit: 1000        # requests allowed per window
X-RateLimit-Remaining: 750     # requests remaining in current window
X-RateLimit-Reset: 1701388800  # unix timestamp when window resets
Retry-After: 30                # seconds to wait after 429
```

### Rate Limit Strategies

| Strategy | Pros | Cons | Use Case |
|----------|------|------|---------|
| Fixed window | Simple | Burst at window edge | Internal APIs |
| Sliding window | Smooth distribution | More complex | Public APIs |
| Token bucket | Burst-friendly | State per client | CDN, reverse proxy |
| Leaky bucket | Consistent rate | Queues requests | Payment APIs |

---

## 7. Backward Compatibility Rules

### Non-Breaking Changes (safe to ship)

- Adding optional request fields
- Adding response fields (clients ignore unknown fields)
- Adding new endpoints
- Adding new enum values (if clients handle unknowns)
- Expanding allowed values for a field

### Breaking Changes (require new API version)

- Removing or renaming fields
- Changing field types
- Adding required request fields
- Changing endpoint URLs
- Changing behavior of existing operations
- Removing enum values

### Deprecation Protocol

```
1. Add Deprecation header to responses:
   Deprecation: true
   Sunset: Wed, 31 Dec 2025 23:59:59 GMT
   Link: <https://api.example.com/v2/users>; rel="successor-version"

2. Log deprecated endpoint usage (by client)
3. Notify API consumers 6 months before sunset
4. Remove after sunset date
```

---

## API Design Checklist

```markdown
### Contract
- [ ] Contract defined first (OpenAPI / Protobuf / GraphQL schema)
- [ ] Breaking changes documented vs non-breaking
- [ ] Versioning strategy decided and documented

### REST
- [ ] Resource names are nouns, plural
- [ ] HTTP methods used correctly (GET safe, PUT idempotent)
- [ ] HTTP status codes are accurate
- [ ] Error responses follow standard format
- [ ] Pagination implemented (cursor-based for large collections)

### Security
- [ ] Authentication documented (Bearer, API key, OAuth2)
- [ ] Authorization checked at each endpoint
- [ ] Rate limiting configured
- [ ] Input validation on all parameters
- [ ] Sensitive fields never in URLs (use POST body or headers)

### Reliability
- [ ] Idempotency key for mutation endpoints
- [ ] Retry-After header for 429 responses
- [ ] Timeout documentation
- [ ] Maximum response payload documented

### Developer Experience
- [ ] Example requests and responses in spec
- [ ] Error codes documented with explanations
- [ ] Changelog for API versions
- [ ] SDK or code examples for common languages
```

---

## Reference Files

- [references/rest-patterns.md](references/rest-patterns.md) — REST patterns, naming, pagination, filtering
- [references/graphql-patterns.md](references/graphql-patterns.md) — Schema-first, DataLoader, persisted queries
- [references/grpc-patterns.md](references/grpc-patterns.md) — Protocol Buffers, streaming, interceptors
- [references/openapi-workflow.md](references/openapi-workflow.md) — Contract-first, code generation, validation
- [references/error-standards.md](references/error-standards.md) — Error response formats, problem+json
- [references/idempotency.md](references/idempotency.md) — Idempotency key pattern, storage, replay
