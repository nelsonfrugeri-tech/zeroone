# Multi-Window Burn Rate Alerting

## Conceito
Instead of static thresholds, alert based on how fast the error budget is being consumed.

## Formula
```
burn_rate = (error_rate_observed / error_rate_allowed)
error_rate_allowed = (1 - SLO_target) / window_days
```

## Multi-Window Strategy (Google SRE)
Two windows per alert to balance speed vs noise:
- **Long window**: detects sustained issues
- **Short window**: confirms issue is still happening (avoids alert on resolved spike)

```promql
# P1: 2% budget in 1 hour (burn rate 14.4x)
alert: SLOBurnRateHigh
expr: |
  (
    sum(rate(http_errors_total[1h])) / sum(rate(http_requests_total[1h])) > (14.4 * 0.001)
  ) and (
    sum(rate(http_errors_total[5m])) / sum(rate(http_requests_total[5m])) > (14.4 * 0.001)
  )
labels:
  severity: critical

# P2: 5% budget in 6 hours (burn rate 6x)  
alert: SLOBurnRateMedium
expr: |
  (
    sum(rate(http_errors_total[6h])) / sum(rate(http_requests_total[6h])) > (6 * 0.001)
  ) and (
    sum(rate(http_errors_total[30m])) / sum(rate(http_requests_total[30m])) > (6 * 0.001)
  )
labels:
  severity: warning
```

## Tuning
- Start with Google's recommended windows, adjust based on team's response time
- Too sensitive → alert fatigue; too loose → miss real issues
- Always pair with error budget dashboard for context
