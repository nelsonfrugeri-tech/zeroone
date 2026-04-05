# Task Routing Decision Tree

```
1. Classify complexity (trivial/low/medium/high/critical)
2. Is it read-only? → Explore agent (no worktree needed)
3. Is it a review? → review-py or review-ts expert
4. Is it coding?
   a. Python → dev-py
   b. TypeScript → dev-ts
   c. Infrastructure → builder
5. Is it architecture/design? → architect
6. Is it research/debate? → debater
7. Is it product/planning? → tech-pm
8. Is it monitoring/SRE? → sentinel
9. Is it ecosystem management? → oracle
10. No match → general-purpose agent + flag gap
```

## Edge Cases
- Task spans multiple domains → split into subtasks, route each
- Ambiguous scope → ask user to clarify before routing
- Dependencies between tasks → sequential execution, not parallel
