# Incident Response Workflow

## The Five Phases

### 1. Detect

**Goal:** Minimize time-to-detection (TTD).

- Symptom-based alerts fire (user-facing impact, not internal cause)
- Burn-rate alerts on SLO breach trajectory
- Customer reports via support channels
- Synthetic monitoring failures

**Key metric:** TTD = time from incident start to first alert.

### 2. Triage

**Goal:** Assess severity, assemble responders, communicate.

**Severity levels:**

| Level | Impact | Response Time | Example |
|-------|--------|---------------|---------|
| SEV1 | Full outage, data loss | Immediate, all-hands | Payment system down |
| SEV2 | Major degradation | 15 min, on-call team | 50% error rate |
| SEV3 | Minor degradation | 1 hour, primary on-call | Slow responses, one region |
| SEV4 | Low impact | Next business day | Cosmetic issues |

**Triage actions:**
1. Assign Incident Commander (IC)
2. Open incident channel (Slack #inc-YYYYMMDD-short-desc)
3. Post initial assessment: what, when, who's affected, severity
4. Page additional responders if needed

### 3. Mitigate

**Goal:** Restore service ASAP. Fix later, mitigate now.

**Common mitigations:**
- Rollback deployment
- Toggle feature flag off
- Scale up / failover
- Rate limit / shed load
- Redirect traffic to healthy region
- Restart crashed processes

**Anti-patterns:**
- Debugging root cause before mitigating
- Making untested changes to prod
- Multiple people making changes simultaneously without coordination

### 4. Resolve

**Goal:** Confirm full recovery, monitor for recurrence.

- Verify all metrics return to baseline
- Confirm via synthetic checks and real user monitoring
- Remove temporary mitigations (or document if they stay)
- Close incident channel with summary
- Update status page

### 5. Postmortem

**Goal:** Learn and prevent recurrence. See `postmortem-template.md`.

**Timeline:**
- Draft within 48 hours
- Review within 1 week
- Action items tracked to completion

## Communication During Incidents

### Status Update Template

```
[HH:MM UTC] Status Update #N
Impact: {what users see}
Current status: {investigating | mitigating | monitoring | resolved}
Next update: {time or "in 30 minutes"}
```

### Cadence
- SEV1: Every 15 minutes
- SEV2: Every 30 minutes
- SEV3: Every hour

## Roles

| Role | Responsibility |
|------|---------------|
| **Incident Commander** | Coordinates response, delegates, communicates |
| **Tech Lead** | Drives technical investigation and mitigation |
| **Communications** | Updates status page, stakeholders, customers |
| **Scribe** | Documents timeline, actions, decisions |

## Post-Incident Checklist

- [ ] Timeline documented
- [ ] Root cause identified (see `root-cause-analysis.md`)
- [ ] Postmortem written (see `postmortem-template.md`)
- [ ] Action items created with owners and deadlines
- [ ] Runbook updated if applicable
- [ ] Monitoring/alerting gaps addressed
