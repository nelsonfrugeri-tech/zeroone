# Dashboard Patterns

## Four Golden Signals (Google SRE)
| Signal | What | Metric |
|--------|------|--------|
| Latency | Time to serve a request | `histogram_quantile(0.99, rate(http_duration_seconds_bucket[5m]))` |
| Traffic | Request volume | `sum(rate(http_requests_total[5m]))` |
| Errors | Rate of failed requests | `sum(rate(http_requests_total{code=~"5.."}[5m]))` |
| Saturation | Resource utilization | `container_memory_usage_bytes / container_spec_memory_limit_bytes` |

## RED Method (for request-driven services)
- **Rate**: requests per second
- **Errors**: errors per second
- **Duration**: latency distribution (p50, p95, p99)

## USE Method (for resources: CPU, memory, disk, network)
- **Utilization**: % time resource is busy
- **Saturation**: queue depth / work waiting
- **Errors**: error count

## Dashboard Layout Best Practices
```
Row 1: SLO status (availability, latency budget remaining)
Row 2: Golden signals (rate, errors, latency, saturation)
Row 3: Dependency health (database, cache, external APIs)
Row 4: Infrastructure (CPU, memory, disk, network)
```

## Grafana Patterns
- Use variables for service/namespace/environment selection
- Template dashboards per service type (API, worker, database)
- Annotations for deploys, incidents, config changes
- Link alerts to relevant dashboard panels
