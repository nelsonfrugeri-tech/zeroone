# Task Complexity Classification

## Levels
| Level | Signals | Model | Example |
|-------|---------|-------|---------|
| Trivial | Single file, no ambiguity, < 10 lines | Haiku | Fix typo, update config value |
| Low | 1-3 files, clear scope, well-defined | Sonnet | Add endpoint, write tests |
| Medium | 3-10 files, some ambiguity, cross-cutting | Sonnet | New feature with tests + docs |
| High | 10+ files, architectural impact, multiple domains | Opus | Refactor module, new integration |
| Critical | System-wide, irreversible, security-sensitive | Opus + human review | Auth redesign, data migration |

## Scoring Signals
- **File count**: how many files will be touched
- **Cross-cutting**: does it span multiple domains/modules
- **Ambiguity**: is the requirement clear or needs interpretation
- **Reversibility**: can changes be easily rolled back
- **Risk**: security, data loss, breaking changes
- **Dependencies**: does it block or depend on other work

## Composite Score
```
score = file_count_weight(0.2) + ambiguity(0.3) + risk(0.3) + cross_cutting(0.2)
trivial: < 0.2 | low: 0.2-0.4 | medium: 0.4-0.6 | high: 0.6-0.8 | critical: > 0.8
```
