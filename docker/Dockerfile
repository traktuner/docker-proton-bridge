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

ARG TTYD_VERSION=1.7.7

EXPOSE 2025/tcp
EXPOSE 2143/tcp
EXPOSE 7681/tcp

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

RUN curl -fsSL \
    "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
    -o /usr/local/bin/ttyd \
    && chmod 0755 /usr/local/bin/ttyd

# Copy entrypoint script and ProtonMail Bridge binaries
COPY gpgparams entrypoint.sh /protonmail/
COPY --from=build /build/proton-bridge/bridge /protonmail/
COPY --from=build /build/proton-bridge/proton-bridge /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
