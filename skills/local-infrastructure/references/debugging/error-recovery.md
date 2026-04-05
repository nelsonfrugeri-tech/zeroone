# Error Recovery Procedures

## Docker Issues
| Error | Fix |
|-------|-----|
| Port already in use | `lsof -i :PORT` then `kill <PID>`, or change port |
| No space left | `docker system prune -a --volumes` (WARNING: removes all) |
| Container won't start | Check logs: `docker logs <id>`, fix config, rebuild |
| Build cache stale | `docker compose build --no-cache service` |
| Network conflict | `docker network prune` then recreate |

## Database Issues
| Error | Fix |
|-------|-----|
| PostgreSQL "role does not exist" | Check POSTGRES_USER in env, recreate volume |
| MongoDB auth failed | Ensure MONGO_INITDB_ROOT_USERNAME matches connection string |
| Redis maxmemory | Set `maxmemory-policy allkeys-lru` in redis.conf |
| Migration failed | Check migration state, `migrate down` then re-apply |
| Corrupted volume | `docker volume rm <vol>` and re-seed |

## Nuclear Reset
```bash
# Stop everything, remove volumes, rebuild
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## Prevention
- Always use named volumes (not anonymous)
- Health checks on all services
- Seed scripts idempotent (safe to re-run)
- Pin image versions (never use :latest in dev)
