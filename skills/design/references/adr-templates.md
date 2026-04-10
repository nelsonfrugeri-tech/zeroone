# ADR Templates

## MADR (Markdown Any Decision Record) v3.0

The recommended template for this ecosystem. Based on https://adr.github.io/madr/

### Full Template

```markdown
# ADR-{NNN}: {Title}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-XXX}

## Context and Problem Statement

{Describe the context and problem statement, e.g., in free form using two to three sentences
or in the form of an illustrative story. You may want to articulate the problem in form of
a question.}

## Decision Drivers

- {decision driver 1, e.g., a force, facing concern, ...}
- {decision driver 2, e.g., a force, facing concern, ...}
- ...

## Considered Options

- {title of option 1}
- {title of option 2}
- {title of option 3}

## Decision Outcome

Chosen option: "{title of option 1}", because {justification. e.g., only option which meets
k.o. criterion decision driver | which resolves force {force} | ... | comes out best (see
below)}.

### Consequences

- Good, because {positive consequence, e.g., improvement of one or more desired qualities, ...}
- Bad, because {negative consequence, e.g., compromising one or more desired qualities, ...}
- ...

### Confirmation

{Describe how the implementation of/compliance with the ADR can be confirmed. E.g., by a
review, test, architecture fitness function, or manual inspection. Not every ADR needs this.}

## Pros and Cons of the Options

### {title of option 1}

{example | description | pointer to more information | ...}

- Good, because {argument a}
- Good, because {argument b}
- Neutral, because {argument c}
- Bad, because {argument d}

### {title of option 2}

- Good, because {argument a}
- Bad, because {argument b}
- ...

## More Information

{Links to related ADRs, external references, meeting notes, etc.}
```

### Lightweight Template (Y-Statement)

For smaller decisions that don't need full analysis:

```markdown
# ADR-{NNN}: {Title}

## Status: {Proposed | Accepted}

In the context of {use case / story},
facing {concern / problem},
we decided for {option},
and against {other options},
to achieve {quality / goal},
accepting {downside / trade-off}.
```

### Nygardian Template (Original)

The simplest format, by Michael Nygard:

```markdown
# {NUMBER}. {TITLE}

Date: {YYYY-MM-DD}

## Status

{Proposed | Accepted | Deprecated | Superseded by [ADR-XXX](XXX-title.md)}

## Context

{What is the issue that we're seeing that is motivating this decision or change?}

## Decision

{What is the change that we're proposing and/or doing?}

## Consequences

{What becomes easier or more difficult to do because of this change?}
```

## Naming Convention

```
docs/adr/
  0001-use-postgresql-for-primary-storage.md
  0002-adopt-event-driven-architecture.md
  0003-choose-grpc-for-internal-communication.md
  README.md  (index of all ADRs)
```

## ADR Index Template (README.md)

```markdown
# Architecture Decision Records

| # | Title | Status | Date |
|---|-------|--------|------|
| 1 | [Use PostgreSQL for primary storage](0001-use-postgresql.md) | Accepted | 2026-01-15 |
| 2 | [Adopt event-driven architecture](0002-event-driven.md) | Accepted | 2026-02-01 |
| 3 | [Choose gRPC for internal comms](0003-grpc-internal.md) | Superseded by #5 | 2026-02-15 |
```

## CLI Tools

- **adr-tools** (bash): `adr new "Use PostgreSQL"` — auto-numbers, creates from template
- **log4brains** (node): generates searchable ADR website from markdown
- **adr-manager** (VS Code extension): visual ADR management

## Sources

- https://adr.github.io/
- https://adr.github.io/madr/
- https://github.com/joelparkerhenderson/architecture-decision-record
- https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/
