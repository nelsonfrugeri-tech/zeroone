# Operadores Avançados de Busca do Google

## Operadores Essenciais
| Operador | Exemplo | Propósito |
|----------|---------|-----------|
| `site:` | `site:github.com fastapi middleware` | Buscar dentro de um site específico |
| `filetype:` | `filetype:pdf "system design"` | Encontrar tipos específicos de arquivo |
| `intitle:` | `intitle:"migration guide" django` | Buscar títulos de páginas |
| `after:` | `after:2025-01-01 "opentelemetry python"` | Apenas resultados recentes |
| `before:` | `before:2026-01-01` | Limite superior de data |
| `"exact"` | `"error budget burn rate"` | Correspondência exata de frase |
| `-` | `python framework -django -flask` | Excluir termos |
| `OR` | `k6 OR locust load testing` | Qualquer um dos termos |

## Padrões de Query Eficazes
```
# Find latest stable version
"release notes" site:github.com <project> after:2025-06
# Find migration guides
"migration guide" <library> <from-version> to <to-version>
# Find benchmarks
"benchmark" <tool-a> vs <tool-b> after:2025-01
# Find known issues
site:github.com/owner/repo/issues "<error message>"
```
