---
name: operate
description: |
  SRE and modern observability knowledge base (2026). Covers the three observability pillars
  (logs, metrics, traces) with OpenTelemetry as the standard, SLI/SLO definition and error
  budget management, incident response workflow (DETECT-TRIAGE-MITIGATE-RESOLVE-POSTMORTEM),
  symptom-based alerting (multi-window multi-burn-rate), dashboard patterns (USE, RED, Four
  Golden Signals), cost optimization, root cause analysis, runbook templates, and on-call
  best practices. Tools: Prometheus, Grafana, Jaeger, OpenTelemetry.
  Use when: (1) Instrumenting applications, (2) Defining SLOs and error budgets,
  (3) Configuring alerting and dashboards, (4) Responding to incidents, (5) Writing runbooks,
  (6) On-call setup.
  Triggers: /operate, /sre, /observability, SRE, observability, monitoring, alerting, SLO, SLI,
  incident response, postmortem, on-call, dashboards, OpenTelemetry.
type: capability
---

# Operate — SRE and Observability

## Purpose

This skill is the knowledge base for SRE and modern observability (2026).

**What this skill contains:**
- Observability pillars (logs, metrics, traces) with OpenTelemetry
- SLO/SLI definition and error budget management
- Incident response workflow (DETECT → TRIAGE → MITIGATE → RESOLVE → POSTMORTEM)
- Alerting strategies (symptom-based)
- Dashboard patterns (USE, RED, Four Golden Signals)
- Cost optimization for observability
- Root cause analysis (5 Whys, fault trees)
- Runbook templates
- On-call best practices

---

## Philosophy

### Observability != Monitoring

**Monitoring** tells you WHEN something is wrong.
**Observability** tells you WHY something is wrong.

A system is observable when you can understand its internal state from external signals
— without deploying new code to debug.

### Fundamental Principles

1. **OpenTelemetry is the standard** — vendor-neutral, one SDK for everything
2. **SLOs drive decisions** — error budgets quantify "how much can I fail"
3. **Symptom-based alerting** — alert on user impact, not internal causes
4. **Blameless culture** — incidents are learning opportunities, not blame assignments
5. **Cost-aware** — telemetry has cost, optimize signal-to-noise ratio

---

## 1. Observability Pillars

### The Three Pillars + Events

| Pillar | What | When | Tool |
|--------|------|------|------|
| **Logs** | Discrete events with context | Debug, audit trail, compliance | OpenTelemetry Logs, structlog |
| **Metrics** | Numeric values over time | Trends, alerting, capacity planning | Prometheus, OpenTelemetry Metrics |
| **Traces** | Request path across services | Latency analysis, dependency mapping | Jaeger, OpenTelemetry Traces |
| **Events** | Significant state changes | Deployments, config changes, incidents | Custom events, annotations |

### OpenTelemetry Setup (Python)

```python
# opentelemetry-sdk==1.40.0
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource

resource = Resource.create({
    "service.name": "my-service",
    "service.version": "1.0.0",
    "deployment.environment": "production",
})

# Traces
tracer_provider = TracerProvider(resource=resource)
tracer_provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://otel-collector:4317"))
)
trace.set_tracer_provider(tracer_provider)

# Usage
tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("process_order") as span:
    span.set_attribute("order.id", order_id)
    span.set_attribute("order.total", total)
    span.add_event("payment_processed", {"method": "credit_card"})
    try:
        result = process_payment(order_id)
    except Exception as e:
        span.set_status(trace.StatusCode.ERROR, str(e))
        span.record_exception(e)
        raise
```

### Structured Logging with OTel Context

```python
import structlog
from opentelemetry import trace

def add_otel_context(logger, method_name, event_dict):
    """Add OpenTelemetry trace context to log entries."""
    span = trace.get_current_span()
    ctx = span.get_span_context()
    if ctx.is_valid:
        event_dict["trace_id"] = format(ctx.trace_id, "032x")
        event_dict["span_id"] = format(ctx.span_id, "016x")
    return event_dict

structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        add_otel_context,
        structlog.processors.JSONRenderer(),
    ],
)

logger = structlog.get_logger()
logger.info("order_created", order_id="abc-123", total=99.99)
# {"level":"info","timestamp":"...","trace_id":"...","order_id":"abc-123","event":"order_created"}
```

---

## 2. SLI/SLO Management

### Definitions

| Concept | What | Example |
|---------|------|---------|
| **SLI** | Quantitative metric of service aspect | 99.2% of requests < 200ms |
| **SLO** | Target for an SLI | 99.5% of requests must be < 200ms |
| **SLA** | Contract with consequences | 99.9% uptime or credits |
| **Error Budget** | 100% - SLO | 0.5% = budget to experiment/fail |

### SLI Formula

```
SLI = (good events / total events) * 100

# Availability SLI
availability = (successful_requests / total_requests) * 100

# Latency SLI
latency = (requests_under_threshold / total_requests) * 100
```

### Choosing SLIs by Service Type

| Service Type | Primary SLIs |
|-------------|-------------|
| **API** | Availability, Latency (p50, p95, p99), Error rate |
| **Pipeline** | Freshness (data age), Correctness, Throughput |
| **Storage** | Availability, Latency, Durability |
| **Frontend** | LCP, FID, CLS (Core Web Vitals) |
| **AI/LLM** | Latency, Correctness (eval score), Token cost, Error rate |

### Error Budget Policy

```markdown
## Error Budget Policy for [Service]

### Budget calculation
- SLO: 99.5% availability (28-day rolling window)
- Error budget: 0.5% = ~201 minutes / 28 days

### When budget is healthy (>50% remaining)
- Ship features freely
- Experiment with new deployments
- Perform maintenance

### When budget is low (10-50% remaining)
- Slow down feature releases
- Prioritize reliability work
- Increase test coverage

### When budget is exhausted (<10% remaining)
- Feature freeze
- All hands on reliability
- Mandatory postmortem for any new incident
- Rollback risky changes
```

---

## 3. Incident Response Workflow

```
DETECT -> TRIAGE -> MITIGATE -> RESOLVE -> POSTMORTEM -> IMPROVE
```

### Phase 1: Detect

**Sources:** Automated alerts, customer reports, synthetic monitoring, anomaly detection

**Rules:**
- Time-to-detect (TTD) is the most critical metric
- Alert on symptoms, not causes
- Every alert must be actionable

### Phase 2: Triage

**Severity classification:**

| Severity | Impact | Response Time | Examples |
|----------|--------|---------------|---------|
| **SEV-0** | Total outage, data loss | Immediate (all hands) | Database corruption, security breach |
| **SEV-1** | Major feature broken | < 15 min | Payment down, auth failure |
| **SEV-2** | Degraded service | < 30 min | Elevated latency, partial errors |
| **SEV-3** | Minor issue | < 4 hours | Non-critical feature degraded |

**Roles:**
- **Incident Commander (IC)** — coordinates response, makes decisions
- **Communications Lead (CL)** — updates stakeholders, status page
- **Operations Lead (OL)** — hands-on debugging and mitigation

### Phase 3: Mitigate

**Priority order:**
1. **Rollback** — revert to last known good state
2. **Drain** — remove affected instance from rotation
3. **Scale** — add capacity if resource-bound
4. **Feature flag** — disable problematic feature
5. **Hotfix** — only if above options don't work

**Rule:** Mitigate first, debug later. Restore service ASAP.

### Phase 4: Resolve

- Confirm service is fully recovered
- Verify SLI metrics are back to normal
- Monitor for regression (30+ minutes)
- Close incident channel

### Phase 5: Blameless Postmortem

```markdown
## Postmortem: [Incident Title]

**Date:** YYYY-MM-DD
**Duration:** X hours Y minutes
**Severity:** SEV-N
**Incident Commander:** [name]

### Summary
[1-2 sentences describing what happened]

### Impact
- [N users affected]
- [N minutes of downtime]
- [Error budget consumed: X%]

### Timeline (UTC)
| Time | Event |
|------|-------|
| HH:MM | Alert fired: [alert name] |
| HH:MM | IC declared, triage started |
| HH:MM | Root cause identified: [cause] |
| HH:MM | Mitigation applied: [action] |
| HH:MM | Service restored |

### Root Cause
[Technical description of what went wrong]

### Contributing Factors
- [system or process factor, not person]

### What Went Well
- [item]

### What Went Wrong
- [item]

### Action Items
| Action | Owner | Priority | Due Date |
|--------|-------|----------|----------|
| [action] | [name] | P0/P1/P2 | YYYY-MM-DD |

### Lessons Learned
- [key takeaway]
```

### Phase 6: Improve

- Track action items to completion
- Update runbooks with what was learned
- Improve alerts based on detection gaps
- Add automated tests for the failure mode

---

## 4. Alerting Strategy

### Symptom-Based Alerting

```
BAD:  Alert on CPU > 80%         (cause — may have no user impact)
GOOD: Alert on error rate > 1%   (symptom — users are affected)

BAD:  Alert on disk > 90%        (cause — might be fine for weeks)
GOOD: Alert on write failures > 0 (symptom — data loss happening)
```

### Multi-Window Multi-Burn-Rate Alerts

```yaml
# Prometheus alerting rules
groups:
  - name: slo_alerts
    rules:
      # Fast burn: 2% budget in 1 hour = 14.4x burn
      - alert: ErrorBudgetBurnFast
        expr: |
          slo:http_request_error_ratio:rate1h > (14.4 * 0.005)
          and
          slo:http_request_error_ratio:rate5m > (14.4 * 0.005)
        for: 2m
        labels:
          severity: critical
          page: "true"
        annotations:
          summary: "Fast error budget burn ({{ $value | humanizePercentage }})"

      # Slow burn: 5% budget in 6 hours = 1.2x burn
      - alert: ErrorBudgetBurnSlow
        expr: |
          slo:http_request_error_ratio:rate6h > (1.2 * 0.005)
          and
          slo:http_request_error_ratio:rate30m > (1.2 * 0.005)
        for: 15m
        labels:
          severity: warning
          ticket: "true"
        annotations:
          summary: "Slow error budget burn ({{ $value | humanizePercentage }})"
```

### Alert Quality Checklist

```markdown
For every alert:
- [ ] Based on a symptom (user impact), not a cause
- [ ] Has a runbook linked
- [ ] Has clear severity and routing
- [ ] Fires for >= 2 minutes (reduce flapping)
- [ ] Tested to confirm it fires when it should
- [ ] Actionable — engineer knows what to do
- [ ] Has been silent for >= 1 week without manual action -> delete/improve
```

---

## 5. Dashboard Patterns

### RED Method (for request-driven services)

| Metric | What | SLO Example |
|--------|------|-------------|
| **R**ate | Requests per second | Sustain 5K rps |
| **E**rrors | Error rate percentage | < 0.1% 5xx |
| **D**uration | Latency distribution | p99 < 200ms |

### USE Method (for resources)

| Metric | What |
|--------|------|
| **U**tilization | % time resource is busy (CPU, memory) |
| **S**aturation | How much work is queued (waiting) |
| **E**rrors | Error count per resource |

### Four Golden Signals (Google SRE)

1. **Latency** — time to service a request
2. **Traffic** — demand on the system
3. **Errors** — rate of failed requests
4. **Saturation** — how "full" the service is

### Service Overview Dashboard Structure

```
Row 1: SLO Status
  - Error budget remaining (gauge)
  - Burn rate (last 1h, 6h, 1d)
  - Availability SLI (last 28d)

Row 2: RED Metrics
  - Request rate (graph)
  - Error rate (graph)
  - P50/P95/P99 latency (graph)

Row 3: Infrastructure
  - CPU utilization
  - Memory utilization
  - Disk I/O

Row 4: Dependencies
  - Database query duration
  - External API call duration
  - Cache hit rate
```

---

## 6. Runbook Template

```markdown
# Runbook: [Service/Component Name]

## Purpose
[What this service does and why it matters]

## On-call Contact
- Primary: [team/person]
- Escalation: [manager/senior]

## Service URLs
- Production: [URL]
- Monitoring: [Grafana dashboard URL]
- Logs: [log aggregation URL]
- Traces: [Jaeger/tracing URL]

## Architecture Overview
[Brief description of dependencies]

## Common Failure Modes

### Symptom: High Error Rate (> 1%)
**Investigation:**
1. Check error logs: `{log query}`
2. Check recent deployments: `{command}`
3. Check database health: `{command}`

**Mitigation:**
- Rollback: `{command}`
- Scale up: `{command}`
- Enable circuit breaker: `{command}`

**Escalate if:** Error rate > 5% for more than 5 minutes

---

### Symptom: High Latency (p99 > 1s)
**Investigation:**
1. Check slow query log
2. Check trace for bottleneck
3. Check resource utilization

**Mitigation:**
- Restart service: `docker compose restart api`
- Flush cache: `{command}`

---

## Deployment
**Deploy command:** `{command}`
**Rollback command:** `{command}`
**Health check:** `curl -sf {url}/health`

## Maintenance
**Scheduled maintenance window:** [schedule]
**Notify:** [stakeholders to notify]
```

---

## 7. On-Call Best Practices

### Healthy On-Call Culture

1. **Sustainable rotations** — no hero culture, distribute load
2. **Blameless postmortems** — systems fail, not people
3. **Alert hygiene** — reduce noise, every alert actionable
4. **Runbooks always current** — update after every incident
5. **On-call handoffs** — written summary of active issues

### On-Call Metrics to Track

| Metric | Target | Why |
|--------|--------|-----|
| MTTA (Mean Time to Acknowledge) | < 5 min | Detect gaps in coverage |
| MTTM (Mean Time to Mitigate) | < 1 hour for SEV-1 | Measure response effectiveness |
| Alerts per on-call week | < 5 actionable | Measure alert quality |
| Pages outside business hours | < 2/week | Measure sustainability |

### On-Call Shift Handoff

```markdown
## On-Call Handoff: [date]

### Active Incidents
- [none / link to incident]

### Ongoing Issues (watch list)
- {issue}: {status, what to watch for}

### Recent Deployments
- {service} {version}: deployed {date}, {status}

### Known Flaky Alerts
- {alert name}: {why it's noisy, when to ignore}

### Action Items
- {item}: {owner}
```

---

## Reference Files

- [references/opentelemetry-setup.md](references/opentelemetry-setup.md) — OTel SDK configuration, auto-instrumentation
- [references/prometheus-rules.md](references/prometheus-rules.md) — Recording rules, alerting rules, SLO rules
- [references/grafana-dashboards.md](references/grafana-dashboards.md) — Dashboard templates, panel configurations
- [references/incident-playbooks.md](references/incident-playbooks.md) — Incident playbooks by symptom type
- [references/oncall-guide.md](references/oncall-guide.md) — On-call setup, escalation paths
