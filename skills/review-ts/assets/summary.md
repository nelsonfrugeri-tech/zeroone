# Analise de Impacto - Code Review (Frontend)

**Branches:** `{base_branch}` -> `{compare_branch}`
**Data:** {review_date}
**Reviewer:** Claude (review-ts skill)

---

## 📊 Estatisticas Gerais

| Metrica | Valor |
|---------|-------|
| **Commits** | {total_commits} |
| **Arquivos modificados** | {total_files} |
| **Arquivos TypeScript/TSX** | {ts_files} |
| **Linhas adicionadas** | +{lines_added} |
| **Linhas removidas** | -{lines_removed} |
| **Mudanca liquida** | {net_change} |

---

## 📁 Arquivos por Categoria

### Componentes React Modificados ({components_modified_count})
{components_modified_list}

### Componentes React Adicionados ({components_added_count})
{components_added_list}

### Hooks Customizados ({hooks_count})
{hooks_list}

### Arquivos de Estilo ({style_files_count})
{style_files_list}

### Arquivos de Teste ({test_files_count})
{test_files_list}

### Arquivos de Configuracao ({config_files_count})
{config_files_list}

### Outros Arquivos ({other_files_count})
{other_files_list}

---

## 🎯 Features/Mudancas Principais

{features_list}

---

## 👥 Autores das Mudancas

{authors_list}

---

## 📈 Analise de Complexidade

| Arquivo | Linhas +/- | Complexidade |
|---------|------------|--------------|
{complexity_table}

**Legenda de Complexidade:**
- 🟢 **Baixa:** < 50 linhas modificadas
- 🟡 **Media:** 50-200 linhas modificadas
- 🟠 **Alta:** 200-500 linhas modificadas
- 🔴 **Muito Alta:** > 500 linhas modificadas

---

## 📦 Impacto no Bundle

| Metrica | Antes | Depois | Delta |
|---------|-------|--------|-------|
| **Bundle Size (gzip)** | {bundle_before} | {bundle_after} | {bundle_delta} |
| **First Load JS** | {first_load_before} | {first_load_after} | {first_load_delta} |
| **Novas dependencias** | — | {new_deps_count} | {new_deps_list} |

---

## ♿ Impacto em Acessibilidade

| Metrica | Status |
|---------|--------|
| **Novos componentes interativos** | {interactive_components_count} |
| **ARIA labels necessarios** | {aria_needed} |
| **Keyboard navigation afetada** | {keyboard_nav_impact} |
| **Semantic HTML usado** | {semantic_html_status} |

---

## ⚡ Impacto em Performance

| Metrica | Impacto |
|---------|---------|
| **Core Web Vitals (LCP)** | {lcp_impact} |
| **Core Web Vitals (CLS)** | {cls_impact} |
| **Core Web Vitals (INP)** | {inp_impact} |
| **Render cycles afetados** | {render_impact} |
| **Server vs Client components** | {server_client_ratio} |

---

## ⚠️ Alertas Preliminares

{preliminary_alerts}

---

## 🎯 Recomendacoes de Prioridade

### Alta Prioridade
{high_priority_files}

### Media Prioridade
{medium_priority_files}

### Baixa Prioridade
{low_priority_files}

---

## 📝 Proximos Passos

1. {next_step_1}
2. {next_step_2}
3. {next_step_3}

---

**Nota:** Esta e apenas uma analise de impacto. Para review detalhado, execute a opcao "Review por Arquivo" ou "Relatorio Completo".
