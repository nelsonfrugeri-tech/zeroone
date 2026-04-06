# Árvore de Decisão de Roteamento

```
1. Classificar complexidade (trivial/low/medium/high/critical)
2. É read-only? → agent sem worktree (apenas leitura)
3. É review? → agent com persona de review
4. É coding?
   a. Qualquer linguagem → agent dev (neo, trinity)
5. É arquitetura/design? → the_architect
6. É pesquisa/debate? → morpheus
7. É coordenação/gestão? → oracle
8. É monitoramento/SRE? → cypher
9. Sem match → agent general-purpose + flag gap
```

## Casos Especiais
- Tarefa abrange múltiplos domínios → dividir em subtarefas, rotear cada uma
- Escopo ambíguo → pedir clarificação ao usuário antes de rotear
- Dependências entre tarefas → execução sequencial, não paralela
