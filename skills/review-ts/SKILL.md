---
name: review-ts
description: |
  Baseline de conhecimento para code review TypeScript/Frontend: templates de comentários, checklist de verificação,
  critérios de severidade e decisão. Referência de padrões e qualidade de review.
  Integra com arch-ts skill para referenciar best practices técnicas.
  Use quando: (1) Precisar de templates de comentários frontend, (2) Consultar checklist de review TS/React, (3) Classificar severidade de issues.
  Triggers: review-ts skill, templates de review frontend, critérios de severidade frontend.
---

# Review-Ts Skill - TypeScript/Frontend Code Review Knowledge Base

## Propósito

Esta skill é uma **biblioteca de conhecimento** para code review TypeScript/Frontend. Provê padrões, templates e critérios para reviews sistemáticos de código TypeScript/Frontend.

**O que esta skill contem:**
- Templates de comentários por severidade e categoria
- Checklist de verificação (o que revisar em cada arquivo TS/TSX)
- Critérios de classificação de severidade
- Critérios de decisão final (aprovar, bloquear, aprovar com ressalvas)
- Exemplos de comentários bem formatados para issues frontend

---

## Estrutura da Skill

### Assets (Templates)

Templates markdown com placeholders que devem ser preenchidos:

| Arquivo | Propósito | Quando Usar |
|---------|-----------|-------------|
| `assets/comment.md` | Template de comentário individual | Ao gerar cada comentário de review |
| `assets/summary.md` | Template de análise de impacto | Ao gerar summary de mudancas |
| `assets/report.md` | Template de relatório completo | Ao gerar relatório final consolidado |

**Como usar:**
1. Leia o template com `view assets/{template}.md`
2. Identifique os placeholders `{placeholder_name}`
3. Substitua todos os placeholders por valores reais
4. Apresente o resultado final formatado

### References (Documentacao)

Documentacao de referencia para consulta:

| Arquivo | Propósito | Quando Usar |
|---------|-----------|-------------|
| `references/checklist.md` | Checklist de review com 28+ checks para TS/React/Next.js | Durante review de cada arquivo |
| `references/templates.md` | Exemplos de comentários por tipo de issue frontend | Ao gerar comentários, para inspiracao |
| `references/git.md` | Comandos git uteis incluindo análise de bundle e TypeScript | Quando precisar de comandos git específicos |

---

## Templates de Comentarios

### Template Base

Use para comentários detalhados:

````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** {emoji} {categoria}
**Severidade:** {emoji} {severidade}

**Issue:**
{descrição clara e objetiva do problema em 1-2 frases}

**Codigo Atual:**
```tsx
{código problematico extraido do diff}
```

**Codigo Sugerido:**
```tsx
{código corrigido}
```

**Justificativa:**
{explicacao tecnica do porque isso é um problema}
{impacto se não corrigir}

**Referência:**
- Arch-Ts Skill: [{arquivo}](../arch-ts/{caminho})
{outras referências se aplicável}
````

### Categorias e Emojis

Use estas categorias:
- 🔒 **Security** - XSS, CSRF, dangerouslySetInnerHTML, env vars expostas, auth bypass
- ⚡ **Performance** - Bundle size, re-renders desnecessários, Core Web Vitals, lazy loading
- ♿ **Accessibility** - ARIA, semantic HTML, keyboard nav, focus management, color contrast
- 🧪 **Testing** - Falta de testes de componentes, hooks, E2E, accessibility tests
- ⚙️ **Code Quality** - TypeScript strict, `any` types, naming, component size, proper typing
- 🏗️ **Architecture** - Component composition, state management, server/client boundary, data fetching
- 🎨 **Styling** - Tailwind consistency, responsive, dark mode, design tokens

### Severidades e Emojis

Use estas severidades:
- 🔴 **Critical** - XSS, secrets expostas no client, auth bypass, data leak
- 🟠 **High** - Performance grave, bundle bloat, missing error boundaries, a11y blockers
- 🟡 **Medium** - Code quality, `any` types, missing tests, naming
- 🟢 **Low** - Sugestões de melhoria, styling consistency
- ℹ️ **Info** - Contexto adicional

---

## Checklist de Review

Para cada arquivo TypeScript/TSX, verificar:

### 🔒 Security
- [ ] Sem secrets/API keys no client-side code
- [ ] dangerouslySetInnerHTML sanitizado
- [ ] Input externo validado (Zod/Pydantic)
- [ ] CSRF tokens em forms
- [ ] Env vars prefixadas corretamente (NEXT_PUBLIC_ apenas para públicas)

**Severidade típica:** 🔴 Critical
**Referência:** `references/checklist.md` (completo)

### ♿ Accessibility
- [ ] ARIA labels em elementos interativos
- [ ] Semantic HTML (nav, main, article, section)
- [ ] Keyboard navigation funcional
- [ ] Focus management em modais/drawers
- [ ] Color contrast WCAG AA (4.5:1)
- [ ] Alt text em imagens

**Severidade típica:** 🟠 High (bloqueadores a11y) / 🟡 Medium
**Referência:** `references/checklist.md`

### ⚡ Performance
- [ ] Sem imports desnecessários aumentando bundle
- [ ] React.memo/useMemo/useCallback onde aprópriado
- [ ] Images otimizadas (next/image, WebP, lazy loading)
- [ ] Dynamic imports para code splitting
- [ ] Sem re-renders desnecessários (keys estáveis, state lifting)
- [ ] Core Web Vitals considerados (LCP, FID, CLS)

**Severidade típica:** 🟠 High (bundle bloat) / 🟡 Medium
**Referência:** `references/checklist.md`

### 🧪 Testing
- [ ] Componentes críticos tem testes
- [ ] Hooks customizados testados
- [ ] User interactions testadas (click, type, submit)
- [ ] Accessibility tests (axe-core)
- [ ] Error states e loading states testados

**Severidade típica:** 🔴 Critical (sem testes) / 🟠 High (<50% coverage)
**Referência:** `references/checklist.md`

### ⚙️ Code Quality
- [ ] TypeScript strict (no `any`, proper generics)
- [ ] Props tipadas com interfaces/types
- [ ] Error handling com Error Boundaries
- [ ] Naming descritivo (components PascalCase, hooks useX)
- [ ] Componentes < 200 linhas
- [ ] Single Responsibility
- [ ] DRY (sem duplicacao)

**Severidade típica:** 🟡 Medium / 🟠 High (APIs públicas)
**Referência:** `references/checklist.md`

### 🏗️ Architecture
- [ ] Separacao Server Components vs Client Components
- [ ] "use client" apenas onde necessário
- [ ] State management justificado (local vs global)
- [ ] Data fetching no servidor quando possível
- [ ] Component composition sobre inheritance
- [ ] Proper use of React Server Actions

**Severidade típica:** 🟡 Medium / 🟠 High (violação grave)
**Referência:** `references/checklist.md`

### 🎨 Styling
- [ ] Tailwind classes consistentes
- [ ] Responsive design (mobile-first)
- [ ] Dark mode suportado se aplicável
- [ ] Design tokens usados (cores, spacing, tipografia)
- [ ] Sem estilos inline desnecessários

**Severidade típica:** 🟢 Low / 🟡 Medium
**Referência:** `references/checklist.md`

**Checklist completo:** Consulte `references/checklist.md` para todos os 28 checks detalhados com ponteiros para arch-ts skill.

---

## Critérios de Severidade

### 🔴 Critical

**Quando usar:**
- XSS via dangerouslySetInnerHTML sem sanitização
- Secrets/API keys expostas no client bundle
- Auth bypass ou token leak
- Data leak em Server Components para Client Components
- Server Actions sem validação

**Caracteristicas:**
- Pode causar comprometimento do sistema ou dados do usuário
- Deve bloquear merge imediatamente
- Requer correcao urgente

**Template:**
```markdown
**Acao Requerida:** Bloqueia merge. Deve ser corrigido imediatamente.

**Impacto:**
- {consequencia grave 1}
- {consequencia grave 2}
```

### 🟠 High

**Quando usar:**
- Bundle size explodindo (importando biblioteca inteira sem tree-shaking)
- Missing Error Boundaries em rotas críticas
- Accessibility blockers (WCAG A violations)
- Memory leaks (event listeners não removidos, subscriptions abertas)
- Falta de testes em componentes críticos
- "use client" desnecessário em componentes que poderiam ser Server Components

**Caracteristicas:**
- Impacta producao se não corrigido
- Deve corrigir antes de merge ou logo apos
- Cria debito técnico significativo

**Template:**
```markdown
**Acao Requerida:** Deve corrigir antes de merge.

**Impacto:** {impacto em producao se não corrigir}
```

### 🟡 Medium

**Quando usar:**
- `any` types onde tipos específicos sao possiveis
- Naming não descritivo
- Componentes muito grandes (>200 linhas)
- Missing memoization em renders frequentes
- Acessibilidade WCAG AA não atendida

**Caracteristicas:**
- Não bloqueia merge
- Deve corrigir em breve
- Afeta manutenibilidade

**Template:**
```markdown
**Justificativa:**
{explicacao do porque isso e importante}

**Referência:**
- Arch-Ts Skill: [{arquivo}](../arch-ts/{caminho})
```

### 🟢 Low

**Quando usar:**
- Pequenas otimizações de styling
- Sugestões de melhoria
- Imports não organizados
- Preferencia de pattern (mas ambos corretos)

**Caracteristicas:**
- Nice to have
- Pode corrigir depois
- Melhoria incremental

### ℹ️ Info

**Quando usar:**
- Contexto adicional sobre React 19 features
- FYI sobre patterns alternativos
- Notas sobre comportamento de Server Components

**Caracteristicas:**
- Não requer acao
- Informativo apenas

---

## Critérios de Decisão Final

Use estes critérios para determinar a recomendação final do review:

### ❌ Não Aprovar (Block Merge)

**Condicao:** 1+ issues **Critical** presentes

**Exemplos:**
- XSS via dangerouslySetInnerHTML
- Secrets hardcoded no client
- Auth bypass
- Data leak para o client

**Acao:** Merge deve ser bloqueado ate correcao

**Template:**
```markdown
**Recomendação:** ❌ Não aprovar

**Justificativa:** Encontrados {n} issues Critical que devem ser corrigidos antes do merge:
- {issue 1}
- {issue 2}
```

### ⚠️ Aprovar com Ressalvas

**Condicao:**
- 0 issues Critical
- 1+ issues **High** presentes

**Exemplos:**
- Bundle bloat significativo
- Missing Error Boundaries
- Accessibility blockers
- Componentes sem testes

**Acao:** Pode mergear, mas deve corrigir antes de producao. Criar tasks/tickets para correcao.

**Template:**
```markdown
**Recomendação:** ⚠️ Aprovar com ressalvas

**Justificativa:** Encontrados {n} issues High que devem ser corrigidos antes de producao:
- {issue 1}
- {issue 2}

Sugestao: criar tasks para correcao pos-merge.
```

### ✅ Aprovar

**Condicao:**
- 0 issues Critical
- 0 issues High
- Apenas Medium, Low, e/ou Info

**Acao:** Pode mergear normalmente. Issues menores podem ser corrigidos posteriormente.

**Template:**
```markdown
**Recomendação:** ✅ Aprovar

**Justificativa:** Nenhum issue bloqueante encontrado. Issues Medium/Low podem ser enderecados posteriormente como melhoria continua.
```

### 🎉 Aprovação com Elogios

**Condicao:**
- Poucos ou zero issues (apenas Low/Info)
- Codigo de alta qualidade
- Boas práticas seguidas consistentemente

**Acao:** Destacar qualidade do trabalho

**Template:**
```markdown
**Recomendação:** 🎉 Aprovar com elogios

**Justificativa:** Codigo de excelente qualidade. Padrões seguidos consistentemente. Poucos issues menores identificados.

**Destaques:**
- {destaque 1}
- {destaque 2}
```

---

## Integração com Arch-Ts Skill

Sempre que identificar violação de padrão TypeScript/Frontend, referencie a arch-ts skill:

### Exemplos de Referencias

**TypeScript strict violations:**
```markdown
**Referência:**
- Arch-Ts Skill: [references/typescript/strict-mode.md](../arch-ts/references/typescript/strict-config.md)
```

**React component patterns:**
```markdown
**Referência:**
- Arch-Ts Skill: [references/react/component-patterns.md](../arch-ts/references/react/component-patterns.md)
```

**Server Components vs Client Components:**
```markdown
**Referência:**
- Arch-Ts Skill: [references/nextjs/server-client-boundary.md](../arch-ts/references/react/server-components.md)
```

**State management:**
```markdown
**Referência:**
- Arch-Ts Skill: [references/react/state-management.md](../arch-ts/references/state/architecture.md)
```

**Testing patterns:**
```markdown
**Referência:**
- Arch-Ts Skill: [references/testing/vitest.md](../arch-ts/references/testing/vitest.md)
```

**Accessibility:**
```markdown
**Referência:**
- Arch-Ts Skill: [references/accessibility/wcag.md](../arch-ts/references/react/component-patterns.md)
```

---

## Estrutura de Arquivos da Skill

```
review-ts/
├── SKILL.md                          (este arquivo - conhecimento declarativo)
├── references/
│   ├── checklist.md                 (checklist completo com 28 checks)
│   ├── templates.md                 (exemplos de comentários por tipo de issue)
│   └── git.md                       (comandos git uteis + bundle/TS analysis)
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
| Revisando arquivo TS/TSX | `references/checklist.md` | Lista dos 28 checks a fazer |
| Precisando de exemplos | `references/templates.md` | Comentarios prontos por tipo |
| Precisando de comando git | `references/git.md` | Comandos git + bundle analysis |

### Para Voce Diretamente

Se você esta fazendo review manualmente:
1. Use `references/checklist.md` como guia do que verificar
2. Consulte `references/templates.md` para ver exemplos de comentários bem formatados
3. Use os critérios de severidade desta skill para classificar issues
4. Use os critérios de decisão final para determinar se aprova ou bloqueia

---

## Referencias

### Arquivos desta Skill
- [references/checklist.md](references/checklist.md) - Checklist completo de review (28 checks)
- [references/templates.md](references/templates.md) - Templates e exemplos de comentários por tipo de issue
- [references/git.md](references/git.md) - Comandos Git, bundle analysis e TypeScript checks

### Assets (Templates)
- [assets/comment.md](assets/comment.md) - Template de comentário individual
- [assets/summary.md](assets/summary.md) - Template de análise de impacto
- [assets/report.md](assets/report.md) - Template de relatório completo

### Arch-Ts Skill (Padrões Técnicos TypeScript/Frontend)
- [../arch-ts/SKILL.md](../arch-ts/SKILL.md) - Arch-Ts skill principal
- [../arch-ts/references/typescript/](../arch-ts/references/typescript/) - Padrões TypeScript (strict mode, generics, utility types)
- [../arch-ts/references/react/](../arch-ts/references/react/) - Padrões React (components, hooks, state, Server Components)
- [../arch-ts/references/state/](../arch-ts/references/state/) - State Management (Zustand, TanStack Query)
- [../arch-ts/references/testing/](../arch-ts/references/testing/) - Testes (Vitest, Testing Library, Playwright)
- [../arch-ts/references/styling/](../arch-ts/references/styling/) - Styling (Tailwind, CSS Modules)
- [../arch-ts/references/tooling/](../arch-ts/references/tooling/) - Tooling (Vite, Biome, pnpm)

### Output Gerado (pelo Agent)
- `review-output.md` - Arquivo final salvo na raiz do projeto (copy-paste ready para PRs)
