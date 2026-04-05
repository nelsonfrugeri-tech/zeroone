---
name: sre-observability
description: |
  Baseline de conhecimento para SRE e observabilidade moderna. Foco nos tres pilares (logs, metrics, traces)
  com OpenTelemetry como padrao, SLO/SLI management, incident response workflow, alerting strategies
  (symptom-based), dashboard patterns (USE, RED, Four Golden Signals), cost optimization, root cause analysis,
  disaster recovery, runbooks e on-call best practices. Ferramentas: Prometheus, Grafana, Jaeger, Langfuse,
  OpenTelemetry. Complementa arch-py e ai-engineer skills com a camada operacional.
  Use quando: (1) Instrumentar aplicacoes com traces/metrics/logs, (2) Definir SLOs e error budgets,
  (3) Configurar alerting e dashboards, (4) Responder a incidentes, (5) Otimizar custos de observabilidade,
  (6) Monitorar AI/LLM systems com Langfuse.
triggers:
  - /sre
  - /observability
  - SRE
  - observability
  - monitoring
  - alerting
  - SLO
  - SLI
  - incident response
  - postmortem
  - on-call
  - dashboards
  - OpenTelemetry
  - Prometheus
  - Grafana
---

# SRE-Observability — Conhecimento de Observabilidade e SRE

## Proposito

Esta skill e a **biblioteca de conhecimento** para SRE e observabilidade moderna (2026).
Ela complementa `arch-py` (fundacao Python) e `ai-engineer` (AI layer) com a camada operacional.

**Quem usa esta skill:**
- Agent `sentinel` -> ao monitorar, alertar e responder a incidentes
- Agent `dev-py` -> ao instrumentar aplicacoes com telemetria
- Voce diretamente -> quando precisar de referencia de observabilidade

**O que esta skill contem:**
- Observability pillars (logs, metrics, traces) com OpenTelemetry
- SLO/SLI definition e error budgets
- Incident response workflow completo
- Alerting strategies (symptom-based)
- Dashboard patterns (USE, RED, Four Golden Signals)
- Cost analysis e optimization
- Root cause analysis (5 Whys, fault trees)
- Disaster recovery e runbooks
- On-call best practices
- AI/LLM observability (Langfuse)

**O que esta skill NAO contem:**
- Implementacao de codigo Python (isso esta em `arch-py`)
- AI/ML patterns (isso esta em `ai-engineer`)
- Workflow de execucao — isso esta nos agents

---

## Filosofia

### Observability != Monitoring

**Monitoring** te diz QUANDO algo esta errado.
**Observability** te diz POR QUE algo esta errado.

Um sistema e observavel quando voce pode entender seu estado interno
a partir dos sinais externos que ele emite — sem precisar fazer deploy
de codigo novo para debugar.

### Principios Fundamentais

**1. OpenTelemetry e o padrao**
- Unico SDK para logs, metrics e traces
- Vendor-neutral — troque de backend sem mudar instrumentacao
- Semantic conventions para consistencia cross-service
- Auto-instrumentation como ponto de partida

**2. SLOs drive decisions**
- Sem SLO, nao ha como decidir se o servico precisa de mais reliability ou mais velocity
- Error budgets quantificam o "quanto posso errar"
- SLOs devem refletir a experiencia do usuario, nao metricas de infra

**3. Symptom-based alerting**
- Alerte sobre sintomas (latencia alta, error rate), nao causas (CPU alta)
- CPU alta sem impacto no usuario = nao alerte
- Menos alerts, mais acionaveis

**4. Blameless culture**
- Postmortems blameless — foque em sistemas, nao pessoas
- Cada incidente e uma oportunidade de aprendizado
- Documentar para prevenir recorrencia

**5. Cost-aware observability**
- Telemetria tem custo (storage, network, processing)
- Sampling inteligente — nem todo trace precisa ser armazenado
- Retention policies baseadas em valor

---

## 1. Pilares de Observabilidade

### Os Três Pilares + Eventos

| Pillar | What | When | Tool |
|--------|------|------|------|
| **Logs** | Eventos discretos com contexto | Debug, audit trail, compliance | OpenTelemetry Logs, structlog |
| **Metrics** | Valores numericos ao longo do tempo | Trends, alerting, capacity planning | Prometheus 3.x, OpenTelemetry Metrics |
| **Traces** | Caminho de uma request across services | Latency analysis, dependency mapping | Jaeger v2, OpenTelemetry Traces |
| **Events** | Mudancas de estado significativas | Deployments, config changes, incidents | Custom events, annotations |

### OpenTelemetry — O Padrão

OpenTelemetry (OTel) e o padrao CNCF para telemetria. Um unico SDK para instrumentar tudo.

```python
# opentelemetry-sdk==1.40.0
# opentelemetry-api==1.40.0
# opentelemetry-exporter-otlp==1.40.0

from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource

# Resource identifies your service
resource = Resource.create({
    "service.name": "my-service",
    "service.version": "1.0.0",
    "deployment.environment": "production",
})

# Traces setup
tracer_provider = TracerProvider(resource=resource)
tracer_provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://otel-collector:4317"))
)
trace.set_tracer_provider(tracer_provider)

# Metrics setup
metric_reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint="http://otel-collector:4317"),
    export_interval_millis=60000,
)
meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(meter_provider)

# Usage
tracer = trace.get_tracer(__name__)
meter = metrics.get_meter(__name__)

request_counter = meter.create_counter(
    "http.server.request.count",
    description="Total HTTP requests",
)

request_duration = meter.create_histogram(
    "http.server.request.duration",
    unit="ms",
    description="HTTP request duration",
)
```

### Propagação de Contexto

W3C Trace Context e o padrao. Propaga trace_id e span_id entre servicos.

```python
# Automatic propagation with OTel instrumentation
# Headers: traceparent, tracestate

# Manual span creation with context
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

### Logging Estruturado com OTel

```python
# structlog==24.4.0
import structlog
from opentelemetry import trace

def add_otel_context(
    logger: structlog.types.WrappedLogger,
    method_name: str,
    event_dict: dict,
) -> dict:
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
# {"level":"info","timestamp":"...","trace_id":"...","span_id":"...","order_id":"abc-123","total":99.99,"event":"order_created"}
```

**Referencia:** [references/opentelemetry/setup.md](references/opentelemetry/setup.md)
**Referencia:** [references/opentelemetry/instrumentation.md](references/opentelemetry/instrumentation.md)

---

## 2. Gestão de SLO/SLI

### Definições

| Conceito | O que e | Exemplo |
|----------|---------|---------|
| **SLI** (Service Level Indicator) | Metrica quantitativa de aspecto do servico | 99.2% of requests < 200ms |
| **SLO** (Service Level Objective) | Target para um SLI | 99.5% of requests must be < 200ms |
| **SLA** (Service Level Agreement) | Contrato com consequencias | 99.9% uptime or credits issued |
| **Error Budget** | 100% - SLO | 0.5% = budget para experimentar/falhar |

### Fórmula de SLI

```
SLI = (good events / total events) * 100

# Availability SLI
availability = (successful_requests / total_requests) * 100

# Latency SLI
latency = (requests_under_threshold / total_requests) * 100

# Correctness SLI
correctness = (correct_responses / total_responses) * 100
```

### Escolhendo SLIs

| Service Type | Primary SLIs |
|-------------|-------------|
| **API** | Availability, Latency (p50, p95, p99), Error rate |
| **Pipeline** | Freshness (data age), Correctness, Throughput |
| **Storage** | Availability, Latency, Durability |
| **Frontend** | LCP, FID, CLS (Core Web Vitals) |
| **AI/LLM** | Latency, Correctness (eval score), Token cost, Error rate |

### Política de Error Budget

```markdown
## Error Budget Policy for [Service]

### Cálculo do budget
- SLO: 99.5% availability (28-day rolling window)
- Error budget: 0.5% = ~201 minutes / 28 days

### Quando o budget está saudável (>50% remaining)
- Ship features freely
- Experiment with new deployments
- Perform maintenance

### Quando o budget está baixo (10-50% remaining)
- Slow down feature releases
- Prioritize reliability work
- Increase test coverage

### Quando o budget está esgotado (<10% remaining)
- Feature freeze
- All hands on reliability
- Mandatory postmortem for any new incident
- Rollback risky changes
```

### Implementação de SLO com Prometheus

```yaml
# Prometheus recording rules for SLO
groups:
  - name: slo_rules
    interval: 30s
    rules:
      # Error ratio (1 - availability)
      - record: slo:http_request_error_ratio:rate5m
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))

      # Latency SLI: % of requests under 200ms
      - record: slo:http_request_latency_good_ratio:rate5m
        expr: |
          sum(rate(http_request_duration_seconds_bucket{le="0.2"}[5m]))
          /
          sum(rate(http_request_duration_seconds_count[5m]))

      # Error budget remaining (28d window)
      - record: slo:error_budget_remaining:ratio
        expr: |
          1 - (
            sum(increase(http_requests_total{status=~"5.."}[28d]))
            /
            (sum(increase(http_requests_total[28d])) * (1 - 0.995))
          )
```

**Referencia:** [references/slo-management/defining-slos.md](references/slo-management/defining-slos.md)
**Referencia:** [references/slo-management/error-budgets.md](references/slo-management/error-budgets.md)

---

## 3. Resposta a Incidentes Workflow

### Lifecycle

```
DETECT -> TRIAGE -> MITIGATE -> RESOLVE -> POSTMORTEM -> IMPROVE
```

### Phase 1: Detect

**Sources:**
- Automated alerts (Prometheus/Grafana alerting)
- Customer reports
- Synthetic monitoring (probes, health checks)
- Anomaly detection

**Rules:**
- Time-to-detect (TTD) e a metrica mais critica
- Alert on symptoms, not causes
- Reduce noise — every alert must be actionable

### Phase 2: Triage

**Severity classification:**

| Severity | Impact | Response Time | Examples |
|----------|--------|---------------|---------|
| **SEV-0** | Total outage, data loss | Immediate (all hands) | Database corruption, security breach |
| **SEV-1** | Major feature broken | < 15 min | Payment processing down, auth failure |
| **SEV-2** | Degraded service | < 30 min | Elevated latency, partial errors |
| **SEV-3** | Minor issue | < 4 hours | UI bug, non-critical feature degraded |

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

### Phase 5: Postmortem (Blameless)

```markdown
## Postmortem: [Incident Title]

**Date:** YYYY-MM-DD
**Duration:** X hours Y minutes
**Severity:** SEV-N
**IC:** [name]

### Summary
[1-2 sentences describing what happened]

### Impact
- [N users affected]
- [N minutes of downtime]
- [error budget consumed: X%]

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
- Update runbooks
- Improve alerts
- Add automated tests for the failure mode

**Referencia:** [references/incident-response/workflow.md](references/incident-response/workflow.md)
**Referencia:** [references/incident-response/postmortem-template.md](references/incident-response/postmortem-template.md)

---

## 4. Estratégias de Alerting

### Alerting Baseado em Sintomas

```
BAD:  Alert on CPU > 80%         (cause, may have no user impact)
GOOD: Alert on error rate > 1%   (symptom, users are affected)

BAD:  Alert on disk > 90%        (cause, might be fine for weeks)
GOOD: Alert on write failures > 0 (symptom, data loss happening)
```

### Alert Quality Criteria

| Property | Description |
|----------|-------------|
| **Actionable** | Someone can and must do something about it NOW |
| **Relevant** | It represents real user impact |
| **Timely** | Fires soon enough to mitigate damage |
| **Unique** | Not duplicated by other alerts |
| **Understandable** | Includes context: what's wrong, probable cause, runbook link |

### Multi-Window, Multi-Burn Rate

Google SRE's recommended approach for SLO-based alerting:

```yaml
# Prometheus alerting rules: multi-burn-rate
groups:
  - name: slo_alerts
    rules:
      # Fast burn: 14.4x error rate over 1h (consumes 2% budget in 1h)
      - alert: HighErrorRate_FastBurn
        expr: |
          (
            slo:http_request_error_ratio:rate1h > (14.4 * 0.005)
          and
            slo:http_request_error_ratio:rate5m > (14.4 * 0.005)
          )
        labels:
          severity: critical
        annotations:
          summary: "High error rate - fast burn (14.4x)"
          runbook: "https://wiki/runbooks/high-error-rate"

      # Slow burn: 1x error rate over 3d (sustained degradation)
      - alert: HighErrorRate_SlowBurn
        expr: |
          (
            slo:http_request_error_ratio:rate3d > (1 * 0.005)
          and
            slo:http_request_error_ratio:rate6h > (1 * 0.005)
          )
        labels:
          severity: warning
        annotations:
          summary: "Elevated error rate - slow burn"
```

### Alert Routing

```yaml
# Alertmanager config
route:
  receiver: "default"
  group_by: ["alertname", "service"]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  routes:
    - match:
        severity: critical
      receiver: "pagerduty-oncall"
      repeat_interval: 5m
    - match:
        severity: warning
      receiver: "slack-sre"
      repeat_interval: 1h
    - match:
        severity: info
      receiver: "slack-monitoring"
      repeat_interval: 24h
```

**Referencia:** [references/alerting/symptom-based.md](references/alerting/symptom-based.md)
**Referencia:** [references/alerting/burn-rate.md](references/alerting/burn-rate.md)

---

## 5. Padrões de Dashboard

### Método USE (Resources)

For every resource (CPU, memory, disk, network):
- **U**tilization — % of time the resource is busy
- **S**aturation — queue depth, work pending
- **E**rrors — error count for the resource

```
# Prometheus queries for USE method
# CPU Utilization
1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)

# CPU Saturation (load average / cores)
node_load1 / count(node_cpu_seconds_total{mode="idle"}) by (instance)

# Disk Errors
rate(node_disk_io_errors_total[5m])
```

### Método RED (Services)

For every service:
- **R**ate — requests per second
- **E**rrors — errors per second
- **D**uration — distribution of request latency

```
# Prometheus queries for RED method
# Rate
sum(rate(http_requests_total[5m])) by (service)

# Errors
sum(rate(http_requests_total{status=~"5.."}[5m])) by (service)

# Duration (p50, p95, p99)
histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))
```

### Four Golden Signals (Google SRE)

| Signal | What to measure | Why |
|--------|-----------------|-----|
| **Latency** | Time to serve a request (success vs error separately) | User experience |
| **Traffic** | Requests per second, concurrent users | Demand |
| **Errors** | Rate of failed requests (explicit + implicit) | Correctness |
| **Saturation** | How "full" the service is (queue depth, memory) | Capacity |

### Layout de Dashboard Best Practices

```
Row 1: SLO Status
  - Current SLI value vs target
  - Error budget remaining (gauge)
  - Error budget burn rate (sparkline)

Row 2: Golden Signals
  - Request rate (timeseries)
  - Error rate (timeseries + threshold line)
  - Latency p50/p95/p99 (timeseries)
  - Saturation (gauge or timeseries)

Row 3: Dependencies
  - Downstream service health
  - Database latency/errors
  - External API health

Row 4: Infrastructure
  - USE metrics for compute
  - Pod/container resource usage
  - Auto-scaling events
```

**Referencia:** [references/dashboards/patterns.md](references/dashboards/patterns.md)

---

## 6. Cost Analysis and Optimization

### Observability Cost Model

```
Total Cost = Ingestion Cost + Storage Cost + Query Cost

Ingestion:  volume of data sent (GB/day)
Storage:    retained data * retention period
Query:      dashboards, alerts, ad-hoc queries
```

### Optimization Strategies

| Strategy | Impact | Implementation |
|----------|--------|----------------|
| **Tail sampling** | 80-90% trace volume reduction | OTel Collector tail_sampling processor |
| **Metric aggregation** | Reduce cardinality | Pre-aggregate in recording rules |
| **Log level filtering** | 50-70% log volume reduction | Drop DEBUG/TRACE in production |
| **Retention tiers** | Storage cost reduction | Hot (7d), Warm (30d), Cold (90d) |
| **Attribute filtering** | Reduce per-event size | Drop non-essential attributes at collector |

### Tail Sampling (OTel Collector)

```yaml
# otel-collector-config.yaml
processors:
  tail_sampling:
    decision_wait: 10s
    num_traces: 100000
    policies:
      # Always keep errors
      - name: errors
        type: status_code
        status_code:
          status_codes: [ERROR]
      # Always keep slow requests
      - name: slow-requests
        type: latency
        latency:
          threshold_ms: 1000
      # Sample 10% of successful fast requests
      - name: probabilistic
        type: probabilistic
        probabilistic:
          sampling_percentage: 10
```

### Cost Tracking

```python
# Track observability costs per service
meter = metrics.get_meter("observability.costs")

traces_ingested = meter.create_counter(
    "observability.traces.ingested",
    description="Number of trace spans ingested",
)

logs_ingested = meter.create_counter(
    "observability.logs.ingested.bytes",
    unit="By",
    description="Volume of logs ingested in bytes",
)

# Tag by service for cost attribution
traces_ingested.add(1, {"service.name": "payment-service"})
```

**Referencia:** [references/tools/cost-optimization.md](references/tools/cost-optimization.md)

---

## 7. Análise de Causa Raiz

### 5 Whys

```markdown
## 5 Whys: Payment Service Outage

**Problem:** Users could not complete purchases for 45 minutes.

1. **Why?** Payment API returned 500 errors.
2. **Why?** Database connection pool was exhausted.
3. **Why?** A slow query was holding connections for 30s+.
4. **Why?** A missing index on the orders table caused full table scan.
5. **Why?** The migration that added the column did not include the index.

**Root cause:** Missing index in database migration.
**Action:** Add index + add CI check for missing indexes on query-heavy tables.
```

### Fault Tree Analysis

```
                    [Service Outage]
                    /              \
           [App Error]        [Infra Error]
           /        \            /        \
    [Code Bug]  [Dependency]  [Capacity]  [Network]
       |            |            |            |
  [Missing     [DB timeout]  [OOM kill]  [DNS failure]
   null check]
```

### Contributing Factor Categories

| Category | Examples |
|----------|---------|
| **Code** | Bug, race condition, missing validation |
| **Config** | Wrong env var, bad feature flag, misconfig |
| **Dependency** | DB down, external API timeout, DNS failure |
| **Capacity** | OOM, CPU saturation, connection pool exhausted |
| **Process** | Missing review, no runbook, inadequate testing |
| **Human** | Wrong command, missed alert, miscommunication |

**Referencia:** [references/incident-response/root-cause-analysis.md](references/incident-response/root-cause-analysis.md)

---

## 8. Recuperação de Desastres and Runbooks

### Recovery Objectives

| Metric | Definition | Example |
|--------|-----------|---------|
| **RTO** (Recovery Time Objective) | Max acceptable downtime | 4 hours |
| **RPO** (Recovery Point Objective) | Max acceptable data loss | 1 hour |
| **MTTR** (Mean Time To Recovery) | Average recovery time | 30 minutes |
| **MTBF** (Mean Time Between Failures) | Average uptime between incidents | 90 days |

### Runbook Template

````markdown
# Runbook: [Service] - [Scenario]

## Overview
- **Service:** [service name]
- **Scenario:** [what this runbook covers]
- **Severity:** SEV-N
- **Last tested:** YYYY-MM-DD
- **Owner:** [team/person]

## Detection
- **Alert:** [alert name that triggers this runbook]
- **Dashboard:** [link to relevant dashboard]

## Diagnosis
1. Check [metric/log] for [condition]
   ```bash
   # command to check
   ```
2. Verify [dependency] is healthy
   ```bash
   # command to check
   ```

## Mitigation
### Option A: Rollback (preferred)
```bash
# rollback command
```

### Option B: Scale up
```bash
# scale command
```

### Option C: Feature flag
```bash
# disable flag command
```

## Verification
1. Confirm [SLI] is back to normal
2. Check [dashboard] for error rate
3. Monitor for 30 minutes

## Escalation
- If not resolved in [N] minutes, escalate to [team/person]
- PagerDuty: [escalation policy]
````

### Runbook Hygiene

- **Test quarterly** — run game days to validate runbooks
- **Update after every incident** — if a runbook was wrong, fix it immediately
- **Link from alerts** — every alert annotation must include a runbook URL
- **Version control** — runbooks live in git, not wiki

**Referencia:** [references/incident-response/runbook-template.md](references/incident-response/runbook-template.md)

---

## 9. Boas Práticas de On-Call

### Schedule Design

| Practice | Why |
|----------|-----|
| **Minimum 2 people on-call** | Primary + secondary prevents single point of failure |
| **8-12 hour shifts** (not 24h) | Fatigue degrades response quality |
| **Maximum 1 week rotation** | Longer rotations cause burnout |
| **Follow-the-sun** if possible | Avoid overnight shifts |
| **Handoff document** | Outgoing on-call briefs incoming on status |

### On-Call Expectations

```markdown
## On-Call Contract

### What on-call IS:
- Respond to pages within 15 minutes
- Mitigate user-facing issues
- Escalate when stuck (no hero culture)
- Document actions taken

### What on-call is NOT:
- Doing feature work while on-call (reduced load expected)
- Being awake 24/7
- Handling non-urgent requests
- Single point of failure

### Compensation:
- On-call compensation per shift
- Time off after high-severity incidents
- No more than [N] pages/week target
```

### On-Call Health Metrics

| Metric | Target | Action if exceeded |
|--------|--------|-------------------|
| Pages per shift | < 2 | Tune alerts, fix noisy sources |
| False positive rate | < 20% | Improve alert accuracy |
| Time to acknowledge | < 5 min | Review escalation policy |
| Time to mitigate | < 30 min | Improve runbooks |
| After-hours pages | < 1/week | Fix root causes, improve stability |

**Referencia:** [references/incident-response/on-call.md](references/incident-response/on-call.md)

---

## 10. AI/LLM Observability

### Why AI Systems Need Special Observability

| Challenge | Why |
|-----------|-----|
| **Non-deterministic** | Same input can produce different outputs |
| **Expensive** | Each LLM call costs tokens = money |
| **Opaque** | Chain/agent reasoning is hard to debug |
| **Quality varies** | "Correct" is subjective, needs evaluation |
| **Latency varies** | 200ms to 60s depending on model/prompt |

### Langfuse for LLM Observability

```python
# langfuse==2.56.1
from langfuse import Langfuse
from langfuse.decorators import observe, langfuse_context

langfuse = Langfuse()

@observe()
def rag_pipeline(query: str) -> str:
    # Automatically traced: input, output, latency, cost
    docs = retrieve_documents(query)
    response = generate_answer(query, docs)
    return response

@observe(as_type="generation")
def generate_answer(query: str, docs: list[str]) -> str:
    # Traced as LLM generation with token tracking
    langfuse_context.update_current_observation(
        model="claude-sonnet-4-20250514",
        input={"query": query, "context": docs},
        metadata={"doc_count": len(docs)},
    )
    # ... call LLM ...
    return result
```

### LLM SLIs

| SLI | Formula | Target |
|-----|---------|--------|
| **Availability** | successful_calls / total_calls | 99.5% |
| **Latency (p95)** | p95 of response time | < 5s (chat), < 30s (batch) |
| **Quality** | eval_score (LLM-as-judge) | > 0.8 |
| **Cost per request** | total_tokens * price_per_token | < $0.05 avg |
| **Token efficiency** | output_tokens / input_tokens | Monitor trend |

### OpenTelemetry for AI (GenAI Semantic Conventions)

```python
# OTel GenAI semantic conventions (2025+)
with tracer.start_as_current_span("llm.generate") as span:
    span.set_attribute("gen_ai.system", "anthropic")
    span.set_attribute("gen_ai.request.model", "claude-sonnet-4-20250514")
    span.set_attribute("gen_ai.request.max_tokens", 4096)
    span.set_attribute("gen_ai.request.temperature", 0.7)
    span.set_attribute("gen_ai.usage.input_tokens", input_tokens)
    span.set_attribute("gen_ai.usage.output_tokens", output_tokens)
    span.set_attribute("gen_ai.response.finish_reason", "stop")
```

**Referencia:** [references/tools/langfuse.md](references/tools/langfuse.md)

---

## Tool Versions (Pinned, Stable — April 2026)

| Tool | Version | Purpose |
|------|---------|---------|
| opentelemetry-sdk | 1.40.0 | Telemetry SDK (Python) |
| opentelemetry-api | 1.40.0 | Telemetry API (Python) |
| opentelemetry-exporter-otlp | 1.40.0 | OTLP exporter |
| Prometheus | 3.8.0 | Metrics collection and alerting |
| Grafana | 12.4.2 | Dashboards and visualization |
| Jaeger | 2.x | Distributed tracing backend |
| Langfuse | 2.56.1 | LLM observability |
| structlog | 24.4.0 | Structured logging |
| OTel Collector | 0.146.1 | Telemetry pipeline |

---

## Composicao com Outras Skills

| Aspecto | Arch-Py Skill | AI-Engineer Skill | SRE-Observability Skill |
|---------|---------------|-------------------|------------------------|
| **Logging** | structlog patterns | LLM call logging | Log correlation, OTel integration |
| **Metrics** | -- | Token/cost tracking | Prometheus, RED/USE, SLOs |
| **Tracing** | -- | LangSmith, Phoenix | OTel traces, Jaeger, context propagation |
| **Testing** | pytest | LLM evaluation | Synthetic monitoring, game days |
| **Error Handling** | Exception hierarchy | Rate limits, retries | Incident response, runbooks |
| **Architecture** | Clean Architecture | RAG, agents | Dashboard design, alert routing |

**Sempre use as tres juntas:**
- `arch-py` para fundacao Python solida
- `ai-engineer` para layer AI-specific
- `sre-observability` para layer operacional

---

## Referencias por Dominio

### OpenTelemetry
- [references/opentelemetry/setup.md](references/opentelemetry/setup.md) - Setup completo OTel Python
- [references/opentelemetry/instrumentation.md](references/opentelemetry/instrumentation.md) - Auto e manual instrumentation

### Incident Response
- [references/incident-response/workflow.md](references/incident-response/workflow.md) - Lifecycle completo
- [references/incident-response/postmortem-template.md](references/incident-response/postmortem-template.md) - Template blameless
- [references/incident-response/root-cause-analysis.md](references/incident-response/root-cause-analysis.md) - 5 Whys, fault trees
- [references/incident-response/runbook-template.md](references/incident-response/runbook-template.md) - Runbook padrao
- [references/incident-response/on-call.md](references/incident-response/on-call.md) - On-call practices

### SLO Management
- [references/slo-management/defining-slos.md](references/slo-management/defining-slos.md) - Como definir SLIs e SLOs
- [references/slo-management/error-budgets.md](references/slo-management/error-budgets.md) - Error budget policies

### Alerting
- [references/alerting/symptom-based.md](references/alerting/symptom-based.md) - Symptom vs cause alerting
- [references/alerting/burn-rate.md](references/alerting/burn-rate.md) - Multi-window burn rate alerts

### Dashboards
- [references/dashboards/patterns.md](references/dashboards/patterns.md) - USE, RED, Golden Signals layouts

### Tools
- [references/tools/prometheus.md](references/tools/prometheus.md) - Prometheus 3.x setup and PromQL
- [references/tools/grafana.md](references/tools/grafana.md) - Grafana 12.x dashboards
- [references/tools/jaeger.md](references/tools/jaeger.md) - Jaeger v2 + OTel
- [references/tools/langfuse.md](references/tools/langfuse.md) - LLM observability
- [references/tools/cost-optimization.md](references/tools/cost-optimization.md) - Sampling, retention, cost control
