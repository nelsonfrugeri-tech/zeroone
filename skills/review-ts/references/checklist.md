# Code Review Checklist (TypeScript/Frontend)

Checklist de code review para TypeScript/React/Next.js. Cada item aponta para a arch-ts skill que contem os padrões completos e exemplos.

---

## Como Usar

**Para cada arquivo TypeScript/TSX modificado:**

1. Percorra as categorias abaixo sequencialmente
2. Para cada check, consulte a referencia indicada na arch-ts skill
3. Marque [x] quando item verificado
4. Se encontrar violação, gere comentário citando:
   - O check violado
   - Severidade típica
   - Referencia da arch-ts skill

**Severidade e indicativa.** Use bom senso baseado no contexto.

---

## 🔒 Security

### [ ] 1. Secrets e Env Vars
**Verificar:**
- Sem API keys, tokens, passwords no client-side code
- Env vars com `NEXT_PUBLIC_` apenas para dados realmente públicos
- Secrets usados apenas em Server Components ou API routes
- `.env.local` no `.gitignore`

**Severidade típica:** 🔴 Critical
**Referência:** [Arch-Ts - Environment Variables](../../arch-ts/references/typescript/type-system.md)

---

### [ ] 2. XSS Prevention
**Verificar:**
- `dangerouslySetInnerHTML` nunca usado com input de usuário sem sanitização
- DOMPurify ou equivalente usado quando HTML dinâmico e necessário
- `href` com `javascript:` protocol bloqueado
- User-generated content escapado por padrão (React faz isso, mas verificar bypasses)

**Severidade típica:** 🔴 Critical
**Referência:** OWASP XSS Prevention + [Arch-Ts - Security](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 3. CSRF e Forms
**Verificar:**
- Forms com CSRF tokens quando necessário
- Server Actions com validação de origem
- Fetch requests com credentials corretamente configurados

**Severidade típica:** 🟠 High
**Referência:** [Arch-Ts - Server Actions](../../arch-ts/references/react/server-components.md)

---

### [ ] 4. Authentication e Authorization
**Verificar:**
- Rotas protegidas com middleware ou layout guards
- Tokens não armazenados em localStorage (prefira httpOnly cookies)
- Verificação de permissões antes de exibir dados sensíveis
- Server Components usados para dados que requerem auth

**Severidade típica:** 🔴 Critical (rotas públicas) / 🟠 High (internas)
**Referência:** [Arch-Ts - Auth Patterns](../../arch-ts/references/react/server-components.md)

---

### [ ] 5. Input Validation
**Verificar:**
- Dados de formulários validados com Zod ou equivalente
- Server Actions validam input antes de processar
- Schemas compartilhados entre client e server quando possível
- File uploads com validação de tipo e tamanho

**Severidade típica:** 🟠 High
**Referência:** [Arch-Ts - Validation](../../arch-ts/references/typescript/type-system.md)

---

## ♿ Accessibility

### [ ] 6. Semantic HTML
**Verificar:**
- `<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`, `<header>`, `<footer>` usados corretamente
- `<button>` para ações, `<a>` para navegação (nunca `<div onClick>`)
- Headings em ordem hierárquica (h1 > h2 > h3)
- Lists (`<ul>`, `<ol>`) para conteúdo em lista

**Severidade típica:** 🟠 High
**Referência:** [Arch-Ts - Semantic HTML](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 7. ARIA Labels e Roles
**Verificar:**
- Elementos interativos customizados tem `role` e `aria-label`
- Icons-only buttons tem `aria-label`
- `aria-live` para conteúdo dinâmico que muda
- `aria-hidden="true"` em elementos decorativos
- `aria-expanded`, `aria-selected` em menus e tabs

**Severidade típica:** 🟠 High (elementos interativos) / 🟡 Medium (decorativos)
**Referência:** [Arch-Ts - ARIA](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 8. Keyboard Navigation
**Verificar:**
- Todos os elementos interativos acessíveis via Tab
- Tab order lógico (sem `tabIndex` > 0)
- Escape fecha modais/dropdowns
- Enter/Space ativa buttons
- Arrow keys para navegação em menus/tabs
- Focus trap em modais

**Severidade típica:** 🟠 High
**Referência:** [Arch-Ts - Keyboard Navigation](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 9. Focus Management
**Verificar:**
- Focus movido para modal quando abre
- Focus retorna ao trigger quando modal fecha
- Focus visível (outline não removido globalmente)
- Skip links para conteúdo principal
- `autoFocus` usado com cuidado (pode confundir screen readers)

**Severidade típica:** 🟠 High (modais) / 🟡 Medium (geral)
**Referência:** [Arch-Ts - Focus Management](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 10. Color e Contrast
**Verificar:**
- Contrast ratio >= 4.5:1 para texto normal (WCAG AA)
- Contrast ratio >= 3:1 para texto grande (>18px bold, >24px)
- Informacao não transmitida apenas por cor (ícones, patterns, texto)
- Dark mode com contrast adequado

**Severidade típica:** 🟡 Medium
**Referência:** [Arch-Ts - Color Contrast](../../arch-ts/references/styling/tailwind.md)

---

### [ ] 11. Images e Media
**Verificar:**
- Todas as imagens informativas tem `alt` descritivo
- Imagens decorativas tem `alt=""`
- Videos tem captions/subtitles quando possível
- SVGs acessíveis com `role="img"` e `aria-label`

**Severidade típica:** 🟠 High (images informativas) / 🟢 Low (decorativas)
**Referência:** [Arch-Ts - Accessible Media](../../arch-ts/references/react/component-patterns.md)

---

## ⚡ Performance

### [ ] 12. Bundle Size
**Verificar:**
- Sem imports de bibliotecas inteiras quando so precisa de uma funcao
- Dynamic imports (`next/dynamic`, `React.lazy`) para componentes pesados
- Tree-shaking funcionando (named imports, não default de barrel files)
- Sem dependências duplicadas (verifique com `npm ls` ou bundle analyzer)

**Severidade típica:** 🟠 High (>50KB adicionados) / 🟡 Medium (<50KB)
**Referência:** [Arch-Ts - Bundle Optimization](../../arch-ts/references/react/performance.md)

---

### [ ] 13. Render Optimization
**Verificar:**
- `React.memo` em componentes puros renderizados frequentemente
- `useMemo` para computações caras
- `useCallback` para callbacks passados como props
- Keys estáveis em listas (nunca array index se a lista muda)
- State no nível correto (nao lifting desnecessário)
- Sem state updates em cascata causando re-renders múltiplos

**Severidade típica:** 🟡 Medium / 🟠 High (listas grandes, tabelas)
**Referência:** [Arch-Ts - React Performance](../../arch-ts/references/react/performance.md)

---

### [ ] 14. Images e Assets
**Verificar:**
- `next/image` usado em vez de `<img>` (otimização automática)
- Formatos modernos (WebP, AVIF) quando possível
- `loading="lazy"` para imagens abaixo do fold
- `priority` em imagens LCP (hero, acima do fold)
- `sizes` prop correta para responsive images

**Severidade típica:** 🟡 Medium / 🟠 High (imagens LCP)
**Referência:** [Arch-Ts - Image Optimization](../../arch-ts/references/react/performance.md)

---

### [ ] 15. Data Fetching
**Verificar:**
- Data fetching no servidor quando possível (Server Components)
- `fetch` com `cache` e `revalidate` configurados corretamente
- Sem waterfalls (parallel data fetching com `Promise.all`)
- Loading states com Suspense boundaries
- Streaming com React Server Components quando aplicável

**Severidade típica:** 🟠 High (waterfalls em paginas críticas) / 🟡 Medium
**Referência:** [Arch-Ts - Data Fetching](../../arch-ts/references/react/server-components.md)

---

### [ ] 16. Core Web Vitals
**Verificar:**
- LCP: elemento principal renderiza rápido (sem bloqueios)
- CLS: layouts estáveis (tamanhos definidos para images/ads/embeds)
- INP: interações respondem rápido (<200ms)
- Sem layout shifts causados por fonts, images, ou conteúdo dinâmico

**Severidade típica:** 🟠 High
**Referência:** [Arch-Ts - Core Web Vitals](../../arch-ts/references/react/performance.md)

---

## 🧪 Testing

### [ ] 17. Component Tests
**Verificar:**
- Componentes críticos tem testes com Testing Library
- Testes interagem como usuário (click, type, not implementation details)
- Queries acessíveis usadas (`getByRole`, `getByLabelText`, não `getByTestId`)
- States testados (loading, error, empty, success)

**Severidade típica:** 🔴 Critical (componentes críticos sem testes) / 🟠 High (coverage <50%)
**Referência:** [Arch-Ts - Testing Library](../../arch-ts/references/testing/testing-library.md)

---

### [ ] 18. Hook Tests
**Verificar:**
- Hooks customizados testados com `renderHook`
- Side effects testados (API calls, subscriptions)
- Cleanup verificado (event listeners, timers)

**Severidade típica:** 🟠 High
**Referência:** [Arch-Ts - Hook Testing](../../arch-ts/references/testing/vitest.md)

---

### [ ] 19. E2E Tests
**Verificar:**
- Fluxos críticos cobertos (login, checkout, CRUD principal)
- Playwright ou Cypress configurado
- Tests não frageis (sem hard waits, usar locators estáveis)
- CI pipeline roda E2E

**Severidade típica:** 🟠 High (fluxos críticos) / 🟡 Medium
**Referência:** [Arch-Ts - E2E Testing](../../arch-ts/references/testing/playwright.md)

---

### [ ] 20. Accessibility Tests
**Verificar:**
- axe-core integrado nos testes
- `toHaveNoViolations()` em component tests
- Testes de keyboard navigation em componentes interativos

**Severidade típica:** 🟡 Medium
**Referência:** [Arch-Ts - A11y Testing](../../arch-ts/references/testing/testing-library.md)

---

## ⚙️ Code Quality

### [ ] 21. TypeScript Strict
**Verificar:**
- Sem `any` (use `unknown` se tipo é realmente desconhecido)
- Sem `@ts-ignore` ou `@ts-expect-error` sem justificativa
- Generics usados corretamente
- Utility types usados onde aprópriado (Partial, Pick, Omit, Record)
- Discriminated unions para state machines
- `satisfies` operator para validação de tipos

**Severidade típica:** 🟡 Medium (`any` em locais isolados) / 🟠 High (`any` em interfaces públicas)
**Referência:** [Arch-Ts - TypeScript Strict](../../arch-ts/references/typescript/strict-config.md)

---

### [ ] 22. Component Design
**Verificar:**
- Props tipadas com interface ou type (nao inline)
- Componentes < 200 linhas (senao, decomponha)
- Single Responsibility (um componente, uma responsabilidade)
- Composition sobre inheritance
- Default exports para paginas, named exports para componentes

**Severidade típica:** 🟡 Medium / 🟠 High (componentes >300 linhas)
**Referência:** [Arch-Ts - Component Patterns](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 23. Error Handling
**Verificar:**
- Error Boundaries em rotas/layouts
- `error.tsx` files em App Router
- Fetch errors tratados com try/catch
- User-facing error messages claras
- Sentry ou equivalente para error tracking

**Severidade típica:** 🟠 High (rotas sem error boundary) / 🟡 Medium
**Referência:** [Arch-Ts - Error Handling](../../arch-ts/references/react/component-patterns.md)

---

### [ ] 24. Naming e Conventions
**Verificar:**
- Components: PascalCase (`UserProfile`, não `userProfile`)
- Hooks: `use` prefix (`useAuth`, não `getAuth`)
- Files: kebab-case ou match component name
- Constants: UPPER_SNAKE_CASE
- Types/Interfaces: PascalCase com prefixo descritivo
- Boolean props: `is`, `has`, `should` prefix

**Severidade típica:** 🟡 Medium
**Referência:** [Arch-Ts - Naming Conventions](../../arch-ts/references/typescript/patterns.md)

---

## 🏗️ Architecture

### [ ] 25. Server vs Client Components
**Verificar:**
- `"use client"` apenas onde necessário (interatividade, hooks, browser APIs)
- Dados sensíveis apenas em Server Components
- Props serializaveis entre Server e Client Components
- Não passando funções como props de Server para Client Components

**Severidade típica:** 🟠 High (`"use client"` desnecessário em arvore grande) / 🟡 Medium
**Referência:** [Arch-Ts - Server/Client Boundary](../../arch-ts/references/react/server-components.md)

---

### [ ] 26. State Management
**Verificar:**
- State local quando possível (useState, useReducer)
- Context para state compartilhado em arvore pequena
- External store (Zustand, Jotai) para state global complexo
- URL state para filtros/paginacao (nuqs, useSearchParams)
- Sem prop drilling excessivo (>3 níveis)

**Severidade típica:** 🟡 Medium / 🟠 High (state management errado em escala)
**Referência:** [Arch-Ts - State Management](../../arch-ts/references/state/architecture.md)

---

### [ ] 27. Data Fetching Patterns
**Verificar:**
- Server Components para data fetching estático/SSR
- React Server Actions para mutações
- SWR/TanStack Query para client-side data fetching com cache
- Sem fetch em useEffect quando Server Component e possível
- Loading states (Suspense, loading.tsx)

**Severidade típica:** 🟠 High (fetch em useEffect desnecessário) / 🟡 Medium
**Referência:** [Arch-Ts - Data Fetching Patterns](../../arch-ts/references/react/server-components.md)

---

## 🎨 Styling

### [ ] 28. Tailwind e Design System
**Verificar:**
- Classes Tailwind consistentes (nao misturar com CSS modules sem razao)
- Design tokens usados (cores do theme, não hex hardcoded)
- Responsive design com breakpoints corretos (sm, md, lg, xl)
- Dark mode usando `dark:` variant quando aplicável
- Spacing consistente (usar scale: 1, 2, 3, 4, não valores arbitrários)

**Severidade típica:** 🟢 Low (inconsistencias menores) / 🟡 Medium (design system violation)
**Referência:** [Arch-Ts - Styling Patterns](../../arch-ts/references/styling/tailwind.md)

---

## Resumo Rápido

**Ordem de prioridade durante review:**

1. **Security** (checks 1-5) -> Máxima prioridade
2. **Accessibility** (checks 6-11) -> Compliance e inclusão
3. **Performance** (checks 12-16) -> Core Web Vitals e UX
4. **Testing** (checks 17-20) -> Coverage e qualidade
5. **Code Quality** (checks 21-24) -> Conformidade com arch-ts skill
6. **Architecture** (checks 25-27) -> Estrutura e patterns
7. **Styling** (check 28) -> Consistencia visual

---

## Ferramentas de Apoio

Algumas verificações podem ser automatizadas:
```bash
# Type checking
npx tsc --noEmit

# Linting
npx eslint . --ext .ts,.tsx

# Formatting
npx prettier --check .

# Accessibility audit (CLI)
npx axe-core-cli http://localhost:3000

# Bundle analysis
npx @next/bundle-analyzer

# Lighthouse CI
npx lhci autorun

# Testing
npx vitest run

# E2E
npx playwright test

# TypeScript strict compliance
npx tsc --noEmit --strict 2>&1 | wc -l
```

**Referencia completa:** [Arch-Ts - Tooling](../../arch-ts/references/tooling/biome.md)

---

## Notas Importantes

**Este checklist é um guia, não uma regra rígida:**
- Use bom senso baseado no contexto do projeto
- Severidades sao indicativas, não absolutas
- Consulte sempre a arch-ts skill para padrões detalhados
- Adapte para o contexto (startup vs enterprise, prototipo vs producao)

**Para decisão final de aprovação:**
Consulte a seção "Decisão Final" no SKILL.md principal da review-ts.
