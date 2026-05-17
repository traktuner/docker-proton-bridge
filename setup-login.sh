#!/bin/bash
set -e

cd "$(dirname "$0")/docker"

if [[ ! -f .env ]] || ! grep -q '^TS_AUTHKEY=' .env; then
    echo "ERROR: docker/.env must contain TS_AUTHKEY=..." >&2
    exit 1
fi

echo "Stopping the headless Bridge container while setup is running..."
docker compose stop protonmail-bridge >/dev/null 2>&1 || true

echo "Starting Tailscale and browser-based Bridge setup..."
docker compose --profile setup up -d tailscale protonmail-bridge-login

echo "Configuring Tailscale HTTP forwarder for the setup terminal..."
for i in $(seq 1 60); do
    if docker exec protonmail-bridge-tailscale tailscale status >/dev/null 2>&1; then
        docker exec protonmail-bridge-tailscale tailscale serve --yes --bg --http=7681 http://127.0.0.1:7681
        echo "Open: http://proton-bridge:7681"
        echo "When login is done, type 'exit' in Bridge and run ./start.sh"
        exit 0
    fi
    sleep 1
done

echo "ERROR: Tailscale did not become ready after 60s." >&2
exit 1
