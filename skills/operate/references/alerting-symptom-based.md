# Symptom-Based Alerting

## Principle
Alert on **what users experience** (symptoms), not **why** (causes).

## Symptoms vs Causes
| Symptom (GOOD) | Cause (BAD) |
|----------------|-------------|
| Error rate > 1% | Pod restarting |
| Latency p99 > 2s | CPU > 80% |
| Availability < 99.9% | Disk > 90% |
| Queue depth growing | Connection pool exhausted |

## Why Symptom-Based
- Cause-based alerts fire for non-issues (high CPU but users are fine)
- Cause-based miss novel failures (new cause, no alert)
- Symptom-based naturally ties to SLOs

## Implementation Pattern
```promql
# GOOD: symptom-based
alert: HighErrorRate
expr: sum(rate(http_requests_total{code=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.01

# BAD: cause-based
alert: HighCPU
expr: node_cpu_seconds_total > 0.8
```

## When Cause-Based is OK
- Resource exhaustion that WILL cause symptoms (disk full → crash)
- Security events (unauthorized access attempts)
- Capacity planning (not paging, just tickets)

## Alert Hygiene
- Every alert must be **actionable** — if you can't do anything, don't page
- Every alert must have a **runbook** link
- Review monthly: delete alerts nobody acted on
- Target: <5 pages per on-call shift
