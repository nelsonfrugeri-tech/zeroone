---
name: review-py
description: |
  Baseline de conhecimento para code review Python: templates de comentários, checklist de verificação,
  critérios de severidade e decisão. Referência de padrões e qualidade de review.
  Integra com arch-py skill para referenciar best practices técnicas.
  Use quando: (1) Precisar de templates de comentários, (2) Consultar checklist de review, (3) Classificar severidade de issues.
  Triggers: review-py skill, templates de review, critérios de severidade.
---

# Review-Py Skill - Python Code Review Knowledge Base

## Propósito

Esta skill é uma **biblioteca de conhecimento** para code review Python. Provê padrões, templates e critérios para reviews sistemáticos de código Python.

**Skill global** — carregada automaticamente por todos os agents.

**O que esta skill contém:**
- Templates de comentários por severidade e categoria
- Checklist de verificação (o que revisar em cada arquivo)
- Critérios de classificação de severidade
- Critérios de decisão final (aprovar, bloquear, aprovar com ressalvas)
- Exemplos de comentários bem formatados

---

## Estrutura da Skill

### Assets (Templates)

Templates markdown com placeholders que devem ser preenchidos:

| Arquivo | Propósito | Quando Usar |
|---------|-----------|-------------|
| `assets/comment.md` | Template de comentário individual | Ao gerar cada comentário de review |
| `assets/summary.md` | Template de análise de impacto | Ao gerar summary de mudanças |
| `assets/report.md` | Template de relatório completo | Ao gerar relatório final consolidado |

**Como usar:**
1. Leia o template com `view assets/{template}.md`
2. Identifique os placeholders `{placeholder_name}`
3. Substitua todos os placeholders por valores reais
4. Apresente o resultado final formatado

### References (Documentação)

Documentação de referência para consulta:

| Arquivo | Propósito | Quando Usar |
|---------|-----------|-------------|
| `references/checklist.md` | Checklist lean de review com ponteiros para arch-py | Durante review de cada arquivo |
| `references/templates.md` | Exemplos de comentários por tipo de issue | Ao gerar comentários, para inspiração |
| `references/git.md` | Comandos git úteis e workflows | Quando precisar de comandos git específicos |

### Scripts (Ferramentas)

Scripts Python auxiliares (executados pelo agent):

| Script | Propósito | Output |
|--------|-----------|--------|
| `scripts/analyze_diff.py` | Análise automática de diffs, detecção de padrões | JSON com métricas, features, alertas |
| `scripts/format_output.py` | Formatação de JSON em markdown usando templates | Arquivo markdown formatado |

---

## Templates de Comentários

### Template Base

Use para comentários detalhados:

````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** {emoji} {categoria}
**Severidade:** {emoji} {severidade}

**Issue:**
{descrição clara e objetiva do problema em 1-2 frases}

**Código Atual:**
```python
{código problemático extraído do diff}
```

**Código Sugerido:**
```python
{código corrigido}
```

**Justificativa:**
{explicação técnica do porquê isso é um problema}
{impacto se não corrigir}

**Referência:**
- Arch-Py Skill: [{arquivo}](../arch-py/{caminho})
{outras referências se aplicável}
````

### Categorias e Emojis

Use estas categorias:
- 🔒 **Security** - Vulnerabilidades, secrets, injeções
- ⚡ **Performance** - N+1 queries, algoritmos ineficientes
- 🧪 **Testing** - Falta de testes, assertions fracas
- 📝 **Documentation** - Docstrings, comentários
- ⚙️ **Code Quality** - Type hints, naming, complexidade
- 🏗️ **Architecture** - SOLID, patterns, acoplamento

### Severidades e Emojis

Use estas severidades:
- 🔴 **Critical** - Vulnerabilidades, secrets expostos, data loss
- 🟠 **High** - Performance grave, bugs sérios, falta testes críticos
- 🟡 **Medium** - Code quality, type hints, naming
- 🟢 **Low** - Sugestões de melhoria
- ℹ️ **Info** - Contexto adicional

---

## Checklist de Review

Para cada arquivo Python, verificar:

### 🔒 Security
- [ ] Secrets não hardcodados
- [ ] Input externo validado
- [ ] SQL injection prevenido
- [ ] Autenticação/autorização correta
- [ ] Dados sensíveis não em logs

**Severidade típica:** 🔴 Critical
**Referência:** `references/checklist.md` (completo)

### ⚡ Performance
- [ ] Sem N+1 queries
- [ ] Algoritmos eficientes
- [ ] Resources gerenciados (context managers)

**Severidade típica:** 🟠 High (hot path) / 🟡 Medium
**Referência:** `references/checklist.md`

### 🧪 Testing
- [ ] Código crítico tem testes
- [ ] Testes não frágeis
- [ ] Assertions específicas

**Severidade típica:** 🔴 Critical (sem testes) / 🟠 High (<50% coverage)
**Referência:** `references/checklist.md`

### ⚙️ Code Quality
- [ ] Type hints presentes
- [ ] Error handling adequado
- [ ] Logging estruturado
- [ ] Docstrings em APIs públicas
- [ ] Naming descritivo
- [ ] Single Responsibility Principle
- [ ] DRY (código não duplicado)
- [ ] Complexidade ciclomática razoável
- [ ] Imports organizados

**Severidade típica:** 🟡 Medium / 🟠 High (APIs públicas)
**Referência:** `references/checklist.md`

### 🏗️ Architecture
- [ ] Separação de concerns
- [ ] Dependency injection
- [ ] Dependências versionadas
- [ ] Async/await usado corretamente

**Severidade típica:** 🟡 Medium / 🟠 High (violação grave)
**Referência:** `references/checklist.md`

**Checklist completo:** Consulte `references/checklist.md` para todos os 25 checks detalhados com ponteiros para arch-py skill.

---

## Critérios de Severidade

### 🔴 Critical

**Quando usar:**
- Vulnerabilidades de segurança
- Secrets hardcoded
- SQL injection, XSS, injeções
- Data loss potencial
- Bypass de autenticação/autorização

**Características:**
- Pode causar comprometimento do sistema
- Deve bloquear merge imediatamente
- Requer correção urgente

**Template:**
```markdown
**Ação Requerida:** Bloqueia merge. Deve ser corrigido imediatamente.

**Impacto:**
- {consequência grave 1}
- {consequência grave 2}
```

### 🟠 High

**Quando usar:**
- Performance grave (N+1 queries em hot path)
- Bugs que afetam funcionalidade core
- Falta de testes em código crítico
- Memory leaks
- Error handling inadequado em operações críticas

**Características:**
- Impacta produção se não corrigido
- Deve corrigir antes de merge ou logo após
- Cria débito técnico significativo

**Template:**
```markdown
**Ação Requerida:** Deve corrigir antes de merge.

**Impacto:** {impacto em produção se não corrigir}
```

### 🟡 Medium

**Quando usar:**
- Type hints faltando
- Naming não descritivo
- Code quality issues
- Complexidade alta
- Docstrings ausentes em funções importantes

**Características:**
- Não bloqueia merge
- Deve corrigir em breve
- Afeta manutenibilidade

**Template:**
```markdown
**Justificativa:**
{explicação do porquê isso é importante}

**Referência:**
- Arch-Py Skill: [{arquivo}](../arch-py/{caminho})
```

### 🟢 Low

**Quando usar:**
- Pequenas otimizações
- Sugestões de melhoria
- Imports não usados
- Formatação

**Características:**
- Nice to have
- Pode corrigir depois
- Melhoria incremental

### ℹ️ Info

**Quando usar:**
- Contexto adicional
- FYI sobre patterns alternativos
- Notas sobre comportamento

**Características:**
- Não requer ação
- Informativo apenas

---

## Critérios de Decisão Final

Use estes critérios para determinar a recomendação final do review:

### ❌ Não Aprovar (Block Merge)

**Condição:** 1+ issues **Critical** presentes

**Exemplos:**
- Secrets hardcoded
- SQL injection
- Vulnerabilidades de segurança
- Data loss potencial

**Ação:** Merge deve ser bloqueado até correção

**Template:**
```markdown
**Recomendação:** ❌ Não aprovar

**Justificativa:** Encontrados {n} issues Critical que devem ser corrigidos antes do merge:
- {issue 1}
- {issue 2}
```

### ⚠️ Aprovar com Ressalvas

**Condição:**
- 0 issues Critical
- 1+ issues **High** presentes

**Exemplos:**
- N+1 queries
- Falta de testes em código importante
- Performance grave
- Bugs não críticos

**Ação:** Pode mergear, mas deve corrigir antes de produção. Criar tasks/tickets para correção.

**Template:**
```markdown
**Recomendação:** ⚠️ Aprovar com ressalvas

**Justificativa:** Encontrados {n} issues High que devem ser corrigidos antes de produção:
- {issue 1}
- {issue 2}

Sugestão: criar tasks para correção pós-merge.
```

### ✅ Aprovar

**Condição:**
- 0 issues Critical
- 0 issues High
- Apenas Medium, Low, e/ou Info

**Ação:** Pode mergear normalmente. Issues menores podem ser corrigidos posteriormente.

**Template:**
```markdown
**Recomendação:** ✅ Aprovar

**Justificativa:** Nenhum issue bloqueante encontrado. Issues Medium/Low podem ser endereçados posteriormente como melhoria contínua.
```

### 🎉 Aprovação com Elogios

**Condição:**
- Poucos ou zero issues (apenas Low/Info)
- Código de alta qualidade
- Boas práticas seguidas consistentemente

**Ação:** Destacar qualidade do trabalho

**Template:**
```markdown
**Recomendação:** 🎉 Aprovar com elogios

**Justificativa:** Código de excelente qualidade. Padrões seguidos consistentemente. Poucos issues menores identificados.

**Destaques:**
- {destaque 1}
- {destaque 2}
```

---

## Integração com Arch-Py Skill

Sempre que identificar violação de padrão Python, referencie a arch-py skill:

### Exemplos de Referências

**Type hints faltando:**
```markdown
**Referência:**
- Arch-Py Skill: [references/python/type-system.md](../arch-py/references/python/type-system.md)
```

**Error handling inadequado:**
```markdown
**Referência:**
- Arch-Py Skill: [references/python/error-handling.md](../arch-py/references/python/error-handling.md)
```

**Async usado incorretamente:**
```markdown
**Referência:**
- Arch-Py Skill: [references/python/async-patterns.md](../arch-py/references/python/async-patterns.md)
```

**Pydantic patterns errados:**
```markdown
**Referência:**
- Arch-Py Skill: [references/python/pydantic.md](../arch-py/references/python/pydantic.md)
```

**Falta de testes:**
```markdown
**Referência:**
- Arch-Py Skill: [references/testing/pytest.md](../arch-py/references/testing/pytest.md)
```

**Arquitetura acoplada:**
```markdown
**Referência:**
- Arch-Py Skill: [references/architecture/clean-architecture.md](../arch-py/references/architecture/clean-architecture.md)
```

---

## Estrutura de Arquivos da Skill

```
review-py/
├── SKILL.md                          (este arquivo - conhecimento declarativo)
├── references/
│   ├── checklist.md                 (checklist completo com 25 checks)
│   ├── templates.md                 (exemplos de comentários por tipo de issue)
│   └── git.md                       (comandos git úteis)
├── scripts/
│   ├── analyze_diff.py              (parser de git diff + detecção de padrões)
│   └── format_output.py             (formatador de output markdown)
└── assets/
    ├── comment.md                   (template de comentário individual)
    ├── summary.md                   (template de análise de impacto)
    └── report.md                    (template de relatório completo)
```

---

## Guia Rápido: Quando Consultar Cada Arquivo

### Durante Reviews

| Momento | Arquivo | O que consultar |
|---------|---------|-----------------|
| Gerando comentário individual | `assets/comment.md` | Template base com placeholders |
| Gerando análise de impacto | `assets/summary.md` | Template de summary |
| Gerando relatório completo | `assets/report.md` | Template de relatório |
| Revisando arquivo Python | `references/checklist.md` | Lista dos 25 checks a fazer |
| Precisando de exemplos | `references/templates.md` | Comentários prontos por tipo |
| Precisando de comando git | `references/git.md` | Comandos git úteis |

### Para Você Diretamente

Se você está fazendo review manualmente:
1. Use `references/checklist.md` como guia do que verificar
2. Consulte `references/templates.md` para ver exemplos de comentários bem formatados
3. Use os critérios de severidade desta skill para classificar issues
4. Use os critérios de decisão final para determinar se aprova ou bloqueia

---

## Referências

### Arquivos desta Skill
- [references/checklist.md](references/checklist.md) - Checklist completo de review (25 checks)
- [references/templates.md](references/templates.md) - Templates e exemplos de comentários por tipo de issue
- [references/git.md](references/git.md) - Comandos Git e workflows

### Assets (Templates)
- [assets/comment.md](assets/comment.md) - Template de comentário individual
- [assets/summary.md](assets/summary.md) - Template de análise de impacto
- [assets/report.md](assets/report.md) - Template de relatório completo

### Scripts
- [scripts/analyze_diff.py](scripts/analyze_diff.py) - Análise automática de diffs
- [scripts/format_output.py](scripts/format_output.py) - Formatação de output

### Arch-Py Skill (Padrões Técnicos Python)
- [../arch-py/SKILL.md](../arch-py/SKILL.md) - Arch-Py skill principal
- [../arch-py/references/python/](../arch-py/references/python/) - Padrões Python (type system, async, Pydantic, error handling, etc.)
- [../arch-py/references/testing/](../arch-py/references/testing/) - Padrões de testes (pytest, fixtures, mocking)
- [../arch-py/references/architecture/](../arch-py/references/architecture/) - Arquitetura (clean architecture, DI, repository pattern)

### Output Gerado (pelo Agent)
- `review-output.md` - Arquivo final salvo na raiz do projeto (copy-paste ready para PRs)
