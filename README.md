# Proton Mail Bridge in Docker via Tailscale

This fork targets `linux/amd64` only, specifically an Intel Xeon style Docker
host. The GitHub Actions workflow publishes the app image to GHCR:

```sh
docker pull ghcr.io/<owner>/<repo>:latest
```

Runtime base is Debian Trixie, build base is Go 1.26 on Trixie, and the optional
browser login terminal uses the upstream `ttyd.x86_64` release binary.

Container ports:

- `2143/tcp`: local IMAP forwarder, published in Tailscale as `1143/tcp`
- `2025/tcp`: local SMTP forwarder, published in Tailscale as `1025/tcp`
- `7681/tcp`: temporary browser login terminal during `./setup-login.sh`
