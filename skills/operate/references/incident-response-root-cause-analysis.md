# Root Cause Analysis Techniques

## 1. Five Whys

Iteratively ask "why" to peel back layers from symptom to root cause.

```
Problem: Users getting 500 errors on checkout
Why 1: The payment service is returning errors
Why 2: The payment service can't connect to the database
Why 3: The database connection pool is exhausted
Why 4: A new query is holding connections for 30+ seconds
Why 5: The query lacks an index on the orders.user_id column
Root cause: Missing database index causing slow queries under load
```

**Tips:**
- Don't stop at the first "human error" -- ask why the system allowed it
- Multiple branches are normal (not always linear)
- 5 is a guideline, not a rule -- stop when you reach actionable systemic cause
- Avoid "why didn't someone..." -- focus on system gaps

## 2. Fault Tree Analysis (FTA)

Top-down deductive analysis using AND/OR gates.

```
                    [Service Outage]
                         |
                    [OR gate]
                   /          \
    [Database failure]    [Network failure]
          |                      |
     [OR gate]              [AND gate]
     /       \              /        \
[Disk full] [OOM]   [Switch down] [No failover]
```

**When to use:** Complex incidents with multiple potential causes.
Useful for identifying single points of failure.

## 3. Ishikawa (Fishbone) Diagram

Categorize contributing factors along six branches:

```
People --------+
Methods -------+
Machines ------+----> [Incident]
Materials -----+
Measurements --+
Environment ---+
```

**SRE-adapted categories:**

| Category | Examples |
|----------|---------|
| **People** | Training gaps, handoff failures, fatigue |
| **Process** | Missing runbook, no change review, no rollback plan |
| **Technology** | Single point of failure, missing monitoring, bad defaults |
| **Environment** | Cloud provider issue, network, DNS |
| **Data** | Corrupt data, schema mismatch, missing validation |
| **Dependencies** | Third-party outage, API change, certificate expiry |

## 4. Timeline Analysis

Plot every event on a timeline to identify:
- **Gaps:** Long periods with no action (detection delay?)
- **Cascades:** Event A caused B caused C
- **Red herrings:** Time spent investigating wrong cause
- **Decision points:** Where different choices would change outcome

## 5. Change Analysis

Compare the state before and after the incident:
- What changed in the last 24h? (deploys, configs, infra)
- What didn't change that should have? (stale certs, unpatched)
- Use `git log`, deploy logs, config management history

## Choosing a Technique

| Technique | Best For | Complexity |
|-----------|----------|-----------|
| 5 Whys | Simple, single-cause incidents | Low |
| Fault Tree | Complex, multiple potential causes | Medium |
| Ishikawa | Broad exploration, many contributing factors | Medium |
| Timeline | Understanding sequence and delays | Low |
| Change | Incidents correlated with recent changes | Low |

## Anti-Patterns

- Stopping at "human error" -- always ask what system gap allowed it
- Single root cause bias -- most incidents have multiple contributing factors
- Confirmation bias -- don't just validate your first theory
- Blame framing -- "who" is never the root cause
