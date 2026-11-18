#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

# fallback to example env if not present
if [ ! -f .env ]; then
  echo "[deploy] .env missing, copying from .env.example"
  cp .env.example .env
fi

# load variables from .env
set -a
source .env
set +a

# choose compose command
if command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  DC="docker compose"
fi

echo "[deploy] building latest image..."
$DC build

echo "[deploy] starting service in background..."
$DC up -d --remove-orphans

echo "[deploy] waiting for healthcheck..."
CONTAINER="flask-devops-app"

for i in {1..15}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER" 2>/dev/null || echo "starting")
  if [ "$STATUS" = "healthy" ]; then
    echo "[deploy] container is healthy!"
    echo "[deploy] live at http://localhost:${PORT:-5000}"
    exit 0
  fi
  echo "[deploy] status: $STATUS (attempt $i/15), retrying in 3s..."
  sleep 3
done

echo "[deploy] error: healthcheck failed or timed out"
docker logs --tail 20 "$CONTAINER"
exit 1
