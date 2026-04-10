# OpenTelemetry Python Setup

## Installation

```bash
# Core SDK — pin to exact versions
pip install opentelemetry-api==1.40.0
pip install opentelemetry-sdk==1.40.0
pip install opentelemetry-exporter-otlp==1.40.0

# Auto-instrumentation
pip install opentelemetry-distro==0.49b0
pip install opentelemetry-instrumentation==0.49b0

# Common instrumentations
pip install opentelemetry-instrumentation-fastapi==0.49b0
pip install opentelemetry-instrumentation-httpx==0.49b0
pip install opentelemetry-instrumentation-sqlalchemy==0.49b0
pip install opentelemetry-instrumentation-redis==0.49b0
pip install opentelemetry-instrumentation-logging==0.49b0
```

## Full Setup Pattern

```python
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.semconv.resource import ResourceAttributes


def setup_telemetry(
    service_name: str,
    service_version: str,
    environment: str,
    otlp_endpoint: str = "http://localhost:4317",
) -> None:
    """Initialize OpenTelemetry with traces and metrics."""
    resource = Resource.create({
        ResourceAttributes.SERVICE_NAME: service_name,
        ResourceAttributes.SERVICE_VERSION: service_version,
        ResourceAttributes.DEPLOYMENT_ENVIRONMENT: environment,
    })

    # Traces
    tracer_provider = TracerProvider(resource=resource)
    tracer_provider.add_span_processor(
        BatchSpanProcessor(
            OTLPSpanExporter(endpoint=otlp_endpoint),
            max_queue_size=2048,
            max_export_batch_size=512,
            schedule_delay_millis=5000,
        )
    )
    trace.set_tracer_provider(tracer_provider)

    # Metrics
    metric_reader = PeriodicExportingMetricReader(
        OTLPMetricExporter(endpoint=otlp_endpoint),
        export_interval_millis=60000,
    )
    meter_provider = MeterProvider(
        resource=resource,
        metric_readers=[metric_reader],
    )
    metrics.set_meter_provider(meter_provider)
```

## OTel Collector Config

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 5s
    send_batch_size: 512
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
    spike_limit_mib: 128

exporters:
  otlp/jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true
  prometheus:
    endpoint: 0.0.0.0:8889

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [otlp/jaeger]
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus]
```

## Environment Variables

```bash
# Standard OTel env vars
OTEL_SERVICE_NAME=my-service
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1  # 10% sampling
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production
```

## Sources

- [OpenTelemetry Python Docs](https://opentelemetry.io/docs/languages/python/)
- [OTel Collector Configuration](https://opentelemetry.io/docs/collector/configuration/)
- [OpenTelemetry Best Practices](https://betterstack.com/community/guides/observability/opentelemetry-best-practices/)
