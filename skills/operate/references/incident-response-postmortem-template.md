# Blameless Postmortem Template

## Header

```markdown
# Postmortem: {Incident Title}

**Date:** YYYY-MM-DD
**Severity:** SEV{1-4}
**Duration:** {start} to {end} ({total duration})
**Authors:** {names}
**Status:** Draft | In Review | Complete
```

## 1. Summary

One paragraph: what happened, impact, duration, resolution.

```markdown
On {date}, {service} experienced {description of failure} for {duration},
affecting {N users / N% of traffic / specific functionality}. The root cause
was {one sentence}. The incident was resolved by {mitigation action}.
```

## 2. Impact

```markdown
- **Duration:** HH:MM to HH:MM UTC ({N} minutes)
- **Users affected:** {number or percentage}
- **Revenue impact:** {estimated or N/A}
- **SLO impact:** {error budget consumed}
- **Data loss:** {yes/no, details}
```

## 3. Timeline

```markdown
| Time (UTC) | Event |
|------------|-------|
| HH:MM | {trigger event} |
| HH:MM | Alert fired: {alert name} |
| HH:MM | IC assigned: {name} |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied: {action} |
| HH:MM | Service restored |
| HH:MM | All-clear declared |
```

## 4. Root Cause

Detailed technical explanation. Use 5 Whys or fault tree analysis.
See `root-cause-analysis.md` for techniques.

```markdown
The root cause was {detailed explanation}.

### Contributing Factors
- {factor 1}
- {factor 2}
```

## 5. What Went Well

```markdown
- {positive aspect of the response}
- {thing that prevented worse outcome}
```

## 6. What Went Wrong

```markdown
- {thing that made the incident worse or slower to resolve}
- {gap in monitoring, process, or tooling}
```

## 7. Where We Got Lucky

```markdown
- {thing that could have made it worse but didn't}
```

## 8. Action Items

```markdown
| # | Action | Type | Owner | Deadline | Status |
|---|--------|------|-------|----------|--------|
| 1 | {action} | Prevent | {name} | {date} | TODO |
| 2 | {action} | Detect | {name} | {date} | TODO |
| 3 | {action} | Mitigate | {name} | {date} | TODO |
```

**Action types:**
- **Prevent:** Stop this from happening again
- **Detect:** Catch it faster next time
- **Mitigate:** Reduce impact when it happens

## 9. Lessons Learned

```markdown
- {key takeaway for the team}
```

## Blameless Culture Rules

1. Focus on systems and processes, not individuals
2. "Who" is never the root cause -- "what system allowed this"
3. Assume everyone acted with best intentions and available information
4. The goal is learning, not punishment
5. Share widely -- other teams benefit from your learnings
