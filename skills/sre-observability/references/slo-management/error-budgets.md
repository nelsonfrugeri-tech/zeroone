# Error Budgets

## Concept
Error budget = allowed unreliability. If SLO is 99.9%, you can afford 0.1% failures.

## Burn Rate
```
burn_rate = actual_error_rate / allowed_error_rate
```
- burn_rate = 1 → consuming budget at exactly the allowed pace
- burn_rate > 1 → consuming faster than sustainable
- burn_rate = 10 → budget exhausted in 1/10th of the window

## Multi-Window Burn Rate Alerting
| Severity | Long window | Short window | Burn rate | Budget consumed |
|----------|------------|--------------|-----------|----------------|
| Page (P1) | 1h | 5min | 14.4x | 2% in 1h |
| Page (P2) | 6h | 30min | 6x | 5% in 6h |
| Ticket | 3d | 6h | 1x | 10% in 3d |

## Budget Exhaustion Policy
When error budget is exhausted:
1. **Freeze** feature releases — stability-only work
2. **Mandatory** postmortems for all incidents that consumed budget
3. **Invest** in reliability work (toil reduction, automation, testing)
4. **Resume** feature work when budget recovers above threshold (e.g., 50%)

## Budget Tracking
- Dashboard showing remaining budget % over rolling window
- Weekly email/Slack report to product + engineering
- Automated freeze trigger when budget < 10%

## Trade-offs
- Too generous → team ignores reliability
- Too tight → can't ship anything, frustration
- Sweet spot: budget aligns with user pain threshold
