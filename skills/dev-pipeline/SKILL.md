---
name: dev-pipeline
description: |
  Pipeline obrigatório de desenvolvimento que todo dev agent segue, do código ao PR aprovado.
  Cobre os 9 estágios sequenciais: CODE, SELF-JUDGE, QA, OPEN PR, REVIEW, FIX, SELF-JUDGE, QA, RE-REVIEW.
  Define quality gates, critérios de entrada e saída por estágio, protocolo de handoff entre dev e reviewer,
  checklist de self-judge, protocolo QA com setup/teardown, e o loop fix→re-review até aprovação ou escalação.
  Use quando: (1) Iniciar qualquer tarefa de desenvolvimento, (2) Preparar entrega para review,
  (3) Responder a comentários de review, (4) Verificar se uma tarefa está pronta para PR.
  Triggers: /dev-pipeline, pipeline, workflow, stages, self-judge, QA step, review handoff, fix loop.
---

# Skill Dev-Pipeline — Pipeline de Desenvolvimento

## Propósito

Esta skill define o **pipeline obrigatório** que todos os dev agents executam em toda tarefa de desenvolvimento.
É o contrato de processo que garante qualidade, rastreabilidade e handoff limpo entre agentes.

**Skill global** — carregada automaticamente por todos os agents.

**O que esta skill contém:**
- Definição dos 9 estágios e seus critérios de entrada/saída
- Self-judge checkpoint obrigatório
- Protocolo QA com setup, execução e teardown
- Protocolo de handoff dev → reviewer
- Loop fix → self-judge → QA → re-review
- Templates de evidência (QA report, review summary)

**O que esta skill NÃO contém:**
- Padrões de código por linguagem (vivem em `arch-py`, `arch-ts`)
- Estratégia de testes detalhada (vive em `qa`)
- Gestão de infraestrutura local (vive em `local-infrastructure`)
- Workflow de metodologia de desenvolvimento (vive em `dev-methodology`)

---

## Filosofia

### Pipeline é lei, não sugestão

Cada estágio existe por uma razão. Pular self-judge cria PRs envergonhados.
Pular QA cria bugs em produção. Pular review cria código sem segunda opinião.
O pipeline é sequencial e não tem atalhos.

### Princípios

**1. Evidence-based — sem evidência, não aconteceu**
- QA sem relatório não conta
- Review sem findings documentados não conta
- Self-judge sem checklist preenchido não conta

**2. Agentes diferentes revisam**
- O agent que escreve o código nunca revisa o próprio PR
- Review é sempre um agent diferente, com perspectiva diferente

**3. Loop até aprovação ou escalação**
- Fix → self-judge → QA → re-review repetem quantas vezes for necessário
- Se o loop não converge após 3 iterações, escalação para `the_architect`

**4. Skills certas no estágio certo**
- Cada estágio referencia as skills que devem ser consultadas
- Não improvisar — usar o conhecimento estruturado disponível

---

## Os 9 Estágios

### Visão Geral

```
Dev agent (neo / trinity / morpheus):
  1. CODE       → implementa a feature ou fix
  2. SELF-JUDGE → refatora, melhora, valida boas práticas
  3. QA         → sobe ambiente local, roda E2E, valida DoD
  4. OPEN PR    → push da branch, abre o PR com evidências

Reviewer agent (dev agent diferente):
  5. REVIEW     → code review completo

Se houver comentários:
  Dev agent:
  6. FIX        → endereça comentários de review
  7. SELF-JUDGE → re-valida após mudanças
  8. QA         → re-testa após mudanças

  Reviewer agent:
  9. RE-REVIEW  → verifica se fixes endereçam os comentários
     → loop até aprovação ou escalação
```

### Skills por Estágio

| Estágio | Skills a consultar |
|---------|-------------------|
| CODE | `dev-methodology`, `arch-py` ou `arch-ts`, `ai-engineer` (se AI) |
| SELF-JUDGE | `dev-methodology` |
| QA | `qa`, `local-infrastructure` |
| OPEN PR | `github` |
| REVIEW | `review-py` ou `review-ts`, `arch-py` ou `arch-ts` |
| FIX | `dev-methodology`, `arch-py` ou `arch-ts` |
| SELF-JUDGE (pós-fix) | `dev-methodology` |
| QA (pós-fix) | `qa`, `local-infrastructure` |
| RE-REVIEW | `review-py` ou `review-ts` |

---

## Referências

- [Estágios — definição detalhada e critérios](references/pipeline/stages.md)
- [Transições — critérios de entrada e saída](references/pipeline/transitions.md)
- [Self-judge checklist](references/self-judge/checklist.md)
- [Protocolo QA](references/qa-execution/protocol.md)
- [Protocolo de handoff review](references/review-handoff/protocol.md)
- [Template — QA report](references/templates/qa-report.md)
- [Template — review summary](references/templates/review-summary.md)
