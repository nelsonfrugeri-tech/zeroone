# Jaeger

## Distributed Tracing

### Trace Sampling Strategies
| Strategy | When |
|----------|------|
| Head-based (probabilistic) | Default, low overhead, 1-10% sample rate |
| Tail-based | Capture all errors/slow requests, higher resource cost |
| Rate-limiting | Fixed traces/second per service |

### Span Attributes (OpenTelemetry conventions)
```
http.method, http.status_code, http.url
db.system, db.statement (sanitized)
rpc.service, rpc.method
error (boolean), error.message
```

### Trace-to-logs correlation
- Inject trace_id into structured logs
- Grafana: Jaeger datasource linked to Loki via trace_id

### Version: Jaeger 2.x with OTLP native (2026 stable)
