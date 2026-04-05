# Service Startup Order

## Docker Compose depends_on with Healthcheck
```yaml
services:
  postgres:
    image: postgres:17
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7.4
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  api:
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
```

## Application-Level Readiness
- Don't rely solely on container health — check actual connectivity
- Retry with exponential backoff on startup
- Readiness probe vs liveness probe: readiness = "ready to serve", liveness = "not crashed"

## Common Patterns
| Service | Health Check |
|---------|-------------|
| PostgreSQL | `pg_isready` |
| MongoDB | `mongosh --eval "db.runCommand('ping')"` |
| Redis | `redis-cli ping` |
| HTTP API | `curl -f http://localhost:PORT/health` |
| gRPC | grpc_health_probe |
