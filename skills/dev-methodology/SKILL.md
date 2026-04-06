---
name: dev-methodology
description: |
  Metodologia completa de desenvolvimento de software. Cobre o workflow completo
  QUESTIONAR > PESQUISAR > PROJETAR > TESTAR > IMPLEMENTAR > VALIDAR > REVISAR,
  test-first (TDD/BDD), workflow de bug fix, refactoring (strangler fig, branch by abstraction,
  parallel change), decomposicao de features (vertical slicing, walking skeleton), code review
  self-check, Definition of Done, gestao de debito tecnico, pair/mob programming, e disciplina CI.
  Use quando: (1) Planejar como atacar uma tarefa de desenvolvimento, (2) Definir estrategia de testes,
  (3) Refatorar sistemas legados, (4) Quebrar features grandes em entregas incrementais,
  (5) Preparar codigo para review, (6) Gerenciar debito tecnico.
  Triggers: /dev-methodology, development workflow, TDD, BDD, refactoring, vertical slice,
  walking skeleton, definition of done, technical debt, code review checklist.
---

# Skill Dev-Methodology - Metodologia de Desenvolvimento de Software

## Propósito

Esta skill é a **base de conhecimento** para metodologia sistemática de desenvolvimento de software.
Ela define COMO desenvolver software — o processo, a disciplina e os quality gates que
transformam requisitos em código pronto para produção.

**Skill global** — carregada automaticamente por todos os agents.
- Qualquer agent que escreve código

**O que esta skill contém:**
- Workflow completo de desenvolvimento (7 fases)
- Metodologia test-first (TDD, BDD, ATDD)
- Workflow de bug fix (reprodução sistemática até prevenção)
- Metodologia de refactoring (strangler fig, branch by abstraction, parallel change)
- Decomposição de features grandes (vertical slicing, walking skeleton)
- Self-check de code review antes de submeter
- Critérios de Definition of Done
- Gestão de débito técnico (modelo de quadrante)
- Padrões de pair/mob programming
- Disciplina de CI (commits pequenos, builds verdes, feedback rápido)

**O que esta skill NÃO contém:**
- Padrões específicos de linguagem (esses vivem em `arch-py`, `arch-ts`)
- Frameworks/ferramentas de teste (esses vivem em `arch-py`, `arch-ts`)
- Padrões de arquitetura (esses vivem em `arch-py`, `arch-ts`, `ai-engineer`)
- Workflow de execução (esse vive nos próprios agents)

---

## Filosofia

### Processo não é burocracia — é disciplina

Boa metodologia elimina desperdício, reduz retrabalho e constrói confiança.
Má metodologia adiciona cerimônia sem valor. Esta skill mira na primeira.

### Princípios

**1. Entenda antes de construir**
- Leia código existente, contratos, dependências e edge cases
- Se você não consegue articular como "pronto" se parece, você não entende a tarefa

**2. Teste antes de implementar**
- Defina critérios de aceitação primeiro
- Escreva testes que falham e codificam esses critérios
- Implemente apenas o suficiente para passar
- Refatore enquanto verde

**3. Entregue em thin vertical slices**
- Cada slice é deployável, testável e valioso
- Prefira um walking skeleton a uma abordagem em camadas
- Lotes pequenos reduzem risco e aceleram feedback

**4. Nunca entregue código não testado**
- "Compila" não é um teste
- Execute os comandos reais, verifique a saída real
- Teste happy path E edge cases

**5. Deixe o codebase melhor do que encontrou**
- Boy Scout Rule: limpe o que você toca
- Reserve tempo para débito técnico em toda iteração
- Refatore com redes de segurança (testes), nunca sem

**6. Commits pequenos, builds verdes, feedback rápido**
- Cada commit é atômico, focado e buildável
- CI deve passar em cada commit — sem exceções
- Builds quebrados são a prioridade máxima do time

---

## 1. Workflow de Desenvolvimento — 7 Fases

```
QUESTIONAR > PESQUISAR > PROJETAR > TESTAR > IMPLEMENTAR > VALIDAR > REVISAR
```

Toda tarefa — feature, bug fix, refactor — segue estas fases.
As fases podem ser rápidas (minutos para um fix trivial) ou profundas (dias para uma feature complexa),
mas nenhuma pode ser pulada.

### Fase 1: QUESTIONAR

**Objetivo:** Garantir entendimento cristalino da tarefa.

**Ações:**
- Ler a issue/ticket/requisito completamente
- Ler código, testes e documentação relacionados
- Identificar ambiguidades e resolvê-las ANTES de codar
- Mapear dependências (o que isso afeta?)
- Identificar restrições (performance, compatibilidade, segurança)

**Critérios de saída:**
- [ ] Consegue articular o problema em uma frase
- [ ] Consegue descrever o comportamento esperado (inputs -> outputs)
- [ ] Consegue listar componentes/arquivos afetados
- [ ] Todas as ambiguidades resolvidas (perguntou ao usuário se necessário)

**Anti-patterns:**
- Começar a codar antes de entender o escopo completo
- Assumir requisitos quando estão inclaros
- Ignorar edge cases descobertos durante o questionamento

**Referência:** [references/workflow/questioning.md](references/workflow/questioning.md)

---

### Fase 2: PESQUISAR

**Objetivo:** Fundamentar decisões em conhecimento atual, não em suposições.

**Ações:**
- Buscar soluções existentes no codebase (isso já foi resolvido antes?)
- Pesquisar na web por melhores práticas atuais (bibliotecas, padrões, abordagens)
- Verificar se dependências precisam de atualização
- Revisar como sistemas similares resolvem esse problema
- Cruzar múltiplas fontes (docs, GitHub, blogs, benchmarks)
- **Verificação de segurança de dependências** (obrigatório antes de qualquer `pip install` / `pnpm add`):
  1. Buscar versão LTS/stable mais recente na web (nunca confiar em training data)
  2. Checar CVEs: NVD, GitHub Advisories, Snyk
  3. Verificar se lib é mantida (último release, issues, maintainer ativo)
  4. Após instalar: `pip-audit` / `npm audit` / `cargo audit`
  5. Ver protocolo completo na skill `research` (seção 8)

**Critérios de saída:**
- [ ] Ciente de soluções existentes no codebase
- [ ] Ciente das melhores práticas atuais para este tipo de problema
- [ ] Dependências identificadas com versões fixas e **segurança verificada**
- [ ] Trade-offs de diferentes abordagens compreendidos

**Anti-patterns:**
- Confiar apenas em dados de treinamento / memória sem verificar
- Escolher a primeira abordagem encontrada sem comparar alternativas
- Pular pesquisa porque "eu já sei a resposta"

**Referência:** [references/workflow/research.md](references/workflow/research.md)

---

### Fase 3: PROJETAR

**Objetivo:** Tornar decisões de design explícitas antes de escrever código.

**Ações:**
- Definir a API / interface pública primeiro
- Identificar o modelo de dados / mudanças de schema
- Escolher o padrão (e documentar O PORQUÊ)
- Considerar pelo menos 2 abordagens com trade-offs
- Documentar a abordagem escolhida brevemente

**Entregáveis (escalar ao tamanho da tarefa):**
- Trivial: modelo mental, nenhum artefato necessário
- Pequeno: comentário no código ou issue
- Médio: nota de design breve (bullet points)
- Grande: documento de design com diagramas

**Critérios de saída:**
- [ ] Interfaces/contratos definidos
- [ ] Padrão escolhido com justificativa
- [ ] Edge cases identificados
- [ ] Breaking changes identificadas (se houver)

**Anti-patterns:**
- Projetar na cabeça sem escrever nada
- Over-engineering (YAGNI — You Aren't Gonna Need It)
- Under-designing (pular direto para código em tarefas complexas)
- Projetar sem considerar testabilidade

**Referência:** [references/workflow/design.md](references/workflow/design.md)

---

### Fase 4: TESTAR (Escrever Testes Primeiro)

**Objetivo:** Codificar o comportamento esperado como testes executáveis ANTES de implementar.

**Ações:**
- Escrever testes que falham e capturam critérios de aceitação
- Incluir happy path, edge cases e casos de erro
- Usar nomes de teste que descrevem comportamento, não implementação
- Configurar fixtures e dados de teste

**Convenção de nomenclatura de testes:**
```
test_<behavior>_when_<condition>_then_<expected>
```

**Exemplos:**
```python
def test_create_user_when_email_valid_then_returns_user():
    ...

def test_create_user_when_email_duplicate_then_raises_conflict():
    ...

def test_calculate_discount_when_premium_user_then_applies_10_percent():
    ...
```

**Critérios de saída:**
- [ ] Testes escritos e falhando (fase RED)
- [ ] Testes cobrem happy path
- [ ] Testes cobrem edge cases principais
- [ ] Testes cobrem caminhos de erro/exceção
- [ ] Nomes dos testes descrevem comportamento claramente

**Anti-patterns:**
- Escrever testes depois da implementação (perde o benefício de design do TDD)
- Testar detalhes de implementação ao invés de comportamento
- Escrever testes que sempre passam (testes tautológicos)
- Pular testes de casos de erro

**Referência:** [references/testing/test-first.md](references/testing/test-first.md)

---

### Fase 5: IMPLEMENTAR

**Objetivo:** Escrever o código mínimo para fazer os testes passarem, depois refatorar.

**Ações:**
- Implementar apenas o suficiente para passar o primeiro teste (fase GREEN)
- Executar testes após cada pequena mudança
- Uma vez verde, refatorar para clareza e design (fase REFACTOR)
- Repetir ciclo RED-GREEN-REFACTOR
- Commitar após cada estado verde significativo

**Ciclo RED-GREEN-REFACTOR:**
```
RED:      Write a failing test
GREEN:    Write the simplest code that passes
REFACTOR: Improve design while staying green
REPEAT
```

**Critérios de saída:**
- [ ] Todos os testes passando
- [ ] Código segue estilo e padrões do projeto
- [ ] Sem complexidade desnecessária
- [ ] Refactoring completo (código limpo)

**Anti-patterns:**
- Escrever todo o código primeiro, depois rodar testes
- Gold-plating (adicionar features que não estão nos testes)
- Pular o passo de refactoring
- Commits grandes com muitas mudanças não relacionadas

**Referência:** [references/workflow/implementation.md](references/workflow/implementation.md)

---

### Fase 6: VALIDAR

**Objetivo:** Provar que o código funciona end-to-end, não apenas em testes unitários.

**Ações:**
- Executar a suíte completa de testes (unit + integration + e2e)
- Executar linters e type checkers (`ruff`, `mypy`, `biome`)
- Testar manualmente se aplicável (curl em endpoints, verificar UI)
- Verificar em um ambiente o mais próximo possível de produção
- Checar por regressões (algo mais quebrou?)

**Critérios de saída:**
- [ ] Todos os testes passando (unit, integration, e2e)
- [ ] Linters limpos (zero warnings)
- [ ] Type checker limpo
- [ ] Verificação manual feita (se aplicável)
- [ ] Nenhuma regressão introduzida

**Anti-patterns:**
- Declarar "pronto" sem rodar a suíte completa
- Ignorar warnings de linters
- Testar apenas o happy path manualmente
- Não checar por regressões

**Referência:** [references/workflow/validation.md](references/workflow/validation.md)

---

### Fase 7: REVISAR (Self-Check)

**Objetivo:** Capturar problemas ANTES de submeter para review.

**Ações:**
- Executar o checklist de self-check (veja seção 6)
- Revisar seu próprio diff como se você fosse o reviewer
- Atualizar documentação (CHANGELOG, README, API docs)
- Limpar commits (atômicos, bem descritos)
- Verificar que a branch está atualizada com a base

**Critérios de saída:**
- [ ] Checklist de self-check passou
- [ ] Documentação atualizada
- [ ] Commits limpos e atômicos
- [ ] Branch rebaseada na branch base
- [ ] Pronto para review

**Anti-patterns:**
- Submeter sem self-review
- Esquecer atualizações de documentação
- Histórico de commits bagunçado (WIP, fix, fix2, etc.)
- Submeter com CI falhando

**Referência:** [references/code-review/self-check.md](references/code-review/self-check.md)

---

## 2. Metodologia Test-First

### TDD (Test-Driven Development)

Centrado no desenvolvedor. Foco na implementação correta de unidades individuais.

**Ciclo:**
```
1. RED    — Write a failing test
2. GREEN  — Write the simplest code to pass
3. REFACTOR — Improve design, keep green
4. REPEAT
```

**Quando usar:**
- Lógica de negócio, algoritmos, transformações de dados
- Funções puras, código utilitário
- Qualquer código com inputs e outputs claros

**Regras chave:**
- Nunca escreva código de produção sem um teste falhando
- Escreva apenas código suficiente para passar o teste atual
- Refatore apenas quando verde
- Cada teste deve testar UM comportamento

**Referência:** [references/testing/tdd.md](references/testing/tdd.md)

### BDD (Behavior-Driven Development)

Centrado no usuário. Foco no comportamento do sistema pela perspectiva do usuário.
Usa linguagem natural (Given-When-Then) para descrever comportamento.

**Formato:**
```gherkin
Feature: User registration

  Scenario: Successful registration with valid email
    Given a new user with email "user@example.com"
    When they submit the registration form
    Then the account is created
    And a welcome email is sent

  Scenario: Registration fails with duplicate email
    Given an existing user with email "user@example.com"
    When a new user tries to register with "user@example.com"
    Then the registration is rejected with "Email already exists"
```

**Quando usar:**
- Features voltadas ao usuário
- Comunicação cross-functional (devs + produto + QA)
- Critérios de aceitação que precisam de validação de stakeholders
- Testes de contrato de API

**Referência:** [references/testing/bdd.md](references/testing/bdd.md)

### ATDD (Acceptance Test-Driven Development)

Combina TDD + BDD. Escreva testes de aceitação primeiro (estilo BDD),
depois implemente usando TDD para componentes internos.

**Workflow:**
```
1. Write acceptance test (BDD — Given/When/Then)
2. Run it — it fails (no implementation)
3. Use TDD to implement the internal components
4. Acceptance test passes — feature is done
```

**Quando usar:**
- Features complexas com múltiplos componentes
- Features que requerem aprovação de stakeholders
- API endpoints (aceitação = contrato de API, TDD = lógica interna)

**Referência:** [references/testing/atdd.md](references/testing/atdd.md)

### Abordagem combinada (recomendada)

```
BDD (acceptance layer)
 |
 +-- TDD (unit layer for each component)
```

- BDD captura O QUE o sistema deve fazer (perspectiva do usuário)
- TDD captura COMO cada unidade funciona (perspectiva do desenvolvedor)
- Ambos escritos ANTES da implementação

### TDD Assistido por IA (2025+)

IA acelera TDD sem substituir a disciplina:

| Estágio | Papel da IA |
|---------|-------------|
| Scaffolding de testes | Gerar estrutura inicial de teste a partir da assinatura da função |
| Edge cases | Sugerir cenários de canto que humanos perdem |
| Refactoring | Destacar testes redundantes, sugerir padrões mais limpos |
| Assertions | Sugerir assertions mais específicas |

**Regra:** IA gera, humano valida. Nunca aceite cegamente testes gerados por IA.

---

## 3. Workflow de Bug Fix

Todo bug fix segue um processo sistemático de 6 passos.

```
REPRODUCE > ISOLATE > WRITE TEST > FIX > VALIDATE > PREVENT
```

### Passo 1: REPRODUZIR

- Criar um caso de reprodução confiável
- Documentar passos exatos, inputs, ambiente
- Confirmar que o bug existe (não é erro do usuário ou dados desatualizados)
- Se não conseguir reproduzir, não consegue corrigir

### Passo 2: ISOLAR

- Estreitar o caminho de código afetado
- Usar busca binária (comentar código, bisect de commits)
- Identificar a causa raiz, não apenas o sintoma
- `git bisect` é seu amigo para bugs de regressão

```bash
# Find the commit that introduced the bug
git bisect start
git bisect bad HEAD
git bisect good v1.2.0
# Git will binary search through commits
# Test each one, mark good/bad
git bisect good  # or git bisect bad
# When found:
git bisect reset
```

### Passo 3: ESCREVER TESTE (antes de corrigir)

- Escrever um teste que reproduz o bug
- O teste DEVE falhar no código atual
- Esta é sua rede de segurança contra regressões
- Nomeie claramente: `test_<what>_when_<condition>_does_not_<bug_behavior>`

### Passo 4: CORRIGIR

- Corrigir a causa raiz, não o sintoma
- Alterar a quantidade mínima de código
- Não misture o fix com refactoring ou features

### Passo 5: VALIDAR

- Executar o teste que falhava — agora deve passar
- Executar a suíte completa de testes — sem regressões
- Testar manualmente se aplicável
- Testar o caso de reprodução original

### Passo 6: PREVENIR

- Adicionar o teste de regressão ao CI
- Considerar se a classe do bug precisa de uma regra de linter
- Documentar a causa raiz se não for óbvia
- Considerar se bugs similares existem em outros lugares

**Referência:** [references/workflow/bug-fix.md](references/workflow/bug-fix.md)

---

## 4. Metodologia de Refactoring

Refactoring muda a estrutura do código sem mudar o comportamento.
Sempre refatore com redes de segurança (testes). Nunca refatore sem testes.

### Quando refatorar

- Durante o passo REFACTOR do TDD (cada ciclo)
- Quando adicionar uma feature requer mudar código existente
- Quando code smells tornam a área difícil de entender
- Quando débito técnico está orçado no sprint
- NUNCA como um "sprint de refactoring" separado (integre no trabalho diário)

### Padrões chave

#### 4.1 Strangler Fig Pattern

**Quando:** Substituir um sistema/componente legado grande de forma incremental.

**Como:**
```
1. IDENTIFY the component to replace
2. CREATE the new implementation alongside the old one
3. ROUTE traffic/calls gradually to the new implementation
4. MONITOR both implementations in parallel
5. REMOVE the old implementation once the new one is proven
```

**Benefícios chave:**
- Zero risco de big-bang — rollback é sempre possível
- Cada passo de migração é pequeno e testável
- Validação em produção a cada passo

**Anti-patterns:**
- Tentar substituir tudo de uma vez
- Não monitorar a nova implementação em produção
- Deixar o código antigo para sempre (complete a migração)

#### 4.2 Branch by Abstraction

**Quando:** Refatorar componentes profundos no stack com dependências upstream.

**Como:**
```
1. IDENTIFY the component to refactor and its callers
2. CREATE an abstraction layer (interface/protocol) between callers and the component
3. CHANGE all callers to use the abstraction
4. CREATE the new implementation behind the abstraction
5. SWITCH the abstraction to use the new implementation
6. REMOVE the old implementation
```

**Benefícios chave:**
- Todas as mudanças acontecem no trunk (sem branches de longa duração)
- Callers desacoplados da implementação
- Pode trocar implementações com um flag

#### 4.3 Parallel Change (Expand-Migrate-Contract)

**Quando:** Mudar uma interface/API que tem múltiplos consumidores.

**Como:**
```
1. EXPAND  — Add the new interface alongside the old one
2. MIGRATE — Move consumers to the new interface one by one
3. CONTRACT — Remove the old interface once all consumers migrated
```

**Exemplo:**
```python
# Phase 1: EXPAND — add new method, keep old
class UserService:
    def get_user(self, user_id: int) -> dict:          # old
        ...
    def get_user_by_uuid(self, uuid: str) -> User:     # new
        ...

# Phase 2: MIGRATE — move callers to new method

# Phase 3: CONTRACT — remove old method
class UserService:
    def get_user_by_uuid(self, uuid: str) -> User:     # only new
        ...
```

#### 4.4 Mikado Method

**Quando:** Refactoring grande com dependências desconhecidas.

**Como:**
```
1. SET a refactoring goal
2. TRY to implement it directly
3. If it breaks things, NOTE the prerequisite
4. REVERT your change
5. IMPLEMENT the prerequisite first
6. TRY the goal again
7. REPEAT until the goal succeeds
```

Produz um grafo de dependências (Mikado Graph) das mudanças necessárias.

**Referência:** [references/refactoring/patterns.md](references/refactoring/patterns.md)

---

## 5. Decomposição de Features Grandes

### Vertical Slicing

**Princípio central:** Cada slice corta por TODAS as camadas (UI, API, lógica de negócio, dados)
e entrega valor visível ao usuário.

**Horizontal slice (RUIM):**
```
Sprint 1: Build database schema
Sprint 2: Build API endpoints
Sprint 3: Build frontend
Sprint 4: Integration testing
Sprint 5: Finally works end-to-end
```

**Vertical slice (BOM):**
```
Slice 1: User can create an account (simple form, one API, one table)
Slice 2: User can log in (auth flow end-to-end)
Slice 3: User can update profile (edit form, API, validation)
```

### Heurísticas de slicing

| Técnica | Descrição | Exemplo |
|---------|-----------|---------|
| **Por passo do workflow** | Cada passo de um processo vira um slice | Checkout: add to cart, enter address, pay |
| **Por regra de negócio** | Cada regra vira um slice | Pricing: base price, bulk discount, loyalty discount |
| **Por variação de dados** | Cada tipo de dado vira um slice | Import: CSV first, then Excel, then API |
| **Por operação** | Operações CRUD como slices separados | Users: create first, then read, update, delete |
| **Por persona** | Diferentes tipos de usuário como slices | Admin dashboard, then user dashboard |
| **Por critério de aceitação** | Cada critério vira um slice | Each Given/When/Then is a slice |

### Walking Skeleton

**Definição:** O slice mais fino possível de funcionalidade real que pode ser construído,
deployado e testado end-to-end.

**Propósito:**
- Valida a arquitetura cedo
- Estabelece o pipeline de deploy
- Cria a fundação para desenvolvimento incremental
- Reduz risco de incógnitas técnicas

**Características:**
- Corta por TODAS as camadas (UI até banco de dados)
- É deployável em produção (mesmo com feature flag)
- Tem testes automatizados
- Tem CI/CD configurado
- Leva no máximo 1-4 dias

**Exemplo — Walking skeleton de e-commerce:**
```
UI:       Single page with a "Buy" button and a product name
API:      POST /orders with hardcoded product
Business: Create order with fixed price
Database: orders table with id, product, status
Deploy:   Docker + CI + staging environment
Test:     E2E test: click Buy -> order created
```

Depois incremente: adicione catálogo de produtos, carrinho, pagamento, etc.

### Template de decomposição de feature

```markdown
## Feature: {name}

### Walking Skeleton (Slice 0)
- {thinnest end-to-end path}
- Target: {1-4 days}

### Slice 1: {name}
- User story: As a {persona}, I want {action}, so that {value}
- Acceptance criteria: Given {context}, When {action}, Then {result}
- Estimated: {days}

### Slice 2: {name}
...

### Out of scope (explicit)
- {what we are NOT building}
```

**Referência:** [references/feature-breakdown/vertical-slicing.md](references/feature-breakdown/vertical-slicing.md)

---

## 6. Self-Check de Code Review

**Antes de submeter código para review, execute este checklist você mesmo.**

O objetivo é capturar problemas óbvios antes de desperdiçar o tempo do reviewer.

### Corretude

- [ ] Código faz o que a ticket/issue pede
- [ ] Todos os critérios de aceitação atendidos
- [ ] Edge cases tratados
- [ ] Casos de erro tratados com mensagens apropriadas
- [ ] Sem erros de off-by-one
- [ ] Sem acesso a null/undefined sem guards

### Testes

- [ ] Todo código novo tem testes
- [ ] Testes são significativos (não apenas padding de cobertura)
- [ ] Testes cobrem happy path, edge cases, casos de erro
- [ ] Nomes dos testes descrevem comportamento
- [ ] Todos os testes passam localmente
- [ ] Nenhum teste flaky introduzido

### Qualidade de código

- [ ] Sem `TODO` ou `FIXME` sem issue linkada
- [ ] Sem código comentado
- [ ] Sem prints/logs de debug deixados
- [ ] Nomes de variáveis/funções são descritivos
- [ ] Funções são pequenas e focadas (responsabilidade única)
- [ ] Sem duplicação de código
- [ ] Type hints completos (Python) ou strict types (TypeScript)

### Segurança

- [ ] Sem secrets ou credenciais no código
- [ ] Input do usuário validado e sanitizado
- [ ] SQL injection prevenido (queries parametrizadas)
- [ ] Sem dados sensíveis em logs
- [ ] Checks de autenticação/autorização implementados

### Performance

- [ ] Sem queries N+1
- [ ] Sem chamadas de API desnecessárias em loops
- [ ] Recursos gerenciados adequadamente (connections, files, locks)
- [ ] Caching apropriado considerado

### Documentação

- [ ] CHANGELOG.md atualizado
- [ ] README.md atualizado (se mudanças voltadas ao usuário)
- [ ] Documentação de API atualizada (se endpoints mudaram)
- [ ] Comentários no código para lógica não óbvia
- [ ] Docstrings em funções/classes públicas

### Higiene de Git

- [ ] Commits são atômicos e bem descritos
- [ ] Sem merge commits (rebaseado na branch base)
- [ ] Sem mudanças não relacionadas misturadas
- [ ] Nome da branch segue convenção

**Referência:** [references/code-review/self-check.md](references/code-review/self-check.md)

---

## 7. Definition of Done

Uma tarefa só está "pronta" quando TODOS estes itens são verdadeiros.
Inegociável. Sem exceções.

### Código

- [ ] Implementação completa e funcionando
- [ ] Todos os testes passando (unit + integration + e2e onde aplicável)
- [ ] Linters limpos (zero warnings)
- [ ] Type checker limpo
- [ ] Nenhum novo débito técnico introduzido sem rastreamento

### Documentação

- [ ] CHANGELOG.md atualizado
- [ ] README.md atualizado (se aplicável)
- [ ] Docs de API atualizados (se aplicável)
- [ ] Decisão arquitetural registrada (se aplicável)

### Review

- [ ] Checklist de self-check passou
- [ ] Code review completo e aprovado
- [ ] Feedback de review endereçado

### Deploy

- [ ] Pipeline de CI verde
- [ ] Deployável para staging/produção
- [ ] Feature flag configurado (se rollout gradual)
- [ ] Monitoramento/alertas implementados (se novo serviço/endpoint)

### Aceitação

- [ ] Todos os critérios de aceitação verificados
- [ ] Testado manualmente (se aplicável)
- [ ] Nenhuma regressão introduzida

---

## 8. Gestão de Débito Técnico

### O Quadrante de Débito Técnico

Classifique débito em dois eixos: **deliberado vs inadvertido** e **prudente vs imprudente**.

```
                    Prudent                          Reckless
            +---------------------------+---------------------------+
Deliberate  | "We know this is a        | "We don't have time for   |
            |  shortcut and will fix    |  tests or design, just    |
            |  it next sprint"          |  ship it"                 |
            | ACTION: Track in backlog, | ACTION: Risk flag, demand |
            | schedule repayment date   | scope cut or more time    |
            +---------------------------+---------------------------+
Inadvertent | "Now we know how we       | "What's a design pattern?"|
            |  should have done it"     |                           |
            | ACTION: Schedule          | ACTION: Pair with senior  |
            | incremental refactors     | engineer, add automated   |
            | as knowledge improves     | tests, training           |
            +---------------------------+---------------------------+
```

### Regras de gestão

**1. Torne o débito visível**
- Toda atalho ganha uma ticket/issue com label `tech-debt`
- Inclua: o quê, por quê, impacto, esforço estimado para corrigir
- Linke à localização no código

**2. Reserve capacidade**
- Aloque 20-30% da capacidade do sprint para débito e trabalho de qualidade
- Times com débito imprudente alto podem precisar de 40-50% temporariamente
- Nunca zero — débito é composto

**3. Priorize por impacto**
- Caminhos de código de alto tráfego primeiro
- Código que muda frequentemente primeiro
- Débito relacionado a segurança é sempre P0

**4. Pague incrementalmente**
- Boy Scout Rule: deixe o código mais limpo do que encontrou
- Anexe pequenos fixes de débito a trabalho de features relacionadas
- Evite "sprints de refactoring" — eles nunca terminam

**5. Previna novo débito**
- Code review captura débito imprudente
- Linters e type checkers capturam débito inadvertido
- Reviews de arquitetura capturam débito estratégico

**Referência:** [references/technical-debt/quadrant.md](references/technical-debt/quadrant.md)

---

## 9. Pair e Mob Programming

### Pair Programming

Dois desenvolvedores, um computador. Dois papéis que alternam frequentemente.

**Driver:** Escreve o código. Focado na linha atual.
**Navigator:** Pensa na direção, captura erros, considera o quadro geral.

**Quando fazer pair:**
- Onboarding de novos membros do time
- Código complexo ou arriscado
- Debugar issues difíceis de reproduzir
- Compartilhamento de conhecimento
- Quando travado por mais de 30 minutos

**Estilos:**

| Estilo | Como funciona | Melhor para |
|--------|--------------|-------------|
| **Driver-Navigator** | Clássico: um digita, outro guia | Desenvolvimento geral |
| **Ping-Pong** | A escreve teste, B implementa, alterna | TDD, aprendizado |
| **Strong-Style** | Navigator dita cada tecla | Ensino, onboarding |

**Regras:**
- Alterne papéis a cada 15-25 minutos (use um timer)
- Navigator NÃO pega o teclado
- Faça pausas — pairing é intenso
- Ambos os nomes no commit

### Mob Programming

Time inteiro, um computador. Um driver, todos os outros navegam.

**Quando fazer mob:**
- Decisões arquiteturais críticas
- Trabalho de integração complexo
- Alinhamento do time em padrões
- Spikes e discovery

**Regras:**
- Rotacione o driver a cada 10-15 minutos
- Driver só escreve o que o mob diz
- Todos participam (sem espectadores)
- "Sim, e..." ao invés de "Não, mas..."
- Pausas a cada 50 minutos

**Referência:** [references/workflow/pairing.md](references/workflow/pairing.md)

---

## 10. Disciplina de CI

### Disciplina de commits

**Commits atômicos:**
- Cada commit faz UMA coisa
- Cada commit compila e passa nos testes
- Cada commit tem uma mensagem clara

**Formato de mensagem de commit:**
```
<type>: <short description>

<optional body explaining WHY, not WHAT>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

**Anti-patterns:**
- `WIP`, `fix`, `fix2`, `final`, `final2`
- Commits que quebram o build
- Commits misturando mudanças não relacionadas
- Commits gigantes com 500+ linhas alteradas

### Disciplina de branches

- Feature branches: `feat/<name>`
- Bug fix branches: `fix/<name>`
- Refactor branches: `refactor/<name>`
- De curta duração: merge em 1-3 dias
- Nunca commite em uma branch com PR aberto em review

### Expectativas do pipeline de CI

```
Every push triggers:
  1. Lint (ruff/biome)        — < 30s
  2. Type check (mypy/tsc)    — < 60s
  3. Unit tests               — < 2min
  4. Integration tests        — < 5min
  5. Build                    — < 2min
  ──────────────────────────
  Total: < 10min target
```

### Regras de build verde

- Um build quebrado é a prioridade máxima do time
- A pessoa que quebrou corrige imediatamente
- Se não conseguir corrigir em 10 minutos, reverta
- Nunca faça merge no vermelho
- Nunca adicione "skip CI" sem justificativa

### Princípios de feedback rápido

- Falhe rápido: linters e type checks rodam primeiro
- Paralelize: suítes de teste independentes rodam concorrentemente
- Cache: dependências e artefatos de build cacheados
- Seletivo: rode apenas testes afetados quando possível
- Local: desenvolvedores podem rodar o pipeline completo localmente

**Referência:** [references/ci/discipline.md](references/ci/discipline.md)

---

## Integração de Workflow com Outras Skills

Esta skill define o PROCESSO. Outras skills definem as FERRAMENTAS e PADRÕES.

| Fase | Esta Skill | Outras Skills |
|------|-----------|---------------|
| QUESTIONAR | Como questionar | — |
| PESQUISAR | Quando pesquisar | `ai-engineer` (padrões de IA) |
| PROJETAR | Metodologia de design | `arch-py` / `arch-ts` (padrões) |
| TESTAR | Processo TDD/BDD | `arch-py` (pytest), `arch-ts` (vitest) |
| IMPLEMENTAR | RED-GREEN-REFACTOR | `arch-py` / `arch-ts` (padrões de código) |
| VALIDAR | Checklist de validação | `arch-py` (ruff/mypy), `arch-ts` (biome) |
| REVISAR | Processo de self-check | `review-py` / `review-ts` (critérios de review) |

---

## Referências

### Workflow
- [references/workflow/questioning.md](references/workflow/questioning.md) - Técnicas de questionamento profundo
- [references/workflow/research.md](references/workflow/research.md) - Metodologia de pesquisa
- [references/workflow/design.md](references/workflow/design.md) - Documentação de design
- [references/workflow/implementation.md](references/workflow/implementation.md) - Disciplina de implementação
- [references/workflow/validation.md](references/workflow/validation.md) - Checklist de validação
- [references/workflow/bug-fix.md](references/workflow/bug-fix.md) - Processo sistemático de bug fix
- [references/workflow/pairing.md](references/workflow/pairing.md) - Pair e mob programming

### Testes
- [references/testing/test-first.md](references/testing/test-first.md) - Princípios test-first
- [references/testing/tdd.md](references/testing/tdd.md) - TDD em profundidade
- [references/testing/bdd.md](references/testing/bdd.md) - BDD com Given-When-Then
- [references/testing/atdd.md](references/testing/atdd.md) - Acceptance TDD

### Refactoring
- [references/refactoring/patterns.md](references/refactoring/patterns.md) - Strangler fig, branch by abstraction, parallel change, Mikado

### Decomposição de Features
- [references/feature-breakdown/vertical-slicing.md](references/feature-breakdown/vertical-slicing.md) - Vertical slicing e walking skeleton

### Code Review
- [references/code-review/self-check.md](references/code-review/self-check.md) - Checklist pré-submissão

### CI
- [references/ci/discipline.md](references/ci/discipline.md) - Disciplina de CI e higiene de commits

### Débito Técnico
- [references/technical-debt/quadrant.md](references/technical-debt/quadrant.md) - Modelo de quadrante e gestão

### Fontes Externas
- [TDD vs BDD vs DDD in 2025](https://medium.com/@sharmapraveen91/tdd-vs-bdd-vs-ddd-in-2025-choosing-the-right-approach-for-modern-software-development-6b0d3286601e)
- [Test-Driven Development Guide 2025](https://www.nopaccelerate.com/test-driven-development-guide-2025/)
- [Strangler Fig Pattern](https://www.gocodeo.com/post/how-the-strangler-fig-pattern-enables-safe-and-gradual-refactoring)
- [Branch by Abstraction - AWS](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-decomposing-monoliths/branch-by-abstraction.html)
- [Vertical Slicing - Walking Skeleton](https://blog.devgenius.io/red-loop-part-5-vertical-slice-walking-skeleton-c75e2003fe2c)
- [Technical Debt Quadrant](https://scalablehuman.com/2025/08/25/exploring-the-technical-debt-quadrant-strategies-for-managing-software-debt/)
- [Trunk-Based Development](https://trunkbaseddevelopment.com/)
- [DORA Capabilities: Trunk-based Development](https://dora.dev/capabilities/trunk-based-development/)
