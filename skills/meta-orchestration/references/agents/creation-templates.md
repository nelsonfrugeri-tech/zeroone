# Templates de Criação de Agents

## Estrutura do Arquivo

```markdown
---
name: <agent-name>
description: >
  <personalidade e caso de uso, 1-2 frases>
tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch
model: sonnet
permissionMode: bypassPermissions
isolation: worktree
---

# <Agent Name>

## Personalidade
- <traço 1>
- <traço 2>

## Comportamento
- <o que faz>
- <como entrega>

## Quando usar
- <caso de uso 1>
- <caso de uso 2>
```

## Checklist de Criação
- [ ] Arquivo em `~/.claude/agents/<name>.md`
- [ ] Frontmatter com `name`, `description`, `tools`, `model`, `isolation: worktree`
- [ ] **Sem `skills:`** no frontmatter (skills são globais)
- [ ] **Zero conhecimento técnico** — apenas personalidade e comportamento
- [ ] Descrição clara para dynamic discovery
- [ ] Não sobrepõe agents existentes
- [ ] Model adequado: `haiku` (trivial), `sonnet` (maioria), `opus` (crítico)

## Convenção de Nomes
- Lowercase, com underscore se necessário: `my_agent`, `code_reviewer`, `infra_ops`
- Nome reflete a persona, não a implementação
- Evitar nomes genéricos: `helper`, `assistant`, `worker`

## Anti-patterns
- Embutir conhecimento técnico no arquivo do agent (use skills)
- Dar todas as tools a todos os agents (princípio do mínimo privilégio)
- Criar agents para tarefas únicas (use inline prompts)
- Duplicar personalidade entre agents
