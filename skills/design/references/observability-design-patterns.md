# Observability by Design

## Three Pillars Integration
```
Request → Trace (distributed, spans) 
       → Metrics (aggregated, counters/histograms)
       → Logs (contextual, structured)
       
Link: trace_id in all three → correlated debugging
```

## Correlation Pattern
```python
# Inject trace_id into every log entry
import structlog
from opentelemetry import trace

structlog.configure(
    processors=[
        add_trace_context,  # adds trace_id, span_id
        structlog.processors.JSONRenderer(),
    ]
)
```

## RED/USE Dashboard Pattern
- **RED** for services: Rate, Errors, Duration
- **USE** for resources: Utilization, Saturation, Errors
- Every service gets both

## Observability Checklist for New Services
- [ ] Structured logging with trace_id correlation
- [ ] OpenTelemetry instrumentation (auto + manual for critical paths)
- [ ] RED metrics exported to Prometheus
- [ ] Health endpoint (/health, /ready)
- [ ] SLO defined and dashboarded
- [ ] Alerts based on SLO burn rate
- [ ] Runbook written and linked to alerts
