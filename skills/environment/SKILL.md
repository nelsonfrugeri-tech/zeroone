---
name: environment
description: |
  Local development environment knowledge base (2026). Covers environment lifecycle,
  Docker best practices (multi-stage builds, layer caching, security), Docker Compose patterns
  (health checks, depends_on, volumes, profiles, watch mode), database initialization
  (PostgreSQL, MongoDB, Redis — init scripts, seeding, migrations), .env management,
  service orchestration (startup order, readiness probes), port management, hot reload,
  dependency installation by ecosystem (pip, poetry, npm, pnpm), teardown, and error recovery.
  Use when: (1) Setting up local environment with Docker, (2) Configuring databases,
  (3) Troubleshooting local infrastructure, (4) Orchestrating multi-service stacks,
  (5) Debugging containers.
  Triggers: /environment, /env, docker, compose, database setup, container, devenv, local infra.
type: capability
---

# Environment — Local Development Infrastructure

## Purpose

This skill is the knowledge base for local development infrastructure (2026).
It covers everything needed to run, debug, and maintain multi-service development environments.

**What this skill contains:**
- Docker best practices (multi-stage builds, security, layer caching)
- Docker Compose patterns (health checks, depends_on, volumes, networks)
- Database setup (PostgreSQL, MongoDB, Redis)
- .env management (validation, templates, secrets)
- Service orchestration (startup order, readiness probes)
- Port management and conflict resolution
- Dependency installation by ecosystem
- Log streaming and debugging
- Watch mode and hot reload
- Error recovery procedures

**What this skill does NOT contain:**
- Cloud deployment (AWS, GCP, Azure) — focus is local
- Kubernetes / Helm — focus is Docker Compose
- CI/CD pipelines — focus is developer workstation

---

## Reference Versions

> Always check current versions before using. Verify at official sites (Docker Hub, PyPI, npmjs.com, etc.)

| Tool | Version | Notes |
|------|---------|-------|
| Docker Engine | 29.3.1 | Latest stable |
| Docker Compose | v2.40+ | CLI plugin, no `version:` field needed |
| PostgreSQL | 18.3 | Latest stable |
| MongoDB | 8.2.3 | Latest stable |
| Redis | 8.4.2 | Latest stable |
| Python | 3.14.3 | Latest stable |
| Node.js | 24.14.1 | LTS |
| Poetry | 2.3.3 | Latest stable |
| pnpm | 10.33.0 | Latest stable |

---

## 1. Docker Best Practices

### Multi-Stage Builds

Multi-stage builds reduce image size by up to 97%.

```dockerfile
# Stage 1: Build
FROM python:3.14.3-slim AS builder
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry==2.3.3 && \
    poetry config virtualenvs.in-project true && \
    poetry install --only=main --no-interaction
COPY src/ ./src/

# Stage 2: Runtime
FROM python:3.14.3-slim AS runtime
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/src /app/src
ENV PATH="/app/.venv/bin:$PATH"
USER nobody
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Layer Caching

Order instructions from least to most frequently changing:

```dockerfile
# 1. Base image (rarely changes)
FROM node:24.14.1-slim

# 2. System deps (rarely changes)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl && rm -rf /var/lib/apt/lists/*

# 3. Dependency files (changes when deps change)
COPY package.json pnpm-lock.yaml ./

# 4. Install deps (cached if lockfile unchanged)
RUN corepack enable && pnpm install --frozen-lockfile

# 5. Source code (changes frequently)
COPY src/ ./src/
```

### Security

```dockerfile
# Use minimal base images
FROM python:3.14.3-slim          # NOT python:3.14.3
FROM node:24.14.1-slim           # NOT node:24.14.1

# Run as non-root
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# .dockerignore
# .git
# node_modules
# .env
# __pycache__
# .mypy_cache
# .pytest_cache
```

### Image Selection

| Use Case | Base Image | Size |
|----------|-----------|------|
| Python production | `python:3.14.3-slim` | ~150MB |
| Python minimal | `python:3.14.3-alpine` | ~50MB |
| Node.js production | `node:24.14.1-slim` | ~200MB |
| Maximum security | `gcr.io/distroless/python3` | ~30MB |

---

## 2. Docker Compose Patterns

### Service Dependencies with Health Checks

```yaml
# compose.yaml (no `version:` field -- deprecated in Compose v2)
services:
  postgres:
    image: postgres:18
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts/postgres:/docker-entrypoint-initdb.d
    ports:
      - "${DB_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s

  redis:
    image: redis:8.4.2-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    ports:
      - "${REDIS_PORT:-6379}:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    env_file: .env
    ports:
      - "${API_PORT:-8000}:8000"
    volumes:
      - ./src:/app/src:ro
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

volumes:
  postgres_data:
  redis_data:
```

### Profiles for Optional Services

```yaml
services:
  api:
    # ... always runs

  adminer:
    image: adminer:4.8.1
    ports:
      - "8080:8080"
    profiles: ["debug"]

  prometheus:
    image: prom/prometheus:v3.2.1
    profiles: ["monitoring"]
```

```bash
docker compose up                        # core services only
docker compose --profile debug up        # with debug tools
docker compose --profile monitoring up   # with monitoring
```

### Watch Mode (hot reload, Compose v2.22+)

```yaml
services:
  api:
    build: .
    develop:
      watch:
        - action: sync
          path: ./src
          target: /app/src
        - action: rebuild
          path: ./pyproject.toml
        - action: sync+restart
          path: ./config
          target: /app/config
```

```bash
docker compose watch  # auto-sync files, rebuild on dependency changes
```

---

## 3. Database Configuration

### PostgreSQL — Initialization Scripts

Files in `/docker-entrypoint-initdb.d/` run on first start (alphabetical order):

```sql
-- init-scripts/postgres/01-extensions.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

```sql
-- init-scripts/postgres/02-schema.sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_users_email ON users(email);
```

```bash
# init-scripts/postgres/03-seed.sh
#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    INSERT INTO users (email, name) VALUES
    ('admin@example.com', 'Admin User')
    ON CONFLICT (email) DO NOTHING;
EOSQL
```

### Redis

```bash
# Check Redis is up and auth working
docker exec <container> redis-cli -a ${REDIS_PASSWORD} ping

# Monitor commands in real-time
docker exec <container> redis-cli -a ${REDIS_PASSWORD} monitor

# Flush all keys (for test reset)
docker exec <container> redis-cli -a ${REDIS_PASSWORD} flushall
```

---

## 4. .env Management

### .env.example Template

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=                    # Required: set before running

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=                 # Required: set before running

# Application
API_PORT=8000
DEBUG=false
LOG_LEVEL=info

# External services
STRIPE_API_KEY=                 # Required for payment features
SENDGRID_API_KEY=               # Required for email features
```

### .env Validation (Python — pydantic-settings)

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # Database
    db_host: str
    db_port: int = 5432
    db_name: str
    db_user: str
    db_password: str

    # Application
    debug: bool = False
    log_level: str = "info"

    @property
    def database_url(self) -> str:
        return f"postgresql://{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}"

settings = Settings()
```

### Rules

1. **Never commit `.env`** — add to `.gitignore`
2. **Always commit `.env.example`** — template with empty values
3. **Validate on startup** — use pydantic-settings or dotenv-vault
4. **Never log env vars** — they contain secrets

---

## 5. Service Readiness Probes

### Waiting for Services in Scripts

```bash
#!/bin/bash
# Wait for PostgreSQL to be ready
until pg_isready -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER}; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
echo "PostgreSQL is ready"

# Wait for API health check
until curl -sf http://localhost:${API_PORT}/health > /dev/null; do
  echo "Waiting for API..."
  sleep 2
done
echo "API is ready"
```

### Readiness in Python

```python
import asyncio
import httpx

async def wait_for_service(url: str, timeout: int = 30) -> None:
    """Wait for a service to become healthy."""
    start = asyncio.get_event_loop().time()
    async with httpx.AsyncClient() as client:
        while True:
            try:
                response = await client.get(url, timeout=2.0)
                if response.status_code == 200:
                    return
            except (httpx.ConnectError, httpx.TimeoutException):
                pass
            if asyncio.get_event_loop().time() - start > timeout:
                raise TimeoutError(f"Service {url} not ready after {timeout}s")
            await asyncio.sleep(1)
```

---

## 6. Port Management

### Standard Port Assignments

| Service | Default Port | Dev Override |
|---------|-------------|--------------|
| API | 8000 | Configurable via env |
| Frontend | 3000 | Configurable via env |
| PostgreSQL | 5432 | 5433 for test |
| Redis | 6379 | 6380 for test |
| MongoDB | 27017 | 27018 for test |
| Adminer | 8080 | — |
| Prometheus | 9090 | — |
| Grafana | 3000 | 3001 (conflict with frontend) |

### Conflict Resolution

```bash
# Find what is using a port
lsof -i :5432

# Kill process on port
kill -9 $(lsof -t -i:5432)

# Check all Docker-used ports
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

---

## 7. Dependency Installation

### Python — Poetry

```bash
# Install all deps
poetry install

# Install without dev deps (CI/production)
poetry install --only main

# Add dep (pinned)
poetry add requests==2.32.3

# Add dev dep
poetry add --group dev pytest==8.3.0

# Export for requirements.txt
poetry export -f requirements.txt --output requirements.txt --without-hashes
```

### Node.js — pnpm

```bash
# Install all deps
pnpm install

# Install without dev deps
pnpm install --prod

# Add dep
pnpm add axios@1.7.0

# Add dev dep
pnpm add -D vitest@1.6.0

# Check for vulnerabilities
pnpm audit
```

---

## 8. Log Streaming and Debugging

### Container Logs

```bash
# Follow logs for all services
docker compose logs -f

# Follow logs for specific service
docker compose logs -f api

# Show last 100 lines
docker compose logs --tail=100 api

# Filter by log level (if using structured logging)
docker compose logs api | grep '"level":"error"'
```

### Interactive Debugging

```bash
# Shell into running container
docker compose exec api bash

# Run one-off command
docker compose run --rm api python -c "from src.main import app; print('OK')"

# Check environment
docker compose exec api env | sort

# Inspect container
docker inspect $(docker compose ps -q api)
```

---

## 9. Teardown

### Clean Shutdown

```bash
# Stop containers, keep volumes
docker compose down

# Stop containers, remove volumes
docker compose down -v

# Stop containers, remove everything (images + volumes)
docker compose down -v --rmi all

# Remove only stopped containers
docker compose rm --force --stop -v
```

### Full System Cleanup

```bash
# Remove all unused containers, networks, images, volumes
docker system prune -a --volumes

# Remove only volumes
docker volume prune

# Remove only images
docker image prune -a
```

---

## 10. Error Recovery

### Common Issues and Solutions

**Port already in use:**
```bash
lsof -i :5432
kill -9 $(lsof -t -i:5432)
```

**Container won't start (check logs):**
```bash
docker compose logs <service>
docker compose events  # real-time event stream
```

**Database connection refused:**
```bash
# Check if container is healthy
docker compose ps
# Check health logs
docker inspect <container_id> | jq '.[0].State.Health'
```

**Volume permissions:**
```bash
# Fix file ownership issues
docker compose exec <service> chown -R <user>:<group> /path
```

**Out of disk space:**
```bash
docker system df          # check usage
docker system prune -a    # clean up
```

---

## Reference Files

- [references/dockerfile-patterns.md](references/dockerfile-patterns.md) — Multi-stage builds, security patterns
- [references/compose-patterns.md](references/compose-patterns.md) — Compose v2 patterns, profiles, watch mode
- [references/database-setup.md](references/database-setup.md) — PostgreSQL, MongoDB, Redis initialization
- [references/env-management.md](references/env-management.md) — .env templates, validation patterns
- [references/debugging.md](references/debugging.md) — Debugging commands, troubleshooting guide
