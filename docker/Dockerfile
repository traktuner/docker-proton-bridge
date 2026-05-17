# syntax=docker/dockerfile:1.7

FROM golang:1.26.3-trixie AS build

# Install build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libsecret-1-dev \
    libfido2-dev \
    libcbor-dev \
    pkg-config \
    ca-certificates

# Build ProtonMail Bridge
WORKDIR /build/
COPY VERSION /build/
RUN git clone --branch "v$(cat VERSION)" --depth 1 https://github.com/ProtonMail/proton-bridge.git
WORKDIR /build/proton-bridge
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    make build-nogui

FROM debian:trixie-slim

EXPOSE 2025/tcp
EXPOSE 2143/tcp

# Install necessary system tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    net-tools \
    procps \
    iproute2 \
    netcat-openbsd \
    curl \
    wget \
    dnsutils \
    socat \
    libsecret-1-0 \
    libfido2-1 \
    libcbor0.10 \
    libudev1 \
    ca-certificates \
    libglib2.0-0t64 \
    libgtk-3-0t64 \
    libsoup-2.4-1 \
    libgdk-pixbuf-2.0-0 \
    libjson-glib-1.0-0 \
    libsqlite3-0 \
    libnss3 \
    pass \
    gnupg

# Copy entrypoint script and ProtonMail Bridge binaries
COPY gpgparams entrypoint.sh /protonmail/
COPY --from=build /build/proton-bridge/bridge /protonmail/
COPY --from=build /build/proton-bridge/proton-bridge /protonmail/

RUN ldd /protonmail/bridge /protonmail/proton-bridge \
    | awk '/not found/ { missing=1; print } END { exit missing }'

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
