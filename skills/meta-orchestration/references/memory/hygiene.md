# Memory Hygiene

## Remove When
- Decision was reversed or superseded
- Fact is no longer true (verified by reading current state)
- Procedure is obsolete (tool/API changed)
- Outcome is >30 days old and not referenced
- Task claims >7 days without update (stale)
- Duplicates covering the same information

## Keep When
- Decision rationale is still relevant (the "why" survives even if the "what" changed)
- Procedure is still valid and reusable
- Fact is hard to reconstruct (tokens, IDs, external configs)
- Preference has not been contradicted by newer feedback

## Cleanup Protocol by Scope

### Every session start
1. `mem0_search(memory_type="task_claim", user_id="team")` — delete completed/abandoned claims
2. `mem0_search(memory_type="blocker", user_id="team")` — delete resolved blockers
3. `mem0_search(query="outdated, old, deprecated", user_id="team:{project}")` — review and prune

### Weekly or on demand
4. `mem0_list(user_id="team:{project}")` — verify project facts still accurate
5. `mem0_list(user_id="{agent}:{project}")` — check for superseded decisions
6. `mem0_search(query="outcome", memory_type="outcome")` — archive outcomes >30 days

## Anti-patterns
- Storing everything (noise overwhelms signal)
- Never pruning (stale memories cause wrong decisions)
- Storing code snippets (code changes, memory doesn't)
- Storing git history summaries (git log is authoritative)
- Using flat user_id instead of three-level scoping

## Golden Rule

> 20 accurate memories > 100 half-stale memories.
> Wrong information is worse than missing information.
