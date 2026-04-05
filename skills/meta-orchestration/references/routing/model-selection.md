# Model Selection

## Selection Criteria
| Factor | Haiku | Sonnet | Opus |
|--------|-------|--------|------|
| Cost | Lowest | Medium | Highest |
| Speed | Fastest | Fast | Slowest |
| Reasoning | Simple tasks | Most tasks | Complex reasoning |
| Context | 200K | 200K | 200K-1M |

## Task → Model Mapping
- **Haiku**: formatting, simple grep/search, config changes, status checks
- **Sonnet**: feature implementation, code review, testing, most development
- **Opus**: architectural decisions, complex debugging, multi-file refactoring, planning

## Cost Optimization Rules
1. Start with lowest viable model, escalate if output quality is insufficient
2. Never use Opus for tasks Sonnet can handle
3. Use Haiku for exploratory/throwaway work
4. Opus for final quality review/judgment
