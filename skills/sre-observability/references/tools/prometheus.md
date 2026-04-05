# Prometheus

## PromQL Essential Patterns

### Rate and increase
- `rate(metric[5m])` — per-second rate over 5 minutes (for counters)
- `increase(metric[1h])` — total increase over 1 hour
- Always use `rate()` before `sum()`: `sum(rate(metric[5m]))` not `rate(sum(metric))`

### Percentiles
```promql
histogram_quantile(0.99, sum(rate(http_duration_seconds_bucket[5m])) by (le))
```

### Recording Rules
Pre-compute expensive queries:
```yaml
groups:
  - name: slo
    interval: 30s
    rules:
      - record: job:http_errors:rate5m
        expr: sum(rate(http_requests_total{code=~"5.."}[5m])) by (job)
```

### Federation
- Use for aggregating across clusters
- Remote write to long-term storage (Thanos, Cortex, Mimir)
- Version: Prometheus 2.53+ (2026 stable)
