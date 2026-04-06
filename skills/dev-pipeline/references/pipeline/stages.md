# Pipeline — Definição dos 9 Estágios

Cada estágio tem um propósito único, um responsável e critérios claros de conclusão.
Nenhum estágio é opcional. Nenhum estágio pode ser pulado.

---

## Estágio 1 — CODE

**Responsável:** Dev agent (neo, trinity ou morpheus)

**Propósito:** Implementar a feature ou fix descrito na issue/tarefa.

**O que fazer:**
- Ler o código existente, dependências e contratos antes de escrever qualquer linha
- Definir o plano de testes antes de codificar (consultar `dev-methodology`)
- Implementar seguindo os padrões da linguagem (`arch-py` ou `arch-ts`)
- Escrever testes unitários e de integração junto com o código
- Fazer commits pequenos e descritivos na branch correta

**Critério de conclusão:**
- Código implementado e com testes passando localmente
- Sem `TODO`, `FIXME` ou código comentado no diff
- Branch com nome correto (`feat/`, `fix/`, `refactor/`)

**Skills:** `dev-methodology`, `arch-py` / `arch-ts`, `ai-engineer` (se aplicável)

---

## Estágio 2 — SELF-JUDGE

**Responsável:** Dev agent (mesmo que fez o CODE)

**Propósito:** Revisar o próprio trabalho com olhar crítico antes de qualquer outra pessoa ver.

**O que fazer:**
- Executar o checklist completo de self-judge (ver `references/self-judge/checklist.md`)
- Refatorar o que for necessário: nomes ruins, funções longas, duplicação
- Validar boas práticas: SOLID, DRY, separação de responsabilidades
- Reler o diff completo como se fosse um reviewer externo
- Garantir que a Definition of Done está atendida

**Output obrigatório:**
- Criar `self-judge.md` na raiz do repo com o checklist preenchido (ver `references/self-judge/checklist.md`)
- **COMMITAR** o `self-judge.md` na branch — o hook `require-self-judge.sh` bloqueia PR se o arquivo não estiver no diff da branch
- O arquivo deve ter no mínimo 50 bytes (um checklist real, não um placeholder)

**Critério de conclusão:**
- `self-judge.md` commitado na branch com checklist preenchido
- Refatorações aplicadas antes de seguir para QA
- Diff limpo: apenas o que é necessário para a tarefa

**Skills:** `dev-methodology`

---

## Estágio 3 — QA

**Responsável:** Dev agent (mesmo que fez o CODE e SELF-JUDGE)

**Propósito:** Validar o comportamento end-to-end em ambiente isolado, antes de abrir o PR.

**O que fazer:**
- Seguir o protocolo completo de QA (ver `references/qa-execution/protocol.md`)
- Subir ambiente local isolado via `local-infrastructure`
- Executar testes E2E, smoke tests e casos de borda
- Capturar evidências: logs, screenshots, saída dos testes
- Fazer teardown completo do ambiente após os testes

**Critério de conclusão:**
- QA report preenchido com evidências reais (ver template `references/templates/qa-report.md`)
- Todos os critérios da DoD validados
- Ambiente derrubado e limpo

**Skills:** `qa`, `local-infrastructure`

---

## Estágio 4 — OPEN PR

**Responsável:** Dev agent (mesmo que fez CODE, SELF-JUDGE e QA)

**Propósito:** Publicar o trabalho e abrir o PR com contexto suficiente para o reviewer.

**O que fazer:**
- Push da branch para o remote
- Abrir PR via MCP GitHub (`mcp__github__github_create_pr`)
- Incluir no corpo do PR: o QA report, evidências, decisões técnicas relevantes
- Atualizar CHANGELOG.md e README.md antes de abrir o PR (obrigatório)
- Notificar o reviewer agent conforme protocolo (ver `references/review-handoff/protocol.md`)

**Critério de conclusão:**
- PR aberto com descrição completa
- CHANGELOG e README atualizados
- Reviewer notificado

**Skills:** `github`

---

## Estágio 5 — REVIEW

**Responsável:** Reviewer agent (diferente do dev que escreveu o código)

**Propósito:** Revisar o código com perspectiva independente e documentar findings.

**O que fazer:**
- Ler o diff completo e o contexto da issue
- Executar checklist de review específico da linguagem (`review-py` ou `review-ts`)
- Verificar padrões de arquitetura (`arch-py` ou `arch-ts`)
- Documentar findings: bugs, melhorias, questões, aprovações
- Preencher o review summary (ver template `references/templates/review-summary.md`)

**Critério de conclusão:**
- Review summary preenchido com todos os findings
- Decisão clara: aprovado, comentários menores, bloqueado
- Se bloqueado: comentários específicos e acionáveis para o dev

**Skills:** `review-py` / `review-ts`, `arch-py` / `arch-ts`

---

## Estágio 6 — FIX

**Responsável:** Dev agent (mesmo que escreveu o código original)

**Propósito:** Endereçar os comentários do review de forma sistemática.

**O que fazer:**
- Ler todos os comentários do reviewer antes de começar
- Endereçar cada comentário explicitamente: corrigir ou justificar por que não
- Não fazer mudanças além do escopo dos comentários
- Fazer commits claros referenciando os comentários endereçados
- Comunicar ao reviewer o que foi feito e o que foi rejeitado com justificativa

**Critério de conclusão:**
- Todos os comentários endereçados (corrigidos ou respondidos)
- Nenhuma mudança fora do escopo dos comentários
- Comunicação de volta ao reviewer documentada

**Skills:** `dev-methodology`, `arch-py` / `arch-ts`

---

## Estágio 7 — SELF-JUDGE (pós-fix)

**Responsável:** Dev agent (mesmo que fez o FIX)

**Propósito:** Re-validar qualidade após as mudanças de fix, antes de re-testar.

**O que fazer:**
- Executar novamente o checklist de self-judge nos arquivos modificados pelo fix
- Verificar se o fix não introduziu regressões ou novos problemas
- Garantir que o diff pós-fix ainda está limpo e coerente

**Critério de conclusão:**
- Checklist de self-judge re-executado nos arquivos modificados
- Nenhum problema novo introduzido pelo fix

**Skills:** `dev-methodology`

---

## Estágio 8 — QA (pós-fix)

**Responsável:** Dev agent (mesmo que fez o FIX)

**Propósito:** Re-validar comportamento end-to-end após as mudanças de fix.

**O que fazer:**
- Repetir o protocolo de QA completo (setup, testes, teardown)
- Focar especialmente nos cenários relacionados aos comentários do review
- Atualizar o QA report com os resultados da nova rodada
- Incluir evidências da re-execução no PR

**Critério de conclusão:**
- QA report atualizado com evidências da re-execução
- Todos os critérios da DoD ainda válidos após o fix
- Ambiente derrubado e limpo

**Skills:** `qa`, `local-infrastructure`

---

## Estágio 9 — RE-REVIEW

**Responsável:** Reviewer agent (mesmo que fez o REVIEW original)

**Propósito:** Verificar se os fixes endereçam satisfatoriamente os comentários anteriores.

**O que fazer:**
- Ler o diff pós-fix e comparar com os comentários originais
- Verificar cada comentário: foi endereçado? A solução é adequada?
- Atualizar o review summary com a decisão final
- Se aprovado: aprovar o PR
- Se ainda há problemas: nova rodada de comentários acionáveis
- Se o loop não converge após 3 iterações: escalar para `the_architect`

**Critério de conclusão:**
- Decisão clara: aprovado ou nova rodada de comentários
- Review summary atualizado
- Se loop > 3 iterações: escalação documentada

**Skills:** `review-py` / `review-ts`
