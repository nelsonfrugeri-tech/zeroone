# Mem0 Knowledge Structure

## Memory Types
| Type | Content | Lifecycle |
|------|---------|-----------|
| User | Preferences, role, expertise | Long-lived, rarely changes |
| Feedback | How to work, corrections, confirmations | Long-lived, accumulates |
| Project | Goals, initiatives, deadlines | Medium-lived, changes with project |
| Reference | External resource pointers | Long-lived, verify before using |

## Storage Rules
1. **Store the non-obvious** — don't store what code/git can tell you
2. **Store the WHY** — not the WHAT (code shows what, memory explains why)
3. **Absolute dates** — convert "next Thursday" to "2026-04-10"
4. **Verify before acting** — memories can be stale

## Query Patterns
- Search by type: `mem0_search(query, type="feedback")`
- Search by project: `mem0_search(query, metadata={"project": "bike-shop"})`
- List all: `mem0_list()` with pagination
