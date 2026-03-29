---
name: sre-observability
description: "SRE & Observability skill — monitoring, tracing, incident response, reliability engineering based on Google SRE and industry best practices."
triggers:
  - /sre
  - observability
  - monitoring
  - tracing
  - incident
  - reliability
  - SLO
  - SLI
  - error budget
---

# SRE & Observability Skill

## Foundation: The Three Pillars of Observability

### 1. Traces (Distributed Tracing)
- Every request has a trace ID that follows it through all services
- Traces contain spans — each span is a unit of work (LLM call, DB query, API call)
- Key metrics per span: latency, status, input/output, tokens used
- Tools: Langfuse (LLM-specific), Jaeger, Zipkin, OpenTelemetry

### 2. Logs (Structured Logging)
- Logs tell you WHAT happened — the narrative
- Always structured (JSON), never free-text in production
- Log levels: DEBUG (dev only), INFO (operations), WARN (degraded), ERROR (failures)
- Key fields: timestamp, service, trace_id, level, message, context
- Tools: ELK Stack, Loki, CloudWatch

### 3. Metrics (Quantitative Measurements)
- Metrics tell you HOW MUCH — the numbers
- Types: counters (total requests), gauges (current connections), histograms (latency distribution)
- RED method for services: Rate, Errors, Duration
- USE method for resources: Utilization, Saturation, Errors
- Tools: Prometheus, Grafana, Datadog

## Google SRE Principles

### Service Level Indicators (SLIs)
- Quantitative measure of a service aspect
- Examples: request latency, error rate, throughput, availability
- For AI agents: response time, token usage per request, error rate, hallucination rate

### Service Level Objectives (SLOs)
- Target value for an SLI
- Example: "99.9% of requests complete in < 30s"
- For AI agents: "95% of agent responses under 60s", "error rate < 2%"

### Error Budgets
- Amount of unreliability allowed: 100% - SLO = error budget
- If SLO is 99.9%, error budget is 0.1%
- When budget is spent → freeze changes, focus on reliability
- For AI agents: token budget per day, max errors per hour

### Toil
- Manual, repetitive, automatable work that scales linearly with service size
- Goal: keep toil below 50% of team time
- Automate monitoring, alerting, and common remediation

## Incident Response

### Severity Levels
- P1: Service down, all users affected → immediate response
- P2: Major feature broken, many users affected → respond within 1h
- P3: Minor feature degraded, some users affected → respond within 4h
- P4: Cosmetic issue, workaround available → next business day

### Incident Lifecycle
1. **Detect** — Monitoring alerts or user reports
2. **Triage** — Assess severity, assign responder
3. **Mitigate** — Stop the bleeding (rollback, disable feature, scale up)
4. **Resolve** — Fix the root cause
5. **Postmortem** — Blameless review, action items, prevention

### Postmortem Template
- What happened (timeline)
- Impact (users affected, duration)
- Root cause (5 whys)
- What went well
- What went wrong
- Action items (with owners and deadlines)

## AI Agent-Specific Observability

### Key Metrics for AI Agents
- **Token usage**: input/output per call, total per day/agent
- **Latency**: time from message received to response sent
- **Error rate**: failed LLM calls / total calls
- **Cost**: token cost per agent, per day, per project
- **Tool usage**: which tools agents call most often
- **Escalation rate**: how often agents escalate to opus
- **Loop detection**: agent-to-agent message count per thread

### Alerting Rules
- Token usage > 2x daily average → warn
- Error rate > 5% in 15min window → alert
- Agent-to-agent loop > 5 messages → auto-stop
- Response latency > 120s → warn
- Cost per day > budget threshold → alert

### Dashboard Panels
1. **Overview**: active agents, total requests, error rate, total cost
2. **Per-agent**: requests, tokens, latency p50/p95/p99, errors
3. **Traces**: recent traces with input/output, drill-down capability
4. **Costs**: daily/weekly cost breakdown by agent and model
5. **Anomalies**: loops detected, escalations, errors timeline

## Classic References
- "Site Reliability Engineering" (Google, 2016) — The SRE Bible
- "The Site Reliability Workbook" (Google, 2018) — Practical implementation
- "Observability Engineering" (Majors, Fong-Jones, Miranda, 2022) — Modern observability
- "Designing Data-Intensive Applications" (Kleppmann, 2017) — Data systems reliability
- "Release It!" (Nygard, 2018) — Stability patterns and anti-patterns
