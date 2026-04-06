---
name: meta-orchestration
description: |
  Baseline de conhecimento para meta-orquestracao de agents em ecossistemas Claude Code. Cobre classificacao
  de complexidade de tarefas, selecao dinamica de modelo (Haiku/Sonnet/Opus), roteamento inteligente para
  agents, discovery dinamico de agents e skills, coordenacao multi-agent peer-to-peer via Mem0,
  protocolos de claim/release, gestao de memoria semantica (tipos, curadoria, poda), criacao de agents,
  resolucao de conflitos, e gestao de contexto cross-project. Use quando: (1) Rotear tarefas para o agent/modelo
  certo, (2) Coordenar multiplos agents em paralelo, (3) Gerenciar memoria persistente compartilhada,
  (4) Criar novos agents/skills, (5) Detectar gaps no ecossistema.
  Triggers: /meta-orchestration, task routing, agent coordination, memory management, agent creation.
---

# Skill de Meta-Orquestração - Orquestração de Ecossistema Multi-Agent

## Propósito

Esta skill é a **base de conhecimento** para orquestrar ecossistemas multi-agent no Claude Code.
Ela codifica padrões para roteamento de tarefas, seleção de modelo, coordenação de agents e gestão de memória compartilhada.

**Quem usa esta skill:**
- Agent `oracle` -> roteamento de tarefas, gestão do ecossistema, curadoria de memória
- Agent `sentinel` -> monitoramento de saúde, verificações de coordenação
- Qualquer agent fundacional que gerencia o ecossistema

**O que esta skill contém:**
- Classificação de complexidade de tarefas com sinais e heurísticas
- Matriz de seleção de modelo (Haiku, Sonnet, Opus) por complexidade e tipo de tarefa
- Padrões de discovery dinâmico de agents e skills
- Árvore de decisão de roteamento de tarefas
- Protocolo de coordenação multi-agent (claim, work, report, release)
- Estrutura de conhecimento Mem0 (tipos de memória, ciclo de vida, queries)
- Higiene e curadoria de memória (critérios manter vs podar)
- Templates de criação de agents
- Resolução de conflitos e detecção de trabalho duplicado
- Gestão de contexto cross-project

**O que esta skill NÃO contém:**
- Expertise de domínio específico (isso vive nos agents/skills experts)
- Código de implementação para servidores MCP ou ferramentas
- Configuração específica de projetos

---

## 1. Classificação de Complexidade de Tarefas

Classifique toda tarefa recebida antes de decidir como executá-la.

### Níveis de Complexidade

| Nível | Sinais | Exemplos |
|-------|--------|----------|
| **trivial** | Busca simples, checagem de status, edição de uma linha | "em que branch estou?", "listar servidores MCP", "mostrar git log" |
| **low** | Mudança direta, escopo claro, arquivo único | "renomear variável X para Y", "atualizar CHANGELOG", "corrigir typo na linha 42" |
| **medium** | Multi-etapa, requer leitura de contexto, múltiplos arquivos | "adicionar novo endpoint de API", "corrigir este bug", "implementar feature X" |
| **high** | Decisões arquiteturais, trade-offs, trabalho de design | "redesenhar sistema de auth", "planejar migração de banco", "avaliar SSE vs stdio" |
| **critical** | Transversal, impacta múltiplos sistemas, irreversível | "reestruturar ecossistema de agents", "auditoria de segurança", "incidente de produção" |

### Heurística de Classificação

```
1. How many files are touched?
   - 0-1 file -> trivial or low
   - 2-5 files -> medium
   - 5+ files or cross-project -> high or critical

2. Are there architectural decisions?
   - No decisions, just execution -> trivial/low/medium
   - Trade-offs to evaluate -> high
   - Irreversible system-wide impact -> critical

3. Does it require domain expertise?
   - General knowledge -> handle directly
   - Specialized domain -> delegate to expert

4. What is the blast radius if done wrong?
   - Cosmetic -> trivial/low
   - Functional regression -> medium/high
   - Data loss, security breach, ecosystem corruption -> critical
```

### Resolução de Ambiguidade

Quando a classificação não é clara, **arredonde para cima** um nível. O custo de pensar demais
é menor do que o custo de pensar de menos numa tarefa de alto impacto.

**Referência:** [references/routing/complexity-classification.md](references/routing/complexity-classification.md)

---

## 2. Seleção de Modelo

Combine a capacidade do modelo com a complexidade da tarefa. Troca tática de modelo otimiza custos
em 60-80% sem sacrificar qualidade.

### Matriz de Seleção

| Complexidade | Modelo | Thinking Instruction | Justificativa |
|--------------|--------|---------------------|---------------|
| **trivial** | `haiku` | (nenhuma) | Rápido, barato. Sem necessidade de reasoning. |
| **low** | `sonnet` | (nenhuma) | Equilibrado. Bom para mudanças diretas. |
| **medium** | `sonnet` | "Think step by step" | Reasoning guiado para tarefas multi-etapa. |
| **high** | `opus` | "Analyze deeply, consider trade-offs, think step by step before acting" | Análise profunda para decisões arquiteturais. |
| **critical** | `opus` | "This is critical. Reason exhaustively. Consider all edge cases, risks, and second-order effects before proposing anything" | Reasoning máximo para mudanças irreversíveis. |

### Capacidades dos Modelos

| Modelo | Forças | Fraquezas | Custo Relativo |
|--------|--------|-----------|----------------|
| **Haiku** | Velocidade, tarefas simples, checagens de status | Profundidade de reasoning limitada | 1x (baseline) |
| **Sonnet** | Reasoning equilibrado, geração de código, 90% das tarefas de dev | Não ideal para análise arquitetural profunda | 5x |
| **Opus** | Reasoning profundo, análise de trade-off, decisões arquiteturais | Mais lento, caro, exagero para tarefas simples | 25x |

### Override de Modelo por Domínio

Alguns domínios de tarefa sobrescrevem a seleção padrão de modelo:

| Domínio | Override | Motivo |
|---------|----------|--------|
| Análise de segurança | Mínimo `sonnet` | Segurança requer reasoning cuidadoso |
| Code review | `sonnet` (padrão) | Análise equilibrada |
| Design de arquitetura | `opus` | Avaliação de trade-offs |
| Documentação | `haiku` ou `sonnet` | Baixa demanda de reasoning |
| Refactoring | `sonnet` | Reconhecimento de padrões |

### Thinking Instructions por Profundidade

Thinking instructions são embutidas no prompt enviado ao expert:

- **Nenhuma** (trivial/low): Apenas a descrição da tarefa
- **Step-by-step** (medium): "Think step by step before implementing."
- **Análise profunda** (high): "Analyze deeply. Consider trade-offs, edge cases, and risks. Think step by step before proposing a solution."
- **Exaustiva** (critical): "This is critical. Reason exhaustively about all implications, second-order effects, and failure modes before acting. Show your reasoning."

**Referência:** [references/routing/model-selection.md](references/routing/model-selection.md)

---

## 3. Discovery Dinâmico

Nunca mantenha listas hardcoded. O filesystem É o registro.

### Discovery de Agents

Escaneie `~/.claude/agents/experts/` no início da sessão para construir o roster atual de experts.

```bash
# Discover all available experts
for f in ~/.claude/agents/experts/*.md; do head -10 "$f"; echo "---"; done
```

Cada arquivo `.md` de expert tem frontmatter com campos `name` e `description`.
Combine o domínio da tarefa com a `description` do expert.

**Heurística de matching:**
1. Faça parse do campo `description` do frontmatter de cada expert
2. Combine palavras-chave da tarefa com as descrições dos experts
3. Se múltiplos experts combinam, prefira o mais especializado
4. Se nenhum expert combina, trate diretamente ou proponha criar um novo (detecção de gap)

### Discovery de Skills

Escaneie `~/.claude/skills/` no início da sessão para descobrir todas as skills disponíveis.

```bash
# Discover all skills and their descriptions
for f in ~/.claude/skills/*/SKILL.md; do head -12 "$f"; echo "---"; done
```

Cada `SKILL.md` tem frontmatter com campos `name`, `description` e `triggers`.
Combine o contexto da tarefa com os `triggers` e `description` da skill.

### Detecção de Gaps

Se uma tarefa requer uma capacidade que não existe no ecossistema:

1. **Identifique o gap**: "Esta tarefa precisa de X, mas nenhum agent/skill/MCP fornece isso"
2. **Proponha a criação**: Sugira criar o componente faltante para o usuário
3. **Nunca improvise**: Não use workarounds quando o ecossistema deveria ter a capacidade built-in

Exemplos de gaps detectáveis:
- Tarefa precisa de integração com Jira mas nenhum MCP de Jira existe
- Tarefa precisa de deploy mas nenhuma skill de deploy existe
- Tarefa precisa de um expert de linguagem (ex: Rust) mas nenhum `dev-rust` expert existe

**Referência:** [references/routing/dynamic-discovery.md](references/routing/dynamic-discovery.md)

---

## 4. Árvore de Decisão de Roteamento de Tarefas

```
Task received
  |
  +-- Is it about the ecosystem itself? (agents, skills, MCP, CLAUDE.md)
  |     YES --> Handle directly (Oracle scope)
  |
  +-- Is it trivial? (grep, status, quick lookup)
  |     YES --> Handle directly, no delegation
  |
  +-- Does it require cross-project context only Oracle has?
  |     YES --> Handle directly
  |
  +-- Did the user explicitly ask Oracle to do it?
  |     YES --> Handle directly
  |
  +-- Classify complexity (Section 1)
  |
  +-- Select model (Section 2)
  |
  +-- Discover matching expert (Section 3)
  |     |
  |     +-- Expert found --> Delegate with isolation: "worktree"
  |     |
  |     +-- No expert found --> Gap detection (Section 3)
  |           |
  |           +-- Propose new expert to user
  |           +-- Or handle directly if within Oracle's capability
  |
  +-- Execute delegation
        |
        Agent(
          subagent_type="<expert-name>",
          model="<chosen-model>",
          prompt="<thinking instruction> + <task> + <context>",
          isolation="worktree"
        )
```

### Template de Delegação

Ao delegar para um expert, o prompt deve incluir:
1. **Thinking instruction** (baseada no nível de complexidade)
2. **Descrição da tarefa** (clara, específica, acionável)
3. **Contexto** (arquivos relevantes, decisões, restrições)
4. **Critérios de aceitação** (como "feito" se parece)

```
Agent(
  subagent_type="dev-py",
  model="sonnet",
  prompt="Think step by step before implementing.\n\nTask: Add a DELETE endpoint for issues in the GitHub MCP server.\n\nContext:\n- Server file: mcp/github-server/server.py\n- Follow existing endpoint patterns\n- Must validate agent_name parameter\n\nAcceptance criteria:\n- Endpoint handles DELETE /issues/{id}\n- Returns 204 on success\n- Tests pass",
  isolation="worktree"
)
```

### Quando NÃO Delegar

| Condição | Ação |
|----------|------|
| Tarefa de gestão do ecossistema | Tratar diretamente |
| Tarefa trivial (grep, status) | Tratar diretamente |
| Contexto cross-project necessário | Tratar diretamente |
| Usuário pediu explicitamente ao Oracle | Tratar diretamente |
| Exploração somente leitura | Pode pular isolamento por worktree |

**Referência:** [references/routing/decision-tree.md](references/routing/decision-tree.md)

---

## 5. Protocolo de Coordenação Multi-Agent

Múltiplas instâncias de Oracle coordenam como **peers** via memória compartilhada Mem0.
Sem eleição de líder. Cada Oracle é autônomo e auto-coordenado.

### Protocolo: Claim, Work, Report, Release

```
Phase 1: CLAIM
  - mem0_search(memory_type="task_claim") -> see what others are doing
  - Check for scope overlap with existing claims
  - If overlap -> store conflict memory, alert user
  - If clear -> mem0_store(content="Working on X", memory_type="task_claim")

Phase 2: WORK
  - Execute the task
  - Store decisions: mem0_store(memory_type="decision")
  - Store blockers: mem0_store(memory_type="blocker")
  - Update progress on long tasks: mem0_store(memory_type="progress")

Phase 3: REPORT
  - Store completion summary: mem0_store(memory_type="progress")
  - Store reusable knowledge: mem0_store(memory_type="procedural")

Phase 4: RELEASE
  - Delete task_claim memory
  - Delete resolved blocker memories
  - Update/archive completed progress memories
```

### Regra de Deduplicação

Antes de reivindicar qualquer tarefa:

```
results = mem0_search(query="<task description>", memory_type="task_claim")
```

Se um claim ativo existe para o mesmo escopo ou escopo sobreposto:
- NÃO inicie a tarefa
- Alerte o usuário sobre o claim existente
- Ofereça esperar ou trabalhar em uma tarefa diferente

### Detecção de Conflitos

Um conflito ocorre quando:
1. Dois agents reivindicam escopos de arquivo sobrepostos
2. Dois agents tomam decisões contraditórias sobre o mesmo sistema
3. O trabalho de um agent invalida o trabalho em andamento de outro agent

Resposta a conflito:
```
mem0_store(
  content="Conflict: Agent A editing settings.json while Agent B also modifying it",
  memory_type="conflict",
  tags="active"
)
```
Então alerte o usuário imediatamente.

### Spawning de Experts

Qualquer Oracle pode spawnar experts como subagents. Experts sempre rodam em worktrees isoladas.

```bash
# Discover agents dynamically
ls ~/.claude/agents/experts/*.md | xargs -I{} head -3 {}
```

Experts são stateless -- eles recebem contexto no prompt, fazem seu trabalho e retornam resultados.
Eles não coordenam diretamente entre si. O Oracle gerencia toda coordenação.

**Referência:** [references/coordination/peer-protocol.md](references/coordination/peer-protocol.md)

---

## 6. Estrutura de Conhecimento Mem0

Todo conhecimento persistente vive no Mem0 (Qdrant vector store + Ollama embeddings).
Compartilhado entre todos os terminais e agents.

### Tipos de Memória

| Tipo | Propósito | Ciclo de Vida | Exemplo |
|------|-----------|---------------|---------|
| `feedback` | Correções e preferências do usuário | Longa duração, raramente podado | "Never push to main" |
| `project` | Estado do projeto, decisões, contexto | Vive com o projeto | "Project X uses event-driven arch" |
| `reference` | Ponteiros para sistemas externos | Longa duração | "Bugs tracked in Linear INGEST" |
| `decision` | Decisões arquiteturais/técnicas | Longa duração até substituída | "Chose stdio over SSE for MCP" |
| `procedural` | Conhecimento how-to, procedimentos reutilizáveis | Longa duração, atualizado | "Steps to create a GitHub App" |
| `task_claim` | Coordenação: quem está trabalhando em quê | Efêmero (tempo de sessão) | "Oracle-A working on MCP isolation" |
| `blocker` | Coordenação: sinalizar blockers | Efêmero (até resolvido) | "Blocked on Qdrant timeout" |
| `progress` | Coordenação: atualizações de status | Efêmero a médio | "MCP server 80% complete" |
| `conflict` | Coordenação: colisão detectada | Efêmero (até resolvido) | "Two agents editing settings.json" |

### Regras de Armazenamento

| Evento | Ação |
|--------|------|
| Início de sessão | `mem0_search(memory_type="task_claim")` -- verificar peers |
| Início de sessão | `mem0_recall("pending work, recent decisions")` -- restaurar contexto |
| Tarefa reivindicada | `mem0_store(memory_type="task_claim")` |
| Decisão tomada | `mem0_store(memory_type="decision")` |
| Procedimento aprendido | `mem0_store(memory_type="procedural")` |
| Problema resolvido | `mem0_store(memory_type="procedural", tags="troubleshooting")` |
| Projeto configurado | `mem0_store(memory_type="project", project="X")` |
| Agent criado/modificado | `mem0_store(memory_type="procedural")` |
| Blocker encontrado | `mem0_store(memory_type="blocker", tags="active")` |
| Fim de sessão | Armazenar resumo de progresso, deletar task_claims, deletar blockers resolvidos |

### Padrões de Query

```
# Restore context at session start
mem0_recall(query="pending work, recent changes", limit=10)

# Check what other agents are doing
mem0_search(query="active tasks", memory_type="task_claim", limit=20)

# Find how-to knowledge
mem0_search(query="how to create GitHub App", memory_type="procedural")

# Find project context
mem0_search(query="architecture decisions", memory_type="decision", project="bike-shop")

# List all claims for cleanup
mem0_list(memory_type="task_claim", limit=50)

# Clean up stale memories
mem0_delete(memory_id="<id>")

# Update outdated memory
mem0_update(memory_id="<id>", content="Updated procedure...", memory_type="procedural")
```

**Referência:** [references/memory/knowledge-structure.md](references/memory/knowledge-structure.md)

---

## 7. Higiene e Curadoria de Memória

Memória sem curadoria se torna ruído. Poda ativa é tão importante quanto armazenamento ativo.

### Quando Podar

Avalie a cada início de sessão:

| Sinal | Ação |
|-------|------|
| Projeto não mencionado em semanas, usuário confirmou abandono | Arquivar memórias do projeto |
| Decisão substituída por uma decisão mais recente | Deletar antiga, ou marcar `[SUPERSEDED]` |
| Troubleshooting de bug que foi corrigido permanentemente | Remover o workaround |
| Procedimento referencia versões/paths/configs que não existem mais | Atualizar ou remover |
| Task claims com mais de 7 dias sem atualização | Deletar (stale) |
| Memórias duplicadas cobrindo a mesma informação | Manter a mais completa, deletar as outras |

### Critérios Manter vs Podar

**MANTER quando:**
- Procedimento reutilizável (setup, criação, configuração)
- Decisão arquitetural com trade-offs documentados (o "porquê")
- Referenciado por outras memórias ou documentos
- Contém informação que seria difícil reconstruir (tokens, IDs, configs)
- Consultado ativamente em sessões recentes

**PODAR quando:**
- Referencia versões/paths/configs que não existem mais
- Descreve workaround para problema resolvido na raiz
- Documenta decisão explicitamente revertida
- Duplica informação que existe em outro lugar
- Não consultado nos últimos 30 dias E não é procedimento core

### Protocolo de Limpeza

```
# Periodic cleanup (every session start)
1. mem0_list(memory_type="task_claim") -> delete completed/abandoned claims
2. mem0_list(memory_type="blocker") -> delete resolved blockers
3. mem0_search(query="outdated, old, deprecated") -> review and prune

# Deep cleanup (weekly or on demand)
4. mem0_list(memory_type="procedural") -> verify procedures still accurate
5. mem0_list(memory_type="decision") -> check for superseded decisions
6. mem0_list(memory_type="project") -> archive dead projects
```

### Regra de Ouro

> Prefira uma base de conhecimento com 20 documentos precisos e atuais a 100 onde metade está desatualizada.
> Informação errada é pior que informação ausente.

**Referência:** [references/memory/hygiene.md](references/memory/hygiene.md)

---

## 8. Templates de Criação de Agents

Ao criar um novo agent, siga esta estrutura.

### Template de Agent Fundacional (founds/)

```markdown
---
name: <agent-name>
description: <what this agent does, 1-2 sentences>
skills: [<skill-1>, <skill-2>]
tools: [<tool-1>, <tool-2>]
mcp: [<mcp-server-1>]
---

# <Agent Name>

## Identity
- **Name**: <name>
- **Role**: <role description>
- **Scope**: <what this agent manages>

## Responsibilities
1. <responsibility 1>
2. <responsibility 2>

## Workflow
### On session start:
1. <step>

### During execution:
1. <step>

### On session end:
1. <step>

## Principles
1. <principle>
```

### Template de Agent Expert (experts/)

```markdown
---
name: <expert-name>
description: <pure specialist description, domain-only>
skills: [<domain-skill>]
---

# <Expert Name>

## Identity
- **Name**: <name>
- **Role**: <specialist role>
- **Scope**: <domain scope>

## Expertise
- <capability 1>
- <capability 2>

## Workflow
1. Receive task with context from orchestrator
2. Execute within domain expertise
3. Return results

## Principles
1. <domain principle>
```

### Checklist para Novos Agents

- [ ] Arquivo do agent criado no namespace correto (`founds/` ou `experts/`)
- [ ] Frontmatter inclui `name`, `description`, `skills`
- [ ] Descrição é precisa e ajuda no discovery dinâmico
- [ ] Skills referenciadas realmente existem em `~/.claude/skills/`
- [ ] Servidores MCP referenciados (se houver) estão configurados
- [ ] Agent tem limites de escopo claros (não sobrepõe agents existentes)
- [ ] Armazenado no Mem0: `mem0_store(memory_type="procedural", content="Created agent X: ...")`

**Referência:** [references/agents/creation-templates.md](references/agents/creation-templates.md)

---

## 9. Resolução de Conflitos

### Detecção de Trabalho Duplicado

Antes de qualquer tarefa, verifique se há claims ativos com escopo sobreposto:

```
results = mem0_search(query="<task description>", memory_type="task_claim")
```

**Heurísticas de sobreposição:**
- Mesmos paths de arquivo mencionados no claim e na nova tarefa
- Mesma feature/sistema sendo modificado
- Mesmo projeto e mesmo subsistema

### Padrões de Lock

Task_claims do Mem0 atuam como advisory locks (não impostos pela infraestrutura):

```
# Acquire lock
mem0_store(
  content="LOCK: Editing mcp/github-server/server.py - adding delete endpoint",
  memory_type="task_claim",
  tags="active,lock"
)

# Release lock
mem0_delete(memory_id="<claim-id>")
```

### Estratégias de Resolução

| Tipo de Conflito | Resolução |
|------------------|-----------|
| Mesmo arquivo, seções diferentes | Coordenar: um agent espera o outro |
| Mesmo arquivo, mesma seção | Alertar usuário, deixar ele decidir prioridade |
| Decisões contraditórias | Armazenar ambas, escalar para o usuário para resolução |
| Claim stale bloqueando novo trabalho | Se claim > 7 dias sem atualização, deletar e prosseguir |

### Protocolo de Escalação

Quando o conflito não pode ser auto-resolvido:
1. Armazenar memória de conflito com detalhes completos
2. Apresentar ambos os lados ao usuário
3. Esperar decisão do usuário
4. Atualizar memórias com base na resolução

**Referência:** [references/coordination/conflict-resolution.md](references/coordination/conflict-resolution.md)

---

## 10. Gestão de Contexto Cross-Project

Oracle mantém contexto entre todos os projetos ativos.

### Registro de Projetos

Cada projeto ativo deve ter memórias armazenadas com tag `project`:

```
mem0_store(
  content="Project bike-shop: Slack bot team (Mr. Robot, Elliot, Tyrell). Stack: Python, Claude CLI.",
  memory_type="project",
  project="bike-shop"
)
```

### Queries Cross-Project

Quando uma tarefa pode abranger projetos:

```
# Find related decisions across projects
mem0_search(query="authentication approach", memory_type="decision")

# Find shared procedures
mem0_search(query="MCP server setup", memory_type="procedural")
```

### Transferência de Contexto para Experts

Ao delegar para um expert, forneça apenas o contexto relevante do projeto:

1. Consulte o Mem0 para decisões e restrições específicas do projeto
2. Inclua apenas o que o expert precisa (não o histórico completo do projeto)
3. Inclua paths de arquivo relevantes e decisões arquiteturais
4. Nunca inclua credenciais, tokens ou dados sensíveis em prompts de experts

### Ciclo de Vida do Projeto

| Fase | Ações |
|------|-------|
| **Onboarding** | Armazenar setup, configs, decisões de arquitetura, estrutura do time |
| **Desenvolvimento ativo** | Atualizar decisões, progresso, blockers conforme ocorrem |
| **Manutenção** | Reduzir frequência de atualização, manter decisões e procedimentos core |
| **Arquivamento** | Marcar memórias do projeto como arquivadas, manter apenas procedimentos reutilizáveis |

**Referência:** [references/coordination/cross-project.md](references/coordination/cross-project.md)

---

## Referência Rápida: Exemplos de Roteamento

| Pedido do Usuário | Complexidade | Modelo | Expert | Ação |
|-------------------|--------------|--------|--------|------|
| "corrigir typo no README linha 42" | trivial | (self) | (nenhum) | Tratar diretamente |
| "renomear variável foo para bar" | low | sonnet | dev-py | Delegar |
| "adicionar endpoint delete ao servidor MCP" | medium | sonnet | dev-py | Delegar com step-by-step |
| "devemos usar SSE ou stdio para MCP?" | high | opus | architect | Delegar com análise profunda |
| "reestruturar agents para multi-tenancy" | critical | opus | architect | Delegar com reasoning exaustivo, revisar output |
| "listar todos os servidores MCP" | trivial | (self) | (nenhum) | Tratar diretamente |
| "criar novo expert agent para Go" | medium | (self) | (nenhum) | Tratar diretamente (tarefa do ecossistema) |
| "revisar PR #42" | medium | sonnet | review-py | Delegar |

---

## Referências

### Roteamento
- [references/routing/complexity-classification.md](references/routing/complexity-classification.md) - Sinais e exemplos estendidos de classificação
- [references/routing/model-selection.md](references/routing/model-selection.md) - Comparação de modelos e otimização de custos
- [references/routing/dynamic-discovery.md](references/routing/dynamic-discovery.md) - Padrões de discovery de agents e skills
- [references/routing/decision-tree.md](references/routing/decision-tree.md) - Árvore de decisão completa de roteamento com edge cases

### Coordenação
- [references/coordination/peer-protocol.md](references/coordination/peer-protocol.md) - Coordenação peer multi-Oracle
- [references/coordination/conflict-resolution.md](references/coordination/conflict-resolution.md) - Detecção e resolução de conflitos
- [references/coordination/cross-project.md](references/coordination/cross-project.md) - Gestão de contexto cross-project

### Memória
- [references/memory/knowledge-structure.md](references/memory/knowledge-structure.md) - Tipos de memória e padrões de query do Mem0
- [references/memory/hygiene.md](references/memory/hygiene.md) - Regras de curadoria e poda de memória

### Agents
- [references/agents/creation-templates.md](references/agents/creation-templates.md) - Templates e checklist de criação de agents

### Fontes Externas
- [LLM Orchestration Frameworks 2026](https://aimultiple.com/llm-orchestration) - Comparação de frameworks
- [Multi-Agent Memory Systems](https://mem0.ai/blog/multi-agent-memory-systems) - Padrões de memória em produção
- [State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026) - Tendências de arquitetura de memória
- [Claude Code Sub-Agents](https://code.claude.com/docs/en/sub-agents) - Documentação oficial de subagents
- [Claude Code Model Selection](https://claudefa.st/blog/models/model-selection) - Padrões de roteamento de modelos
- [OpenAI Agent Orchestration](https://openai.github.io/openai-agents-python/multi_agent/) - Padrões de orquestração
- [Multi-Agent Orchestration Architectures](https://arxiv.org/html/2601.13671v1) - Survey acadêmico de protocolos
