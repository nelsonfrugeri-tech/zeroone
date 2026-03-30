"""GitHub MCP Server — agnostic GitHub operations for Claude Code agents.

Each agent authenticates via its own GitHub App (JWT → installation token).
Built-in validation enforces documentation standards before PR creation.
"""

from __future__ import annotations

import json
import logging
import os
import subprocess
import time
from pathlib import Path
from typing import Annotated

import httpx
import jwt
from mcp.server.fastmcp import FastMCP
from pydantic import Field

logger = logging.getLogger(__name__)

mcp = FastMCP(name="github")

# ---------------------------------------------------------------------------
# GitHub App registry — maps agent names to their GitHub App credentials
# ---------------------------------------------------------------------------

_APPS_REGISTRY: dict | None = None


def _load_registry() -> dict:
    """Load agent → GitHub App mapping from config."""
    global _APPS_REGISTRY
    if _APPS_REGISTRY is not None:
        return _APPS_REGISTRY

    config_path = os.environ.get(
        "GITHUB_APPS_CONFIG",
        os.path.join(os.path.dirname(__file__), "apps.json"),
    )
    try:
        with open(config_path) as f:
            _APPS_REGISTRY = json.load(f)
    except FileNotFoundError:
        _APPS_REGISTRY = {}
        logger.warning("No apps.json found at %s — agent auth will fail", config_path)
    return _APPS_REGISTRY


def _get_installation_token(agent_name: str) -> tuple[str, str]:
    """Get a GitHub installation token for the given agent's App.

    Returns (token, app_slug) tuple.
    Raises ToolError-compatible ValueError on failure.
    """
    registry = _load_registry()
    agent_key = agent_name.lower().replace(" ", "-")

    app_config = registry.get(agent_key)
    if not app_config:
        available = ", ".join(sorted(registry.keys())) or "(none)"
        raise ValueError(
            f"No GitHub App configured for agent '{agent_name}'. "
            f"Available agents: {available}. "
            f"Add this agent to apps.json."
        )

    app_id = app_config["app_id"]
    pem_path = os.path.expanduser(app_config["pem_path"])
    installation_id = app_config["installation_id"]
    app_slug = app_config.get("slug", agent_key)

    if not os.path.isfile(pem_path):
        raise ValueError(f"PEM file not found: {pem_path}")

    with open(pem_path) as f:
        private_key = f.read()

    now = int(time.time())
    payload = {"iat": now - 60, "exp": now + 600, "iss": str(app_id)}
    token = jwt.encode(payload, private_key, algorithm="RS256")

    with httpx.Client() as client:
        resp = client.post(
            f"https://api.github.com/app/installations/{installation_id}/access_tokens",
            headers={
                "Authorization": f"Bearer {token}",
                "Accept": "application/vnd.github+json",
            },
        )
        resp.raise_for_status()
        inst_token = resp.json()["token"]

    return inst_token, app_slug


def _get_pat_token() -> str:
    """Get the personal access token for operations that don't use App auth."""
    token = os.environ.get("GITHUB_PERSONAL_ACCESS_TOKEN", "")
    if not token:
        raise ValueError(
            "GITHUB_PERSONAL_ACCESS_TOKEN env var not set. "
            "Required for issue creation."
        )
    return token


# ---------------------------------------------------------------------------
# PR validation — enforces documentation standards
# ---------------------------------------------------------------------------


def _validate_pr_docs(project_dir: str) -> dict:
    """Check if required docs are updated in the current branch diff.

    Returns {"allowed": bool, "errors": [...], "warnings": [...]}.
    """
    errors: list[str] = []
    warnings: list[str] = []

    try:
        base = subprocess.run(
            ["git", "symbolic-ref", "refs/remotes/origin/HEAD"],
            capture_output=True, text=True, cwd=project_dir,
        )
        base_branch = base.stdout.strip().replace("refs/remotes/origin/", "") if base.returncode == 0 else "main"

        diff = subprocess.run(
            ["git", "diff", "--name-only", f"{base_branch}...HEAD"],
            capture_output=True, text=True, cwd=project_dir,
        )
        if diff.returncode != 0:
            diff = subprocess.run(
                ["git", "diff", "--name-only", "HEAD~1"],
                capture_output=True, text=True, cwd=project_dir,
            )
        changed = diff.stdout.strip().split("\n") if diff.stdout.strip() else []
    except Exception as e:
        warnings.append(f"Could not check git diff: {e}")
        return {"allowed": True, "errors": errors, "warnings": warnings}

    # CHANGELOG is mandatory
    if not any("CHANGELOG" in f for f in changed):
        errors.append("CHANGELOG.md not updated in this branch. Update it before opening the PR.")

    # README is a warning
    if not any("README" in f for f in changed):
        warnings.append("README.md not updated — verify if changes affect documented features.")

    # API collections (Postman/Insomnia/Bruno) — warning if they exist but weren't updated
    has_api_collections = False
    for pattern in ["postman_collection.json", "insomnia.json", "bruno"]:
        check = subprocess.run(
            ["find", project_dir, "-name", f"*{pattern}*", "-maxdepth", "3"],
            capture_output=True, text=True,
        )
        if check.stdout.strip():
            has_api_collections = True
            break

    if has_api_collections:
        code_changed = any(f.endswith((".py", ".ts", ".js", ".go", ".rs")) for f in changed)
        collections_changed = any("postman" in f or "insomnia" in f or "bruno" in f for f in changed)
        if code_changed and not collections_changed:
            warnings.append("API collection files exist but were not updated — verify if endpoints changed.")

    return {
        "allowed": len(errors) == 0,
        "errors": errors,
        "warnings": warnings,
    }


# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------


@mcp.tool()
async def github_create_pr(
    repo: Annotated[str, Field(description="Repository in owner/repo format")],
    title: Annotated[str, Field(description="PR title (max 256 chars)", max_length=256)],
    body: Annotated[str, Field(description="PR body/description in markdown")],
    head: Annotated[str, Field(description="Source branch name")],
    agent_name: Annotated[str, Field(description="Agent creating this PR (must match apps.json)")],
    base: Annotated[str, Field(description="Target branch")] = "main",
    draft: Annotated[bool, Field(description="Create as draft PR")] = False,
    project_dir: Annotated[str, Field(description="Local project directory for doc validation")] = "",
) -> str:
    """Create a Pull Request via the agent's GitHub App identity.

    VALIDATES before creating:
    - CHANGELOG.md must be updated (mandatory — blocks PR if missing)
    - README.md update check (warning if not updated)
    - API collection files check (warning if code changed but collections didn't)

    The PR is created under the agent's GitHub App bot identity, not the user's.
    """
    # Step 1: Validate documentation
    if project_dir:
        validation = _validate_pr_docs(project_dir)
        if not validation["allowed"]:
            return json.dumps({
                "status": "blocked",
                "errors": validation["errors"],
                "warnings": validation["warnings"],
                "message": "PR creation blocked. Fix the errors above and try again.",
            })
    else:
        validation = {"warnings": ["No project_dir provided — doc validation skipped."]}

    # Step 2: Get installation token for this agent's App
    try:
        token, app_slug = _get_installation_token(agent_name)
    except ValueError as e:
        return json.dumps({"status": "error", "error": str(e)})

    # Step 3: Create PR
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"https://api.github.com/repos/{repo}/pulls",
                headers={
                    "Authorization": f"token {token}",
                    "Accept": "application/vnd.github+json",
                },
                json={
                    "title": title,
                    "body": body,
                    "head": head,
                    "base": base,
                    "draft": draft,
                },
            )
            resp.raise_for_status()
            pr = resp.json()

        result = {
            "status": "created",
            "pr_url": pr["html_url"],
            "pr_number": pr["number"],
            "created_by": app_slug,
            "agent": agent_name,
        }
        if validation.get("warnings"):
            result["warnings"] = validation["warnings"]
        return json.dumps(result)

    except httpx.HTTPStatusError as e:
        error_body = e.response.json() if e.response.content else {}
        return json.dumps({
            "status": "error",
            "http_status": e.response.status_code,
            "error": error_body.get("message", str(e)),
            "errors": error_body.get("errors", []),
        })
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def github_create_issue(
    repo: Annotated[str, Field(description="Repository in owner/repo format")],
    title: Annotated[str, Field(description="Issue title")],
    body: Annotated[str, Field(description="Issue body in markdown")] = "",
    labels: Annotated[str, Field(description="Comma-separated labels")] = "",
    agent_name: Annotated[str, Field(description="Agent creating this issue (must match apps.json)")] = "",
) -> str:
    """Create a GitHub issue.

    Uses the agent's GitHub App if agent_name is provided,
    otherwise falls back to GITHUB_PERSONAL_ACCESS_TOKEN.
    """
    try:
        if agent_name:
            token, app_slug = _get_installation_token(agent_name)
        else:
            token = _get_pat_token()
            app_slug = "pat"
    except ValueError as e:
        return json.dumps({"status": "error", "error": str(e)})

    payload: dict = {"title": title}
    if body:
        payload["body"] = body
    if labels:
        payload["labels"] = [l.strip() for l in labels.split(",")]

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"https://api.github.com/repos/{repo}/issues",
                headers={
                    "Authorization": f"token {token}",
                    "Accept": "application/vnd.github+json",
                },
                json=payload,
            )
            resp.raise_for_status()
            issue = resp.json()

        return json.dumps({
            "status": "created",
            "issue_url": issue["html_url"],
            "issue_number": issue["number"],
            "created_by": app_slug,
        })
    except httpx.HTTPStatusError as e:
        error_body = e.response.json() if e.response.content else {}
        return json.dumps({
            "status": "error",
            "http_status": e.response.status_code,
            "error": error_body.get("message", str(e)),
        })
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def github_add_comment(
    repo: Annotated[str, Field(description="Repository in owner/repo format")],
    issue_number: Annotated[int, Field(description="Issue or PR number")],
    body: Annotated[str, Field(description="Comment body in markdown")],
    agent_name: Annotated[str, Field(description="Agent posting this comment (must match apps.json)")],
) -> str:
    """Add a comment to an issue or PR via the agent's GitHub App identity."""
    try:
        token, app_slug = _get_installation_token(agent_name)
    except ValueError as e:
        return json.dumps({"status": "error", "error": str(e)})

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"https://api.github.com/repos/{repo}/issues/{issue_number}/comments",
                headers={
                    "Authorization": f"token {token}",
                    "Accept": "application/vnd.github+json",
                },
                json={"body": body},
            )
            resp.raise_for_status()
            comment = resp.json()

        return json.dumps({
            "status": "created",
            "comment_url": comment["html_url"],
            "comment_id": comment["id"],
            "created_by": app_slug,
        })
    except httpx.HTTPStatusError as e:
        error_body = e.response.json() if e.response.content else {}
        return json.dumps({
            "status": "error",
            "http_status": e.response.status_code,
            "error": error_body.get("message", str(e)),
        })
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def github_close_pr(
    repo: Annotated[str, Field(description="Repository in owner/repo format")],
    pr_number: Annotated[int, Field(description="PR number to close")],
    agent_name: Annotated[str, Field(description="Agent closing this PR (must match apps.json)")],
) -> str:
    """Close a Pull Request via the agent's GitHub App identity."""
    try:
        token, app_slug = _get_installation_token(agent_name)
    except ValueError as e:
        return json.dumps({"status": "error", "error": str(e)})

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.patch(
                f"https://api.github.com/repos/{repo}/pulls/{pr_number}",
                headers={
                    "Authorization": f"token {token}",
                    "Accept": "application/vnd.github+json",
                },
                json={"state": "closed"},
            )
            resp.raise_for_status()

        return json.dumps({
            "status": "closed",
            "pr_number": pr_number,
            "closed_by": app_slug,
        })
    except httpx.HTTPStatusError as e:
        error_body = e.response.json() if e.response.content else {}
        return json.dumps({
            "status": "error",
            "http_status": e.response.status_code,
            "error": error_body.get("message", str(e)),
        })
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


@mcp.tool()
async def github_list_issues(
    repo: Annotated[str, Field(description="Repository in owner/repo format")],
    state: Annotated[str, Field(description="Filter by state: open, closed, all")] = "open",
    labels: Annotated[str, Field(description="Comma-separated labels to filter")] = "",
    limit: Annotated[int, Field(description="Max results")] = 10,
    agent_name: Annotated[str, Field(description="Agent querying (must match apps.json)")] = "",
) -> str:
    """List issues for a repository."""
    try:
        if agent_name:
            token, _ = _get_installation_token(agent_name)
        else:
            token = _get_pat_token()
    except ValueError as e:
        return json.dumps({"status": "error", "error": str(e)})

    params: dict = {"state": state, "per_page": min(limit, 100)}
    if labels:
        params["labels"] = labels

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"https://api.github.com/repos/{repo}/issues",
                headers={
                    "Authorization": f"token {token}",
                    "Accept": "application/vnd.github+json",
                },
                params=params,
            )
            resp.raise_for_status()
            issues = resp.json()

        result = []
        for issue in issues:
            result.append({
                "number": issue["number"],
                "title": issue["title"],
                "state": issue["state"],
                "url": issue["html_url"],
                "labels": [l["name"] for l in issue.get("labels", [])],
                "created_at": issue["created_at"],
                "body": issue.get("body", "")[:500],
            })

        return json.dumps({"count": len(result), "issues": result})
    except Exception as e:
        return json.dumps({"status": "error", "error": str(e)})


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run(transport="stdio")
