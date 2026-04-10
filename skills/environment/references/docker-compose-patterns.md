# Docker Compose Advanced Patterns

## Networks

```yaml
services:
  api:
    networks:
      - backend
      - frontend

  postgres:
    networks:
      - backend  # not accessible from frontend network

  nginx:
    networks:
      - frontend
    ports:
      - "80:80"

networks:
  backend:
    driver: bridge
  frontend:
    driver: bridge
```

## Volume Patterns

```yaml
volumes:
  # Named volume (persistent, managed by Docker)
  postgres_data:

  # Named volume with driver options
  redis_data:
    driver: local

services:
  api:
    volumes:
      # Bind mount (development: sync source code)
      - ./src:/app/src

      # Read-only bind mount (safer)
      - ./src:/app/src:ro

      # Named volume (persistent data)
      - postgres_data:/var/lib/postgresql/data

      # Anonymous volume (ephemeral)
      - /app/node_modules

      # tmpfs (in-memory, no persistence)
    tmpfs:
      - /tmp
```

## Resource Limits

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: 512M
        reservations:
          cpus: "0.5"
          memory: 256M
```

## Restart Policies

```yaml
services:
  api:
    restart: unless-stopped   # restart unless manually stopped

  postgres:
    restart: always           # always restart

  migration:
    restart: "no"             # run once, don't restart
```

## Environment Variable Precedence

1. `environment:` in compose.yaml (highest)
2. `env_file:` in compose.yaml
3. Shell environment variables
4. `.env` file in project root (lowest)

## Extend and Override

```yaml
# compose.yaml (base)
services:
  api:
    build: .
    ports:
      - "8000:8000"

# compose.override.yaml (auto-loaded in dev)
services:
  api:
    volumes:
      - ./src:/app/src
    environment:
      - DEBUG=true
    command: uvicorn src.main:app --reload

# compose.prod.yaml (explicit)
services:
  api:
    restart: always
    environment:
      - DEBUG=false
```

```bash
# Dev (auto-loads compose.override.yaml)
docker compose up

# Prod
docker compose -f compose.yaml -f compose.prod.yaml up -d
```

## Init Containers Pattern

```yaml
services:
  db-migrate:
    build: .
    command: alembic upgrade head
    depends_on:
      postgres:
        condition: service_healthy
    restart: "no"  # run once

  api:
    build: .
    depends_on:
      db-migrate:
        condition: service_completed_successfully  # wait for migration
      postgres:
        condition: service_healthy
```

## Compose Watch Actions (v2.22+)

| Action | Trigger | Behavior |
|--------|---------|----------|
| `sync` | File change | Copy changed files into container |
| `rebuild` | File change | Rebuild image and recreate container |
| `sync+restart` | File change | Copy files + restart container process |

Best practices:
- `sync` for source code (fastest feedback)
- `rebuild` for dependency files (pyproject.toml, package.json)
- `sync+restart` for config files that need process restart
