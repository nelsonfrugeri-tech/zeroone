#!/usr/bin/env bash
# zeroone bootstrap — complete first-run setup
# Usage: git clone <repo> && cd zeroone && scripts/bootstrap.sh
set -euo pipefail

ZEROONE_HOME="${ZEROONE_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
CLAUDE_HOME="$HOME/.claude"

echo "=== zeroone bootstrap ==="
echo ""

# --- 1. Prerequisites ---
echo "[1/6] Prerequisites"

# uv (Python package manager)
if command -v uv >/dev/null 2>&1; then
    echo "  uv: $(uv --version 2>/dev/null)"
else
    echo "  Installing uv..."
    brew install uv
    echo "  uv: installed"
fi

# docker
if command -v docker >/dev/null 2>&1; then
    echo "  docker: $(docker --version 2>/dev/null | head -1)"
else
    echo "  ERROR: docker not found. Install Docker Desktop first."
    echo "         https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# --- 2. Ollama ---
echo ""
echo "[2/6] Ollama"
if command -v ollama >/dev/null 2>&1; then
    echo "  installed: $(ollama --version 2>/dev/null || echo 'yes')"
else
    echo "  Installing ollama..."
    brew install ollama
    echo "  installed"
fi

if curl -s --max-time 3 http://localhost:11434/ >/dev/null 2>&1; then
    echo "  running: http://localhost:11434"
else
    echo "  Starting ollama..."
    ollama serve &>/dev/null &
    for i in $(seq 1 10); do
        if curl -s --max-time 2 http://localhost:11434/ >/dev/null 2>&1; then
            echo "  running: http://localhost:11434"
            break
        fi
        if [[ $i -eq 10 ]]; then
            echo "  ERROR: ollama failed to start"
            exit 1
        fi
        sleep 1
    done
fi

# --- 3. Embedding model ---
echo ""
echo "[3/6] Embedding model"
if ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
    echo "  nomic-embed-text: present"
else
    echo "  Pulling nomic-embed-text..."
    ollama pull nomic-embed-text
    echo "  nomic-embed-text: pulled"
fi

# --- 4. Qdrant ---
echo ""
echo "[4/6] Qdrant"
if curl -s --max-time 3 http://localhost:6333/healthz >/dev/null 2>&1; then
    echo "  running: http://localhost:6333"
else
    echo "  Starting qdrant via docker..."
    if docker ps -a --format '{{.Names}}' | grep -q '^qdrant$'; then
        docker start qdrant
    else
        docker run -d --name qdrant \
            -p 6333:6333 -p 6334:6334 \
            -v qdrant_storage:/qdrant/storage \
            qdrant/qdrant:latest
    fi
    echo "  Waiting for qdrant..."
    for i in $(seq 1 10); do
        if curl -s --max-time 2 http://localhost:6333/healthz >/dev/null 2>&1; then
            echo "  running: http://localhost:6333"
            break
        fi
        if [[ $i -eq 10 ]]; then
            echo "  ERROR: qdrant failed to start"
            exit 1
        fi
        sleep 1
    done
fi

# --- 5. Mem0 MCP server ---
echo ""
echo "[5/6] Mem0 MCP server"
MEM0_DIR="$ZEROONE_HOME/mcp/mem0-server"
if [[ -d "$MEM0_DIR" ]]; then
    echo "  Installing dependencies..."
    (cd "$MEM0_DIR" && uv sync --quiet)
    echo "  deps installed (uv sync)"
    # Verify imports
    if (cd "$MEM0_DIR" && uv run python -c "from qdrant_client import QdrantClient; from mcp.server.fastmcp import FastMCP; print('OK')" 2>/dev/null); then
        echo "  verified: imports OK"
    else
        echo "  WARNING: import verification failed"
    fi
else
    echo "  SKIP: $MEM0_DIR not found"
fi

# --- 6. Sync ---
echo ""
echo "[6/6] Sync"
# Deploy everything to ~/.claude/ (bypass git check during bootstrap)
mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"

# Agents
cp "$ZEROONE_HOME"/agents/*.md "$CLAUDE_HOME/agents/"
echo "  $(ls "$ZEROONE_HOME"/agents/*.md | wc -l | tr -d ' ') agents deployed"

# Skills
rsync -a --delete "$ZEROONE_HOME/skills/" "$CLAUDE_HOME/skills/"
echo "  $(ls -d "$ZEROONE_HOME"/skills/*/ | wc -l | tr -d ' ') skills deployed"

# Settings
cp "$ZEROONE_HOME/config/settings.base.json" "$CLAUDE_HOME/settings.json"
echo "  settings.json deployed"

# Global CLAUDE.md
cp "$ZEROONE_HOME/config/CLAUDE.global.md" "$CLAUDE_HOME/CLAUDE.md"
echo "  CLAUDE.md deployed"

# MCP (absolute paths)
python3 -c "
import json

with open('$ZEROONE_HOME/.mcp.json.example') as f:
    config = json.load(f)

for name, server in config.get('mcpServers', {}).items():
    args = server.get('args', [])
    for i, arg in enumerate(args):
        if arg.startswith('mcp/') or arg.startswith('mcp-servers/'):
            args[i] = '$ZEROONE_HOME/' + arg

with open('$ZEROONE_HOME/.mcp.json', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"
echo "  .mcp.json deployed"

echo ""
echo "=== bootstrap complete ==="
echo ""

# Run status to confirm
bash "$ZEROONE_HOME/scripts/status.sh"
