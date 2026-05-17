#!/bin/bash
set -e

# Kill any leftover Bridge process from a previous unclean shutdown.
stop_existing_instance() {
    pids=$(ps aux | grep '[p]roton-bridge' | awk '{print $2}')
    if [ -n "$pids" ]; then
        echo "Killing leftover Bridge processes: $pids"
        kill $pids || true
        sleep 1
    fi
}

# First-run setup: GPG key + pass init, then drop into the interactive CLI
# so the user can `login` to Proton. Run with:
#   docker compose run --rm protonmail-bridge init
initialize() {
    echo "Initializing ProtonMail Bridge (first-run setup)..."
    if [ ! -f /root/.gnupg/pubring.kbx ]; then
        gpg --generate-key --batch /protonmail/gpgparams
    fi
    if [ ! -d /root/.password-store ]; then
        pass init bridge@localhost  # key name should match that in gpgparams file
    fi
    stop_existing_instance
    exec /protonmail/proton-bridge --cli
}

web_initialize() {
    echo "Starting browser-based ProtonMail Bridge setup..."
    if [ ! -f /root/.gnupg/pubring.kbx ]; then
        gpg --generate-key --batch /protonmail/gpgparams
    fi
    if [ ! -d /root/.password-store ]; then
        pass init bridge@localhost
    fi
    stop_existing_instance
    exec ttyd -W -p 7681 -i 0.0.0.0 /protonmail/proton-bridge --cli
}

# Normal run: start Bridge headless.
# Bridge binds 127.0.0.1:1143/1025. socat exposes stable local
# forwarder ports that Tailscale Serve can publish inside the tailnet.
start_bridge() {
    echo "Starting ProtonMail Bridge..."
    stop_existing_instance
        
    socat TCP-LISTEN:2143,fork,reuseaddr TCP:127.0.0.1:1143 &
    socat TCP-LISTEN:2025,fork,reuseaddr TCP:127.0.0.1:1025 &

    # Bridge's CLI wants a TTY; fake one with a FIFO and keep a writer
    # attached so it doesn't EOF immediately.
    rm -f /tmp/faketty
    mkfifo /tmp/faketty
    sleep infinity > /tmp/faketty &
    exec /protonmail/proton-bridge --cli < /tmp/faketty
}

# Forward signals so `docker stop` shuts Bridge down cleanly instead of
# waiting for SIGKILL after the grace period. Abrupt kills during sync
# can corrupt the local cache.
trap 'stop_existing_instance; exit 0' SIGTERM SIGINT

case "$1" in
    init)
        initialize
        ;;
    web-init)
        web_initialize
        ;;
    *)
        start_bridge
        ;;
esac
