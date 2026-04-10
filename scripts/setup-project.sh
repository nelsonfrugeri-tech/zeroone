#!/usr/bin/env bash
# zeroone setup — create project workspace and Qdrant collection
set -euo pipefail

PROJECT="${1:?Usage: setup-project.sh <project-name>}"
ZEROONE_HOME="${ZEROONE_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
WORKSPACE="$ZEROONE_HOME/workspaces/$PROJECT"

# Create workspace
if [[ -d "$WORKSPACE" ]]; then
    echo "Workspace already exists: $WORKSPACE"
else
    echo "Creating workspace: $WORKSPACE"
    mkdir -p "$WORKSPACE"

    cat > "$WORKSPACE/context.md" << 'TMPL'
# Project Context

## Overview
<!-- Project description, purpose, and scope -->

## Stack
<!-- Languages, frameworks, databases, infrastructure -->

## Conventions
<!-- Coding standards, naming conventions, patterns -->
TMPL

    cat > "$WORKSPACE/decisions.md" << 'TMPL'
# Architecture Decisions

<!-- Log decisions as they are made. Format:
## YYYY-MM-DD — Decision Title
**Context:** Why this decision was needed
**Decision:** What was decided
**Consequences:** What changes as a result
-->
TMPL

    cat > "$WORKSPACE/runbook.md" << 'TMPL'
# Operational Runbook

## Setup
<!-- How to set up the local development environment -->

## Deploy
<!-- How to deploy to production -->

## Troubleshooting
<!-- Common issues and solutions -->
TMPL

    echo "  Created context.md, decisions.md, runbook.md"
fi

# Create Qdrant collection
echo ""
echo "Checking Qdrant..."
if ! curl -s --max-time 3 http://localhost:6333/healthz >/dev/null 2>&1; then
    echo "ERROR: Qdrant is not running. Start it first: docker compose -f $ZEROONE_HOME/infra/docker-compose.yml up -d"
    exit 1
fi

if curl -s http://localhost:6333/collections/"$PROJECT" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('status')=='ok' else 1)" 2>/dev/null; then
    echo "  Collection '$PROJECT' already exists"
else
    echo "  Creating collection '$PROJECT'..."
    curl -s -X PUT "http://localhost:6333/collections/$PROJECT" \
        -H 'Content-Type: application/json' \
        -d '{"vectors": {"size": 768, "distance": "Cosine"}}' >/dev/null
    echo "  Collection '$PROJECT' created (768 dims, Cosine)"
fi

echo ""
echo "Project '$PROJECT' is ready."
