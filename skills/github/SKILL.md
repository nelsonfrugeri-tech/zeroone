---
name: github
description: |
  Skill de operações GitHub — OBRIGATÓRIA para qualquer escrita no GitHub (PRs, issues, comments).
  Força o uso do MCP github server (tools mcp__github__*). NUNCA usar curl, gh CLI, ou urllib para GitHub.
  Cada agent autentica via seu próprio GitHub App registrado em env vars.
  Validações embutidas: CHANGELOG obrigatório, README warning, API collections warning.
  Triggers: /github, criar PR, abrir issue, comentar PR, GitHub operations.
---

# GitHub Skill — Operações GitHub via MCP

## Regra Fundamental

**TODA operação de escrita no GitHub DEVE usar as tools `mcp__github__*`.**

Isso é **inegociável**. As tools MCP:
- Autenticam via GitHub App do agent (identidade do bot, não do usuário)
- Validam documentação antes de criar PRs
- Garantem rastreabilidade

### PROIBIDO
- `curl` para GitHub API
- `gh` CLI para escrita
- `urllib`/`httpx`/`requests` direto para GitHub API
- Qualquer bypass das tools MCP

### PERMITIDO
- `gh` CLI apenas para **leitura** (status, diff, log)
- Tools `mcp__github__*` para **toda escrita**

---

## Tools Disponíveis

| Tool | Quando usar |
|------|-------------|
| `mcp__github__github_create_pr` | Abrir Pull Request |
| `mcp__github__github_create_issue` | Criar issue |
| `mcp__github__github_add_comment` | Comentar em issue/PR |
| `mcp__github__github_close_pr` | Fechar PR |
| `mcp__github__github_list_issues` | Listar issues |

---

## Identificação do Agent

Cada agent tem seu próprio GitHub App registrado em `env vars`.
O parâmetro `agent_name` é **obrigatório** em todas as tools de escrita.

O agent DEVE usar seu próprio nome. Exemplos:
- Oracle → `agent_name: "oracle"`
- Mr. Robot → `agent_name: "mr-robot"`
- Elliot → `agent_name: "elliot"`
- Tyrell → `agent_name: "tyrell"`

GitHub App credentials are configured via environment variables in `.mcp.json`:
- `GITHUB_APP_ID` — GitHub App ID
- `GITHUB_APP_PEM_PATH` — Path to the App's private key PEM file
- `GITHUB_APP_INSTALLATION_ID` — Installation ID for the target org/user
- `GITHUB_APP_SLUG` — App slug (bot identity in responses)

---

## Workflow: Criar PR

### Pré-requisitos (o agent DEVE verificar antes)
1. Branch criada a partir da main
2. Alterações commitadas
3. Branch pushed para remote
4. **CHANGELOG.md atualizado** (obrigatório — a tool bloqueia se ausente)
5. **README.md revisado** (warning se não atualizado)
6. **API collections revisadas** se existirem no projeto (Postman/Insomnia/Bruno)

### Chamada
```
mcp__github__github_create_pr(
  repo="owner/repo",
  title="tipo: descrição curta",
  body="## Summary\n- bullet points\n\n## Test plan\n- [ ] ...",
  head="branch-name",
  agent_name="oracle",
  project_dir="/path/to/project"  ← OBRIGATÓRIO para validação
)
```

### Se a tool retornar `status: "blocked"`
A tool bloqueou porque falta documentação. O agent DEVE:
1. Ler os `errors` retornados
2. Atualizar os arquivos indicados (CHANGELOG, etc.)
3. Commitar as atualizações
4. Tentar novamente

### Formato do body do PR
```markdown
## Summary
- Bullet points descrevendo o que foi feito

## Test plan
- [ ] Como testar

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Workflow: Criar Issue

```
mcp__github__github_create_issue(
  repo="owner/repo",
  title="tipo: descrição",
  body="## Contexto\n...\n\n## Acceptance Criteria\n- [ ] ...",
  labels="bug,priority:high",
  agent_name="oracle"
)
```

---

## Workflow: Comentar em PR/Issue

```
mcp__github__github_add_comment(
  repo="owner/repo",
  issue_number=10,
  body="Review comment here",
  agent_name="oracle"
)
```

---

## Convenções

### Títulos de PR
- `feat: nova funcionalidade`
- `fix: correção de bug`
- `chore: manutenção, cleanup`
- `docs: documentação`
- `refactor: refatoração sem mudança de comportamento`

### Nunca
- Push direto na main
- PR no nome pessoal do usuário (sempre via App)
- Criar PR sem CHANGELOG atualizado
- Ignorar warnings de README e API collections
