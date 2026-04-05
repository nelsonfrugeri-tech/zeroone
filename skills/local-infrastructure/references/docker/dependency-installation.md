# Dependency Installation by Ecosystem

## Python

### Poetry (recommended)

```dockerfile
FROM python:3.14.3-slim AS builder
RUN pip install --no-cache-dir poetry==2.3.3
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true && \
    poetry install --only=main --no-interaction --no-ansi
```

Key flags:
- `virtualenvs.in-project true` -- creates .venv inside /app (easy to COPY)
- `--only=main` -- skip dev dependencies
- `--no-interaction --no-ansi` -- CI/Docker friendly

### pip + requirements.txt

```dockerfile
FROM python:3.14.3-slim
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```

### uv (fast alternative)

```dockerfile
FROM python:3.14.3-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
```

## Node.js

### pnpm (recommended)

```dockerfile
FROM node:24.14.0-slim
RUN corepack enable
WORKDIR /app
COPY package.json pnpm-lock.yaml .npmrc ./
RUN pnpm install --frozen-lockfile
```

### npm

```dockerfile
FROM node:24.14.0-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
```

## Rust

### Cargo (with dependency caching trick)

```dockerfile
FROM rust:1.94.1-slim AS builder
WORKDIR /app

# Cache dependencies: build with dummy source
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main(){}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# Build real source (deps already cached)
COPY src/ ./src/
RUN touch src/main.rs && cargo build --release
```

## Common Patterns

### Cache mounts (BuildKit)

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.14.3-slim
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

FROM node:24.14.0-slim
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

FROM rust:1.94.1-slim
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release
```

### Bind mounts for lockfiles

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=pnpm-lock.yaml,target=pnpm-lock.yaml \
    pnpm install --frozen-lockfile
```
