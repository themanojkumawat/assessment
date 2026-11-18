#!/usr/bin/env bash
set -e

# load port from .env if present
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

PORT="${PORT:-5000}"
URL="${1:-http://localhost:${PORT}/health}"
INTERVAL="${2:-10}"
LOGFILE="monitor.log"

echo "Started health monitoring for $URL (interval: ${INTERVAL}s)"
echo "Writing logs to $LOGFILE. Press Ctrl+C to exit."

trap 'echo -e "\nMonitor stopped."; exit 0' INT TERM

while true; do
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  
  # query health endpoint and capture status code and latency
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" --connect-timeout 4 "$URL" 2>/dev/null || echo "000 0.00")
  CODE=$(echo "$RESPONSE" | awk '{print $1}')
  LATENCY=$(echo "$RESPONSE" | awk '{print $2}')
  
  ENTRY="[$TIMESTAMP] status: $CODE | latency: ${LATENCY}s | target: $URL"
  echo "$ENTRY"
  echo "$ENTRY" >> "$LOGFILE"
  
  sleep "$INTERVAL"
done
