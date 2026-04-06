---
name: local-infrastructure
description: |
  Baseline de conhecimento para infraestrutura local de desenvolvimento. Docker (multi-stage builds,
  security, layer caching), docker compose (health checks, depends_on, volumes, networks), databases
  (PostgreSQL, MongoDB, Redis — init, seeding, migrations), .env management, service orchestration
  (startup order, readiness probes), port management, dependency installation por ecossistema
  (pip, poetry, npm, pnpm, cargo), log streaming, debugging, watch mode, hot reload, error recovery.
  Use quando: (1) Subir ambiente local com Docker, (2) Configurar databases, (3) Resolver problemas
  de infraestrutura local, (4) Orquestrar multi-service stacks, (5) Debugging de containers.
  Triggers: /local-infra, docker, compose, database setup, container, infrastructure, devenv.
---

# Local Infrastructure — Infraestrutura Local de Desenvolvimento

## Propósito

Esta skill é a **knowledge base** for local development infrastructure (2026).
It covers everything needed to run, debug, and maintain multi-service development environments.

**Global skill** — loaded automatically by all agents.

- You directly -> when troubleshooting infrastructure issues

**What this skill contains:**
- Docker best practices (multi-stage builds, security, layer caching)
- Docker Compose patterns (health checks, depends_on, volumes, networks)
- Database setup (PostgreSQL, MongoDB, Redis)
- .env management (validation, templates, secrets)
- Service orchestration (startup order, readiness probes)
- Port management and conflict resolution
- Dependency installation by ecosystem (pip, poetry, npm, pnpm, cargo)
- Log streaming and debugging
- Health check patterns (HTTP, TCP, command)
- Watch mode and hot reload
- Error recovery procedures

**What this skill does NOT contain:**
- Cloud deployment (AWS, GCP, Azure) -- focus is local
- Kubernetes / Helm -- focus is Docker Compose
- CI/CD pipelines -- focus is developer workstation

---

## Versões de Referência

> **Nota:** Sempre verificar versões atuais antes de usar. Consultar sites oficiais (Docker Hub, PyPI, npmjs.com, etc.)

| Tool | Version | Notes |
|------|---------|-------|
| Docker Engine | 29.3.1 | Latest stable |
| Docker Compose | v2.40+ | CLI plugin, no `version:` field needed |
| Docker Desktop | 4.66 | Bundles Engine v29.x |
| PostgreSQL | 18.3 | Latest stable |
| MongoDB | 8.2.3 | Latest stable |
| Redis | 8.4.2 | Latest stable |
| Python | 3.14.3 | Latest stable |
| Node.js | 24.14.1 | LTS |
| Rust | 1.94.1 | Latest stable |
| Poetry | 2.3.3 | Latest stable |
| pnpm | 10.33.0 | Latest stable |

---

## 1. Boas Práticas de Docker

### Builds Multi-Stage

Multi-stage builds reduce image size by up to 97%. Separate build dependencies from runtime.

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

### Cache de Camadas

Order instructions from least to most frequently changing:

```dockerfile
# 1. Base image (rarely changes)
FROM node:24.14.1-slim

# 2. System deps (rarely changes)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Dependency files (changes when deps change)
COPY package.json pnpm-lock.yaml ./

# 4. Install deps (cached if lockfile unchanged)
RUN corepack enable && pnpm install --frozen-lockfile

# 5. Source code (changes frequently)
COPY src/ ./src/

# 6. Build step
RUN pnpm build
```

### Segurança

```dockerfile
# Use minimal base images
FROM python:3.14.3-slim          # NOT python:3.14.3
FROM node:24.14.1-slim           # NOT node:24.14.1
FROM rust:1.94.1-slim            # NOT rust:1.94.1

# Run as non-root
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Drop capabilities
# In compose.yaml:
# security_opt:
#   - no-new-privileges:true
# cap_drop:
#   - ALL

# Use .dockerignore
# .git
# node_modules
# .env
# *.md
# __pycache__
# .mypy_cache
# .pytest_cache
```

### Guia de Seleção de Imagens

| Use Case | Base Image | Size |
|----------|-----------|------|
| Python production | `python:3.14.3-slim` | ~150MB |
| Python minimal | `python:3.14.3-alpine` | ~50MB (watch for musl issues) |
| Node.js production | `node:24.14.1-slim` | ~200MB |
| Rust production | Multi-stage with `debian:bookworm-slim` runtime | ~80MB |
| Maximum security | `gcr.io/distroless/python3` | ~30MB |
| Scratch (static binaries) | `scratch` | ~5MB |

**Reference:** [references/docker/dockerfile-patterns.md](references/docker/dockerfile-patterns.md)

---

## 2. Padrões de Docker Compose

### Dependências de Serviços com Health Checks

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
    volumes:
      - redis_data:/data
    ports:
      - "${REDIS_PORT:-6379}:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  mongo:
    image: mongo:8.2.3
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_DB}
    volumes:
      - mongo_data:/data/db
      - ./init-scripts/mongo:/docker-entrypoint-initdb.d
    ports:
      - "${MONGO_PORT:-27017}:27017"
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
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
        restart: true  # restart api if redis restarts (Compose v2.21+)
    env_file: .env
    ports:
      - "${API_PORT:-8000}:8000"
    volumes:
      - ./src:/app/src:ro  # read-only bind mount for hot reload
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 15s

volumes:
  postgres_data:
  redis_data:
  mongo_data:
```

### Profiles do Compose

Use profiles to group optional services:

```yaml
services:
  api:
    # ... always runs

  postgres:
    # ... always runs

  adminer:
    image: adminer:4.8.1
    ports:
      - "8080:8080"
    profiles: ["debug"]

  mongo-express:
    image: mongo-express:1.0.2
    ports:
      - "8081:8081"
    profiles: ["debug"]

  prometheus:
    image: prom/prometheus:v3.2.1
    profiles: ["monitoring"]
```

```bash
# Run core only
docker compose up

# Run with debug tools
docker compose --profile debug up

# Run with monitoring
docker compose --profile monitoring up
```

### Modo Watch (Compose v2.22+)

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

**Reference:** [references/docker/compose-patterns.md](references/docker/compose-patterns.md)

---

## 3. Configuração de Bancos de Dados

### PostgreSQL

#### Initialization scripts

Files in `/docker-entrypoint-initdb.d/` run on first start (alphabetical order):

```sql
-- init-scripts/postgres/01-extensions.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "hstore";
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
    ('admin@example.com', 'Admin User'),
    ('test@example.com', 'Test User')
    ON CONFLICT (email) DO NOTHING;
EOSQL
```

#### Migrations with Alembic

```bash
# Generate migration
alembic revision --autogenerate -m "add_orders_table"

# Run migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

### MongoDB

#### Initialization scripts

```javascript
// init-scripts/mongo/01-init.js
db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || 'app');

db.createCollection('users');
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ created_at: -1 });

db.users.insertMany([
  { email: 'admin@example.com', name: 'Admin', role: 'admin', created_at: new Date() },
  { email: 'test@example.com', name: 'Test', role: 'user', created_at: new Date() }
]);
```

### Redis

#### Persistence and initialization

```yaml
redis:
  image: redis:8.4.2-alpine
  command: >
    redis-server
    --requirepass ${REDIS_PASSWORD}
    --appendonly yes
    --maxmemory 256mb
    --maxmemory-policy allkeys-lru
  volumes:
    - redis_data:/data
```

**Reference:** [references/databases/setup-patterns.md](references/databases/setup-patterns.md)

---

## 4. Gestão de .env

### Template pattern

```bash
# .env.example (committed to git -- never contains real secrets)
# === Database ===
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=change_me_in_local_env
DB_HOST=postgres
DB_PORT=5432
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}

# === Redis ===
REDIS_PASSWORD=change_me_in_local_env
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/0

# === MongoDB ===
MONGO_USER=root
MONGO_PASSWORD=change_me_in_local_env
MONGO_DB=myapp
MONGO_PORT=27017

# === API ===
API_PORT=8000
API_DEBUG=true
API_LOG_LEVEL=debug
```

### Validation with Pydantic

```python
from pydantic_settings import BaseSettings, SettingsConfigDict
class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # Database
    db_name: str
    db_user: str
    db_password: str
    db_host: str = "localhost"
    db_port: int = 5432

    # Redis
    redis_password: str
    redis_host: str = "localhost"
    redis_port: int = 6379

    # API
    api_port: int = 8000
    api_debug: bool = False
    api_log_level: str = "info"

    @property
    def database_url(self) -> str:
        return f"postgresql://{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}"

    @property
    def redis_url(self) -> str:
        return f"redis://:{self.redis_password}@{self.redis_host}:{self.redis_port}/0"
```

### Rules

1. **Never commit `.env`** -- only `.env.example`
2. **`.env.example` has no real secrets** -- placeholder values only
3. **Validate at startup** -- fail fast if required vars are missing
4. **Use variable interpolation in compose** -- `${VAR:-default}`
5. **Separate `.env` per environment** -- `.env.local`, `.env.test`

**Reference:** [references/orchestration/env-management.md](references/orchestration/env-management.md)

---

## 5. Orquestração de Serviços

### Ordem de Inicialização

```
depends_on with condition: service_healthy guarantees:
1. Dependency container is RUNNING
2. Dependency health check is PASSING
3. Only then does the dependent container start
```

### Recommended startup order

```
databases (postgres, mongo, redis)
  -> message brokers (rabbitmq, kafka)
    -> backend services (api, workers)
      -> frontend (web, admin)
        -> debug tools (adminer, mongo-express)
```

### Readiness vs Liveness

| Check | Purpose | When to use |
|-------|---------|-------------|
| **Readiness** | Can accept traffic? | `depends_on condition` |
| **Liveness** | Is still alive? | Container restart policy |

### Health Check Patterns

```yaml
# HTTP health check
healthcheck:
  test: ["CMD", "curl", "-sf", "http://localhost:8000/health"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 15s

# TCP port check (when curl not available)
healthcheck:
  test: ["CMD-SHELL", "nc -z localhost 8000 || exit 1"]
  interval: 5s
  timeout: 3s
  retries: 5

# PostgreSQL
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]

# Redis
healthcheck:
  test: ["CMD", "redis-cli", "ping"]

# MongoDB
healthcheck:
  test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]

# Custom command
healthcheck:
  test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8000/health').raise_for_status()"]
```

**Reference:** [references/orchestration/startup-order.md](references/orchestration/startup-order.md)

---

## 6. Gestão de Portas

### Default port assignments

| Service | Default Port | Convention |
|---------|-------------|------------|
| PostgreSQL | 5432 | Standard |
| MongoDB | 27017 | Standard |
| Redis | 6379 | Standard |
| API (Python) | 8000 | uvicorn default |
| API (Node.js) | 3000 | express/next default |
| Frontend dev | 5173 | Vite default |
| Adminer | 8080 | DB admin |
| Mongo Express | 8081 | DB admin |
| Prometheus | 9090 | Monitoring |
| Grafana | 3001 | Monitoring |

### Conflict resolution

```yaml
# Use env vars for all ports -- allows parallel projects
services:
  postgres:
    ports:
      - "${DB_PORT:-5432}:5432"
  api:
    ports:
      - "${API_PORT:-8000}:8000"
```

```bash
# Find what is using a port
lsof -i :8000
# or
ss -tlnp | grep 8000

# Kill process on port
kill $(lsof -t -i :8000)
```

### Multi-project strategy

```bash
# Project A: .env
DB_PORT=5432
API_PORT=8000

# Project B: .env
DB_PORT=5433
API_PORT=8001
```

---

## 7. Instalação de Dependências por Ecossistema

> **Pré-requisito obrigatório:** Antes de instalar qualquer dependência, executar o protocolo de verificação de segurança da skill `research` (seção 8). Verificar CVEs, manutenção da lib, e versão LTS/stable.

### Python (Poetry)

```dockerfile
FROM python:3.14.3-slim AS builder
RUN pip install poetry==2.3.3
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true && \
    poetry install --only=main --no-interaction --no-ansi
```

```bash
# Local
poetry install              # all deps (including dev)
poetry install --only=main  # production only
poetry add httpx            # add dependency
poetry lock                 # regenerate lockfile
```

### Python (pip)

```dockerfile
FROM python:3.14.3-slim
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```

### Node.js (pnpm)

```dockerfile
FROM node:24.14.1-slim
RUN corepack enable
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build
```

```bash
# Local
pnpm install              # all deps
pnpm install --prod       # production only
pnpm add zod              # add dependency
```

### Rust (Cargo)

```dockerfile
# Cache dependencies separately from source
FROM rust:1.94.1-slim AS builder
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main(){}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

COPY src/ ./src/
RUN cargo build --release

# Runtime: minimal image
FROM debian:bookworm-slim
COPY --from=builder /app/target/release/myapp /usr/local/bin/
CMD ["myapp"]
```

**Reference:** [references/docker/dependency-installation.md](references/docker/dependency-installation.md)

---

## 8. Streaming de Logs and Debugging

### Docker Compose logs

```bash
# Follow all service logs
docker compose logs -f

# Follow specific service
docker compose logs -f api

# Last 100 lines
docker compose logs --tail=100 api

# With timestamps
docker compose logs -f -t api

# Filter with grep
docker compose logs -f api 2>&1 | grep -i error
```

### Interactive debugging

```bash
# Shell into running container
docker compose exec api bash
docker compose exec api sh  # alpine images

# Run one-off command
docker compose run --rm api python -c "from src.config import Settings; print(Settings())"

# Database shell
docker compose exec postgres psql -U ${DB_USER} -d ${DB_NAME}
docker compose exec mongo mongosh -u ${MONGO_USER} -p ${MONGO_PASSWORD}
docker compose exec redis redis-cli -a ${REDIS_PASSWORD}
```

### Container inspection

```bash
# Resource usage
docker compose stats

# Container details
docker compose ps -a

# Inspect container config
docker inspect $(docker compose ps -q api)

# Check health status
docker inspect --format='{{.State.Health.Status}}' $(docker compose ps -q postgres)

# View container filesystem changes
docker diff $(docker compose ps -q api)
```

### Network debugging

```bash
# List networks
docker network ls

# DNS resolution inside container
docker compose exec api nslookup postgres

# Connectivity test
docker compose exec api curl -v http://postgres:5432
```

**Reference:** [references/debugging/log-streaming.md](references/debugging/log-streaming.md)

---

## 9. Watch Mode and Hot Reload

### Python (uvicorn)

```bash
# Direct
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# In compose with bind mount
services:
  api:
    command: uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
    volumes:
      - ./src:/app/src
```

### Node.js / TypeScript

```bash
# Vite dev server (auto-HMR)
pnpm dev

# Node.js with --watch (Node 22+)
node --watch src/server.ts

# tsx for TypeScript
npx tsx watch src/server.ts
```

### Docker Compose Watch (v2.22+)

```yaml
services:
  api:
    build: .
    develop:
      watch:
        # Sync source files without rebuilding
        - action: sync
          path: ./src
          target: /app/src

        # Rebuild when dependencies change
        - action: rebuild
          path: ./pyproject.toml

        # Sync + restart when config changes
        - action: sync+restart
          path: ./config
          target: /app/config
```

```bash
docker compose watch
```

| Action | Behavior | Use case |
|--------|----------|----------|
| `sync` | Copy files into container | Source code changes |
| `rebuild` | Rebuild and replace container | Dependency changes |
| `sync+restart` | Copy files + restart process | Config file changes |

---

## 10. Error Recovery Procedures

### Container won't start

```bash
# 1. Check logs
docker compose logs api

# 2. Check exit code
docker compose ps -a

# 3. Run shell to debug
docker compose run --rm api bash

# 4. Check Dockerfile
docker build --target runtime --no-cache .
```

### Database connection refused

```bash
# 1. Is the database healthy?
docker compose ps postgres
docker inspect --format='{{.State.Health.Status}}' $(docker compose ps -q postgres)

# 2. Can you connect from inside the network?
docker compose exec api nc -z postgres 5432

# 3. Check DNS resolution
docker compose exec api nslookup postgres

# 4. Check environment variables
docker compose exec api env | grep DB_

# 5. Nuclear: recreate
docker compose down -v  # WARNING: destroys data
docker compose up -d
```

### Port already in use

```bash
# Find the process
lsof -i :8000

# Kill it
kill $(lsof -t -i :8000)

# Or change the port in .env
API_PORT=8001
docker compose up -d
```

### Out of disk space

```bash
# Check disk usage
docker system df

# Clean up (safe)
docker system prune          # remove stopped containers, unused networks, dangling images

# Clean up (aggressive)
docker system prune -a       # also removes unused images
docker volume prune          # remove unused volumes (WARNING: data loss)

# Clean build cache
docker builder prune
```

### Volume data corruption

```bash
# 1. Stop services
docker compose down

# 2. Remove specific volume
docker volume rm myproject_postgres_data

# 3. Recreate
docker compose up -d
```

### Stale image / need full rebuild

```bash
# Rebuild without cache
docker compose build --no-cache

# Pull latest base images + rebuild
docker compose build --pull --no-cache

# Recreate containers
docker compose up -d --force-recreate
```

**Reference:** [references/debugging/error-recovery.md](references/debugging/error-recovery.md)

---

## 11. Multi-Service Orchestration Patterns

### Makefile for common tasks

```makefile
.PHONY: up down restart logs shell db-shell test clean

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart $(service)

logs:
	docker compose logs -f $(service)

shell:
	docker compose exec $(service) bash

db-shell:
	docker compose exec postgres psql -U $${DB_USER} -d $${DB_NAME}

db-migrate:
	docker compose exec api alembic upgrade head

db-rollback:
	docker compose exec api alembic downgrade -1

test:
	docker compose run --rm api pytest

clean:
	docker compose down -v --remove-orphans
	docker system prune -f

status:
	@docker compose ps
	@echo ""
	@docker compose stats --no-stream
```

### Full stack template

```
project/
  compose.yaml
  .env.example
  .env                    # git-ignored
  .dockerignore
  Dockerfile
  Makefile
  init-scripts/
    postgres/
      01-extensions.sql
      02-schema.sql
      03-seed.sh
    mongo/
      01-init.js
  src/
  tests/
```

---

## Quick Reference: Common Commands

```bash
# Lifecycle
docker compose up -d              # start all services detached
docker compose down               # stop and remove containers
docker compose restart api        # restart single service
docker compose stop               # stop without removing

# Build
docker compose build              # build all images
docker compose build --no-cache   # force rebuild
docker compose up -d --build      # rebuild + start

# Monitoring
docker compose ps                 # list services
docker compose logs -f            # follow all logs
docker compose stats              # resource usage
docker compose top                # running processes

# Debugging
docker compose exec api bash      # shell into container
docker compose run --rm api pytest  # one-off command
docker compose cp api:/app/logs . # copy files out

# Cleanup
docker compose down -v            # stop + remove volumes
docker system prune -a            # remove all unused resources
docker volume prune               # remove unused volumes
```

---

## References

### Docker
- [references/docker/dockerfile-patterns.md](references/docker/dockerfile-patterns.md) - Multi-stage, security, caching
- [references/docker/compose-patterns.md](references/docker/compose-patterns.md) - Compose advanced patterns
- [references/docker/dependency-installation.md](references/docker/dependency-installation.md) - Per-ecosystem installation

### Bancos de Dados
- [references/databases/setup-patterns.md](references/databases/setup-patterns.md) - PostgreSQL, MongoDB, Redis init/seed/migrate

### Orchestration
- [references/orchestration/env-management.md](references/orchestration/env-management.md) - .env validation and templates
- [references/orchestration/startup-order.md](references/orchestration/startup-order.md) - Service dependencies and readiness

### Debugging
- [references/debugging/log-streaming.md](references/debugging/log-streaming.md) - Logs, inspection, network debugging
- [references/debugging/error-recovery.md](references/debugging/error-recovery.md) - Common error recovery procedures
