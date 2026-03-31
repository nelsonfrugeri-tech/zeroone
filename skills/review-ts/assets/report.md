# Code Review Report (Frontend)

**Branches:** `{base_branch}` -> `{compare_branch}`
**Data:** {review_date}
**Reviewer:** Claude (review-ts skill)

---

## 📊 Executive Summary

| Metrica | Valor |
|---------|-------|
| **Arquivos TS/TSX Revisados** | {files_reviewed} |
| **Comentarios Totais** | {total_comments} |
| **Issues Criticos** | 🔴 {critical_count} |
| **Issues High** | 🟠 {high_count} |
| **Issues Medium** | 🟡 {medium_count} |
| **Issues Low** | 🟢 {low_count} |
| **Informacoes** | ℹ️ {info_count} |

---

## 🎯 Recomendacao Final

{final_recommendation_emoji} **{final_recommendation_text}**

**Justificativa:**
{final_justification}

---

## 📁 Analise de Impacto

### Estatisticas Gerais

| Metrica | Valor |
|---------|-------|
| **Commits** | {total_commits} |
| **Arquivos modificados** | {total_files} |
| **Arquivos TS/TSX** | {ts_files} |
| **Linhas adicionadas** | +{lines_added} |
| **Linhas removidas** | -{lines_removed} |
| **Mudanca liquida** | {net_change} |

### Features/Mudancas Principais

{features_list}

### Autores das Mudancas

{authors_list}

---

## 📋 Review Detalhado por Arquivo

{detailed_reviews}

---

## 📊 Resumo por Categoria

### 🔒 Security ({security_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {security_critical} | {security_critical_files} |
| 🟠 High | {security_high} | {security_high_files} |
| 🟡 Medium | {security_medium} | {security_medium_files} |
| 🟢 Low | {security_low} | {security_low_files} |

**Issues Principais:**
{security_top_issues}

---

### ♿ Accessibility ({accessibility_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {a11y_critical} | {a11y_critical_files} |
| 🟠 High | {a11y_high} | {a11y_high_files} |
| 🟡 Medium | {a11y_medium} | {a11y_medium_files} |
| 🟢 Low | {a11y_low} | {a11y_low_files} |

**Issues Principais:**
{accessibility_top_issues}

---

### ⚡ Performance ({performance_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {performance_critical} | {performance_critical_files} |
| 🟠 High | {performance_high} | {performance_high_files} |
| 🟡 Medium | {performance_medium} | {performance_medium_files} |
| 🟢 Low | {performance_low} | {performance_low_files} |

**Issues Principais:**
{performance_top_issues}

---

### 🧪 Testing ({testing_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {testing_critical} | {testing_critical_files} |
| 🟠 High | {testing_high} | {testing_high_files} |
| 🟡 Medium | {testing_medium} | {testing_medium_files} |
| 🟢 Low | {testing_low} | {testing_low_files} |

**Issues Principais:**
{testing_top_issues}

---

### ⚙️ Code Quality ({quality_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {quality_critical} | {quality_critical_files} |
| 🟠 High | {quality_high} | {quality_high_files} |
| 🟡 Medium | {quality_medium} | {quality_medium_files} |
| 🟢 Low | {quality_low} | {quality_low_files} |

**Issues Principais:**
{quality_top_issues}

---

### 🏗️ Architecture ({architecture_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {architecture_critical} | {architecture_critical_files} |
| 🟠 High | {architecture_high} | {architecture_high_files} |
| 🟡 Medium | {architecture_medium} | {architecture_medium_files} |
| 🟢 Low | {architecture_low} | {architecture_low_files} |

**Issues Principais:**
{architecture_top_issues}

---

### 🎨 Styling ({styling_count} issues)

| Severidade | Count | Arquivos Afetados |
|------------|-------|-------------------|
| 🔴 Critical | {styling_critical} | {styling_critical_files} |
| 🟠 High | {styling_high} | {styling_high_files} |
| 🟡 Medium | {styling_medium} | {styling_medium_files} |
| 🟢 Low | {styling_low} | {styling_low_files} |

**Issues Principais:**
{styling_top_issues}

---

## 🎯 Action Items por Prioridade

### 🔥 Bloqueadores (Corrigir ANTES do merge)

{blocking_items}

---

### ⚠️ Alta Prioridade (Corrigir antes de producao)

{high_priority_items}

---

### 📌 Media Prioridade (Considerar corrigir)

{medium_priority_items}

---

### 💡 Sugestoes (Melhorias futuras)

{low_priority_items}

---

## ✨ Pontos Positivos Destacados

{positive_highlights}

---

## 📈 Metricas de Qualidade

| Metrica | Valor | Status |
|---------|-------|--------|
| **Issues por arquivo** | {issues_per_file} | {issues_per_file_status} |
| **% Critical/High** | {critical_high_percentage}% | {critical_high_status} |
| **Cobertura estimada** | {estimated_coverage}% | {coverage_status} |
| **TypeScript strict compliance** | {ts_strict_compliance}% | {ts_strict_status} |
| **Accessibility score** | {a11y_score}/100 | {a11y_status} |
| **Bundle size impact** | {bundle_impact} | {bundle_status} |

**Legenda de Status:**
- 🟢 **Excelente:** Dentro dos padroes
- 🟡 **Atencao:** Melhorias recomendadas
- 🔴 **Critico:** Requer acao imediata

---

## 🔍 Analise de Tendencias

{trends_analysis}

---

## 📚 Referencias Consultadas

### Arch-Ts Skill
{developer_references}

### External Resources
{external_references}

---

## 👤 Informacoes do Review

**Reviewer:** Claude (review-ts skill v1.0)
**Data do Review:** {review_date}
**Duracao:** {review_duration}
**Base Branch:** `{base_branch}`
**Compare Branch:** `{compare_branch}`
**Total de Commits Analisados:** {total_commits}

---

## 📝 Notas Finais

{final_notes}

---

**Este relatorio foi gerado automaticamente pela review-ts skill.**
**Para questoes ou sugestoes sobre o review, consulte a arch-ts skill ou entre em contato com o time.**

---

## Apendice: Checklist Completo

{full_checklist_status}

---
