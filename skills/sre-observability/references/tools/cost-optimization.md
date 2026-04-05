# Cost Optimization

## Cost Optimization

### Metrics Cardinality
- High cardinality = high cost (labels with user_id, request_id)
- Target: < 10K unique time series per service
- Use recording rules to pre-aggregate, then drop raw high-cardinality metrics

### Sampling Strategies
| Data | Sampling |
|------|----------|
| Metrics | Keep all (aggregated by nature) |
| Traces | 1-10% head-based, 100% for errors |
| Logs | Filter debug/trace in production |

### Retention Policies
| Resolution | Retention |
|-----------|-----------|
| Raw (15s) | 7 days |
| 1min downsampled | 30 days |
| 5min downsampled | 1 year |
| Alerts/incidents | Forever |

### Quick Wins
1. Drop unused metrics (`metric_relabel_configs`)
2. Increase scrape interval for non-critical services (30s → 60s)
3. Use exemplars instead of high-cardinality labels
4. Compact logs: structured JSON, no stack traces for known errors
