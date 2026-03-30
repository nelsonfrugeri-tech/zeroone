"""Semantic Memory MCP Server — shared vector memory for Claude Code agents.

Stores and retrieves memories via Qdrant (vector DB) + Ollama (embeddings).
No LLM needed — Claude Code handles intelligence (fact extraction, summarization).
This server is a pure storage + semantic search layer.
"""

from __future__ import annotations

import json
import os
import uuid
from datetime import datetime, timezone

import httpx
from mcp.server.fastmcp import FastMCP
from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance,
    FieldCondition,
    Filter,
    MatchValue,
    PointStruct,
    VectorParams,
)

mcp = FastMCP(name="mem0")

# ---------------------------------------------------------------------------
# Configuration (all via env vars)
# ---------------------------------------------------------------------------

QDRANT_HOST = os.environ.get("QDRANT_HOST", "localhost")
QDRANT_PORT = int(os.environ.get("QDRANT_PORT", "6333"))
COLLECTION = os.environ.get("MEM0_COLLECTION", "claude-code-memory")
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
EMBED_MODEL = os.environ.get("OLLAMA_EMBED_MODEL", "nomic-embed-text")
EMBED_DIMS = int(os.environ.get("OLLAMA_EMBED_DIMS", "768"))
DEFAULT_USER = os.environ.get("MEM0_USER_ID", "claude-code")

# ---------------------------------------------------------------------------
# Clients (lazy singletons)
# ---------------------------------------------------------------------------

_qdrant: QdrantClient | None = None
_http: httpx.Client | None = None


def get_qdrant() -> QdrantClient:
    global _qdrant
    if _qdrant is None:
        _qdrant = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
        # Ensure collection exists
        collections = [c.name for c in _qdrant.get_collections().collections]
        if COLLECTION not in collections:
            _qdrant.create_collection(
                collection_name=COLLECTION,
                vectors_config=VectorParams(size=EMBED_DIMS, distance=Distance.COSINE),
            )
    return _qdrant


def get_http() -> httpx.Client:
    global _http
    if _http is None:
        _http = httpx.Client(timeout=30.0)
    return _http


def embed(text: str) -> list[float]:
    """Get embedding vector from Ollama."""
    resp = get_http().post(
        f"{OLLAMA_URL}/api/embed",
        json={"model": EMBED_MODEL, "input": text},
    )
    resp.raise_for_status()
    return resp.json()["embeddings"][0]


# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------


@mcp.tool()
async def mem0_store(
    content: str,
    memory_type: str = "general",
    project: str = "",
    tags: str = "",
    user_id: str = "",
) -> str:
    """Store a memory in shared semantic storage. Content should be pre-processed
    (extracted facts, summaries) by Claude Code before storing.

    Args:
        content: The memory content to store. Should be concise, factual, and self-contained.
        memory_type: Category — feedback, project, reference, decision, procedural, general,
            task_claim, blocker, progress, conflict (coordination types for multi-agent).
        project: Project name (empty for cross-project memories).
        tags: Comma-separated tags (e.g. "architecture,python").
        user_id: Memory scope/owner (defaults to MEM0_USER_ID env var). Use shared ID
            (e.g. "oracle-team") for cross-instance coordination memories.
    """
    uid = user_id or DEFAULT_USER

    try:
        vector = embed(content)
        point_id = str(uuid.uuid4())
        payload = {
            "content": content,
            "user_id": uid,
            "type": memory_type,
            "stored_at": datetime.now(timezone.utc).isoformat(),
        }
        if project:
            payload["project"] = project
        if tags:
            payload["tags"] = tags

        get_qdrant().upsert(
            collection_name=COLLECTION,
            points=[PointStruct(id=point_id, vector=vector, payload=payload)],
        )
        return json.dumps({"status": "stored", "id": point_id, "user_id": uid})
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def mem0_recall(
    query: str,
    limit: int = 10,
    user_id: str = "",
) -> str:
    """Semantic search across all memories. Use before starting work to get context.

    Args:
        query: Natural language query (e.g. "language preferences", "bike-shop architecture").
        limit: Maximum results (default 10).
        user_id: Filter by owner (defaults to MEM0_USER_ID env var).
    """
    uid = user_id or DEFAULT_USER

    try:
        vector = embed(query)
        results = get_qdrant().query_points(
            collection_name=COLLECTION,
            query=vector,
            query_filter=Filter(
                must=[FieldCondition(key="user_id", match=MatchValue(value=uid))]
            ),
            limit=limit,
            with_payload=True,
        )

        memories = []
        for point in results.points:
            p = point.payload or {}
            memories.append({
                "id": str(point.id),
                "content": p.get("content", ""),
                "score": round(point.score, 4),
                "type": p.get("type", "general"),
                "project": p.get("project", ""),
                "tags": p.get("tags", ""),
                "stored_at": p.get("stored_at", ""),
            })

        return json.dumps({"query": query, "count": len(memories), "memories": memories})
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def mem0_search(
    query: str,
    memory_type: str = "",
    project: str = "",
    limit: int = 10,
    user_id: str = "",
) -> str:
    """Search memories with filters by type and/or project.

    Args:
        query: Natural language search query.
        memory_type: Filter by type — feedback, project, reference, decision, procedural, general,
            task_claim, blocker, progress, conflict (coordination types for multi-agent).
        project: Filter by project name.
        limit: Maximum results (default 10).
        user_id: Filter by owner (defaults to MEM0_USER_ID env var).
    """
    uid = user_id or DEFAULT_USER

    try:
        vector = embed(query)
        conditions = [
            FieldCondition(key="user_id", match=MatchValue(value=uid))
        ]
        if memory_type:
            conditions.append(
                FieldCondition(key="type", match=MatchValue(value=memory_type))
            )
        if project:
            conditions.append(
                FieldCondition(key="project", match=MatchValue(value=project))
            )

        results = get_qdrant().query_points(
            collection_name=COLLECTION,
            query=vector,
            query_filter=Filter(must=conditions),
            limit=limit,
            with_payload=True,
        )

        memories = []
        for point in results.points:
            p = point.payload or {}
            memories.append({
                "id": str(point.id),
                "content": p.get("content", ""),
                "score": round(point.score, 4),
                "type": p.get("type", "general"),
                "project": p.get("project", ""),
                "tags": p.get("tags", ""),
                "stored_at": p.get("stored_at", ""),
            })

        return json.dumps({"query": query, "count": len(memories), "memories": memories})
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def mem0_list(
    user_id: str = "",
    limit: int = 50,
) -> str:
    """List all stored memories.

    Args:
        user_id: Filter by owner (defaults to MEM0_USER_ID env var).
        limit: Maximum memories to return (default 50).
    """
    uid = user_id or DEFAULT_USER

    try:
        results = get_qdrant().scroll(
            collection_name=COLLECTION,
            scroll_filter=Filter(
                must=[FieldCondition(key="user_id", match=MatchValue(value=uid))]
            ),
            limit=limit,
            with_payload=True,
            with_vectors=False,
        )

        memories = []
        for point in results[0]:
            p = point.payload or {}
            memories.append({
                "id": str(point.id),
                "content": p.get("content", ""),
                "type": p.get("type", "general"),
                "project": p.get("project", ""),
                "tags": p.get("tags", ""),
                "stored_at": p.get("stored_at", ""),
            })

        return json.dumps({"count": len(memories), "memories": memories})
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def mem0_delete(
    memory_id: str = "",
    user_id: str = "",
    delete_all: bool = False,
) -> str:
    """Delete a specific memory by ID, or all memories for a user.

    Args:
        memory_id: The ID of the memory to delete (from recall/search results).
        user_id: Memory scope (defaults to MEM0_USER_ID env var).
        delete_all: If true, deletes ALL memories for user_id. Use with caution.
    """
    uid = user_id or DEFAULT_USER

    try:
        qdrant = get_qdrant()
        if delete_all:
            qdrant.delete(
                collection_name=COLLECTION,
                points_selector=Filter(
                    must=[FieldCondition(key="user_id", match=MatchValue(value=uid))]
                ),
            )
            return json.dumps({"status": "deleted_all", "user_id": uid})
        elif memory_id:
            qdrant.delete(
                collection_name=COLLECTION,
                points_selector=[memory_id],
            )
            return json.dumps({"status": "deleted", "memory_id": memory_id})
        else:
            return json.dumps(
                {"status": "error", "error": "Provide memory_id or set delete_all=true"}
            )
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def mem0_update(
    memory_id: str,
    content: str,
) -> str:
    """Update an existing memory's content (re-embeds automatically).

    Args:
        memory_id: The ID of the memory to update.
        content: The new content for this memory.
    """
    try:
        qdrant = get_qdrant()
        # Get existing point to preserve metadata
        points = qdrant.retrieve(collection_name=COLLECTION, ids=[memory_id])
        if not points:
            return json.dumps({"status": "error", "error": f"Memory {memory_id} not found"})

        old_payload = points[0].payload or {}
        old_payload["content"] = content
        old_payload["updated_at"] = datetime.now(timezone.utc).isoformat()

        vector = embed(content)
        qdrant.upsert(
            collection_name=COLLECTION,
            points=[PointStruct(id=memory_id, vector=vector, payload=old_payload)],
        )
        return json.dumps({"status": "updated", "memory_id": memory_id})
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run(transport="stdio")
