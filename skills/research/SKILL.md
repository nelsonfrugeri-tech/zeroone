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

# Skill de Pesquisa - Metodologia de Pesquisa Técnica

## Propósito

Esta skill é a **base de conhecimento** para pesquisa técnica estruturada.
Ela fornece metodologia, não opiniões. Toda recomendação que um agent fizer
deve ser fundamentada em pesquisa atual, verificada e multi-fonte.

**Quem usa esta skill:**
- Qualquer agent que precise fazer uma escolha de tecnologia
- Oracle para decisões de ecossistema

**O que esta skill contém:**
- Estratégias de busca por plataforma
- Operadores avançados de busca
- Taxonomia de fontes por domínio
- Protocolo de validação (multi-fonte, verificação de data, detecção de viés)
- Templates de síntese (tabelas de comparação, formato de recomendação)
- Frameworks de debate (análise de trade-off, decision matrices)
- Anti-patterns a evitar
- Quando parar de pesquisar

**O que esta skill NÃO contém:**
- Conhecimento de domínio específico (isso vive em arch-py, ai-engineer, etc.)
- Workflow de execução (agents são donos disso)

---

## 1. Estratégias de Busca por Plataforma

Cada plataforma tem forças diferentes. Use a plataforma certa para a pergunta certa.

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

### Forças por Plataforma

| Plataforma | Melhor para | Limitações |
|------------|-------------|------------|
| **Google** | Buscas gerais, blog posts, tutoriais, docs | Ruidoso, SEO spam, resultados desatualizados |
| **GitHub** | Código fonte, releases, stars, issues, uso real | Popularidade != qualidade |
| **PyPI** | Pacotes Python, versões, dependências | Sem sinal de qualidade além de downloads |
| **npm** | Pacotes JS/TS, versões, dependências | Mesmo que PyPI |
| **HuggingFace** | Modelos, datasets, spaces, benchmarks | Específico para AI/ML |
| **arXiv** | Papers de pesquisa, técnicas de ponta | Acadêmico, pode não ser prático |
| **Papers with Code** | Benchmarks SOTA, links paper+código | Foco acadêmico |
| **Stack Overflow** | Problemas comuns, workarounds | Respostas podem estar desatualizadas |
| **Docs oficiais** | Referência de API oficial, guias | Pode ficar atrás das releases |

**Referência:** [references/platforms/google.md](references/platforms/google.md)
**Referência:** [references/platforms/github.md](references/platforms/github.md)
**Referência:** [references/platforms/pypi-npm.md](references/platforms/pypi-npm.md)
**Referência:** [references/platforms/huggingface.md](references/platforms/huggingface.md)
**Referência:** [references/platforms/arxiv.md](references/platforms/arxiv.md)
**Referência:** [references/platforms/infrastructure.md](references/platforms/infrastructure.md)

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

Domínios diferentes exigem estratégias de fontes diferentes.

### Bibliotecas e Frameworks

| Prioridade | Fonte | O que verificar |
|------------|-------|-----------------|
| 1 | **Docs oficiais** | Referência de API, guias de migração, changelog |
| 2 | **GitHub releases** | Notas de release, breaking changes, histórico de versões |
| 3 | **PyPI/npm** | Tendências de download, data da última release, dependências |
| 4 | **GitHub issues** | Bugs conhecidos, problemas comuns, responsividade dos maintainers |
| 5 | **Blog posts** | Tutoriais, comparações, uso no mundo real |
| 6 | **Stack Overflow** | Erros comuns, workarounds |

**Red flags:**
- Última release > 12 meses atrás
- Tendência de downloads em declínio
- Muitas issues abertas sem resposta dos maintainers
- Sem type stubs (Python) ou sem @types (TypeScript)

### Modelos e Técnicas de AI/ML

| Prioridade | Fonte | O que verificar |
|------------|-------|-----------------|
| 1 | **Papers with Code** | Benchmarks SOTA, leaderboards |
| 2 | **HuggingFace** | Model cards, benchmarks, uso pela comunidade |
| 3 | **arXiv** | Paper original, metodologia, limitações |
| 4 | **Blogs oficiais** | Anúncios da Anthropic, OpenAI, Google |
| 5 | **GitHub** | Implementações de referência, reproduções da comunidade |
| 6 | **Benchmarks** | MMLU, HumanEval, MTEB, etc. |

**Red flags:**
- Sem reprodução por times independentes
- Benchmarks apenas em datasets selecionados a dedo
- Sem pesos abertos ou acesso via API
- Paper sem código

### Infraestrutura e DevOps

| Prioridade | Fonte | O que verificar |
|------------|-------|-----------------|
| 1 | **Docs oficiais** | Instalação, configuração, operação |
| 2 | **GitHub** | Stars, issues, cadência de releases |
| 3 | **CNCF landscape** | Nível de maturidade, adoção |
| 4 | **Comparações de vendors** | (ler com consciência de viés) |
| 5 | **Postmortems de produção** | Modos reais de falha |
| 6 | **Benchmarks** | Performance sob carga |

**Red flags:**
- Sem referências de uso em produção
- Projeto com único maintainer para infra crítica
- Sem documentação de disaster recovery
- Vendor lock-in sem estratégia de saída

### Segurança

| Prioridade | Fonte | O que verificar |
|------------|-------|-----------------|
| 1 | **NVD (nvd.nist.gov)** | Base de dados de CVE, scores de severidade |
| 2 | **GitHub Security Advisories** | Advisories por repositório |
| 3 | **OWASP** | Top 10, cheat sheets, guia de testes |
| 4 | **Snyk/Sonatype** | Bases de dados de vulnerabilidades de dependências |
| 5 | **Boletins de segurança de vendors** | Advisories específicos do provedor |

**Referência:** [references/security/vulnerability-sources.md](references/security/vulnerability-sources.md)

---

## 4. Protocolo de Validação

Toda informação pesquisada deve passar por validação antes de ser apresentada como fato.

### O Protocolo de 4 Verificações

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

### Níveis de Confiança

Após validação, atribua um nível de confiança a cada afirmação:

| Nível | Critérios | Rótulo |
|-------|-----------|--------|
| **Alto** | 3+ fontes independentes recentes concordam, sem contradições | Apresentar como fato |
| **Médio** | 2 fontes concordam, ou fontes são recentes mas limitadas | "Com base nas evidências disponíveis..." |
| **Baixo** | Fonte única, ou fontes datadas, ou existem contradições | Rótulo "[Unverified]" obrigatório |
| **Nenhum** | Nenhuma fonte encontrada, ou todas as fontes estão desatualizadas | "Cannot verify. Based on training data which may be outdated." |

### O que fazer quando fontes conflitam

```
1. Note the conflict explicitly
2. Check which source is more recent
3. Check which source has more credibility (official docs > blog post)
4. Check if the conflict is due to version differences
5. Present both sides with dates and sources
6. Recommend the user verify with their specific version/setup
```

**Referência:** [references/methodology/validation-protocol.md](references/methodology/validation-protocol.md)

---

## 5. Síntese -- Templates e Formatos

### Template de Tabela de Comparação

Use este formato quando comparar 2+ alternativas:

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

### Formato de Recomendação Única

Use quando uma única recomendação é necessária:

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

### Formato de Log de Pesquisa

Use para documentar o processo de pesquisa em si:

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

**Referência:** [references/methodology/synthesis-templates.md](references/methodology/synthesis-templates.md)

---

## 6. Frameworks de Debate

Use quando múltiplas abordagens válidas existem e uma decisão precisa ser tomada.

### Análise de Trade-off

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

### Decision Matrix

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

Ao avaliar uma preferência forte ou escolha popular:

```
1. State the preferred option clearly
2. Steel-man the OPPOSING option (make the strongest case against your preference)
3. Identify the #1 reason the preferred option could FAIL
4. Identify the #1 reason the opposing option could SUCCEED
5. Check: did we dismiss the alternative too quickly?
6. Final decision with honest acknowledgment of risks
```

### Verificação de Reversibilidade

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

**Referência:** [references/methodology/debate-frameworks.md](references/methodology/debate-frameworks.md)

---

## 7. Anti-Patterns

### 1. Confiança em Dados de Treinamento

```
WRONG: "Based on my knowledge, X is the best option for Y."
RIGHT: "Let me search for the current state of X." [performs web search]

WHY: Training data has a cutoff. Libraries release new versions,
     benchmarks change, new tools emerge. NEVER trust training data
     for technology recommendations.
```

### 2. Fonte Única

```
WRONG: "According to this blog post, X is better than Y."
RIGHT: "Multiple sources confirm X outperforms Y: [source1], [source2], [source3]."

WHY: A single source may be biased, outdated, or wrong.
     Cross-reference is mandatory.
```

### 3. Ignorar Datas

```
WRONG: "This tutorial says to use library X version 2.0."
RIGHT: "This tutorial from 2023 recommends X v2.0, but the current
        stable version is 4.1. Let me check the migration guide."

WHY: Software moves fast. A 6-month-old recommendation may already
     be outdated if a major version was released.
```

### 4. Viés de Popularidade

```
WRONG: "X has 50k GitHub stars, so it's the best choice."
RIGHT: "X has 50k stars (popularity), but Y has better benchmarks
        for our specific use case and is actively maintained."

WHY: Stars measure popularity, not fitness for purpose.
     A smaller, focused tool may be better than a popular general one.
```

### 5. Docs de Vendor como Fonte Neutra

```
WRONG: "According to AWS, Bedrock is the best choice for LLM hosting."
RIGHT: "AWS recommends Bedrock (expected vendor position). Let me
        compare with independent benchmarks and user reports."

WHY: Vendors always recommend their own products.
     Independent sources are required for unbiased evaluation.
```

### 6. Encerramento Prematuro

```
WRONG: Found one good option -> recommend it immediately
RIGHT: Found one good option -> search for alternatives ->
       compare -> THEN recommend

WHY: The first good option found is rarely the best option.
     Always compare at least 2-3 alternatives.
```

### 7. Ignorar Evidências Negativas

```
WRONG: "X is great because [pros only]."
RIGHT: "X is strong in [pros], but has known issues with [cons].
        For our use case, the pros outweigh the cons because [reasoning]."

WHY: Every technology has trade-offs. Hiding negatives leads to
     surprises later. Acknowledge trade-offs explicitly.
```

### 8. Buraco de Coelho da Pesquisa

```
WRONG: Spending 2 hours researching which JSON library to use
RIGHT: Apply the reversibility check. If easily reversible,
       pick the most popular one and move on.

WHY: Research depth should match decision impact.
     See "When to Stop Researching" below.
```

---

## 8. Quando Parar de Pesquisar

Pesquisa sem limites é desperdício. Aplique estas regras de parada:

### Orçamentos de Tempo por Impacto da Decisão

| Impacto | Tempo máximo de pesquisa | Fontes necessárias | Exemplos |
|---------|--------------------------|---------------------|----------|
| **Trivial** | 5 minutos | 1 (docs oficiais) | Função utilitária, lib de formatação |
| **Baixo** | 15 minutos | 2 | Helper de testes, ferramenta de dev |
| **Médio** | 30 minutos | 3 | Framework de API, driver de banco |
| **Alto** | 1 hora | 4+ | Arquitetura core, banco de dados principal |
| **Crítico** | 2+ horas | 5+ | Provedor de cloud, formato de dados, API pública |

### Critérios de Parada

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

### O Princípio do "Bom o Suficiente"

```
For most decisions, you need a GOOD choice, not the PERFECT choice.

Perfect is the enemy of done. If you have 2-3 viable options and
a clear comparison, make the decision. Document the reasoning and
the "revisit when" conditions so the team can re-evaluate later.

Exception: Irreversible decisions (public APIs, data formats,
vendor lock-in) deserve maximum research.
```

---

## Arquivos de Referência

### Guias Específicos por Plataforma
- [references/platforms/google.md](references/platforms/google.md) - Operadores de busca do Google, filtragem, truques de data
- [references/platforms/github.md](references/platforms/github.md) - Busca de código/repo/issue no GitHub, sinais de qualidade
- [references/platforms/pypi-npm.md](references/platforms/pypi-npm.md) - Avaliação de registros de pacotes, verificação de versões
- [references/platforms/huggingface.md](references/platforms/huggingface.md) - Busca de modelos/datasets, interpretação de benchmarks
- [references/platforms/arxiv.md](references/platforms/arxiv.md) - Busca de papers, códigos de categoria, análise de citações
- [references/platforms/infrastructure.md](references/platforms/infrastructure.md) - CNCF landscape, avaliação de vendors

### Metodologia
- [references/methodology/validation-protocol.md](references/methodology/validation-protocol.md) - Protocolo de 4 verificações, níveis de confiança
- [references/methodology/synthesis-templates.md](references/methodology/synthesis-templates.md) - Templates de comparação, recomendação, log de pesquisa
- [references/methodology/debate-frameworks.md](references/methodology/debate-frameworks.md) - Análise de trade-off, advogado do diabo, decision matrix

### Segurança
- [references/security/vulnerability-sources.md](references/security/vulnerability-sources.md) - NVD, GitHub Advisories, OWASP, Snyk
