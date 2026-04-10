---
name: observability
description: |
  Observability tooling knowledge base (2026). Covers OpenTelemetry SDK configuration (Python and
  TypeScript), span management and context propagation, auto-instrumentation, Prometheus recording
  rules and SLO alerting, Grafana dashboard templates (RED, USE, Four Golden Signals), Jaeger trace
  analysis, structlog + OTel context correlation, Langfuse for LLM observability (traces, scores,
  cost tracking), alerting strategies (multi-window multi-burn-rate), and cost optimization for
  telemetry pipelines.
  Use when: (1) Instrumenting applications with OpenTelemetry, (2) Setting up Prometheus/Grafana,
  (3) Analyzing traces in Jaeger, (4) Monitoring LLM costs with Langfuse, (5) Writing alert rules.
  Triggers: /observability, OpenTelemetry, Prometheus, Grafana, Jaeger, Langfuse, tracing, metrics.
type: knowledge
---

# Observability — Knowledge Base

## Purpose

This skill is the knowledge base for observability tooling (2026).
It covers the instrumentation layer: how to configure OpenTelemetry, write Prometheus rules,
build Grafana dashboards, trace with Jaeger, and monitor LLM applications with Langfuse.

**What this skill contains:**
- OpenTelemetry SDK setup (Python and TypeScript)
- Span management, context propagation, sampling
- Auto-instrumentation (FastAPI, httpx, sqlalchemy, Next.js)
- Prometheus recording rules and alert rules
- SLO-based alerting (multi-window multi-burn-rate)
- Grafana dashboard patterns (RED, USE, Four Golden Signals)
- Jaeger trace analysis
- structlog + OTel context correlation
- Langfuse for LLM observability
- Cost optimization for observability pipelines

---

## 1. OpenTelemetry — Python

### SDK Setup

```python
# otel_setup.py
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.sampling import TraceIdRatioBased
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.resources import Resource, SERVICE_NAME, SERVICE_VERSION

def configure_telemetry(
    service_name: str,
    service_version: str,
    environment: str,
    otel_endpoint: str = "http://otel-collector:4317",
    sample_rate: float = 1.0,
) -> None:
    resource = Resource.create({
        SERVICE_NAME: service_name,
        SERVICE_VERSION: service_version,
        "deployment.environment": environment,
    })

    # Traces
    sampler = TraceIdRatioBased(sample_rate)
    tracer_provider = TracerProvider(resource=resource, sampler=sampler)
    tracer_provider.add_span_processor(
        BatchSpanProcessor(
            OTLPSpanExporter(endpoint=otel_endpoint),
            max_queue_size=2048,
            max_export_batch_size=512,
        )
    )
    trace.set_tracer_provider(tracer_provider)

    # Metrics
    metric_reader = PeriodicExportingMetricReader(
        OTLPMetricExporter(endpoint=otel_endpoint),
        export_interval_millis=30_000,
    )
    meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
    metrics.set_meter_provider(meter_provider)
```

### Auto-Instrumentation (FastAPI + httpx + SQLAlchemy)

```python
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.instrumentation.redis import RedisInstrumentor

def instrument_app(app: FastAPI, engine: Engine) -> None:
    FastAPIInstrumentor.instrument_app(
        app,
        tracer_provider=trace.get_tracer_provider(),
        http_capture_headers_server_request=["x-request-id", "x-user-id"],
    )
    HTTPXClientInstrumentor().instrument()
    SQLAlchemyInstrumentor().instrument(engine=engine)
    RedisInstrumentor().instrument()
```

### Manual Instrumentation

```python
tracer = trace.get_tracer(__name__)

async def process_order(order_id: str, user_id: str) -> OrderResult:
    with tracer.start_as_current_span(
        "process_order",
        kind=trace.SpanKind.INTERNAL,
    ) as span:
        span.set_attribute("order.id", order_id)
        span.set_attribute("user.id", user_id)

        try:
            # Child span for payment processing
            with tracer.start_as_current_span("process_payment") as payment_span:
                result = await payment_service.charge(order_id)
                payment_span.set_attribute("payment.method", result.method)
                payment_span.set_attribute("payment.amount", result.amount)
                payment_span.add_event("payment_captured", {"transaction_id": result.tx_id})

            span.set_attribute("order.status", "completed")
            return result

        except PaymentError as exc:
            span.set_status(trace.StatusCode.ERROR, str(exc))
            span.record_exception(exc)
            raise
```

### Context Propagation Across Services

```python
import httpx
from opentelemetry.propagate import inject, extract
from opentelemetry import context

async def call_downstream_service(url: str, payload: dict) -> dict:
    """Propagate trace context via HTTP headers."""
    headers: dict[str, str] = {}
    inject(headers)  # adds traceparent, tracestate headers

    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers)
        return response.json()

# In the receiving service (auto-instrumentation handles this automatically)
# Manual extraction if needed:
def extract_context_from_request(request: Request) -> context.Context:
    return extract(dict(request.headers))
```

**Reference:** [references/opentelemetry-python.md](references/opentelemetry-python.md)

---

## 2. OpenTelemetry — TypeScript/Node.js

### SDK Setup

```typescript
// otel.ts — must be imported BEFORE all other modules
import { NodeSDK } from "@opentelemetry/sdk-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-grpc";
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-grpc";
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics";
import { Resource } from "@opentelemetry/resources";
import { SEMRESATTRS_SERVICE_NAME, SEMRESATTRS_SERVICE_VERSION } from "@opentelemetry/semantic-conventions";
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";

const sdk = new NodeSDK({
	resource: new Resource({
		[SEMRESATTRS_SERVICE_NAME]: process.env.SERVICE_NAME ?? "unknown",
		[SEMRESATTRS_SERVICE_VERSION]: process.env.SERVICE_VERSION ?? "0.0.0",
		"deployment.environment": process.env.NODE_ENV ?? "development",
	}),
	traceExporter: new OTLPTraceExporter({
		url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ?? "http://otel-collector:4317",
	}),
	metricReader: new PeriodicExportingMetricReader({
		exporter: new OTLPMetricExporter(),
		exportIntervalMillis: 30_000,
	}),
	instrumentations: [
		getNodeAutoInstrumentations({
			"@opentelemetry/instrumentation-http": { enabled: true },
			"@opentelemetry/instrumentation-pg": { enabled: true },
			"@opentelemetry/instrumentation-redis": { enabled: true },
		}),
	],
});

sdk.start();
process.on("SIGTERM", () => sdk.shutdown());
```

### Manual Spans (TypeScript)

```typescript
import { trace, SpanStatusCode } from "@opentelemetry/api";

const tracer = trace.getTracer("my-service", "1.0.0");

async function processCheckout(cartId: string, userId: string): Promise<CheckoutResult> {
	return tracer.startActiveSpan("checkout.process", async (span) => {
		span.setAttributes({
			"cart.id": cartId,
			"user.id": userId,
		});

		try {
			const result = await chargePayment(cartId);
			span.setAttributes({ "payment.status": result.status });
			span.setStatus({ code: SpanStatusCode.OK });
			return result;
		} catch (err) {
			span.setStatus({ code: SpanStatusCode.ERROR, message: String(err) });
			span.recordException(err as Error);
			throw err;
		} finally {
			span.end();
		}
	});
}
```

**Reference:** [references/opentelemetry-typescript.md](references/opentelemetry-typescript.md)

---

## 3. structlog + OTel Context Correlation

```python
import structlog
from opentelemetry import trace

def add_otel_context(logger: Any, method_name: str, event_dict: dict) -> dict:
    """Inject current span's trace_id and span_id into every log entry."""
    span = trace.get_current_span()
    ctx = span.get_span_context()
    if ctx.is_valid:
        event_dict["trace_id"] = format(ctx.trace_id, "032x")
        event_dict["span_id"] = format(ctx.span_id, "016x")
        event_dict["trace_flags"] = ctx.trace_flags
    return event_dict

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        add_otel_context,
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
)

# Usage — logs automatically include trace_id for cross-signal correlation
logger = structlog.get_logger()
logger.info("order_created", order_id="ord_123", total=99.99)
# {"level":"info","timestamp":"...","trace_id":"abc...","span_id":"def...","order_id":"ord_123"}
```

---

## 4. Prometheus

### Recording Rules (pre-compute expensive queries)

```yaml
# prometheus/rules/recording-rules.yaml
groups:
  - name: api_recording_rules
    interval: 30s
    rules:
      # Request rate (5-minute rolling)
      - record: job:http_requests:rate5m
        expr: sum(rate(http_requests_total[5m])) by (job, handler, method, status)

      # Error ratio (5-minute rolling)
      - record: job:http_request_error_ratio:rate5m
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) by (job, handler)
          /
          sum(rate(http_requests_total[5m])) by (job, handler)

      # Latency percentiles
      - record: job:http_request_duration_seconds:p99_5m
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (job, handler, le)
          )

      # SLO recording rules (for error budget dashboards)
      - record: slo:http_request_error_ratio:rate1h
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[1h])) by (job)
          /
          sum(rate(http_requests_total[1h])) by (job)
```

### Instrumentation in Python (prometheus-client)

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

http_requests = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "handler", "status"],
)

http_duration = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration",
    ["method", "handler"],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0],
)

active_requests = Gauge(
    "http_requests_active",
    "Currently active HTTP requests",
)

@app.middleware("http")
async def prometheus_middleware(request: Request, call_next: Callable) -> Response:
    handler = request.url.path
    method = request.method
    active_requests.inc()
    start = time.perf_counter()

    try:
        response = await call_next(request)
        http_requests.labels(method=method, handler=handler, status=response.status_code).inc()
        return response
    finally:
        active_requests.dec()
        http_duration.labels(method=method, handler=handler).observe(
            time.perf_counter() - start
        )
```

**Reference:** [references/prometheus-rules.md](references/prometheus-rules.md)

---

## 5. Grafana Dashboards

### Service Overview Dashboard Structure

```
Row 1: SLO Status
  Panel: Error budget remaining (gauge, color: green > 50%, yellow 10-50%, red < 10%)
  Panel: Burn rate 1h / 6h / 24h (stat panels)
  Panel: Availability SLI 28d rolling (stat, target line at SLO)

Row 2: RED Metrics (request-driven services)
  Panel: Request rate (graph, split by handler)
  Panel: Error rate % (graph, threshold at 1%)
  Panel: p50 / p95 / p99 latency (graph, multi-series)

Row 3: Infrastructure
  Panel: CPU utilization % (graph)
  Panel: Memory utilization % (graph)
  Panel: Disk I/O (graph)

Row 4: Dependencies
  Panel: Database query duration p99 (graph)
  Panel: Cache hit rate % (gauge)
  Panel: External API error rate (graph)
```

### Recommended PromQL for Dashboards

```
# Request rate (per second, 5m window)
sum(rate(http_requests_total[5m])) by (handler)

# Error rate (percentage)
100 * sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))

# p99 latency
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

# Error budget remaining (percentage, 28-day window, 99.5% SLO)
100 * (1 - (
  sum(increase(http_requests_total{status=~"5.."}[28d]))
  /
  sum(increase(http_requests_total[28d]))
) / 0.005)
```

**Reference:** [references/grafana-dashboards.md](references/grafana-dashboards.md)

---

## 6. Jaeger — Trace Analysis

### What to Look For in Traces

```
1. LATENCY HOTSPOTS
   - Which span contributes most to total duration?
   - Is there sequential I/O that could be parallelized?

2. N+1 QUERIES
   - Many identical DB spans in a loop → use DataLoader / batch query

3. MISSING CONTEXT
   - Span gaps (time with no span) → instrumentation gap or thread switch

4. ERROR PROPAGATION
   - Where does the first error occur in the chain?
   - Is the root cause upstream or in the local service?

5. SAMPLING GAPS
   - Long tail (p99/p999) errors may not be sampled → consider tail-based sampling

Tags to always add to spans:
  service.name, service.version, http.method, http.url, http.status_code
  db.system, db.statement (sanitized), db.operation
  user.id (non-PII), request.id
```

### Tail-Based Sampling Configuration

```yaml
# otel-collector.yaml — route errors and slow traces to storage
processors:
  tail_sampling:
    decision_wait: 10s
    policies:
      - name: errors
        type: status_code
        status_code: {status_codes: [ERROR]}
      - name: slow-traces
        type: latency
        latency: {threshold_ms: 1000}
      - name: small-sample
        type: probabilistic
        probabilistic: {sampling_percentage: 10}
```

**Reference:** [references/jaeger-analysis.md](references/jaeger-analysis.md)

---

## 7. Langfuse — LLM Observability

### Setup (Python)

```python
from langfuse import Langfuse
from langfuse.decorators import observe, langfuse_context

langfuse = Langfuse(
    public_key=settings.langfuse_public_key.get_secret_value(),
    secret_key=settings.langfuse_secret_key.get_secret_value(),
    host=settings.langfuse_host,
)

@observe(name="rag_pipeline")
async def rag_query(question: str, user_id: str) -> str:
    # Langfuse automatically creates a trace for this function
    langfuse_context.update_current_observation(
        metadata={"user_id": user_id},
        tags=["rag", "production"],
    )

    # Instrument the LLM call
    with langfuse_context.observe_llm(
        name="claude_generation",
        model="claude-sonnet-4-5",
        model_parameters={"temperature": 0.0, "max_tokens": 1024},
        input=question,
    ) as llm_observation:
        response = await anthropic_client.messages.create(
            model="claude-sonnet-4-5",
            max_tokens=1024,
            messages=[{"role": "user", "content": question}],
        )
        llm_observation.update(
            output=response.content[0].text,
            usage={
                "input": response.usage.input_tokens,
                "output": response.usage.output_tokens,
            },
        )
        return response.content[0].text
```

### Evaluation Scores

```python
# Submit quality scores after evaluation
langfuse.score(
    trace_id=trace_id,
    name="faithfulness",
    value=0.92,  # 0-1
    comment="Answer is grounded in the retrieved context",
)

langfuse.score(
    trace_id=trace_id,
    name="relevance",
    value=0.87,
)

# LLM-as-judge evaluation
langfuse.score(
    trace_id=trace_id,
    name="llm_judge",
    value=1.0,  # 0 or 1 for binary
    comment="Claude judged the answer as correct",
)
```

### What to Track

```
Per trace:
  latency (total, per span)
  token usage (input, output, total)
  cost (USD, calculated from token usage × model pricing)
  quality scores (faithfulness, relevance, custom)

Aggregated:
  cost per user per day
  error rate by model
  latency p50/p99 by model
  cache hit rate (semantic cache)
  quality score trends over time
```

**Reference:** [references/langfuse.md](references/langfuse.md)

---

## 8. Cost Optimization

### Telemetry Cost Reduction

```
SAMPLING STRATEGY
  Development: 100% sampling (debug everything)
  Staging:     100% sampling
  Production:  10-20% baseline + tail-based for errors/slow traces

METRICS CARDINALITY
  Never use high-cardinality labels (user_id, session_id, request_id)
  Good: {method="GET", handler="/users/{id}", status="200"}
  Bad:  {user_id="usr_123", request_id="req_abc"}

LOG VOLUME
  Use structured sampling for high-frequency INFO logs
  Always log: errors, security events, slow queries (> 1s), business events
  Downsample: health check logs, routine access logs

STORAGE
  Hot path (last 7 days): low-latency storage (SSD)
  Warm path (7-30 days): object storage
  Cold path (> 30 days): archival storage or delete
```

---

## Reference Files

- [references/opentelemetry-python.md](references/opentelemetry-python.md) — OTel SDK setup, auto-instrumentation, sampling
- [references/opentelemetry-typescript.md](references/opentelemetry-typescript.md) — OTel Node.js setup, manual spans
- [references/prometheus-rules.md](references/prometheus-rules.md) — Recording rules, alert rules, SLO rules
- [references/grafana-dashboards.md](references/grafana-dashboards.md) — Dashboard templates, PromQL reference
- [references/jaeger-analysis.md](references/jaeger-analysis.md) — Trace analysis patterns, tail-based sampling
- [references/langfuse.md](references/langfuse.md) — LLM tracing, evaluation, cost tracking
- [references/structlog.md](references/structlog.md) — structlog configuration, OTel correlation
