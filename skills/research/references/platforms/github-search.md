# Busca no GitHub

## Busca de Código
```
# Search code across repos
language:python "from pydantic import" path:src
# Find specific patterns
org:fastapi "middleware" language:python
# File name search
filename:docker-compose.yml redis postgres
# Path-scoped
path:src/api "rate_limit" language:python
```

## Busca de Issues/PRs
```
# Open issues with label
repo:owner/repo is:issue is:open label:bug
# Recent PRs
repo:owner/repo is:pr is:merged merged:>2025-01-01
# Search discussions
repo:owner/repo type:discussions "performance"
```

## Busca de Releases
- Verifique a página /releases para changelogs
- Compare releases: `/compare/v1.0...v2.0`
- Stars/forks como sinais de popularidade (mas não de qualidade)
