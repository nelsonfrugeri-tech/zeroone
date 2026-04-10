#!/usr/bin/env bash
# zeroone status — compare repo vs ~/.claude/ and check infra health
set -euo pipefail

ZEROONE_HOME="${ZEROONE_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
CLAUDE_HOME="$HOME/.claude"

# --- Agent drift ---
echo "AGENTS"
for state in synced outdated missing orphaned; do
    declare "${state}="
done

for f in "$ZEROONE_HOME"/agents/*.md; do
    name=$(basename "$f")
    deployed="$CLAUDE_HOME/agents/$name"
    if [[ ! -f "$deployed" ]]; then
        missing="${missing:+$missing, }${name%.md}"
    elif diff -q "$f" "$deployed" >/dev/null 2>&1; then
        synced="${synced:+$synced, }${name%.md}"
    else
        outdated="${outdated:+$outdated, }${name%.md}"
    fi
done

for f in "$CLAUDE_HOME"/agents/*.md; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f")
    if [[ ! -f "$ZEROONE_HOME/agents/$name" ]]; then
        orphaned="${orphaned:+$orphaned, }${name%.md}"
    fi
done

printf "  synced:    %s\n" "${synced:-(none)}"
printf "  outdated:  %s\n" "${outdated:-(none)}"
printf "  missing:   %s\n" "${missing:-(none)}"
printf "  orphaned:  %s\n" "${orphaned:-(none)}"

# --- Skills drift ---
echo ""
echo "SKILLS"
synced="" outdated="" missing="" orphaned=""

for d in "$ZEROONE_HOME"/skills/*/; do
    [[ -d "$d" ]] || continue
    name=$(basename "$d")
    deployed="$CLAUDE_HOME/skills/$name"
    if [[ ! -d "$deployed" ]]; then
        missing="${missing:+$missing, }$name"
    elif diff -rq "$d" "$deployed" >/dev/null 2>&1; then
        synced="${synced:+$synced, }$name"
    else
        outdated="${outdated:+$outdated, }$name"
    fi
done

for d in "$CLAUDE_HOME"/skills/*/; do
    [[ -d "$d" ]] || continue
    name=$(basename "$d")
    if [[ ! -d "$ZEROONE_HOME/skills/$name" ]]; then
        orphaned="${orphaned:+$orphaned, }$name"
    fi
done

printf "  synced:    %s\n" "${synced:-(none)}"
printf "  outdated:  %s\n" "${outdated:-(none)}"
printf "  missing:   %s\n" "${missing:-(none)}"
printf "  orphaned:  %s\n" "${orphaned:-(none)}"

# --- Infra health ---
echo ""
echo "INFRA"

# Qdrant
if qdrant_resp=$(curl -s --max-time 3 http://localhost:6333/healthz 2>/dev/null); then
    qdrant_version=$(curl -s --max-time 3 http://localhost:6333/ 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('version','?'))" 2>/dev/null || echo "?")
    printf "  Qdrant     UP   v%-8s http://localhost:6333\n" "$qdrant_version"
else
    echo "  Qdrant     DOWN             http://localhost:6333"
fi

# Ollama
if curl -s --max-time 3 http://localhost:11434/ >/dev/null 2>&1; then
    echo "  Ollama     UP               http://localhost:11434"
else
    echo "  Ollama     DOWN             http://localhost:11434"
fi

# Embedding model
if ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
    echo "  nomic-embed-text   PRESENT"
else
    echo "  nomic-embed-text   MISSING"
fi
