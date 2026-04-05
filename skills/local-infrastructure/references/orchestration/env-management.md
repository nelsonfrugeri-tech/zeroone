# .env Management

## Estrutura
```
.env.example    — committed, all keys with placeholder values
.env            — gitignored, actual values
.env.test       — gitignored, test environment values
.env.production — NEVER on disk, only in CI/CD secrets
```

## Validation Pattern
```python
# Python with pydantic-settings
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    redis_url: str = "redis://localhost:6379"
    debug: bool = False
    
    model_config = {"env_file": ".env"}
```

## Regras
1. **Never commit .env** — add to .gitignore
2. **Always commit .env.example** — documents required vars
3. **Validate on startup** — fail fast if missing required vars
4. **No secrets in docker-compose.yml** — use env_file directive
5. **Rotate secrets** — never reuse across environments

## Docker Compose
```yaml
services:
  api:
    env_file:
      - .env
    environment:
      - NODE_ENV=development  # overrides .env
```
