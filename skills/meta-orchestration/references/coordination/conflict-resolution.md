# Conflict Resolution

## Duplicate Work Detection
1. Before starting, query Mem0 for active claims on same files/scope
2. If conflict found: coordinate with claiming agent or escalate to user
3. Git worktrees prevent file-level conflicts by isolation

## File Locking
- Worktrees provide natural isolation — each agent has own copy
- Merge conflicts resolved at branch merge time, not during work
- If two agents must touch same file: sequential, not parallel

## Merge Strategies
1. **Independent branches**: each agent's branch merged separately to main
2. **Stacked branches**: agent B branches from agent A's branch
3. **Consolidation branch**: Oracle merges all agent branches into one PR

## Escalation
- If agents produce conflicting recommendations → spawn morpheus (debate agent)
- If merge conflict is non-trivial → flag to user with both versions
