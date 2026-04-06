---
name: research
description: |
  Metodologia de pesquisa técnica estruturada para decisões de engineering. Cobre estratégias de busca
  por plataforma (Google, GitHub, HuggingFace, PyPI, npm, arXiv, Papers with Code), operadores avançados,
  taxonomia de fontes por domínio, protocolo de validação multi-fonte, síntese com templates de comparação,
  frameworks de debate/trade-off, e anti-patterns comuns. Use quando: (1) Escolher tecnologias/libs/frameworks,
  (2) Comparar alternativas, (3) Avaliar estado da arte, (4) Fundamentar decisões arquiteturais,
  (5) Investigar vulnerabilidades ou breaking changes.
  Triggers: /research, pesquisar, comparar opções, estado da arte, avaliar alternativas.
globs:
  - "**/*"
---

# Research — Metodologia de Pesquisa Técnica

## Propósito

Esta skill é a **knowledge base** for structured technical research.
It provides methodology, not opinions. Every recommendation an agent makes
should be grounded in current, verified, multi-source research.

**Who uses this skill:**
- Any agent that needs to make a technology choice

- Agent `dev-py` / `dev-ts` for library selection

- Oracle for ecosystem decisions

**What this skill contains:**
- Search strategies per platform
- Advanced search operators
- Source taxonomy by domain
- Validation protocol (multi-source, date check, bias detection)
- Synthesis templates (comparison tables, recommendation format)
- Debate frameworks (trade-off analysis, decision matrices)
- Anti-patterns to avoid
- When to stop researching

**What this skill does NOT contain:**
- Domain-specific knowledge (that lives in arch-py, ai-engineer, etc.)
- Execution workflow (agents own that)

---

## 1. Estratégias de Busca por Plataforma

Each platform has different strengths. Use the right platform for the right question.

### Árvore de Decisão

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

### Pontos Fortes por Plataforma

| Platform | Best for | Limitations |
|----------|----------|-------------|
| **Google** | General queries, blog posts, tutorials, docs | Noisy, SEO spam, outdated results |
| **GitHub** | Source code, releases, stars, issues, real usage | Popularity != quality |
| **PyPI** | Python packages, versions, dependencies | No quality signal beyond downloads |
| **npm** | JS/TS packages, versions, dependencies | Same as PyPI |
| **HuggingFace** | Models, datasets, spaces, benchmarks | AI/ML specific |
| **arXiv** | Research papers, cutting-edge techniques | Academic, may not be practical |
| **Papers with Code** | SOTA benchmarks, paper+code links | Academic focus |
| **Stack Overflow** | Common problems, workarounds | Answers may be outdated |
| **Vendor docs** | Official API reference, guides | May lag behind releases |

**Reference:** [references/platforms/google.md](references/platforms/google.md)
**Reference:** [references/platforms/github.md](references/platforms/github.md)
**Reference:** [references/platforms/pypi-npm.md](references/platforms/pypi-npm.md)
**Reference:** [references/platforms/huggingface.md](references/platforms/huggingface.md)
**Reference:** [references/platforms/arxiv.md](references/platforms/arxiv.md)
**Reference:** [references/platforms/infrastructure.md](references/platforms/infrastructure.md)

---

## 2. Operadores Avançados de Busca

### Google

```
# Exact match
"pydantic v2 migration guide"

# Site-specific
site:docs.anthropic.com tool use
site:github.com qdrant client python

# Date filter (via Tools > Any time > Custom range)
# Or append to query:
"fastapi middleware" after:2025-01-01

# Exclude results
qdrant python -javascript -typescript

# File type
filetype:pdf "system design" "microservices"

# OR operator
(fastapi OR django) "rate limiting" 2025

# Wildcard
"how to * with pydantic v2"

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

# Path search
path:src/api language:python "rate_limit"

# Org search
org:langchain-ai "qdrant" language:python

# Exclude forks
fork:false stars:>100 "semantic cache"

# Recently updated
pushed:>2025-06-01 topic:vector-database language:python
```

### PyPI / npm

```
# PyPI: check package info
pip index versions <package>
pip show <package>

# PyPI web: https://pypi.org/project/<package>/
# Check: last release date, download stats, Python version support

# npm: check package info
npm view <package> versions
npm view <package> time

# npm web: https://www.npmjs.com/package/<package>
# Check: weekly downloads, last publish, dependencies
```

### HuggingFace

```
# Model search
https://huggingface.co/models?search=<query>&sort=trending

# Filter by task
https://huggingface.co/models?pipeline_tag=text-generation&sort=trending

# Filter by library
https://huggingface.co/models?library=transformers&sort=downloads

# Datasets
https://huggingface.co/datasets?search=<query>&sort=trending
```

### arXiv

```
# Search by title
ti:"retrieval augmented generation"

# Search by abstract
abs:"chain of thought" AND abs:"reasoning"

# Search by author
au:"Touvron"

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

## 3. Taxonomia de Fontes por Domínio

Different domains require different source strategies.

### Bibliotecas e Frameworks

| Priority | Source | What to check |
|----------|--------|---------------|
| 1 | **Official docs** | API reference, migration guides, changelog |
| 2 | **GitHub releases** | Release notes, breaking changes, version history |
| 3 | **PyPI/npm** | Download trends, last release date, dependencies |
| 4 | **GitHub issues** | Known bugs, common problems, maintainer responsiveness |
| 5 | **Blog posts** | Tutorials, comparisons, real-world usage |
| 6 | **Stack Overflow** | Common errors, workarounds |

**Red flags:**
- Last release > 12 months ago
- Declining download trend
- Many open issues with no maintainer response
- No type stubs (Python) or no @types (TypeScript)

### Modelos e Técnicas de AI/ML

| Priority | Source | What to check |
|----------|--------|---------------|
| 1 | **Papers with Code** | SOTA benchmarks, leaderboards |
| 2 | **HuggingFace** | Model cards, benchmarks, community usage |
| 3 | **arXiv** | Original paper, methodology, limitations |
| 4 | **Official blogs** | Anthropic, OpenAI, Google announcements |
| 5 | **GitHub** | Reference implementations, community reproductions |
| 6 | **Benchmarks** | MMLU, HumanEval, MTEB, etc. |

**Red flags:**
- No reproduction by independent teams
- Benchmarks only on cherry-picked datasets
- No open weights or API access
- Paper without code

### Infraestrutura e DevOps

| Priority | Source | What to check |
|----------|--------|---------------|
| 1 | **Official docs** | Installation, configuration, operations |
| 2 | **GitHub** | Stars, issues, release cadence |
| 3 | **CNCF landscape** | Maturity level, adoption |
| 4 | **Vendor comparisons** | (read with bias awareness) |
| 5 | **Production postmortems** | Real failure modes |
| 6 | **Benchmarks** | Performance under load |

**Red flags:**
- No production usage references
- Single-maintainer project for critical infra
- No disaster recovery documentation
- Vendor lock-in without exit strategy

### Security

| Priority | Source | What to check |
|----------|--------|---------------|
| 1 | **NVD (nvd.nist.gov)** | CVE database, severity scores |
| 2 | **GitHub Security Advisories** | Per-repo advisories |
| 3 | **OWASP** | Top 10, cheat sheets, testing guide |
| 4 | **Snyk/Sonatype** | Dependency vulnerability databases |
| 5 | **Vendor security bulletins** | Provider-specific advisories |

**Reference:** [references/security/vulnerability-sources.md](references/security/vulnerability-sources.md)

---

## 4. Protocolo de Validação

Every piece of research must pass validation before being presented as fact.

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
| **Medium** | 2 sources agree, or sources are recent but limited | "Based on available evidence..." |
| **Low** | Single source, or sources are dated, or contradictions exist | "[Unverified]" label required |
| **None** | No sources found, or all sources are outdated | "Cannot verify. Based on training data which may be outdated." |

### What to do when sources conflict

```
1. Note the conflict explicitly
2. Check which source is more recent
3. Check which source has more credibility (official docs > blog post)
4. Check if the conflict is due to version differences
5. Present both sides with dates and sources
6. Recommend the user verify with their specific version/setup
```

**Reference:** [references/methodology/validation-protocol.md](references/methodology/validation-protocol.md)

---

## 5. Síntese -- Templates and Formats

### Tabela de Comparação Template

Use this format when comparing 2+ alternatives:

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
3. ...
```

### Single Recommendation Format

Use when a single recommendation is needed:

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

**Why not {alternative 2}:**
- {Reason with source}

**Risks:**
- {Risk 1 + mitigation}
- {Risk 2 + mitigation}

**Sources:**
1. {source}
2. {source}
```

### Research Log Format

Use to document the research process itself:

```markdown
## Research Log: {Topic}

**Question:** {What are we trying to answer?}
**Started:** {timestamp}
**Completed:** {timestamp}

### Search queries used
1. `{query}` on {platform} -> {N results reviewed}
2. `{query}` on {platform} -> {N results reviewed}

### Sources reviewed
| # | Source | Date | Relevance | Key finding |
|---|--------|------|-----------|-------------|
| 1 | {URL} | {date} | {high/med/low} | {one-liner} |
| 2 | ... | ... | ... | ... |

### Key findings
1. {Finding 1}
2. {Finding 2}

### Contradictions found
- {Source A} says X, but {Source B} says Y. Resolution: {explanation}

### Conclusion
{Final answer with confidence level}
```

**Reference:** [references/methodology/synthesis-templates.md](references/methodology/synthesis-templates.md)

---

## 6. Debate Frameworks

Use these when multiple valid approaches exist and a decision must be made.

### Trade-off Analysis

```markdown
## Trade-off Analysis: {Decision}

### Option A: {Name}

**Pros:**
- {Pro 1} -- weight: {high/medium/low}
- {Pro 2} -- weight: {high/medium/low}

**Cons:**
- {Con 1} -- weight: {high/medium/low}
- {Con 2} -- weight: {high/medium/low}

**Best when:** {conditions where this is the right choice}
**Worst when:** {conditions where this fails}

### Option B: {Name}

**Pros:** ...
**Cons:** ...
**Best when:** ...
**Worst when:** ...

### Matriz de Decisão

| Criterion | Weight | Option A | Option B |
|-----------|--------|----------|----------|
| {criterion 1} | {1-5} | {1-5} | {1-5} |
| {criterion 2} | {1-5} | {1-5} | {1-5} |
| {criterion 3} | {1-5} | {1-5} | {1-5} |
| **Weighted total** | -- | {sum} | {sum} |

### Verdict
{Which option and why, acknowledging what we give up}
```

### Protocolo do Advogado do Diabo

When evaluating a strong preference or popular choice:

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
Before committing to a decision:

1. Is this decision easily reversible? (days to change)
   -> Decide quickly, optimize for speed

2. Is this decision moderately reversible? (weeks to change)
   -> Research adequately, document the reasoning

3. Is this decision hard to reverse? (months to change, or data migration)
   -> Research thoroughly, get multiple opinions, prototype first

4. Is this decision irreversible? (public API, data format, vendor lock-in)
   -> Maximum research, prototype, get stakeholder buy-in
```

**Reference:** [references/methodology/debate-frameworks.md](references/methodology/debate-frameworks.md)

---

## 7. Anti-Patterns

### 1. Training Data Trust

```
WRONG: "Based on my knowledge, X is the best option for Y."
RIGHT: "Let me search for the current state of X." [performs web search]

WHY: Training data has a cutoff. Libraries release new versions,
     benchmarks change, new tools emerge. NEVER trust training data
     for technology recommendations.
```

### 2. Single Source

```
WRONG: "According to this blog post, X is better than Y."
RIGHT: "Multiple sources confirm X outperforms Y: [source1], [source2], [source3]."

WHY: A single source may be biased, outdated, or wrong.
     Cross-reference is mandatory.
```

### 3. Ignoring Dates

```
WRONG: "This tutorial says to use library X version 2.0."
RIGHT: "This tutorial from 2023 recommends X v2.0, but the current
        stable version is 4.1. Let me check the migration guide."

WHY: Software moves fast. A 6-month-old recommendation may already
     be outdated if a major version was released.
```

### 4. Popularity Bias

```
WRONG: "X has 50k GitHub stars, so it's the best choice."
RIGHT: "X has 50k stars (popularity), but Y has better benchmarks
        for our specific use case and is actively maintained."

WHY: Stars measure popularity, not fitness for purpose.
     A smaller, focused tool may be better than a popular general one.
```

### 5. Vendor Docs as Neutral Source

```
WRONG: "According to AWS, Bedrock is the best choice for LLM hosting."
RIGHT: "AWS recommends Bedrock (expected vendor position). Let me
        compare with independent benchmarks and user reports."

WHY: Vendors always recommend their own products.
     Independent sources are required for unbiased evaluation.
```

### 6. Premature Closure

```
WRONG: Found one good option -> recommend it immediately
RIGHT: Found one good option -> search for alternatives ->
       compare -> THEN recommend

WHY: The first good option found is rarely the best option.
     Always compare at least 2-3 alternatives.
```

### 7. Ignoring Negative Evidence

```
WRONG: "X is great because [pros only]."
RIGHT: "X is strong in [pros], but has known issues with [cons].
        For our use case, the pros outweigh the cons because [reasoning]."

WHY: Every technology has trade-offs. Hiding negatives leads to
     surprises later. Acknowledge trade-offs explicitly.
```

### 8. Research Rabbit Hole

```
WRONG: Spending 2 hours researching which JSON library to use
RIGHT: Apply the reversibility check. If easily reversible,
       pick the most popular one and move on.

WHY: Research depth should match decision impact.
     See "When to Stop Researching" below.
```

---

## 8. Quando Parar Researching

Research without bounds is waste. Apply these stopping rules:

### Time Budgets by Decision Impact

| Impact | Max research time | Sources needed | Examples |
|--------|-------------------|----------------|----------|
| **Trivial** | 5 minutes | 1 (official docs) | Utility function, formatting lib |
| **Low** | 15 minutes | 2 | Testing helper, dev tool |
| **Medium** | 30 minutes | 3 | API framework, database driver |
| **High** | 1 hour | 4+ | Core architecture, main database |
| **Critical** | 2+ hours | 5+ | Cloud provider, data format, public API |

### Stopping Criteria

```
STOP researching when ANY of these is true:

1. CONSENSUS: 3+ independent sources agree on the same recommendation
2. CLEAR WINNER: One option dominates on all important criteria
3. DIMINISHING RETURNS: Last 3 sources added no new information
4. TIME BUDGET EXCEEDED: You have hit the time budget for this decision impact level
5. REVERSIBLE: The decision is easily reversible -- pick and move on

CONTINUE researching when ALL of these are true:
1. Sources contradict each other on important criteria
2. You have not found enough independent sources
3. The decision is hard to reverse
4. Time budget not yet exceeded
```

### The "Good Enough" Principle

```
For most decisions, you need a GOOD choice, not the PERFECT choice.

Perfect is the enemy of done. If you have 2-3 viable options and
a clear comparison, make the decision. Document the reasoning and
the "revisit when" conditions so the team can re-evaluate later.

Exception: Irreversible decisions (public APIs, data formats,
vendor lock-in) deserve maximum research.
```

---

## Reference Files

### Platform-Specific Guides
- [references/platforms/google.md](references/platforms/google.md) - Google search operators, filtering, date tricks
- [references/platforms/github.md](references/platforms/github.md) - GitHub code/repo/issue search, quality signals
- [references/platforms/pypi-npm.md](references/platforms/pypi-npm.md) - Package registry evaluation, version checking
- [references/platforms/huggingface.md](references/platforms/huggingface.md) - Model/dataset search, benchmark interpretation
- [references/platforms/arxiv.md](references/platforms/arxiv.md) - Paper search, category codes, citation analysis
- [references/platforms/infrastructure.md](references/platforms/infrastructure.md) - CNCF landscape, vendor evaluation

### Methodology
- [references/methodology/validation-protocol.md](references/methodology/validation-protocol.md) - 4-check protocol, confidence levels
- [references/methodology/synthesis-templates.md](references/methodology/synthesis-templates.md) - Comparison, recommendation, research log templates
- [references/methodology/debate-frameworks.md](references/methodology/debate-frameworks.md) - Trade-off analysis, devil's advocate, decision matrix

### Security
- [references/security/vulnerability-sources.md](references/security/vulnerability-sources.md) - NVD, GitHub Advisories, OWASP, Snyk
