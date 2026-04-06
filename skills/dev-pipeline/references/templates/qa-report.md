# Template — QA Report

Usar este template para documentar a execução do QA nos estágios 3 e 8 do pipeline.
Preencher com evidências reais. Sem evidência, sem QA.

---

```markdown
## QA Report

**Branch:** <nome da branch>
**Issue/Tarefa:** <link ou título>
**Data de execução:** <data>
**Executado por:** <agent responsável>
**Estágio:** QA (estágio 3 — pré-PR) | QA pós-fix (estágio 8)

---

### Ambiente

| Item | Valor |
|------|-------|
| Sistema operacional | <OS e versão> |
| Runtime/linguagem | <ex: Python 3.12, Node 20> |
| Dependências de infra | <ex: PostgreSQL 16, Redis 7> |
| Método de orquestração | <ex: docker compose, processo local> |

---

### Setup

Status: PASSOU | FALHOU

```
<saída do health check ou comando que confirma que o ambiente subiu>
```

---

### Execução

#### Smoke Test

Status: PASSOU | FALHOU

```
<saída dos comandos de smoke test>
```

#### Happy Path — <nome do cenário>

Status: PASSOU | FALHOU

**Entrada:**
```
<input ou request usado>
```

**Saída esperada:**
```
<o que era esperado>
```

**Saída obtida:**
```
<saída real — logs, response body, screenshot>
```

#### Edge Cases

| Cenário | Status | Evidência |
|---------|--------|-----------|
| <edge case 1> | PASSOU / FALHOU | <saída ou referência> |
| <edge case 2> | PASSOU / FALHOU | <saída ou referência> |

#### Casos de Erro

| Cenário | Status | Evidência |
|---------|--------|-----------|
| <erro 1> | PASSOU / FALHOU | <saída ou referência> |
| <erro 2> | PASSOU / FALHOU | <saída ou referência> |

---

### Validação da Definition of Done

| Critério de aceite | Status | Evidência |
|--------------------|--------|-----------|
| <critério 1 da issue> | PASSOU / FALHOU | <saída ou referência> |
| <critério 2 da issue> | PASSOU / FALHOU | <saída ou referência> |

---

### Teardown

Status: CONCLUÍDO | PENDENTE

```
<confirmação que ambiente foi derrubado — ex: docker ps output vazio>
```

---

### Resultado Geral

**Status:** PASSOU | FALHOU
**Bloqueadores (se FALHOU):** <descrição do problema>
**Próximo passo:** OPEN PR (estágio 4) | Voltar ao CODE/FIX com os bloqueadores acima
```
