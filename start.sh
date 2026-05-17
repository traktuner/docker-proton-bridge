#!/bin/bash
set -e

cd "$(dirname "$0")/docker"

if [[ ! -f .env ]] || ! grep -q '^TS_AUTHKEY=' .env; then
    echo "ERROR: docker/.env must contain TS_AUTHKEY=..." >&2
    exit 1
fi

echo "Starting protonmail-bridge with a dedicated Tailscale sidecar..."
docker compose up -d

echo "Configuring Tailscale TCP forwarders..."
for i in $(seq 1 60); do
    if docker exec protonmail-bridge-tailscale tailscale status >/dev/null 2>&1; then
        docker exec protonmail-bridge-tailscale tailscale serve --yes --bg --tcp=1143 tcp://127.0.0.1:2143
        docker exec protonmail-bridge-tailscale tailscale serve --yes --bg --tcp=1025 tcp://127.0.0.1:2025
        exit 0
    fi
    sleep 1
done

echo "ERROR: Tailscale did not become ready after 60s." >&2
exit 1
