# On-Call Best Practices

## Rotation Design
- **Duration**: 1 week rotations (shorter causes context-switching overhead)
- **Overlap**: 30min handoff between rotations
- **Shadow**: new team members shadow for 1-2 rotations before going primary
- **Follow-the-sun**: distribute across timezones for 24/7 coverage without night shifts

## Handoff Protocol
1. Outgoing writes handoff document: active incidents, ongoing investigations, scheduled changes
2. 30-min live sync covering current state
3. Verify alerting routes point to incoming on-call
4. Transfer pager/phone

## Alert Fatigue Reduction
- Target: <5 actionable pages per on-call shift
- Every alert must have a runbook linked
- Snooze noisy alerts and create tickets to fix thresholds
- Review alert signal-to-noise ratio monthly

## Escalation Matrix
```
L1 (0-15min): On-call engineer — diagnose and mitigate
L2 (15-30min): Secondary on-call or team lead
L3 (30min+): Incident commander, cross-team escalation
L4 (1h+, P1): VP/Director-level awareness
```

## Compensation
- Paid on-call stipend (not just "part of the job")
- Time off after high-severity incidents
- Reduced sprint commitments during on-call weeks

## Tooling
- PagerDuty / Opsgenie for alert routing and escalation
- Slack incident channel auto-created per incident
- Status page updates automated via API
