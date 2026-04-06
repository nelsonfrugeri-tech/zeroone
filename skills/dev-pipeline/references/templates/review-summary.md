# Template — Review Summary

Usar este template para documentar o resultado de uma revisão de código nos estágios 5 e 9.
O review summary é a comunicação formal do reviewer para o dev e deve ser acionável.

---

```markdown
## Review Summary

**Branch/PR:** <link do PR>
**Issue/Tarefa:** <link ou título>
**Data:** <data>
**Reviewer:** <agent responsável>
**Iteração:** <1 | 2 | 3 | escalação>
**Estágio:** REVIEW (estágio 5) | RE-REVIEW (estágio 9)

---

### Decisão

**Status:** APROVADO | COMENTÁRIOS MENORES | BLOQUEADO | ESCALADO

> Resumo em 1-3 frases do estado geral do PR.

---

### Findings

#### Bloqueantes (impedem merge)

| # | Arquivo | Linha | Descrição | Sugestão |
|---|---------|-------|-----------|----------|
| 1 | <arquivo> | <linha> | <o que está errado> | <como corrigir> |
| 2 | ... | ... | ... | ... |

#### Sugestões (melhorias recomendadas, não bloqueantes)

| # | Arquivo | Linha | Descrição | Sugestão |
|---|---------|-------|-----------|----------|
| 1 | <arquivo> | <linha> | <o que pode melhorar> | <como melhorar> |

#### Nitpicks (estilo, preferência — pode ignorar)

| # | Arquivo | Linha | Descrição |
|---|---------|-------|-----------|
| 1 | <arquivo> | <linha> | <observação> |

---

### Verificação de Evidências QA

- [ ] QA report incluído no PR
- [ ] Evidências são reais (não "deve funcionar")
- [ ] DoD validada no QA report
- [ ] Ambiente derrubado após QA

---

### Verificação de Documentação

- [ ] CHANGELOG.md atualizado
- [ ] README.md atualizado (se aplicável)

---

### Para RE-REVIEW (iteração 2+)

#### Status dos comentários anteriores

| # | Comentário original | Status | Observação |
|---|---------------------|--------|------------|
| 1 | <resumo do comentário> | ENDEREÇADO / PENDENTE / REJEITADO | <observação> |
| 2 | ... | ... | ... |

---

### Próximo Passo

**Se APROVADO:** PR pronto para merge. Pipeline encerrado.

**Se COMENTÁRIOS MENORES / BLOQUEADO:**
```
O dev deve:
1. Endereçar os findings bloqueantes (lista acima)
2. Executar self-judge (estágio 7)
3. Executar QA pós-fix (estágio 8)
4. Notificar o reviewer via handoff (protocolo de handoff)
```

**Se ESCALADO (iteração 4+):**
```
Motivo da escalação: <descrição do impasse>
Árbitro: the_architect
Histórico de iterações: <resumo das 3+ iterações anteriores>
```
```
