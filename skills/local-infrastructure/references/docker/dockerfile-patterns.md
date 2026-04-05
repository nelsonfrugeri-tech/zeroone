# Dockerfile Patterns

## Multi-Stage Build: Python (Poetry)

```dockerfile
# === Stage 1: Dependencies ===
FROM python:3.14.3-slim AS deps
WORKDIR /app
RUN pip install --no-cache-dir poetry==2.3.3
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true && \
    poetry install --only=main --no-interaction --no-ansi

# === Stage 2: Build (if compilation needed) ===
FROM deps AS builder
COPY src/ ./src/
# Run any build steps (compile, generate, etc.)

# === Stage 3: Runtime ===
FROM python:3.14.3-slim AS runtime
WORKDIR /app

# Security: non-root user
RUN groupadd -r app && useradd -r -g app -d /app -s /sbin/nologin app

# Copy only what's needed
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/src /app/src

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER app
EXPOSE 8000
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Multi-Stage Build: Node.js (pnpm)

```dockerfile
# === Stage 1: Dependencies ===
FROM node:24.14.0-slim AS deps
RUN corepack enable
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# === Stage 2: Build ===
FROM deps AS builder
COPY . .
RUN pnpm build

# === Stage 3: Runtime ===
FROM node:24.14.0-slim AS runtime
RUN corepack enable
WORKDIR /app

RUN groupadd -r app && useradd -r -g app app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package.json ./

USER app
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

## Multi-Stage Build: Rust

```dockerfile
# === Stage 1: Dependency cache ===
FROM rust:1.94.1-slim AS deps
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main(){}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# === Stage 2: Build ===
FROM deps AS builder
COPY src/ ./src/
RUN touch src/main.rs && cargo build --release

# === Stage 3: Runtime (minimal) ===
FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r app && useradd -r -g app app
COPY --from=builder /app/target/release/myapp /usr/local/bin/

USER app
CMD ["myapp"]
```

## .dockerignore Template

```
.git
.gitignore
.env
.env.*
*.md
LICENSE
docker-compose*.yml
compose*.yaml
Dockerfile*
Makefile

# Python
__pycache__
*.pyc
.mypy_cache
.pytest_cache
.ruff_cache
.venv
htmlcov

# Node
node_modules
.next
dist
coverage

# Rust
target

# IDE
.vscode
.idea
*.swp
```

## Security Checklist

1. **Base image**: Use `-slim` variants, never full images
2. **Non-root**: Always `USER app` (never run as root)
3. **No secrets in image**: Use build args for build-time, env vars for runtime
4. **Pin versions**: Base image tags, system packages, language packages
5. **Minimize layers**: Combine RUN commands with `&&`
6. **Clean up**: Remove apt lists, pip cache, build tools in same layer
7. **Read-only root**: Use `--read-only` flag in compose when possible
8. **No new privileges**: Set `security_opt: [no-new-privileges:true]`
9. **Drop capabilities**: `cap_drop: [ALL]`, add back only what's needed
10. **Scan images**: `docker scout cves <image>` or Trivy
