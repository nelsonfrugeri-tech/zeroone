# Runbook Template

## Structure

```markdown
# [Service] — [Scenario]

## Severity: P1/P2/P3/P4

## Symptoms
- Alert name and condition
- User-visible impact
- Expected metrics deviation

## Prerequisites
- Access: SSH, kubectl, cloud console
- Tools: promtool, grafana-cli
- Permissions: write access to config

## Diagnosis Steps
1. Check service health: `curl -s http://service/health | jq .`
2. Check recent deploys: `kubectl rollout history deployment/service`
3. Check error rate: PromQL `rate(http_requests_total{code=~"5.."}[5m])`
4. Check resource usage: `kubectl top pods -n namespace`

## Mitigation
1. **Rollback** (if deploy-related): `kubectl rollout undo deployment/service`
2. **Scale up** (if load-related): `kubectl scale deployment/service --replicas=N`
3. **Circuit breaker** (if dependency): toggle feature flag `SERVICE_CB=true`

## Escalation
| Level | Who | When |
|-------|-----|------|
| L1 | On-call engineer | Immediately |
| L2 | Team lead | After 15min without mitigation |
| L3 | VP Engineering | P1 > 30min, data loss risk |

## Rollback Procedure
1. Identify last known good version
2. Deploy: `kubectl set image deployment/service app=image:version`
3. Verify: check health endpoint + error rate
4. Notify stakeholders

## Post-Incident
- Create postmortem within 48h
- Update this runbook with learnings
```
