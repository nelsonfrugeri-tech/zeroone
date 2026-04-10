---
name: manage
description: |
  Technical Product/Platform Management knowledge base. Covers INVEST user stories,
  acceptance criteria (Given/When/Then), prioritization frameworks (RICE, MoSCoW,
  effort-impact matrix), roadmap planning (Now/Next/Later/Won't), PRD template
  (Problem/Context/Solution/Stories/SLIs/Scope/Risks), AARRR metrics, stakeholder
  communication by audience, and the Discovery-Definition-Delivery-Iteration workflow.
  Use when: (1) Defining and prioritizing backlog, (2) Writing user stories with
  acceptance criteria, (3) Planning roadmaps and releases, (4) Communicating product
  decisions to the team, (5) Writing PRDs.
  Triggers: /manage, /pm, product management, backlog, user stories, roadmap, prioritization, PRD.
type: capability
---

# Manage — Technical Product Management

## Purpose

This skill is the knowledge base for Technical Product/Platform Management.
It focuses on managing technical products — bridging business needs and engineering reality.

**What this skill contains:**
- User stories (INVEST criteria, acceptance criteria format)
- Prioritization frameworks (RICE, MoSCoW, effort-impact)
- Roadmap planning (Now/Next/Later/Won't)
- Sprint/iteration planning template
- PRD (Product Requirements Document) template
- Product metrics (AARRR framework)
- Discovery → Definition → Delivery → Iteration workflow
- Communication formats by audience
- Technical debt management from product perspective

---

## Philosophy

### Product is About Value, Not Features

**Every feature must have a clear "why" connected to business value.**
Metrics of success are defined BEFORE starting development.
Decisions are data-driven when data is available, hypothesis-driven when not.

### Principles

1. **Focus on the user's problem, not the technical solution**
2. **Measurable acceptance criteria** — "done" is not subjective
3. **Say "no" with data** — scope reduction is a feature, not a failure
4. **Roadmaps are commitments to problems, not solutions**
5. **Protect the team from scope creep while keeping stakeholders informed**

---

## 1. User Stories

### Format

```markdown
**As** [persona/user type],
**I want** [action/functionality],
**So that** [benefit/value].

### Acceptance Criteria
- [ ] Given [context], when [action], then [expected result]
- [ ] Given [context], when [action], then [expected result]
- [ ] Given [context], when [action], then [expected result]

### Technical Notes
- {relevant implementation considerations}
- {known dependencies}
- {identified risks}

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Tests written (unit + integration)
- [ ] Documentation updated
- [ ] Deploy to staging validated
- [ ] Acceptance criteria verified
```

### INVEST Criteria

| Letter | Criterion | Meaning |
|--------|-----------|---------|
| **I** | Independent | Can be developed in isolation |
| **N** | Negotiable | Not a contract, it's a conversation |
| **V** | Valuable | Delivers value to the user |
| **E** | Estimable | Team can estimate effort |
| **S** | Small | Fits in one sprint/iteration |
| **T** | Testable | Acceptance criteria are verifiable |

### Common Anti-patterns

- Stories that depend on each other (violates I)
- "As a system, I want to..." — not a user story
- "User can create, read, update, and delete" — too big, split it
- No acceptance criteria — "done" becomes subjective
- Technical specs disguised as user stories

---

## 2. Prioritization Frameworks

### RICE Score

```markdown
| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| {name}  | {1-10}| {1-3}  | {0.5-1.0}  | {days} | {calc}    |

Score = (Reach × Impact × Confidence) / Effort
```

- **Reach:** How many users impacted (1-10)
- **Impact:** How much impact per user (1=minimal, 3=massive)
- **Confidence:** Certainty about estimates (0.5=low, 0.75=medium, 1.0=high)
- **Effort:** Effort in person-days

### MoSCoW

```markdown
### Must Have (P0) — Without this, we don't launch
- {feature}

### Should Have (P1) — Important, but workable without
- {feature}

### Could Have (P2) — Nice to have
- {feature}

### Won't Have (P3) — Explicitly out of scope this release
- {feature} — {reason for deferral}
```

### Effort × Impact Matrix

```
|              | Low Effort | High Effort |
|-------------|------------|-------------|
| High Impact | Quick Wins | Big Bets    |
| Low Impact  | Fill-ins   | Money Pits  |
```

**Quick Wins:** Do first — high value, low cost
**Big Bets:** Evaluate carefully — high value, high investment
**Fill-ins:** Do if time allows — low value, low cost
**Money Pits:** Avoid — low value, high cost

---

## 3. Roadmap

### Now / Next / Later / Won't Format

```markdown
## Roadmap — {Product}

### Now (Current sprint/cycle)
| Item | Status | Owner | ETA |
|------|--------|-------|-----|
| {item} | {status} | {who} | {when} |

### Next (Next cycle)
| Item | Priority | Estimate |
|------|----------|----------|
| {item} | {P0/P1/P2} | {estimate} |

### Later (Prioritized backlog)
| Item | Priority | Notes |
|------|----------|-------|
| {item} | {P1/P2/P3} | {context} |

### Won't Do (Explicit decisions)
| Item | Reason |
|------|--------|
| {item} | {justification} |
```

### Roadmap Rules

1. **Problems not solutions** — roadmaps commit to solving problems, not implementing specific solutions
2. **Timeframes not dates** — "Next quarter" is more honest than "March 15th"
3. **Explicit Won't Do** — what you're NOT building is as important as what you are
4. **Review monthly** — roadmaps are living documents, not contracts

---

## 4. Sprint/Iteration Planning

```markdown
## Sprint {N} — {Theme/Goal}

### Objective
{One clear sentence of what we want to achieve}

### Success Criteria
- {measurable deliverable or metric}

### Items
| # | User Story | Estimate | Owner | Status |
|---|-----------|----------|-------|--------|
| 1 | {story}   | {points} | {dev} | {status} |

### Risks and Dependencies
- {identified risk/dependency}

### Team Capacity
- {N} devs × {M} days = {total} person-days available
- Buffer: 20% for bugs/unplanned work
- Net capacity: {net} person-days
```

---

## 5. PRD Template

```markdown
# PRD: {Feature Name}

## Problem
{What problem are we solving? For whom?}

## Context
{Why now? Data, user feedback, market opportunity}

## Proposed Solution
{High-level description of the solution}

## User Stories
{List of user stories that compose the feature}

## Success Metrics
- {KPI 1}: {baseline} → {target}
- {KPI 2}: {baseline} → {target}

## Scope

### In Scope
- {item}

### Out of Scope
- {item} — {reason for exclusion}

## Dependencies
- {technical or product dependency}

## Timeline
- Discovery: {period}
- Design: {period}
- Development: {period}
- QA/Staging: {period}
- Release: {date}

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| {risk} | {H/M/L} | {H/M/L} | {action} |

## SLIs (Service Level Indicators)
- {metric that will measure if this feature is working correctly}
```

---

## 6. Product Metrics (AARRR)

```markdown
### Acquisition — How users arrive
- {metric}: {definition and target}

### Activation — First value delivered
- {metric}: {definition and target}

### Retention — Users return
- {metric}: {definition and target}

### Revenue — Monetization
- {metric}: {definition and target}

### Referral — Users bring others
- {metric}: {definition and target}
```

### Metrics Best Practices

1. **Define metrics BEFORE building** — not after to justify the decision
2. **Leading indicators over lagging** — detect problems early
3. **One north star metric** — what matters most?
4. **Avoid vanity metrics** — page views without context mean nothing
5. **Instrument from day one** — retrofitting analytics is painful

---

## 7. Product Workflow

### Discovery → Definition → Delivery → Iteration

```
1. DISCOVERY: Understand the problem
   - Research context and data
   - Map personas and needs
   - Identify opportunities
   - Validate hypotheses (user interviews, data analysis)

2. DEFINITION: Define the solution
   - Write PRD
   - Create user stories with acceptance criteria
   - Prioritize backlog (RICE/MoSCoW)
   - Align with technical team (feasibility check)
   - Get stakeholder sign-off

3. DELIVERY: Manage execution
   - Sprint planning with team
   - Daily sync (blockers, decisions)
   - Accept/reject deliveries vs criteria
   - Communicate progress to stakeholders
   - Unblock dependencies

4. ITERATION: Measure and iterate
   - Validate success metrics
   - Collect user feedback
   - Adjust backlog and priorities
   - Document learnings
   - Plan next cycle
```

---

## 8. Communication by Audience

### For Developers

- Detailed user stories with acceptance criteria
- Relevant technical and business context
- Documented trade-off decisions
- Availability for questions and refinement
- Clear definition of "done"

### For Stakeholders

- Executive-format status (summary, risks, next steps)
- Metrics and progress vs goals
- Pending decisions with options and recommendation
- Timeline and roadmap impacts

### For Design

- User problems and context (not solution prescriptions)
- Relevant technical constraints
- User flows and functional requirements
- UX acceptance criteria

---

## 9. Technical Debt from Product Perspective

### When to Prioritize Tech Debt

- When it's slowing down feature delivery (velocity is dropping)
- When it's causing production incidents (reliability suffering)
- When it's creating security risk
- When it's blocking key hires (engineers won't work in the codebase)

### How to Frame Tech Debt to Stakeholders

```
BAD: "We need to refactor the authentication module."

GOOD: "The authentication code causes ~30% of our incidents.
       Fixing it will reduce our incident response time by half
       and let us ship new auth features 3x faster. Investment: 2 sprints."
```

### Tech Debt Budget

- Reserve 20% of each sprint for technical debt
- Track tech debt items with the same rigor as features
- Include velocity impact when making the business case

---

## Reference Files

- [references/story-templates.md](references/story-templates.md) — User story examples by type
- [references/prioritization.md](references/prioritization.md) — RICE calculation examples, MoSCoW examples
- [references/metrics.md](references/metrics.md) — AARRR framework, leading/lagging indicators
- [references/stakeholder-communication.md](references/stakeholder-communication.md) — Status report templates
