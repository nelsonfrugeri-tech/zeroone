---
name: research
description: |
  Structured technical research methodology for engineering decisions. Covers platform-specific
  search strategies (Google, GitHub, HuggingFace, PyPI, npm, arXiv, Papers with Code), advanced
  search operators, source taxonomy by domain, multi-source validation protocol, synthesis templates
  (comparison tables, recommendation format, research log), debate frameworks (trade-off analysis,
  decision matrices), anti-patterns, and when to stop researching.
  Use when: (1) Choosing technologies/libraries/frameworks, (2) Comparing alternatives,
  (3) Evaluating state of the art, (4) Backing architectural decisions with evidence,
  (5) Investigating vulnerabilities or breaking changes.
  Triggers: /research, compare options, state of the art, evaluate alternatives, technology selection.
type: capability
---

# Research — Technical Research Methodology

## Purpose

This skill is the knowledge base for structured technical research. It provides methodology,
not opinions. Every recommendation an agent makes must be grounded in current, verified,
multi-source research.

**What this skill contains:**
- Search strategies by platform
- Advanced search operators
- Source taxonomy by domain
- Validation protocol (multi-source, date verification, bias detection)
- Synthesis templates (comparison tables, recommendation format, research log)
- Debate frameworks (trade-off analysis, decision matrices)
- Common anti-patterns
- When to stop researching

**What this skill does NOT contain:**
- Domain-specific knowledge (that lives in python, typescript, ai-ml, etc.)
- Execution workflow (agents own that)

---

## 1. Search Strategies by Platform

Each platform has different strengths. Use the right platform for the right question.

### Decision Tree

```
What am I researching?
  |
  +-- Library/framework selection? --> PyPI/npm + GitHub + Google
  |
  +-- AI/ML model or technique? --> HuggingFace + arXiv + Papers with Code
  |
  +-- Infrastructure/DevOps tool? --> GitHub + Google + vendor docs
  |
  +-- Security vulnerability? --> NVD + GitHub Advisories + Google
  |
  +-- Benchmark/performance data? --> Papers with Code + GitHub + blog posts
  |
  +-- Best practice/pattern? --> Google + GitHub (real codebases) + docs
  |
  +-- Breaking changes/migration? --> GitHub releases + changelog + Google
```

### Platform Strengths

| Platform | Best For | Limitations |
|----------|----------|-------------|
| **Google** | General search, blog posts, tutorials, docs | Noisy, SEO spam, outdated results |
| **GitHub** | Source code, releases, stars, issues, real usage | Popularity != quality |
| **PyPI** | Python packages, versions, dependencies | No quality signal beyond downloads |
| **npm** | JS/TS packages, versions, dependencies | Same as PyPI |
| **HuggingFace** | Models, datasets, spaces, benchmarks | AI/ML specific |
| **arXiv** | Research papers, cutting-edge techniques | Academic, may not be practical |
| **Papers with Code** | SOTA benchmarks, leaderboards | Academic focus |
| **Stack Overflow** | Common problems, workarounds | Answers may be outdated |
| **Official docs** | Official API reference, guides | May lag behind releases |

**References:** [references/platforms/](references/platforms/)

---

## 2. Advanced Search Operators

### Google

```
# Exact match
"pydantic v2 migration guide"

# Site-specific
site:docs.anthropic.com tool use
site:github.com qdrant client python

# Date filter
"fastapi middleware" after:2025-01-01

# Exclude results
qdrant python -javascript -typescript

# File type
filetype:pdf "system design" "microservices"

# OR operator
(fastapi OR django) "rate limiting" 2025

# In title
intitle:"migration guide" pydantic v2

# In URL
inurl:changelog qdrant
```

### GitHub

```
# Search code
language:python "from anthropic import" stars:>100

# Search repos
topic:rag language:python stars:>500 pushed:>2025-01-01

# Search issues/PRs
repo:pydantic/pydantic is:issue is:open label:bug "v2"

# Filename search
filename:pyproject.toml "pydantic>=2"

# Exclude forks
fork:false stars:>100 "semantic cache"

# Recently updated
pushed:>2025-06-01 topic:vector-database language:python
```

### HuggingFace

```
# Model search with filters
https://huggingface.co/models?search=<query>&sort=trending

# Filter by task
https://huggingface.co/models?pipeline_tag=text-generation&sort=trending

# Filter by library
https://huggingface.co/models?library=transformers&sort=downloads
```

### arXiv

```
# Search by title
ti:"retrieval augmented generation"

# Search by abstract
abs:"chain of thought" AND abs:"reasoning"

# Category filter
cat:cs.CL  (Computation and Language)
cat:cs.AI  (Artificial Intelligence)
cat:cs.LG  (Machine Learning)

# Date filter
submittedDate:[2025-01-01 TO 2025-12-31]

# Combined
ti:"RAG" AND cat:cs.CL AND submittedDate:[2025-01-01 TO *]
```

---

## 3. Source Taxonomy by Domain

### Libraries and Frameworks

| Priority | Source | What to Check |
|----------|--------|---------------|
| 1 | **Official docs** | API reference, migration guides, changelog |
| 2 | **GitHub releases** | Release notes, breaking changes, version history |
| 3 | **PyPI/npm** | Download trends, last release date, dependencies |
| 4 | **GitHub issues** | Known bugs, common issues, maintainer responsiveness |
| 5 | **Blog posts** | Tutorials, comparisons, real-world usage |
| 6 | **Stack Overflow** | Common errors, workarounds |

**Red flags:**
- Last release > 12 months ago
- Declining download trends
- Many open issues without maintainer responses
- No type stubs (Python) or no @types (TypeScript)

### AI/ML Models and Techniques

| Priority | Source | What to Check |
|----------|--------|---------------|
| 1 | **Papers with Code** | SOTA benchmarks, leaderboards |
| 2 | **HuggingFace** | Model cards, benchmarks, community usage |
| 3 | **arXiv** | Original paper, methodology, limitations |
| 4 | **Official blogs** | Announcements from Anthropic, OpenAI, Google |
| 5 | **GitHub** | Reference implementations, community reproductions |

**Red flags:**
- No independent reproduction
- Benchmarks only on cherry-picked datasets
- No open weights or API access
- Paper without code

### Infrastructure and DevOps

| Priority | Source | What to Check |
|----------|--------|---------------|
| 1 | **Official docs** | Installation, configuration, operation |
| 2 | **GitHub** | Stars, issues, release cadence |
| 3 | **CNCF landscape** | Maturity level, adoption |
| 4 | **Vendor comparisons** | Read with bias awareness |
| 5 | **Production postmortems** | Real failure modes |

**Red flags:**
- No production reference customers
- Single-maintainer project for critical infrastructure
- No disaster recovery documentation
- Vendor lock-in with no exit strategy

### Security

| Priority | Source | What to Check |
|----------|--------|---------------|
| 1 | **NVD (nvd.nist.gov)** | CVE database, severity scores |
| 2 | **GitHub Security Advisories** | Per-repository advisories |
| 3 | **OWASP** | Top 10, cheat sheets, testing guide |
| 4 | **Snyk/Sonatype** | Dependency vulnerability databases |
| 5 | **Vendor security bulletins** | Provider-specific advisories |

---

## 4. Validation Protocol

All researched information must pass validation before being presented as fact.

### The 4-Check Protocol

```
For every claim or recommendation:

1. SOURCE COUNT
   - Minimum 2 independent sources for factual claims
   - Minimum 3 sources for technology recommendations
   - "Independent" = different authors/organizations

2. DATE CHECK
   - Source published within last 12 months? -> strong signal
   - Source published 12-24 months ago? -> verify still current
   - Source published > 24 months ago? -> treat as potentially outdated
   - ALWAYS check: has a newer version been released since the source?

3. BIAS DETECTION
   - Is the source a vendor recommending their own product? -> flag bias
   - Is the author affiliated with a competing product? -> flag bias
   - Is the benchmark run by the tool's own team? -> flag bias
   - Are negative aspects discussed? -> more credible if yes

4. CROSS-REFERENCE
   - Do multiple independent sources agree? -> strong signal
   - Do sources contradict each other? -> investigate why
   - Is there a clear consensus? -> note the consensus
   - Is there active debate? -> present both sides
```

### Confidence Levels

After validation, assign a confidence level to each claim:

| Level | Criteria | Label |
|-------|----------|-------|
| **High** | 3+ independent recent sources agree, no contradictions | Present as fact |
| **Medium** | 2 sources agree, or recent but limited sources | "Based on available evidence..." |
| **Low** | Single source, or dated sources, or contradictions | Mark as [Unverified] |
| **None** | No sources found, or all sources outdated | "Cannot verify. Based on training data which may be outdated." |

### When Sources Conflict

```
1. Note the conflict explicitly
2. Check which source is more recent
3. Check which source has more credibility (official docs > blog post)
4. Check if the conflict is due to version differences
5. Present both sides with dates and sources
6. Recommend the user verify with their specific version/setup
```

---

## 5. Synthesis Templates

### Comparison Table Template

```markdown
## Comparison: {Topic}

**Context:** {What problem are we solving? What constraints exist?}
**Date researched:** {YYYY-MM-DD}
**Sources consulted:** {N sources}

| Criterion | {Option A} | {Option B} | {Option C} |
|-----------|------------|------------|------------|
| **Maturity** | {description} | {description} | {description} |
| **Performance** | {metrics} | {metrics} | {metrics} |
| **Ecosystem** | {integrations} | {integrations} | {integrations} |
| **Learning curve** | {assessment} | {assessment} | {assessment} |
| **Maintenance** | {release cadence, community} | ... | ... |
| **Cost** | {pricing model} | {pricing model} | {pricing model} |
| **Lock-in risk** | {low/medium/high + why} | ... | ... |
| **Our constraints** | {fit assessment} | {fit assessment} | {fit assessment} |

### Recommendation

**Choice:** {Option X}
**Confidence:** {High/Medium/Low}
**Reasoning:** {2-3 sentences explaining the decision}
**Trade-offs accepted:** {what we give up by choosing this}
**Revisit when:** {conditions that should trigger re-evaluation}

### Sources
1. {source with URL and date}
2. {source with URL and date}
```

### Single Recommendation Format

```markdown
## Recommendation: {Topic}

**Problem:** {What we need to solve}
**Recommendation:** {Tool/approach}
**Version:** {Exact version}
**Confidence:** {High/Medium/Low}

**Why this:**
- {Reason 1 with source}
- {Reason 2 with source}

**Why not {alternative 1}:**
- {Reason with source}

**Risks:**
- {Risk 1 + mitigation}

**Sources:**
1. {source}
2. {source}
```

### Research Log Format

```markdown
## Research Log: {Topic}

**Question:** {What are we trying to answer?}
**Started:** {timestamp}
**Completed:** {timestamp}

### Search queries used
1. `{query}` on {platform} -> {N results reviewed}

### Sources reviewed
| # | Source | Date | Relevance | Key finding |
|---|--------|------|-----------|-------------|
| 1 | {URL} | {date} | {high/med/low} | {one-liner} |

### Key findings
1. {Finding 1}

### Contradictions found
- {Source A} says X, but {Source B} says Y. Resolution: {explanation}

### Conclusion
{Final answer with confidence level}
```

---

## 6. Debate Frameworks

### Trade-off Analysis

```markdown
## Trade-off Analysis: {Decision}

### Option A: {Name}
**Pros:**
- {Pro 1} -- weight: {high/medium/low}
**Cons:**
- {Con 1} -- weight: {high/medium/low}
**Best when:** {conditions where this is the right choice}
**Worst when:** {conditions where this fails}

### Decision Matrix
| Criterion | Weight | Option A | Option B |
|-----------|--------|----------|----------|
| {criterion 1} | {1-5} | {1-5} | {1-5} |
| **Weighted total** | -- | {sum} | {sum} |

### Verdict
{Which option and why, acknowledging what we give up}
```

### Devil's Advocate Protocol

```
1. State the preferred option clearly
2. Steel-man the OPPOSING option (make the strongest case against your preference)
3. Identify the #1 reason the preferred option could FAIL
4. Identify the #1 reason the opposing option could SUCCEED
5. Check: did we dismiss the alternative too quickly?
6. Final decision with honest acknowledgment of risks
```

### Reversibility Check

```
1. Easily reversible (days)   -> Decide quickly
2. Moderately reversible (weeks) -> Research adequately, document
3. Hard to reverse (months)    -> Research thoroughly, prototype
4. Irreversible (public API, data format, lock-in) -> Maximum research
```

---

## 7. Dependency Security Protocol

Run BEFORE installing any dependency.

### Steps

1. **Find latest stable version** — search PyPI/npm/Cargo, never use training data version
2. **Check security** — NVD, GitHub Advisories, Snyk
3. **Verify maintained** — last release <12 months, active issues, recent commits
4. **Audit after install**

```bash
pip-audit          # Python
npm audit          # Node.js
cargo audit        # Rust
```

### Red Flags (do not install)
- No release in >12 months
- Known CVEs without available patch
- Single maintainer who stopped contributing
- Download count <1K/week (PyPI) or <100/week (npm)
- Incompatible license

---

## 8. Anti-Patterns

| Anti-Pattern | Wrong | Right |
|-------------|-------|-------|
| Training data reliance | "Based on my knowledge, X is best" | Search first, then recommend |
| Single source | "This blog says X is better" | Cross-reference 3+ sources |
| Ignoring dates | "Tutorial says use X v2.0" | Check current version first |
| Popularity bias | "50k stars = best choice" | Stars measure popularity, not fitness |
| Vendor as neutral | "AWS says Bedrock is best" | Vendor recommends own product — flag bias |
| Premature closure | Found one option → recommend | Find alternatives → compare → recommend |
| Hiding negatives | "X is great because [pros only]" | Acknowledge trade-offs explicitly |

---

## 9. When to Stop Researching

### Time Budgets

| Impact | Max time | Sources needed |
|--------|----------|----------------|
| Trivial | 5 min | 1 |
| Low | 15 min | 2 |
| Medium | 30 min | 3 |
| High | 1 hour | 4+ |
| Critical | 2+ hours | 5+ |

### Stop When
- 3+ independent sources agree
- One option dominates on all important criteria
- Last 3 sources added no new information
- Time budget exceeded
- Decision is easily reversible

---

## Reference Files

- [references/platforms/](references/platforms/) — Platform-specific guides (Google, GitHub, PyPI/npm, HuggingFace, arXiv)
- [references/methodology/validation-protocol.md](references/methodology/validation-protocol.md)
- [references/methodology/synthesis-templates.md](references/methodology/synthesis-templates.md)
- [references/methodology/debate-frameworks.md](references/methodology/debate-frameworks.md)
- [references/security/vulnerability-sources.md](references/security/vulnerability-sources.md)
