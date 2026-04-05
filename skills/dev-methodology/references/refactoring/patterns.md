# Refactoring Patterns

## Decision Tree

```
What are you refactoring?
  |
  +-- Entire system/component? --> Strangler Fig
  |
  +-- Deep internal component with upstream callers? --> Branch by Abstraction
  |
  +-- Public API/interface with multiple consumers? --> Parallel Change
  |
  +-- Large change with unknown dependency graph? --> Mikado Method
  |
  +-- Small code smell in current file? --> Direct refactor (RED-GREEN-REFACTOR)
```

## 1. Strangler Fig Pattern

**Named after:** Martin Fowler, 2004. Inspired by strangler fig trees that grow around a host tree.

**When:** Replacing a large legacy system or component incrementally.

**Steps:**
```
1. IDENTIFY   — Choose one feature/route/API to migrate
2. BUILD      — Create new implementation alongside old
3. ROUTE      — Redirect traffic/calls to new implementation
4. VERIFY     — Monitor new implementation in production
5. REPEAT     — Next feature/route/API
6. REMOVE     — Delete old code when fully migrated
```

**Implementation patterns:**

### Facade/Router approach
```python
class OrderRouter:
    """Routes to old or new implementation based on feature flag."""

    def __init__(self, legacy: LegacyOrderService, modern: ModernOrderService):
        self._legacy = legacy
        self._modern = modern

    async def create_order(self, request: OrderRequest) -> Order:
        if feature_flags.is_enabled("modern_orders"):
            return await self._modern.create_order(request)
        return await self._legacy.create_order(request)
```

### Gradual traffic shifting
```
Week 1: 1% traffic to new system (canary)
Week 2: 10% traffic (validate metrics)
Week 3: 50% traffic (load test)
Week 4: 100% traffic (full migration)
Week 5: Remove old code
```

**Key rules:**
- Always have a rollback mechanism (feature flag, reverse proxy)
- Monitor both implementations side-by-side
- Complete the migration — do not leave two implementations forever
- Each migration step must be independently deployable

---

## 2. Branch by Abstraction

**When:** Refactoring a component deep in the stack that has many upstream callers.

**Steps:**
```
1. ABSTRACT  — Create an interface/protocol for the component
2. ADAPT     — Make the old component implement the interface
3. MIGRATE   — Change all callers to use the interface
4. IMPLEMENT — Build the new component behind the interface
5. SWITCH    — Point the interface to the new implementation
6. CLEAN     — Remove the old component and the abstraction (if no longer needed)
```

**Example:**

```python
# Step 1: Create abstraction
class NotificationSender(Protocol):
    async def send(self, user_id: str, message: str) -> None: ...

# Step 2: Old implementation adopts the interface
class EmailNotifier:  # already implements the protocol
    async def send(self, user_id: str, message: str) -> None:
        # ... sends email ...

# Step 3: Callers use the interface (dependency injection)
class OrderService:
    def __init__(self, notifier: NotificationSender):
        self._notifier = notifier

# Step 4: Build new implementation
class SlackNotifier:
    async def send(self, user_id: str, message: str) -> None:
        # ... sends Slack message ...

# Step 5: Switch injection
# In DI container: bind NotificationSender -> SlackNotifier

# Step 6: Remove EmailNotifier
```

**Key difference from Strangler Fig:**
- Strangler Fig works at the **perimeter** (API routes, endpoints)
- Branch by Abstraction works **deep in the stack** (internal components)

---

## 3. Parallel Change (Expand-Migrate-Contract)

**When:** Changing a public API or interface that has multiple consumers.

**The three phases:**

### Phase 1: EXPAND
Add the new interface alongside the old one. Both work. Nothing breaks.

```python
class UserService:
    # OLD — keep it working
    def get_user(self, user_id: int) -> dict:
        user = self._repo.find(user_id)
        return {"id": user.id, "name": user.name}

    # NEW — add alongside
    def get_user_v2(self, user_id: str) -> UserResponse:
        user = self._repo.find_by_uuid(user_id)
        return UserResponse(id=user.uuid, name=user.name)
```

### Phase 2: MIGRATE
Move consumers one by one to the new interface.

```python
# Before: consumer uses old API
user_data = user_service.get_user(42)

# After: consumer uses new API
user = user_service.get_user_v2("uuid-123")
```

### Phase 3: CONTRACT
Once all consumers migrated, remove the old interface.

```python
class UserService:
    # Only new API remains
    def get_user(self, user_id: str) -> UserResponse:
        user = self._repo.find_by_uuid(user_id)
        return UserResponse(id=user.uuid, name=user.name)
```

**Key rule:** Each phase is a separate, deployable commit/PR.

---

## 4. Mikado Method

**When:** Large refactoring where dependencies are unclear.

**The algorithm:**
```
1. Set the goal (e.g., "replace ORM X with ORM Y")
2. Try to implement the goal directly
3. If it compiles and tests pass → DONE
4. If it breaks:
   a. Note what broke (the prerequisite)
   b. REVERT your change
   c. Add the prerequisite to your Mikado Graph
   d. Set the prerequisite as the new goal
   e. Go to step 2
5. When a leaf goal succeeds, commit it
6. Work back up the graph until the root goal succeeds
```

**Mikado Graph example:**
```
Replace ORM X with ORM Y (ROOT GOAL)
  |
  +-- Update UserRepository to use ORM Y
  |     |
  |     +-- Create ORM Y session factory
  |     +-- Update User model to ORM Y format
  |
  +-- Update OrderRepository to use ORM Y
  |     |
  |     +-- Update Order model to ORM Y format
  |     +-- Update migration scripts
  |
  +-- Remove ORM X dependency from requirements.txt
```

**Key benefits:**
- Discovers the true dependency graph through experimentation
- Each commit is small and safe (one leaf at a time)
- Natural ordering — you always fix prerequisites before the goal
- Revert-first culture — never leave the codebase broken

---

## Safety Rules for All Refactoring

1. **Tests first** — Never refactor without tests. If tests don't exist, add characterization tests first.
2. **Small steps** — Each step is independently deployable and testable.
3. **One thing at a time** — Never mix refactoring with feature work in the same commit.
4. **Verify at each step** — Run the full test suite after every change.
5. **Rollback plan** — Always know how to revert if something goes wrong.
