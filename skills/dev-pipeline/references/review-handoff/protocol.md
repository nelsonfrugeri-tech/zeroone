# Review Handoff — Protocolo de Comunicação

O handoff é a comunicação formal entre dev e reviewer que garante que nenhum estágio do pipeline
fica bloqueado por falta de informação ou por contexto insuficiente.

---

## Princípios

**Explícito, não implícito**
Ninguém assume que o outro sabe o que precisa fazer. Cada handoff documenta o que foi feito,
o que está sendo pedido e o que é necessário para avançar.

**Acionável**
Cada comunicação resulta em uma ação clara: revisar, corrigir, aprovar, escalar.

**Rastreável**
O histórico de handoffs fica no PR (comentários, review summary) para auditoria posterior.

---

## Handoff 1 — Dev → Reviewer (após OPEN PR)

**Quando:** Dev conclui estágios 1-4 e abre o PR.

**O que o dev deve comunicar:**

```
Contexto:
- Issue/tarefa sendo endereçada
- Abordagem técnica adotada e por que
- Decisões não óbvias que o reviewer deve saber

Evidências:
- Link para o QA report no PR
- Cenários testados e resultados
- Cenários não testados e por que (se houver)

Pedido explícito:
- O que se espera do reviewer (aprovação, feedback em área específica, etc.)
- Deadline se houver
```

**Canal:** corpo do PR ou comentário inicial no PR.

---

## Handoff 2 — Reviewer → Dev (após REVIEW com comentários)

**Quando:** Reviewer conclui o estágio 5 e tem comentários.

**O que o reviewer deve comunicar:**

```
Sumário:
- Quantos findings, de que severidade
- Decisão: comentários menores (não bloqueante) | bloqueado (deve corrigir antes de merge)

Para cada finding:
- Arquivo e linha (quando aplicável)
- O que está errado ou pode melhorar
- Sugestão de solução (ou pergunta aberta)
- Severidade: bloqueante | sugestão | nitpick

Próximo passo:
- O que o dev deve fazer para este PR avançar
```

**Canal:** review summary no PR (ver template `references/templates/review-summary.md`).

---

## Handoff 3 — Dev → Reviewer (após FIX + SELF-JUDGE + QA)

**Quando:** Dev conclui estágios 6-8 e está pronto para re-review.

**O que o dev deve comunicar:**

```
Para cada comentário do reviewer:
- Comentário original (referência)
- Ação tomada: CORRIGIDO | MANTIDO COM JUSTIFICATIVA
- Se mantido: razão clara para não corrigir

Evidências do QA pós-fix:
- Link para QA report atualizado
- Confirmação que a DoD ainda está satisfeita

Pedido explícito:
- Re-review dos itens específicos corrigidos
```

**Canal:** comentário de resposta no PR referenciando cada comentário do reviewer.

---

## Handoff 4 — Reviewer → Dev (nova rodada, se necessário)

**Quando:** Re-review (estágio 9) ainda tem comentários não resolvidos.

**O que o reviewer deve comunicar:**

```
- Quais comentários foram satisfatoriamente endereçados
- Quais comentários ainda estão em aberto (e por quê a solução não foi suficiente)
- Novos comentários introduzidos pelo fix (se houver)
- Iteração atual (ex: "iteração 2 de 3")
- Aviso de escalação se estiver na iteração 3
```

---

## Escalação (loop > 3 iterações)

**Quando:** O loop FIX → RE-REVIEW passou de 3 iterações sem convergência.

**Quem escala:** Reviewer, no review summary da iteração 4+.

**O que documentar:**

```
Motivo da escalação:
- Resumo do histórico de iterações
- Ponto de discordância específico que não convergiu
- Posição do dev e posição do reviewer

Árbitro: the_architect
Decisão esperada: design decision final, não revisão de código linha a linha
```

**O árbitro `the_architect` tem a decisão final e o pipeline encerra após sua decisão.**
