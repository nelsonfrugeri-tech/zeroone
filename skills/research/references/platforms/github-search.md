# GitHub Search

## Code Search
```
# Search code across repos
language:python "from pydantic import" path:src
# Find specific patterns
org:fastapi "middleware" language:python
# File name search
filename:docker-compose.yml redis postgres
# Path-scoped
path:src/api "rate_limit" language:python
```

## Issue/PR Search
```
# Open issues with label
repo:owner/repo is:issue is:open label:bug
# Recent PRs
repo:owner/repo is:pr is:merged merged:>2025-01-01
# Search discussions
repo:owner/repo type:discussions "performance"
```

## Release Search
- Check /releases page for changelogs
- Compare releases: `/compare/v1.0...v2.0`
- Stars/forks as popularity signals (but not quality)
