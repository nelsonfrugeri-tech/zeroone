---
name: product-manager
description: |
  Skill de Technical Product/Platform Manager — foco em gestão de produto técnico, priorização,
  user stories, critérios de aceite, roadmap, backlog management e comunicação cross-funcional.
  Cobre: discovery, delivery, métricas de produto, OKRs, stakeholder management, e documentação de produto.
  Use quando: (1) Definir e priorizar backlog, (2) Escrever user stories e critérios de aceite,
  (3) Planejar roadmap e releases, (4) Comunicar decisões de produto ao time.
  Triggers: /product-manager, /pm, product management, backlog, user stories, roadmap, priorização.
---

# Product Manager Skill - Technical Product/Platform Management

## Princípios Fundamentais

### Produto e Valor
- Foco no **problema do usuário**, não na solução técnica
- Toda feature deve ter um **"por quê"** claro conectado a valor de negócio
- Métricas de sucesso definidas **antes** de começar o desenvolvimento
- Decisões baseadas em dados quando disponíveis, em hipóteses claras quando não

### Comunicação e Alinhamento
- Documentação clara e acessível para stakeholders técnicos e não-técnicos
- Decisões de produto documentadas com contexto, alternativas e justificativa
- Status do projeto sempre visível e atualizado
- Feedback loops curtos com time de desenvolvimento e stakeholders

---

## Artefatos de Produto

### 1. User Stories

**Formato padrão:**
```markdown
**Como** [persona/tipo de usuário],
**Quero** [ação/funcionalidade],
**Para** [benefício/valor].

### Critérios de Aceite
- [ ] Dado [contexto], quando [ação], então [resultado esperado]
- [ ] Dado [contexto], quando [ação], então [resultado esperado]
- [ ] Dado [contexto], quando [ação], então [resultado esperado]

### Notas Técnicas
- {considerações de implementação relevantes}
- {dependências conhecidas}
- {riscos identificados}

### Definição de Done
- [ ] Código implementado e revisado
- [ ] Testes escritos (unit + integration)
- [ ] Documentação atualizada
- [ ] Deploy em staging validado
- [ ] Critérios de aceite verificados
```

**Qualidade de User Stories (INVEST):**
- **I**ndependente: pode ser desenvolvida isoladamente
- **N**egociável: não é contrato, é conversa
- **V**aliosa: entrega valor ao usuário
- **E**stimável: time consegue estimar esforço
- **S**mall: cabe em uma sprint/iteração
- **T**estável: critérios de aceite verificáveis

---

### 2. Priorização

**Frameworks de priorização:**

**RICE Score:**
```markdown
| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| {nome}  | {1-10}| {1-3}  | {0.5-1.0}  | {dias} | {calculado}|
```
- Reach: quantos usuários impacta (1-10)
- Impact: quanto impacta cada usuário (1=mínimo, 3=massivo)
- Confidence: certeza sobre estimativas (0.5=baixa, 1.0=alta)
- Effort: esforço em pessoa-dias
- Score = (Reach x Impact x Confidence) / Effort

**MoSCoW:**
```markdown
### Must Have (P0) — Sem isso, não lança
- {feature}

### Should Have (P1) — Importante, mas contornável
- {feature}

### Could Have (P2) — Nice to have
- {feature}

### Won't Have (P3) — Explicitamente fora de escopo
- {feature}
```

**Matriz Esforço x Impacto:**
```markdown
|              | Baixo Esforço | Alto Esforço |
|-------------|---------------|--------------|
| Alto Impacto | Quick Wins    | Big Bets     |
| Baixo Impacto| Fill-ins      | Money Pits   |
```

---

### 3. Roadmap

**Formato de Roadmap:**
```markdown
## Roadmap - {Produto}

### Now (Sprint atual)
| Item | Status | Owner | ETA |
|------|--------|-------|-----|
| {item} | {status} | {quem} | {quando} |

### Next (Próximo ciclo)
| Item | Prioridade | Estimativa |
|------|-----------|------------|
| {item} | {P0/P1/P2} | {estimativa} |

### Later (Backlog priorizado)
| Item | Prioridade | Notas |
|------|-----------|-------|
| {item} | {P1/P2/P3} | {contexto} |

### Não Faremos (Decisões explícitas)
| Item | Razão |
|------|-------|
| {item} | {justificativa} |
```

---

### 4. Sprint/Iteração Planning

**Template de Sprint:**
```markdown
## Sprint {N} — {Tema/Objetivo}

### Objetivo
{Uma frase clara do que queremos alcançar}

### Critério de Sucesso
- {métrica ou entrega verificável}

### Itens
| # | User Story | Estimativa | Owner | Status |
|---|-----------|------------|-------|--------|
| 1 | {story}   | {pontos}   | {dev} | {status} |

### Riscos e Dependências
- {risco/dependência identificada}

### Capacidade do Time
- {N} devs x {M} dias = {total} pessoa-dias
- Buffer: 20% para bugs/imprevistos
```

---

### 5. PRD (Product Requirements Document)

**Template simplificado:**
```markdown
# PRD: {Nome da Feature}

## Problema
{Qual problema estamos resolvendo? Para quem?}

## Contexto
{Por que agora? Dados, feedback, oportunidade}

## Solução Proposta
{Descrição de alto nível da solução}

## User Stories
{Lista de user stories que compõem a feature}

## Métricas de Sucesso
- {KPI 1}: {baseline} → {target}
- {KPI 2}: {baseline} → {target}

## Escopo
### In Scope
- {item}

### Out of Scope
- {item} — {razão}

## Dependências
- {dependência técnica ou de produto}

## Timeline
- Discovery: {período}
- Design: {período}
- Desenvolvimento: {período}
- QA/Staging: {período}
- Release: {data}

## Riscos
| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| {risco} | {alta/média/baixa} | {alto/médio/baixo} | {ação} |
```

---

## Workflow de Produto

### Discovery → Definition → Delivery → Iteration

```
1. DISCOVERY: Entender o problema
   - Pesquisar contexto e dados
   - Mapear personas e necessidades
   - Identificar oportunidades

2. DEFINITION: Definir a solução
   - Escrever PRD
   - Criar user stories com critérios de aceite
   - Priorizar backlog (RICE/MoSCoW)
   - Alinhar com time técnico (feasibility)

3. DELIVERY: Acompanhar execução
   - Sprint planning com time
   - Daily sync (bloqueios, decisões)
   - Aceitar/rejeitar entregas vs critérios
   - Comunicar progresso a stakeholders

4. ITERATION: Medir e iterar
   - Validar métricas de sucesso
   - Coletar feedback
   - Ajustar backlog e prioridades
   - Documentar learnings
```

---

## Comunicação

### Formatos por Audiência

**Para Desenvolvedores:**
- User stories detalhadas com critérios de aceite
- Contexto técnico e business relevante
- Decisões de trade-off documentadas
- Disponibilidade para dúvidas e refinamento

**Para Stakeholders:**
- Status em formato executivo (resumo, riscos, próximos passos)
- Métricas e progresso vs metas
- Decisões pendentes com opções e recomendação
- Timeline e impactos em roadmap

**Para Design:**
- Problemas do usuário e contexto
- Constraints técnicos relevantes
- User flows e requisitos funcionais
- Critérios de aceite de UX

---

## Métricas de Produto

### Categorias
```markdown
**Aquisição:** Como usuários chegam
- {métrica}: {definição}

**Ativação:** Primeiro valor entregue
- {métrica}: {definição}

**Retenção:** Usuários voltam
- {métrica}: {definição}

**Revenue:** Monetização
- {métrica}: {definição}

**Referral:** Usuários trazem outros
- {métrica}: {definição}
```

---

## Ferramentas e Integrações

### Board/Backlog Management
- Trello/Jira/Linear para gestão de backlog e sprints
- Labels para prioridade (P0, P1, P2, P3)
- Swimlanes para status (To Do, In Progress, Review, Done)

### Documentação
- Notion/Confluence para PRDs e documentação de produto
- Decision logs para registro de decisões

### Comunicação
- Slack para comunicação assíncrona e sync diário
- Standups estruturados (bloqueios, progresso, próximos passos)

### Design
- Figma para design reviews e handoff
- Specs visuais linkadas nas user stories
