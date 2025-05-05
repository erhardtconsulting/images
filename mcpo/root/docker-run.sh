#!/usr/bin/env bash
set -euo pipefail

PORT=${PORT:-8000}
API_KEY=${API_KEY:-"not-secure"}

exec /app/.venv/bin/mcpo \
    --host "0.0.0.0" \
    --port "$PORT" \
    --api-key "$API_KEY" \
    --config /app/config.json