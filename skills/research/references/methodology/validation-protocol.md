# Protocolo de Validação

## Regra de N Fontes
- Mínimo 3 fontes independentes para qualquer afirmação técnica
- "Independente" = autores/organizações diferentes
- Blogs de vendors contam como UMA fonte (enviesada)

## Verificação de Data
| Domínio | Idade máxima |
|---------|-------------|
| Modelos AI/ML | 3 meses |
| Frameworks/libs | 6 meses |
| Padrões de arquitetura | 2 anos |
| Fundamentos de CS | Atemporal |

## Detecção de Viés
| Tipo de fonte | Risco de viés | Como compensar |
|---------------|--------------|----------------|
| Blog de vendor | Alto (vendendo produto) | Cruzar com benchmarks independentes |
| Palestra de conferência | Médio (promovendo abordagem) | Verificar se a abordagem tem adotantes independentes |
| GitHub README | Médio (vendendo projeto) | Verificar issues, uso no mundo real |
| Paper acadêmico | Baixo-médio (pode overfittar benchmarks) | Verificar reprodutibilidade, disponibilidade de código |
| Benchmark independente | Baixo | Verificar se a metodologia é sólida |

## Checklist de Validação
- [ ] Afirmação respaldada por ≥3 fontes
- [ ] Fontes são recentes o suficiente para o domínio
- [ ] Pelo menos 1 fonte é independente (não vendor)
- [ ] Metodologia de benchmarks é divulgada
- [ ] Contra-argumentos considerados
