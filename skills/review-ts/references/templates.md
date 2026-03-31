# Comment Templates (TypeScript/Frontend)

Templates de comentarios para code review frontend. Use estes templates ao gerar comentarios, preenchendo os placeholders indicados.

---

## Template Base (Completo)

Use este template para comentarios detalhados:
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** {emoji} {categoria}
**Severidade:** {emoji} {severidade}

**Issue:**
{descricao clara e objetiva do problema em 1-2 frases}

**Codigo Atual:**
```tsx
{codigo problematico extraido do diff}
```

**Codigo Sugerido:**
```tsx
{codigo corrigido}
```

**Justificativa:**
{explicacao tecnica do porque isso e um problema}
{impacto se nao corrigir}

**Referencia:**
- Arch-Ts Skill: [{arquivo}](../arch-ts/{caminho})
{outras referencias se aplicavel}
````

---

## Templates por Severidade

### 🔴 Critical
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🔒 Security
**Severidade:** 🔴 Critical

**Issue:**
{descricao do problema critico}

**Codigo Atual:**
```tsx
{codigo problematico}
```

**Codigo Sugerido:**
```tsx
{codigo corrigido}
```

**Justificativa:**
Este e um problema critico que pode causar {impacto grave}.
{explicacao tecnica detalhada}

**Impacto:**
- {consequencia 1}
- {consequencia 2}
- {consequencia 3}

**Acao Requerida:** Bloqueia merge. Deve ser corrigido imediatamente.

**Referencia:**
- Arch-Ts Skill: [{arquivo}](../arch-ts/{caminho})
````

---

### 🟠 High
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** {emoji} {categoria}
**Severidade:** 🟠 High

**Issue:**
{descricao do problema}

**Codigo Atual:**
```tsx
{codigo problematico}
```

**Codigo Sugerido:**
```tsx
{codigo corrigido}
```

**Justificativa:**
{explicacao do problema e impacto}

**Impacto:** {impacto em producao se nao corrigir}

**Acao Requerida:** Deve corrigir antes de merge.

**Referencia:**
- Arch-Ts Skill: [{arquivo}](../arch-ts/{caminho})
````

---

### 🟡 Medium
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** {emoji} {categoria}
**Severidade:** 🟡 Medium

**Issue:**
{descricao do problema}

**Codigo Atual:**
```tsx
{codigo problematico}
```

**Codigo Sugerido:**
```tsx
{codigo corrigido}
```

**Justificativa:**
{explicacao do porque isso e importante}

**Referencia:**
- Arch-Ts Skill: [{arquivo}](../arch-ts/{caminho})
````

---

### 🟢 Low
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** {emoji} {categoria}
**Severidade:** 🟢 Low

**Issue:**
{sugestao de melhoria}

**Codigo Atual:**
```tsx
{codigo atual}
```

**Sugestao:**
```tsx
{codigo melhorado}
```

**Beneficio:** {pequena melhoria que traz}
````

---

### ℹ️ Info
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** ℹ️ Info

**Observacao:**
{informacao util ou contexto adicional}

**Contexto:**
{explicacao ou alternativa}

**Referencia:** {se aplicavel}
````

---

## Templates por Categoria

### 🔒 Security - XSS via dangerouslySetInnerHTML
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🔒 Security
**Severidade:** 🔴 Critical

**Issue:**
`dangerouslySetInnerHTML` usado com input de usuario sem sanitizacao. Isso permite XSS attacks.

**Codigo Atual:**
```tsx
function UserComment({ comment }: { comment: string }) {
  return <div dangerouslySetInnerHTML={{ __html: comment }} />;
}
```

**Codigo Sugerido:**
```tsx
import DOMPurify from "dompurify";

function UserComment({ comment }: { comment: string }) {
  const sanitized = DOMPurify.sanitize(comment);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// Ou melhor ainda, evite dangerouslySetInnerHTML:
function UserComment({ comment }: { comment: string }) {
  return <div>{comment}</div>;
}
```

**Justificativa:**
- Atacante pode injetar `<script>` tags ou event handlers
- Roubo de cookies, session hijacking, phishing
- React escapa conteudo por padrao, mas `dangerouslySetInnerHTML` bypassa isso

**Impacto:** Comprometimento total da sessao do usuario.

**Acao Requerida:** Bloqueia merge. Corrigir imediatamente.

**Referencia:**
- OWASP XSS: https://owasp.org/www-community/attacks/xss/
- DOMPurify: https://github.com/cure53/DOMPurify
````

---

### 🔒 Security - Secrets no Client Bundle
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🔒 Security
**Severidade:** 🔴 Critical

**Issue:**
Secret/API key exposta no client-side code. Variaveis sem prefixo `NEXT_PUBLIC_` nao devem ser acessadas em Client Components, mas esta variavel parece conter dados sensiveis.

**Codigo Atual:**
```tsx
// Client Component
"use client";

const API_SECRET = process.env.NEXT_PUBLIC_API_SECRET;

async function fetchData() {
  const res = await fetch("/api/data", {
    headers: { Authorization: `Bearer ${API_SECRET}` },
  });
}
```

**Codigo Sugerido:**
```tsx
// Move to Server Component or API Route
// app/api/data/route.ts
import { NextResponse } from "next/server";

export async function GET() {
  const API_SECRET = process.env.API_SECRET; // No NEXT_PUBLIC_ prefix
  const res = await fetch("https://external-api.com/data", {
    headers: { Authorization: `Bearer ${API_SECRET}` },
  });
  const data = await res.json();
  return NextResponse.json(data);
}
```

**Justificativa:**
- `NEXT_PUBLIC_` vars sao inlined no client bundle e visiveis para qualquer usuario
- Secrets nunca devem estar no client-side
- Qualquer pessoa pode abrir DevTools e ver a key

**Impacto:** API key comprometida, possivel abuso de servicos pagos ou data breach.

**Acao Requerida:** Bloqueia merge. Remover secret do client e rotacionar a key.

**Referencia:**
- Next.js Env Vars: https://nextjs.org/docs/app/building-your-application/configuring/environment-variables
````

---

### ♿ Accessibility - Missing ARIA Labels
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** ♿ Accessibility
**Severidade:** 🟠 High

**Issue:**
Elemento interativo sem label acessivel. Screen readers nao conseguem identificar o proposito do botao.

**Codigo Atual:**
```tsx
<button onClick={handleClose}>
  <XIcon />
</button>
```

**Codigo Sugerido:**
```tsx
<button onClick={handleClose} aria-label="Close dialog">
  <XIcon aria-hidden="true" />
</button>
```

**Justificativa:**
- Botoes icon-only sao anunciados como "button" sem contexto
- Usuarios de screen readers nao sabem o que o botao faz
- WCAG 2.1 SC 4.1.2 (Name, Role, Value) requer labels

**Acao Requerida:** Corrigir antes de merge.

**Referencia:**
- WCAG 4.1.2: https://www.w3.org/WAI/WCAG21/Understanding/name-role-value
- Arch-Ts Skill: [references/accessibility/aria.md](../arch-ts/references/accessibility/aria.md)
````

---

### ♿ Accessibility - Non-Semantic Interactive Element
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** ♿ Accessibility
**Severidade:** 🟠 High

**Issue:**
`<div>` com `onClick` usado como botao. Nao e acessivel via teclado e nao e anunciado como interativo por screen readers.

**Codigo Atual:**
```tsx
<div className="card" onClick={() => navigate(`/item/${id}`)}>
  {content}
</div>
```

**Codigo Sugerido:**
```tsx
// Se e navegacao, use <a> ou <Link>:
<Link href={`/item/${id}`} className="card">
  {content}
</Link>

// Se e uma acao, use <button>:
<button type="button" className="card" onClick={() => handleAction(id)}>
  {content}
</button>
```

**Justificativa:**
- `<div>` nao e focavel por padrao (nao aparece no tab order)
- Nao responde a Enter/Space como botao
- Screen readers nao anunciam como elemento interativo
- Viola WCAG 2.1 SC 2.1.1 (Keyboard)

**Acao Requerida:** Corrigir antes de merge.

**Referencia:**
- Arch-Ts Skill: [references/accessibility/semantic-html.md](../arch-ts/references/accessibility/semantic-html.md)
````

---

### ⚡ Performance - Unnecessary Re-renders
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** ⚡ Performance
**Severidade:** 🟡 Medium

**Issue:**
Objeto criado inline como prop causa re-render desnecessario do componente filho a cada render do pai.

**Codigo Atual:**
```tsx
function Parent() {
  const [count, setCount] = useState(0);

  return (
    <ExpensiveChild
      config={{ theme: "dark", locale: "en" }}
      onAction={() => console.log("action")}
    />
  );
}
```

**Codigo Sugerido:**
```tsx
const CONFIG = { theme: "dark", locale: "en" } as const;

function Parent() {
  const [count, setCount] = useState(0);

  const handleAction = useCallback(() => {
    console.log("action");
  }, []);

  return <ExpensiveChild config={CONFIG} onAction={handleAction} />;
}

const ExpensiveChild = memo(function ExpensiveChild({
  config,
  onAction,
}: ExpensiveChildProps) {
  // ...
});
```

**Justificativa:**
- Objeto literal cria nova referencia a cada render
- `ExpensiveChild` re-renderiza mesmo sem mudancas reais
- Com `memo` + referencias estaveis, re-renders sao evitados

**Referencia:**
- Arch-Ts Skill: [references/react/performance.md](../arch-ts/references/react/performance.md)
````

---

### 🏗️ Architecture - Unnecessary "use client"
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🏗️ Architecture
**Severidade:** 🟠 High

**Issue:**
Componente marcado com `"use client"` mas nao usa hooks, event handlers, ou browser APIs. Pode ser Server Component.

**Codigo Atual:**
```tsx
"use client";

interface UserCardProps {
  name: string;
  email: string;
  avatar: string;
}

export function UserCard({ name, email, avatar }: UserCardProps) {
  return (
    <div className="card">
      <img src={avatar} alt={name} />
      <h3>{name}</h3>
      <p>{email}</p>
    </div>
  );
}
```

**Codigo Sugerido:**
```tsx
// Remove "use client" - this is a pure presentational component
import Image from "next/image";

interface UserCardProps {
  name: string;
  email: string;
  avatar: string;
}

export function UserCard({ name, email, avatar }: UserCardProps) {
  return (
    <div className="card">
      <Image src={avatar} alt={name} width={48} height={48} />
      <h3>{name}</h3>
      <p>{email}</p>
    </div>
  );
}
```

**Justificativa:**
- Server Components sao renderizados no servidor, zero JS enviado ao client
- Client Components adicionam JavaScript ao bundle desnecessariamente
- Toda a arvore abaixo de `"use client"` tambem se torna client

**Impacto:** Bundle size maior, hidratacao desnecessaria, pior FCP/LCP.

**Acao Requerida:** Corrigir antes de merge.

**Referencia:**
- Arch-Ts Skill: [references/nextjs/server-client-boundary.md](../arch-ts/references/nextjs/server-client-boundary.md)
````

---

### ⚙️ Code Quality - `any` Type
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** ⚙️ Code Quality
**Severidade:** 🟡 Medium

**Issue:**
Tipo `any` usado onde um tipo especifico e possivel.

**Codigo Atual:**
```tsx
function processData(data: any) {
  return data.items.map((item: any) => ({
    id: item.id,
    name: item.name,
  }));
}
```

**Codigo Sugerido:**
```tsx
interface ApiResponse {
  items: ApiItem[];
}

interface ApiItem {
  id: string;
  name: string;
}

function processData(data: ApiResponse): Array<{ id: string; name: string }> {
  return data.items.map((item) => ({
    id: item.id,
    name: item.name,
  }));
}
```

**Justificativa:**
- `any` desabilita type checking, anulando beneficios do TypeScript
- Erros so aparecem em runtime em vez de compile time
- Dificulta refactoring e autocompletion
- Use `unknown` se o tipo e realmente desconhecido

**Referencia:**
- Arch-Ts Skill: [references/typescript/strict-mode.md](../arch-ts/references/typescript/strict-mode.md)
````

---

### ⚙️ Code Quality - Missing Error Boundary
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** ⚙️ Code Quality
**Severidade:** 🟠 High

**Issue:**
Rota/pagina sem Error Boundary. Erro em qualquer componente filho crasha a pagina inteira.

**Codigo Atual:**
```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const data = await fetchDashboardData();
  return (
    <div>
      <MetricsPanel data={data.metrics} />
      <ActivityFeed data={data.activity} />
      <UserList data={data.users} />
    </div>
  );
}
```

**Codigo Sugerido:**
```tsx
// app/dashboard/error.tsx
"use client";

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div role="alert">
      <h2>Something went wrong loading the dashboard</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}

// app/dashboard/page.tsx (with Suspense for granular loading)
import { Suspense } from "react";

export default function DashboardPage() {
  return (
    <div>
      <Suspense fallback={<MetricsSkeleton />}>
        <MetricsPanel />
      </Suspense>
      <Suspense fallback={<ActivitySkeleton />}>
        <ActivityFeed />
      </Suspense>
    </div>
  );
}
```

**Justificativa:**
- Sem error boundary, erro em `MetricsPanel` derruba toda a pagina
- `error.tsx` em Next.js App Router cria error boundary automatico
- Suspense boundaries permitem fallbacks granulares

**Acao Requerida:** Corrigir antes de merge.

**Referencia:**
- Next.js Error Handling: https://nextjs.org/docs/app/building-your-application/routing/error-handling
- Arch-Ts Skill: [references/react/error-handling.md](../arch-ts/references/react/error-handling.md)
````

---

### 🧪 Testing - Missing Component Tests
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🧪 Testing
**Severidade:** 🟠 High

**Issue:**
Componente critico sem testes correspondentes.

**Sugestao de Testes:**
```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi } from "vitest";
import { LoginForm } from "./login-form";

describe("LoginForm", () => {
  it("renders email and password fields", () => {
    render(<LoginForm onSubmit={vi.fn()} />);

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
  });

  it("calls onSubmit with form data", async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/email/i), "test@example.com");
    await user.type(screen.getByLabelText(/password/i), "password123");
    await user.click(screen.getByRole("button", { name: /sign in/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      email: "test@example.com",
      password: "password123",
    });
  });

  it("shows validation error for invalid email", async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={vi.fn()} />);

    await user.type(screen.getByLabelText(/email/i), "invalid");
    await user.click(screen.getByRole("button", { name: /sign in/i }));

    expect(screen.getByText(/valid email/i)).toBeInTheDocument();
  });

  it("has no accessibility violations", async () => {
    const { container } = render(<LoginForm onSubmit={vi.fn()} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

**Justificativa:**
- Login e fluxo critico que precisa de cobertura
- Testes garantem que mudancas futuras nao quebram o formulario
- Testes de a11y previnem regressoes de acessibilidade

**Coverage Esperada:** >80% para componentes de formulario

**Referencia:**
- Arch-Ts Skill: [references/testing/testing-library.md](../arch-ts/references/testing/testing-library.md)
````

---

### 🏗️ Architecture - State Management Anti-pattern
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🏗️ Architecture
**Severidade:** 🟡 Medium

**Issue:**
Prop drilling excessivo (>3 niveis). Considere Context ou state management library.

**Codigo Atual:**
```tsx
function App() {
  const [user, setUser] = useState<User | null>(null);
  return <Layout user={user} setUser={setUser} />;
}

function Layout({ user, setUser }: LayoutProps) {
  return <Sidebar user={user} setUser={setUser} />;
}

function Sidebar({ user, setUser }: SidebarProps) {
  return <UserMenu user={user} setUser={setUser} />;
}

function UserMenu({ user, setUser }: UserMenuProps) {
  return <div>{user?.name}</div>;
}
```

**Codigo Sugerido:**
```tsx
// contexts/user-context.tsx
const UserContext = createContext<UserContextValue | null>(null);

export function UserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (!context) throw new Error("useUser must be within UserProvider");
  return context;
}

// Components access directly:
function UserMenu() {
  const { user } = useUser();
  return <div>{user?.name}</div>;
}
```

**Justificativa:**
- Prop drilling torna componentes intermediarios dependentes de props que nao usam
- Mudancas no tipo propagam por todos os niveis
- Context ou Zustand elimina o acoplamento

**Referencia:**
- Arch-Ts Skill: [references/react/state-management.md](../arch-ts/references/react/state-management.md)
````

---

### 🎨 Styling - Hardcoded Colors
````markdown
**Linhas:** {start_line}-{end_line}
**Categoria:** 🎨 Styling
**Severidade:** 🟢 Low

**Issue:**
Cores hardcoded em vez de usar design tokens do Tailwind theme.

**Codigo Atual:**
```tsx
<div className="bg-[#1a1a2e] text-[#e94560] border-[#0f3460]">
  <h2 className="text-[#16213e]">Title</h2>
</div>
```

**Sugestao:**
```tsx
// tailwind.config.ts - define tokens
const config = {
  theme: {
    extend: {
      colors: {
        brand: {
          bg: "#1a1a2e",
          accent: "#e94560",
          border: "#0f3460",
          text: "#16213e",
        },
      },
    },
  },
};

// Component uses tokens:
<div className="bg-brand-bg text-brand-accent border-brand-border">
  <h2 className="text-brand-text">Title</h2>
</div>
```

**Beneficio:** Mudancas de tema centralizadas, dark mode mais facil, consistencia visual.
````

---

## Template de Pontos Positivos

Use sempre ao final do review de cada arquivo:
````markdown
### ✅ Pontos Positivos

1. ✨ {aspecto bem implementado}
2. ✨ {boa pratica seguida}
3. ✨ {qualidade destacada}
````

**Exemplos concretos:**
````markdown
### ✅ Pontos Positivos

1. ✨ Server Components usados corretamente para data fetching
2. ✨ Acessibilidade excelente: ARIA labels, semantic HTML, keyboard nav
3. ✨ TypeScript strict sem nenhum `any` - tipos precisos em toda a codebase
4. ✨ Error boundaries em todas as rotas com fallback UX agradavel
5. ✨ Component tests com Testing Library usando queries acessiveis
````

---

## Template de Resumo por Arquivo
````markdown
### 📊 Resumo: `{caminho/arquivo.tsx}`

| Categoria | Count | Severidade Maxima |
|-----------|-------|-------------------|
| 🔒 Security | {n} | {max_severity} |
| ♿ Accessibility | {n} | {max_severity} |
| ⚡ Performance | {n} | {max_severity} |
| 🧪 Testing | {n} | {max_severity} |
| ⚙️ Code Quality | {n} | {max_severity} |
| 🏗️ Architecture | {n} | {max_severity} |
| 🎨 Styling | {n} | {max_severity} |
| **Total** | **{total}** | **{overall_max}** |

**Recomendacao:** {✅ Aprovar / ⚠️ Aprovar com ressalvas / ❌ Nao aprovar}

**Justificativa:** {razao concisa da recomendacao}
````

---

## Template de Issue Simples (One-liner)

Para issues muito simples, use formato compacto:
````markdown
**L{line_num}** - {emoji} {severity} - {issue_description} -> Sugestao: {quick_fix}
Ref: [Arch-Ts - {topic}](../arch-ts/references/{path})
````

**Exemplo:**
````markdown
**L42** - 🟢 Low - Import nao usado `useState` -> Remover import
Ref: [Arch-Ts - Code Quality](../arch-ts/references/typescript/best-practices.md)
````

---

## Placeholders Comuns

**Severidades:**
- `🔴 Critical`
- `🟠 High`
- `🟡 Medium`
- `🟢 Low`
- `ℹ️ Info`

**Categorias:**
- `🔒 Security`
- `♿ Accessibility`
- `⚡ Performance`
- `🧪 Testing`
- `⚙️ Code Quality`
- `🏗️ Architecture`
- `🎨 Styling`

**Emojis de Resultado:**
- `✅` - Aprovar
- `⚠️` - Aprovar com ressalvas
- `❌` - Nao aprovar
- `🎉` - Aprovacao com elogios
- `✨` - Ponto positivo
- `🚫` - Bloqueio

---

## Notas de Uso

**Escolha do template:**
1. Use template completo para issues complexos
2. Use template por severidade para issues padrao
3. Use template por categoria para issues especificos conhecidos
4. Use template one-liner para issues triviais

**Personalizacao:**
- Sempre adapte o template ao contexto
- Adicione detalhes especificos ao codigo em questao
- Seja especifico sobre linhas afetadas
- Cite a arch-ts skill quando aplicavel

**Formato GitHub/Bitbucket:**
- Markdown padrao funciona
- Code blocks com ```tsx funcionam
- Links internos funcionam
- Emojis funcionam
