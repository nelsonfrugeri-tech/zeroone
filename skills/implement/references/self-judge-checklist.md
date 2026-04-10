# Self-Judge — Checklist

O self-judge é a revisão crítica que o dev agent faz do próprio trabalho **antes** de qualquer
outra pessoa ver o código. É obrigatório nos estágios 2 e 7 do pipeline.

Executar este checklist significa passar por cada item conscientemente — não fazer scroll e marcar tudo.

---

## Como usar

1. Abrir o diff completo da branch
2. Passar item por item do checklist
3. Para cada item com problema: corrigir antes de continuar
4. Só avançar para QA quando todos os itens estiverem satisfeitos
5. Documentar quaisquer decisões técnicas não óbvias como comentário no PR

---

## Seção 1 — Correção Funcional

- [ ] O código faz exatamente o que a issue/tarefa pede?
- [ ] Os edge cases estão cobertos (valores nulos, listas vazias, limites)?
- [ ] O tratamento de erros é adequado e não silencia falhas?
- [ ] As mensagens de erro são informativas o suficiente para debug?
- [ ] Os tipos/contratos de entrada e saída estão corretos?

---

## Seção 2 — Qualidade do Código

- [ ] Os nomes de variáveis, funções e classes são descritivos e sem abreviações obscuras?
- [ ] As funções têm responsabilidade única (máximo de ~20 linhas é um sinal)?
- [ ] Não há duplicação: se a lógica aparece duas vezes, foi extraída?
- [ ] Não há comentários explicando "o que" o código faz — o código deve ser autoexplicativo?
- [ ] Os comentários existentes explicam "por que", não "o que"?
- [ ] Não há código comentado no diff?
- [ ] Não há TODOs funcionais (aqueles que deveriam estar nesta tarefa)?

---

## Seção 3 — Testes

- [ ] Há testes para o happy path?
- [ ] Há testes para os edge cases identificados na Seção 1?
- [ ] Há testes para os casos de erro?
- [ ] Os testes testam comportamento, não implementação interna?
- [ ] Os testes são independentes entre si (nenhum teste depende de outro)?
- [ ] Os testes têm nomes descritivos que explicam o cenário?
- [ ] Todos os testes passam localmente?

---

## Seção 4 — Design e Arquitetura

- [ ] O código segue os padrões da linguagem e do projeto (consultar `arch-py` ou `arch-ts`)?
- [ ] Não foram introduzidas dependências desnecessárias?
- [ ] O acoplamento é mínimo: o novo código só depende do que precisa?
- [ ] Não foram criadas abstrações prematuras (YAGNI)?
- [ ] Se houver mudança de interface pública, os consumidores foram atualizados?

---

## Seção 5 — Segurança e Performance

- [ ] Inputs externos são validados antes de usar?
- [ ] Não há credenciais, tokens ou segredos no código?
- [ ] Não há queries N+1 ou loops com operações caras sem justificativa?
- [ ] Recursos são fechados/liberados corretamente (conexões, arquivos, streams)?

---

## Seção 6 — Definition of Done

- [ ] O critério de aceite da issue está satisfeito?
- [ ] CHANGELOG.md foi atualizado?
- [ ] README.md foi atualizado (se a mudança afeta documentação pública)?
- [ ] O diff está limpo: apenas mudanças necessárias para esta tarefa?
- [ ] A branch tem o nome correto e os commits são descritivos?

---

## Resultado do Self-Judge

```
Self-Judge executado em: <data>
Estágio: CODE (estágio 2) | FIX (estágio 7)
Itens pendentes: <lista de itens que precisaram de fix>
Status: PASSOU | REQUER FIX
```

Se `REQUER FIX`: corrigir os itens, re-executar o checklist, só avançar quando `PASSOU`.
