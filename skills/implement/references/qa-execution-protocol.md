# QA — Protocolo de Execução

O protocolo QA é executado nos estágios 3 e 8 do pipeline. É composto por três fases sequenciais:
setup, execução e teardown. Nenhuma fase é opcional.

---

## Princípios

**Ambiente isolado — nunca testar em produção ou em ambiente compartilhado**
Cada execução de QA usa um ambiente limpo que não existe antes e não existe depois.

**Evidências reais — sem "deve funcionar"**
O QA só conta se há evidências: saída de comandos, logs, screenshots, relatórios.

**Teardown sempre — mesmo em falha**
Se os testes falharem, o ambiente ainda deve ser derrubado antes de reportar a falha.

---

## Fase 1 — Setup

**Objetivo:** Criar um ambiente isolado, limpo e controlado para os testes.

```
Passos:
1. Verificar pré-requisitos locais (docker, portas disponíveis, variáveis de ambiente)
2. Subir dependências de infraestrutura (DB, cache, filas) via local-infrastructure
3. Iniciar a aplicação/serviço em modo de teste
4. Verificar que o ambiente subiu corretamente (health checks)
5. Carregar dados de teste iniciais (fixtures, seeds)
```

**Checklist de setup:**
- [ ] Nenhum resíduo de execução anterior (containers, volumes, arquivos temp)
- [ ] Todas as dependências iniciadas e healthy
- [ ] Aplicação iniciada sem erros
- [ ] Health checks passando
- [ ] Dados de teste carregados

**Consultar:** skill `local-infrastructure` para padrões de orquestração local.

---

## Fase 2 — Execução

**Objetivo:** Validar o comportamento da feature/fix em todos os cenários relevantes.

### 2.1 Smoke Test

```
Verificar que o sistema está operacional antes de rodar testes detalhados:
- Endpoints principais respondem
- Autenticação funciona
- Operações básicas (CRUD) funcionam
```

### 2.2 Happy Path

```
Testar o fluxo principal da feature/fix:
- Entradas válidas produzem saídas esperadas
- Fluxo completo de ponta a ponta
- Integração com dependências externas funciona
```

### 2.3 Edge Cases

```
Testar condições limite e casos não óbvios:
- Valores nulos, strings vazias, listas vazias
- Valores no limite (0, 1, max_int, strings longas)
- Concorrência (se aplicável)
- Timeout e retry (se aplicável)
```

### 2.4 Casos de Erro

```
Testar que falhas são tratadas corretamente:
- Inputs inválidos retornam erros claros
- Falha de dependência é tratada graciosamente
- Erros são logados com contexto suficiente
- Sistema se recupera de falhas transitórias
```

### 2.5 Validação da DoD

```
Para cada critério de aceite da issue:
- [ ] Critério X: [resultado observado]
- [ ] Critério Y: [resultado observado]
...
```

**Capturar evidências em cada passo:** saída de terminal, logs, screenshots, response bodies.

**Consultar:** skill `qa` para estratégias de teste E2E, Playwright, pytest e test data management.

---

## Fase 3 — Teardown

**Objetivo:** Limpar completamente o ambiente, independentemente do resultado dos testes.

```
Passos:
1. Parar a aplicação/serviço
2. Derrubar containers e dependências de infraestrutura
3. Remover volumes e dados criados durante o setup
4. Remover arquivos temporários e fixtures de teste
5. Verificar que nenhum processo ficou rodando (verificar portas)
```

**Checklist de teardown:**
- [ ] Aplicação parada
- [ ] Containers derrubados
- [ ] Volumes removidos
- [ ] Arquivos temporários limpos
- [ ] Nenhum processo residual nas portas usadas

**Teardown é obrigatório mesmo se os testes falharem.**
Documentar a falha no QA report e então fazer teardown.

---

## Resultado da Execução

Ao final das três fases, preencher o QA report (ver template `references/templates/qa-report.md`).

```
Status geral: PASSOU | FALHOU
Fase de falha (se aplicável): SETUP | EXECUÇÃO | TEARDOWN
Próximo passo:
  - PASSOU: avançar para OPEN PR (estágio 4) ou RE-REVIEW (estágio 9)
  - FALHOU: voltar ao CODE (estágio 1) ou FIX (estágio 6) com QA report documentando a falha
```
