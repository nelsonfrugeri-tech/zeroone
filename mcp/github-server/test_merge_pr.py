"""Tests for github_merge_pr tool."""

from __future__ import annotations

import json
from unittest.mock import patch

import httpx
import pytest
import respx

from server import github_merge_pr

REPO = "owner/repo"
AGENT = "oracle"
TOKEN = "fake-token"
SLUG = "oracle-zeroone"


@pytest.fixture(autouse=True)
def mock_auth():
    """Mock _get_installation_token for all tests."""
    with patch("server._get_installation_token", return_value=(TOKEN, SLUG)):
        yield


@pytest.mark.asyncio
@respx.mock
async def test_merge_happy_path():
    """Successful merge returns status=merged with sha."""
    respx.get(f"https://api.github.com/repos/{REPO}/pulls/1").mock(
        return_value=httpx.Response(200, json={
            "state": "open",
            "mergeable": True,
        })
    )
    respx.put(f"https://api.github.com/repos/{REPO}/pulls/1/merge").mock(
        return_value=httpx.Response(200, json={
            "sha": "abc123",
            "merged": True,
        })
    )

    result = json.loads(await github_merge_pr(REPO, 1, AGENT))
    assert result["status"] == "merged"
    assert result["sha"] == "abc123"
    assert result["merge_method"] == "merge"
    assert result["merged_by"] == SLUG
    assert result["agent"] == AGENT


@pytest.mark.asyncio
@respx.mock
async def test_merge_squash():
    """Squash merge sends correct merge_method."""
    respx.get(f"https://api.github.com/repos/{REPO}/pulls/1").mock(
        return_value=httpx.Response(200, json={
            "state": "open",
            "mergeable": True,
        })
    )
    merge_route = respx.put(f"https://api.github.com/repos/{REPO}/pulls/1/merge").mock(
        return_value=httpx.Response(200, json={"sha": "def456", "merged": True})
    )

    result = json.loads(await github_merge_pr(REPO, 1, AGENT, merge_method="squash"))
    assert result["status"] == "merged"
    assert result["merge_method"] == "squash"
    assert json.loads(merge_route.calls[0].request.content)["merge_method"] == "squash"


@pytest.mark.asyncio
@respx.mock
async def test_merge_pr_not_open():
    """Closed PR returns error."""
    respx.get(f"https://api.github.com/repos/{REPO}/pulls/1").mock(
        return_value=httpx.Response(200, json={
            "state": "closed",
            "mergeable": True,
        })
    )

    result = json.loads(await github_merge_pr(REPO, 1, AGENT))
    assert result["status"] == "error"
    assert "closed" in result["error"]


@pytest.mark.asyncio
@respx.mock
async def test_merge_pr_mergeable_none():
    """mergeable=None (still calculating) returns retry message."""
    respx.get(f"https://api.github.com/repos/{REPO}/pulls/1").mock(
        return_value=httpx.Response(200, json={
            "state": "open",
            "mergeable": None,
        })
    )

    result = json.loads(await github_merge_pr(REPO, 1, AGENT))
    assert result["status"] == "error"
    assert "not yet determined" in result["error"]


@pytest.mark.asyncio
@respx.mock
async def test_merge_pr_has_conflicts():
    """mergeable=False returns conflict error."""
    respx.get(f"https://api.github.com/repos/{REPO}/pulls/1").mock(
        return_value=httpx.Response(200, json={
            "state": "open",
            "mergeable": False,
        })
    )

    result = json.loads(await github_merge_pr(REPO, 1, AGENT))
    assert result["status"] == "error"
    assert "conflicts" in result["error"]


@pytest.mark.asyncio
@respx.mock
async def test_merge_pr_http_error():
    """HTTP 405 from merge endpoint returns structured error."""
    respx.get(f"https://api.github.com/repos/{REPO}/pulls/1").mock(
        return_value=httpx.Response(200, json={
            "state": "open",
            "mergeable": True,
        })
    )
    respx.put(f"https://api.github.com/repos/{REPO}/pulls/1/merge").mock(
        return_value=httpx.Response(405, json={
            "message": "Pull Request is not mergeable",
        })
    )

    result = json.loads(await github_merge_pr(REPO, 1, AGENT))
    assert result["status"] == "error"
    assert result["http_status"] == 405


@pytest.mark.asyncio
async def test_merge_pr_auth_error():
    """Missing credentials returns auth error."""
    with patch("server._get_installation_token", side_effect=ValueError("Missing env vars")):
        result = json.loads(await github_merge_pr(REPO, 1, AGENT))
    assert result["status"] == "error"
    assert "Missing env vars" in result["error"]
