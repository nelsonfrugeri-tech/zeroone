# OpenTelemetry SDK Instrumentation

## Instrumentation Strategy

Start with auto-instrumentation for immediate visibility, then add manual spans
as understanding deepens. The journey is incremental.

### Auto-Instrumentation

```python
# Python: zero-code auto-instrumentation
# pip install opentelemetry-distro opentelemetry-exporter-otlp
# opentelemetry-instrument python app.py

# Programmatic auto-instrumentation (more control)
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

FlaskInstrumentor().instrument_app(app)
SQLAlchemyInstrumentor().instrument(engine=engine)
```

### Manual Instrumentation

```python
from opentelemetry import trace
from opentelemetry.trace import StatusCode

tracer = trace.get_tracer("my.service", "1.0.0")

@tracer.start_as_current_span("process_order")
def process_order(order_id: str) -> dict:
    span = trace.get_current_span()
    span.set_attribute("order.id", order_id)
    try:
        result = validate_order(order_id)
        span.set_attribute("order.items_count", len(result["items"]))
        return result
    except Exception as e:
        span.set_status(StatusCode.ERROR, str(e))
        span.record_exception(e)
        raise
```

## Context Propagation

### W3C Trace Context (default, recommended)

```python
from opentelemetry import propagate

# Inject context into outgoing HTTP headers
headers = {}
propagate.inject(headers)
# headers: traceparent, tracestate

# Extract context from incoming headers
ctx = propagate.extract(carrier=request.headers)
with tracer.start_as_current_span("handle_request", context=ctx):
    pass
```

### Baggage (cross-service context)

```python
from opentelemetry import baggage, context

ctx = baggage.set_baggage("user.tier", "premium")
token = context.attach(ctx)
# Downstream reads: baggage.get_baggage("user.tier")
```

## SDK Initialization (must be FIRST)

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource, SERVICE_NAME

resource = Resource.create({SERVICE_NAME: "my-service"})
provider = TracerProvider(resource=resource)
provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
trace.set_tracer_provider(provider)
# MUST happen before any instrumented library is imported
```

## Collector Deployment

Always send to OTel Collector, not directly to backends:
- Decouples export problems from app
- Simplifies secret management
- Enables enrichment, sampling, routing

```yaml
receivers:
  otlp:
    protocols:
      grpc: { endpoint: 0.0.0.0:4317 }
processors:
  batch: { timeout: 5s, send_batch_size: 8192 }
  memory_limiter: { limit_mib: 512 }
exporters:
  otlp: { endpoint: "tempo:4317" }
  prometheus: { endpoint: "0.0.0.0:8889" }
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [otlp]
```

## Metrics Best Practices

- Avoid heap allocation on hot paths
- Use pre-aggregation for predictable memory
- Measure instrumentation coverage like code coverage

```python
from opentelemetry import metrics
meter = metrics.get_meter("my.service")
request_counter = meter.create_counter("http.requests", unit="1")
latency_histogram = meter.create_histogram("http.latency", unit="ms")
```

## Sampling Strategies

| Strategy | Use Case |
|----------|----------|
| AlwaysOn | Dev/staging |
| TraceIdRatio(0.1) | 10% in high-traffic prod |
| ParentBased | Respect upstream decision |
| Custom | All errors + N% success |

## Semantic Conventions

Follow OTel conventions: `http.request.method`, `db.system`,
`rpc.service`. Custom: reverse-DNS (`com.mycompany.order.id`).
