# Proton Mail Bridge in Docker via Tailscale

This fork targets `linux/amd64` only, specifically an Intel Xeon style Docker
host. The GitHub Actions workflow publishes the app image to GHCR:

```sh
docker pull ghcr.io/<owner>/<repo>:latest
```

Runtime base is Debian Trixie and build base is Go 1.26 on Trixie.

Container ports:

- `2143/tcp`: local IMAP forwarder, published in Tailscale as `1143/tcp`
- `2025/tcp`: local SMTP forwarder, published in Tailscale as `1025/tcp`

Login or re-login is done through the Bridge CLI:

```sh
docker exec -it protonmail-bridge /protonmail/proton-bridge --cli
```

Then run:

```text
login
info
exit
```

If Bridge refuses a second CLI because the main process is already running,
use the one-off init path with the same persisted volumes:

```sh
docker compose stop protonmail-bridge
docker compose run --rm --no-deps protonmail-bridge init
docker compose up -d protonmail-bridge
```
