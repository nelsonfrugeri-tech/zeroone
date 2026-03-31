# Git Workflows - Code Review (Frontend)

Comandos e workflows Git uteis para code review frontend. Todos os comandos assumem que voce esta no diretorio raiz do repositorio.

---

## Comandos Basicos de Comparacao

### Ver branches disponiveis
```bash
# Branch atual
git branch --show-current

# Todas as branches locais
git branch

# Branches remotas
git branch -r

# Todas as branches (local + remote)
git branch -a
```

---

### Validar se branches existem
```bash
# Verificar se branch existe
git rev-parse --verify {branch_name}

# Exemplo
git rev-parse --verify main
git rev-parse --verify origin/feature/new-component
```

**Exit code:**
- `0` = branch existe
- `128` = branch nao existe

---

### Ver commits entre branches
```bash
# Lista commits que estao em compare mas nao em base
git log {base}..{compare} --oneline

# Com mais detalhes
git log {base}..{compare} --oneline --graph --decorate

# Apenas mensagens de commit
git log {base}..{compare} --pretty=format:"%s"

# Com autor e data
git log {base}..{compare} --pretty=format:"%h - %an, %ar : %s"
```

---

## Analise de Mudancas

### Estatisticas gerais
```bash
# Resumo de mudancas
git diff --stat {base}..{compare}

# Output exemplo:
# src/components/user-card.tsx    | 45 ++++++++++++++++++++++-----
# src/hooks/use-auth.ts           | 12 ++++++--
# src/__tests__/user-card.test.tsx | 23 +++++++++++++++
# 3 files changed, 71 insertions(+), 9 deletions(-)
```

---

### Lista de arquivos modificados
```bash
# Apenas nomes dos arquivos
git diff --name-only {base}..{compare}

# Com status (M=Modified, A=Added, D=Deleted, R=Renamed)
git diff --name-status {base}..{compare}

# Apenas arquivos TypeScript/TSX
git diff --name-only {base}..{compare} | grep -E '\.(ts|tsx)$'

# Apenas componentes React (TSX)
git diff --name-only {base}..{compare} | grep '\.tsx$'

# Apenas arquivos de teste
git diff --name-only {base}..{compare} | grep -E '(test|spec)\.(ts|tsx)$'

# Apenas arquivos de estilo
git diff --name-only {base}..{compare} | grep -E '\.(css|scss|module\.css)$'

# Apenas arquivos de configuracao
git diff --name-only {base}..{compare} | grep -E '(config|\.config)\.(ts|js|mjs|json)$'
```

---

### Diff completo
```bash
# Diff de todas as mudancas
git diff {base}..{compare}

# Diff de arquivo especifico
git diff {base}..{compare} -- {caminho/arquivo.tsx}

# Diff sem whitespace
git diff -w {base}..{compare}

# Diff com contexto extra (10 linhas antes e depois)
git diff -U10 {base}..{compare}

# Diff mostrando apenas nomes de funcoes alteradas
git diff {base}..{compare} --function-context
```

---

## Analise Frontend Especifica

### Detectar dependencias novas
```bash
# Ver mudancas em package.json
git diff {base}..{compare} -- package.json

# Apenas dependencias adicionadas
git diff {base}..{compare} -- package.json | grep '^+'

# Ver mudancas no lockfile
git diff --stat {base}..{compare} -- package-lock.json pnpm-lock.yaml yarn.lock
```

---

### Detectar mudancas em configuracao
```bash
# Arquivos de config modificados
git diff --name-only {base}..{compare} | grep -E '(next\.config|tsconfig|tailwind\.config|eslint|prettier|vitest\.config)'

# Ver diff de tsconfig
git diff {base}..{compare} -- tsconfig.json
```

---

### Detectar "use client" adicionado
```bash
# Buscar novas diretivas "use client" adicionadas
git diff {base}..{compare} | grep '^+.*"use client"'

# Contar quantos arquivos sao Client Components
git diff {base}..{compare} | grep '^+.*"use client"' | wc -l
```

---

### Detectar patterns problematicos no diff
```bash
# dangerouslySetInnerHTML (potencial XSS)
git diff {base}..{compare} | grep -i 'dangerouslySetInnerHTML'

# any types adicionados
git diff {base}..{compare} | grep '^+.*: any'

# @ts-ignore ou @ts-expect-error adicionados
git diff {base}..{compare} | grep '^+.*@ts-ignore\|@ts-expect-error'

# console.log statements
git diff {base}..{compare} | grep '^+.*console\.'

# TODO/FIXME/HACK adicionados
git diff {base}..{compare} | grep '^+.*\(TODO\|FIXME\|HACK\)'

# Inline styles adicionados
git diff {base}..{compare} | grep '^+.*style={{'

# Hardcoded colors
git diff {base}..{compare} | grep '^+.*#[0-9a-fA-F]\{3,8\}'

# useEffect sem dependency array ou com [] vazio
git diff {base}..{compare} | grep '^+.*useEffect'

# div com onClick (a11y smell)
git diff {base}..{compare} | grep '^+.*<div.*onClick'
```

---

## Bundle Size Analysis

### Verificar impacto no bundle
```bash
# Build antes (na base branch) - use worktree para nao modificar working dir
git worktree add /tmp/review-base {base}
cd /tmp/review-base && npx next build 2>&1 | tail -20 > /tmp/bundle-before.txt
cd - && git worktree remove /tmp/review-base

# Build depois (na compare branch)
git worktree add /tmp/review-compare {compare}
cd /tmp/review-compare && npx next build 2>&1 | tail -20 > /tmp/bundle-after.txt
cd - && git worktree remove /tmp/review-compare

# Comparar
diff /tmp/bundle-before.txt /tmp/bundle-after.txt
```

---

### Analise com bundle analyzer
```bash
# Gerar report visual
ANALYZE=true npx next build

# Comparar tamanhos de chunks
ls -la .next/static/chunks/*.js | sort -k5 -n
```

---

## TypeScript Strict Compliance

### Verificar erros de tipo
```bash
# Rodar type check completo
npx tsc --noEmit

# Contar erros de tipo
npx tsc --noEmit 2>&1 | grep 'error TS' | wc -l

# Erros por arquivo
npx tsc --noEmit 2>&1 | grep 'error TS' | sed 's/(.*//;s/ -//' | sort | uniq -c | sort -rn

# Verificar strict mode
npx tsc --noEmit --strict 2>&1 | head -30

# Buscar any types no codigo
grep -rn ': any' --include='*.ts' --include='*.tsx' src/
```

---

### Verificar ESLint
```bash
# Rodar lint completo
npx eslint . --ext .ts,.tsx

# Apenas erros (sem warnings)
npx eslint . --ext .ts,.tsx --quiet

# Contar issues por regra
npx eslint . --ext .ts,.tsx -f json | jq '.[].messages[].ruleId' | sort | uniq -c | sort -rn

# Apenas arquivos modificados
git diff --name-only {base}..{compare} | grep -E '\.(ts|tsx)$' | xargs npx eslint
```

---

## Lighthouse e Performance

### Lighthouse CI
```bash
# Rodar Lighthouse localmente
npx lhci autorun --collect.url=http://localhost:3000

# Comparar scores
npx lhci autorun --assert.preset=lighthouse:recommended

# Score especifico
npx lighthouse http://localhost:3000 --output=json | jq '.categories | {performance: .performance.score, accessibility: .accessibility.score}'
```

---

## Analise de Autores e Atividade

### Autores das mudancas
```bash
# Lista autores unicos
git log {base}..{compare} --format='%an' | sort | uniq

# Contagem por autor
git log {base}..{compare} --format='%an' | sort | uniq -c | sort -rn

# Commits por autor com mensagens
git log {base}..{compare} --format='%an: %s' | sort
```

---

## Workflows Avancados

### Ignorar mudancas especificas
```bash
# Ignorar mudancas em lockfiles e gerados
git diff {base}..{compare} -- . \
  ':(exclude)package-lock.json' \
  ':(exclude)pnpm-lock.yaml' \
  ':(exclude)yarn.lock' \
  ':(exclude)*.min.js' \
  ':(exclude)*.min.css' \
  ':(exclude).next/'

# Ignorar whitespace
git diff -w {base}..{compare}
```

---

### Exportar diff para analise
```bash
# Salvar diff completo em arquivo
git diff {base}..{compare} > /tmp/review-diff.txt

# Salvar apenas nomes de arquivos
git diff --name-only {base}..{compare} > /tmp/changed-files.txt

# Salvar diff de cada arquivo TS/TSX separadamente
for file in $(git diff --name-only {base}..{compare} | grep -E '\.(ts|tsx)$'); do
    git diff {base}..{compare} -- "$file" > "/tmp/diff-$(basename $file).txt"
done
```

---

## Padroes de Uso no Review-Ts

### Workflow tipico
```bash
# 1. Validar branches
git rev-parse --verify {base}
git rev-parse --verify {compare}

# 2. Obter estatisticas gerais
git diff --stat {base}..{compare}

# 3. Listar arquivos TS/TSX modificados
git diff --name-only {base}..{compare} | grep -E '\.(ts|tsx)$'

# 4. Quick checks
git diff {base}..{compare} | grep -i 'dangerouslySetInnerHTML'
git diff {base}..{compare} | grep '^+.*: any'
git diff {base}..{compare} | grep '^+.*"use client"'
git diff {base}..{compare} | grep '^+.*<div.*onClick'

# 5. Para cada arquivo TS/TSX:
git diff {base}..{compare} -- {arquivo}

# 6. Verificar types
npx tsc --noEmit

# 7. Verificar lint
npx eslint . --ext .ts,.tsx --quiet
```

---

### Quick checks antes do review
```bash
# Verificar se ha muitas mudancas (>1000 linhas)
CHANGES=$(git diff {base}..{compare} --shortstat | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
if [ "$CHANGES" -gt 1000 ]; then
    echo "⚠️ Atencao: PR muito grande ($CHANGES linhas). Considere quebrar."
fi

# Verificar se ha novos arquivos
NEW_FILES=$(git diff --name-status {base}..{compare} | grep '^A' | wc -l)
if [ "$NEW_FILES" -gt 0 ]; then
    echo "✨ $NEW_FILES novos arquivos adicionados"
fi

# Verificar se testes acompanham
SRC_FILES=$(git diff --name-only {base}..{compare} | grep -E '\.tsx?$' | grep -v -E '(test|spec)' | wc -l)
TEST_FILES=$(git diff --name-only {base}..{compare} | grep -E '(test|spec)\.(ts|tsx)$' | wc -l)
if [ "$SRC_FILES" -gt 0 ] && [ "$TEST_FILES" -eq 0 ]; then
    echo "⚠️ $SRC_FILES source files modificados sem testes correspondentes"
fi
```

---

## Comandos NAO Recomendados

**Evite modificar o repositorio durante review:**
```bash
# ❌ NAO FAZER - checkout modifica working directory
git checkout {compare}

# ❌ NAO FAZER - merge modifica historico
git merge {compare}

# ❌ NAO FAZER - rebase reescreve historico
git rebase {base}

# ❌ NAO FAZER - reset perde mudancas
git reset --hard
```

**Review deve ser read-only!**

---

## Referencias

- Git Diff Documentation: https://git-scm.com/docs/git-diff
- Git Log Documentation: https://git-scm.com/docs/git-log
- Next.js Build Output: https://nextjs.org/docs/app/api-reference/cli/next#build
- Lighthouse CI: https://github.com/GoogleChrome/lighthouse-ci

---

## Notas Importantes

**Sobre branches:**
- Use `origin/{branch}` para branches remotas
- Use `{branch}` para branches locais
- `HEAD` sempre referencia o commit atual
- `HEAD~N` referencia N commits atras

**Sobre performance:**
- Diffs grandes (>1000 arquivos) podem ser lentos
- Use `--stat` para overview rapido primeiro
- Considere revisar em batches menores
- Ignore lockfiles e arquivos gerados

**Sobre seguranca:**
- Git commands no review sao read-only
- Nunca execute comandos que modificam o repo
- Sempre valide branches antes de comparar
