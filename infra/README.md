# Memory Infrastructure

This directory contains the infrastructure configuration for the zeroone memory layer.

## Architecture

The memory stack has two components:

| Component | Runtime | Purpose |
|---|---|---|
| **Qdrant** | Docker (via compose) | Vector database — stores and searches agent memories |
| **Ollama** | Native (host) | Embedding model runtime — generates `nomic-embed-text` embeddings |

Ollama runs natively (not containerized) to access GPU acceleration directly. Containerized inference lacks GPU passthrough on consumer hardware and runs orders of magnitude slower. See [CLAUDE.md](../CLAUDE.md) — Local AI Performance principle.

## Starting the Infrastructure

### 1. Start Qdrant

```bash
cd infra
docker compose up -d
```

Verify Qdrant is healthy:

```bash
curl http://localhost:6333/healthz
# Expected: {"title":"qdrant - vector search engine","version":"1.17.1"}
```

### 2. Start Ollama (native)

```bash
# Start the Ollama server (if not already running as a system service)
ollama serve
```

### 3. Pull the embedding model

```bash
ollama pull nomic-embed-text
```

Verify the model is available:

```bash
ollama list
# Expected: nomic-embed-text listed with size ~274 MB
```

## Ports

| Service | Port | Protocol |
|---|---|---|
| Qdrant HTTP API | 6333 | HTTP |
| Qdrant gRPC API | 6334 | gRPC |
| Ollama API | 11434 | HTTP |

## Stopping the Infrastructure

```bash
cd infra
docker compose down
```

To remove all stored data (destructive — deletes all agent memories):

```bash
docker compose down -v
```

## Data Persistence

Qdrant data is stored in a named Docker volume (`qdrant_data`). This volume persists across `docker compose down` and `docker compose up` cycles. Data is only lost when you explicitly remove the volume with `docker compose down -v`.

## Health Check

Use the `zeroone` agent to verify the full stack is operational:

```
claude --agent zeroone
> status
```

Or check manually:

```bash
# Qdrant
curl -s http://localhost:6333/healthz

# Ollama
curl -s http://localhost:11434/

# Embedding model
ollama list | grep nomic-embed-text
```

## Troubleshooting

**Qdrant container fails to start:**
Check port conflicts: `lsof -i :6333`

**Ollama not found:**
Install from https://ollama.com — native binary, no Docker required.

**nomic-embed-text not found:**
Run `ollama pull nomic-embed-text` — the Mem0 MCP server requires this model for embeddings.

**Mem0 cannot connect to Qdrant:**
Verify the container is running: `docker compose ps`
Check the MCP server is configured with `QDRANT_HOST=localhost` and `QDRANT_PORT=6333`.
