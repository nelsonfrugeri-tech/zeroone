# Pipeline — Critérios de Transição entre Estágios

Cada transição é uma gate. O agente só avança quando todos os critérios de saída do estágio atual
estão satisfeitos. Não existe "quase pronto" em uma gate — está ou não está.

---

## Formato

Cada transição documenta:
- **De → Para:** quais estágios
- **Critérios de saída:** o que deve ser verdadeiro para sair do estágio atual
- **Critérios de entrada:** o que deve existir para entrar no próximo estágio
- **Bloqueadores:** condições que impedem a transição

---

## Transição 1 → 2: CODE → SELF-JUDGE

**Critérios de saída do CODE:**
- [ ] Código implementado e compilando sem erros
- [ ] Testes unitários e de integração escritos e passando localmente
- [ ] Branch com nome correto e commits descritivos
- [ ] Sem arquivos de debug, logs temporários ou código morto no diff

**Critérios de entrada do SELF-JUDGE:**
- Diff completo disponível para revisão
- Testes rodando localmente sem falhas

**Bloqueadores:**
- Testes falhando → voltar ao CODE
- Build quebrado → voltar ao CODE
- Código incompleto (TODOs funcionais) → voltar ao CODE

---

## Transição 2 → 3: SELF-JUDGE → QA

**Critérios de saída do SELF-JUDGE:**
- [ ] Checklist de self-judge executado completamente
- [ ] Refatorações necessárias aplicadas
- [ ] Nomes, funções e módulos revisados
- [ ] DoD verificada conceitualmente (antes da validação em ambiente)

**Critérios de entrada do QA:**
- Código estável após refatorações do self-judge
- Testes ainda passando após refatorações

**Bloqueadores:**
- Checklist de self-judge com itens pendentes → completar self-judge
- Refatorações que quebraram testes → voltar ao CODE

---

## Transição 3 → 4: QA → OPEN PR

**Critérios de saída do QA:**
- [ ] QA report preenchido com evidências reais
- [ ] Todos os critérios da DoD validados em ambiente
- [ ] Smoke tests passando
- [ ] E2E dos happy paths e edge cases executados
- [ ] Ambiente derrubado e limpo

**Critérios de entrada do OPEN PR:**
- QA report com evidências prontas para inclusão no PR
- CHANGELOG.md atualizado
- README.md atualizado (se aplicável)

**Bloqueadores:**
- Qualquer teste E2E falhando → voltar ao CODE
- DoD não satisfeita → voltar ao estágio correspondente
- Ambiente não derrubado → concluir teardown antes de prosseguir

---

## Transição 4 → 5: OPEN PR → REVIEW

**Critérios de saída do OPEN PR:**
- [ ] PR aberto com descrição completa
- [ ] QA report e evidências incluídos no PR
- [ ] CHANGELOG e README incluídos no diff
- [ ] Reviewer notificado via protocolo de handoff

**Critérios de entrada do REVIEW:**
- Reviewer é um agent diferente do dev que escreveu o código
- Reviewer tem acesso ao PR, diff e evidências de QA

**Bloqueadores:**
- PR sem QA report → dev deve completar QA antes de review
- PR sem CHANGELOG → dev deve atualizar antes de review
- Reviewer é o mesmo agent que escreveu o código → trocar de reviewer

---

## Transição 5 → 6: REVIEW → FIX (se houver comentários)

**Critérios de saída do REVIEW:**
- [ ] Review summary preenchido
- [ ] Todos os findings documentados com severidade
- [ ] Decisão clara: aprovado / comentários menores / bloqueado

**Critérios de entrada do FIX:**
- Comentários do reviewer são específicos e acionáveis
- Dev recebeu notificação com review summary

**Sem comentários → PR aprovado:** pipeline encerra no estágio 5.

**Bloqueadores:**
- Comentários vagos ("melhore isso") sem especificidade → reviewer deve detalhar antes

---

## Transição 6 → 7: FIX → SELF-JUDGE (pós-fix)

**Critérios de saída do FIX:**
- [ ] Todos os comentários endereçados (corrigidos ou respondidos com justificativa)
- [ ] Commits de fix separados dos commits originais
- [ ] Nenhuma mudança fora do escopo dos comentários

**Critérios de entrada do SELF-JUDGE (pós-fix):**
- Diff pós-fix disponível para revisão
- Build e testes ainda passando após fix

**Bloqueadores:**
- Comentários não endereçados → completar o FIX
- Fix que quebrou testes → corrigir antes de seguir

---

## Transição 7 → 8: SELF-JUDGE (pós-fix) → QA (pós-fix)

**Critérios de saída do SELF-JUDGE (pós-fix):**
- [ ] Checklist re-executado nos arquivos modificados pelo fix
- [ ] Nenhum novo problema introduzido
- [ ] Diff pós-fix ainda limpo

**Critérios de entrada do QA (pós-fix):**
- Código estável após self-judge
- Testes passando

**Bloqueadores:** mesmos da transição 2 → 3.

---

## Transição 8 → 9: QA (pós-fix) → RE-REVIEW

**Critérios de saída do QA (pós-fix):**
- [ ] QA report atualizado com evidências da re-execução
- [ ] DoD ainda satisfeita após fix
- [ ] Ambiente derrubado

**Critérios de entrada do RE-REVIEW:**
- QA report atualizado disponível no PR
- Reviewer notificado via protocolo de handoff

**Bloqueadores:** mesmos da transição 3 → 4.

---

## Transição 9 — RE-REVIEW: decisão final

**Aprovado:**
- Reviewer aprova o PR
- Pipeline encerrado

**Nova rodada de comentários:**
- Volta ao estágio 6 (FIX)
- Contador de iterações incrementado

**Escalação (loop > 3 iterações):**
- `the_architect` é chamado como árbitro
- Decisão do arquiteto é final
- Pipeline encerrado com resolução documentada
