# Technical Debt Quadrant (Martin Fowler)

## The Quadrant
|  | Deliberate | Inadvertent |
|--|-----------|-------------|
| **Prudent** | "We know this is a shortcut, we'll fix it next sprint" | "Now we know how we should have done it" |
| **Reckless** | "We don't have time for design" | "What's layering?" |

## Management Strategy
### Track
- Tag debt in code: `# DEBT: <description> — <issue-link>`
- Maintain a debt backlog (separate from feature backlog)
- Quantify: estimate cost to fix + cost of NOT fixing (interest)

### Prioritize
1. **High interest**: debt that slows every feature (e.g., no test suite)
2. **Blocking**: debt that prevents important features
3. **Low interest**: ugly but stable code that nobody touches
4. **Accept**: deliberate prudent debt with documented timeline

### Budget
- Allocate 15-20% of sprint capacity to debt reduction
- Never "debt sprint" — distribute across every sprint
- Tie debt work to feature work when possible (boy scout rule)

### Metrics
- Lead time trend (increasing = accumulating debt)
- Defect rate in high-debt areas
- Developer satisfaction surveys
- Time to onboard new team member
