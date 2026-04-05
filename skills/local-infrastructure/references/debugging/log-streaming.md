# Log Streaming & Debugging

## Docker Logs
```bash
# Follow logs for a service
docker compose logs -f api

# Last 100 lines
docker compose logs --tail 100 api

# Multiple services
docker compose logs -f api worker

# With timestamps
docker compose logs -f -t api
```

## Debugging Running Containers
```bash
# Shell into container
docker compose exec api bash

# Run one-off command
docker compose run --rm api python manage.py shell

# Inspect container
docker inspect <container_id> | jq '.[0].State'

# Network debugging
docker compose exec api curl -v http://postgres:5432
```

## Structured Logging
```python
import structlog
logger = structlog.get_logger()
logger.info("request_processed", method="GET", path="/api/users", duration_ms=42)
# Output: {"event": "request_processed", "method": "GET", "path": "/api/users", "duration_ms": 42}
```

## Common Issues
| Problem | Diagnosis |
|---------|-----------|
| Container crash loop | `docker logs <id>` — check startup error |
| Port conflict | `lsof -i :PORT` — find process using port |
| Volume permissions | Check UID/GID mapping between host and container |
| DNS resolution | `docker compose exec api nslookup postgres` |
