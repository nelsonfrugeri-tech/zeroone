# Questioning Techniques

## The 5 Whys

For every requirement, ask "why" until you reach the root need.

```
Requirement: "Add a cache to the API"
Why? → "The API is slow"
Why? → "Database queries take too long"
Why? → "We're doing full table scans"
Why? → "No indexes on the filter columns"
Why? → "Schema was created without performance analysis"

Real solution: Add indexes, not a cache.
```

## Question Categories

### Scope Questions
- What exactly should this change?
- What should NOT change?
- Are there related features affected?
- What is the minimal viable implementation?

### Behavior Questions
- What are the inputs and expected outputs?
- What happens with invalid input?
- What happens with empty/null input?
- What happens under concurrent access?
- What are the boundary conditions?

### Constraint Questions
- What are the performance requirements? (latency, throughput)
- What are the security implications?
- What backwards compatibility must be maintained?
- What environments must this work in?

### Dependency Questions
- What existing code does this interact with?
- What external services does this depend on?
- Are there database migrations needed?
- Are there configuration changes needed?

### Acceptance Questions
- How will we know this is done?
- Who approves the implementation?
- What tests prove it works?
- What does "production-ready" mean for this?

## When to Ask the User

Ask when:
- The requirement is ambiguous
- Multiple valid interpretations exist
- The scope is unclear
- Trade-offs need a product decision

Do NOT ask when:
- The answer is in the code/docs
- It is a purely technical decision
- The requirement is clear and unambiguous
