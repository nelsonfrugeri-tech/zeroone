# Google Search Advanced Operators

## Essential Operators
| Operator | Example | Purpose |
|----------|---------|---------|
| `site:` | `site:github.com fastapi middleware` | Search within a specific site |
| `filetype:` | `filetype:pdf "system design"` | Find specific file types |
| `intitle:` | `intitle:"migration guide" django` | Search page titles |
| `after:` | `after:2025-01-01 "opentelemetry python"` | Recent results only |
| `before:` | `before:2026-01-01` | Upper date bound |
| `"exact"` | `"error budget burn rate"` | Exact phrase match |
| `-` | `python framework -django -flask` | Exclude terms |
| `OR` | `k6 OR locust load testing` | Either term |

## Effective Query Patterns
```
# Find latest stable version
"release notes" site:github.com <project> after:2025-06
# Find migration guides
"migration guide" <library> <from-version> to <to-version>
# Find benchmarks
"benchmark" <tool-a> vs <tool-b> after:2025-01
# Find known issues
site:github.com/owner/repo/issues "<error message>"
```
