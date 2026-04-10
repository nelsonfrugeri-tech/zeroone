# Defining SLOs

## SLI Types

| SLI Type | Formula | Example |
|----------|---------|---------|
| Availability | `good_requests / total_requests` | 99.9% of requests return non-5xx |
| Latency | `fast_requests / total_requests` | 95% of requests < 200ms, 99% < 1s |
| Throughput | `processed / expected` | Process 99.9% of queue messages |
| Correctness | `correct_responses / total_responses` | 99.99% return correct data |
| Freshness | `fresh_data / total_data` | 99% of data updated within 1 minute |

## SLO Target Selection
- Start with current performance (e.g., if availability is 99.95%, set SLO at 99.9%)
- Never set 100% — it's impossible and prevents deployments
- Tighter SLOs = higher engineering cost. Every extra 9 is ~10x harder
- Different SLOs per tier: critical services 99.99%, internal tools 99.5%

## Error Budget
```
Error budget = 1 - SLO target
Example: 99.9% SLO → 0.1% error budget → 43.8 min/month downtime allowed
```

| SLO | Monthly budget | Quarterly budget |
|-----|---------------|-----------------|
| 99% | 7.3h | 21.9h |
| 99.9% | 43.8min | 2.2h |
| 99.95% | 21.9min | 1.1h |
| 99.99% | 4.4min | 13.1min |

## SLO Document Template
```yaml
service: payment-api
slos:
  - name: availability
    sli: ratio of non-5xx responses
    target: 99.95%
    window: 30 days rolling
    measurement: Prometheus query
  - name: latency-p99
    sli: 99th percentile response time
    target: < 500ms
    window: 30 days rolling
```

## Stakeholder Alignment
- Product team agrees on targets (they accept the trade-off)
- SLOs are living documents — review quarterly
- Alert on burn rate, not threshold violations
