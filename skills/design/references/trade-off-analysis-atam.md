# ATAM — Architecture Tradeoff Analysis Method

## Processo
1. **Present architecture** — stakeholders understand the system
2. **Identify quality attributes** — performance, security, modifiability, availability
3. **Build utility tree** — prioritize scenarios by importance and difficulty
4. **Analyze scenarios** — find sensitivity points and tradeoff points
5. **Document risks** — unmitigated risks become ADRs or action items

## Utility Tree
```
Quality Attribute → Sub-attribute → Scenario → Priority (H/M/L)
Performance → Latency → API responds < 200ms for 95% of requests → (H, H)
Security → Auth → Support MFA for all user accounts → (H, M)
Modifiability → Extensibility → Add new payment provider in < 1 sprint → (M, H)
```

## Key Concepts
- **Sensitivity point**: architectural decision that affects ONE quality attribute
- **Tradeoff point**: decision that affects MULTIPLE quality attributes (e.g., caching improves performance but complicates consistency)
- **Risk**: unmitigated sensitivity or tradeoff point

## Lightweight ATAM
For smaller teams, run in 2-4 hours:
1. List top 5 quality attributes
2. Identify 3 architectural decisions per attribute
3. Find tradeoff points (decisions that affect multiple attributes)
4. Document as ADRs
