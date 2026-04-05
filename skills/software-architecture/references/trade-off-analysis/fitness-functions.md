# Architecture Fitness Functions

## Concept
Automated checks that verify architecture decisions are maintained over time.

## Types
| Type | Tool | Example |
|------|------|---------|
| Dependency rules | ArchUnit (Java), Dependency Cruiser (JS), import-linter (Python) | "domain layer must not import from infrastructure" |
| Coupling metrics | Code analysis | "No module has afferent coupling > 10" |
| Build time | CI metric | "Build completes in < 5 minutes" |
| Test coverage | Coverage tools | "Core domain has > 90% coverage" |
| API compatibility | OpenAPI diff | "No breaking changes in public API" |
| Performance | Benchmark suite | "P99 latency < 200ms in load test" |

## Python Example (import-linter)
```toml
# .importlinter
[importlinter]
root_packages = myapp

[importlinter:contract:layers]
name = Layer architecture
type = layers
layers =
    myapp.api
    myapp.domain
    myapp.infrastructure
```

## CI Integration
- Run fitness functions on every PR
- Block merge if architectural constraints violated
- Dashboard showing fitness function trends over time
