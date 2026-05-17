FROM golang:1.26.3-trixie AS build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libsecret-1-dev \
    libfido2-dev \
    libcbor-dev \
    pkg-config \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Build ProtonMail Bridge
WORKDIR /build/
COPY build.sh VERSION /build/
RUN bash build.sh

FROM debian:trixie-slim

ARG TTYD_VERSION=1.7.7

EXPOSE 2025/tcp
EXPOSE 2143/tcp
EXPOSE 7681/tcp

# Install necessary system tools
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
    "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
    -o /usr/local/bin/ttyd \
    && chmod 0755 /usr/local/bin/ttyd

# Copy entrypoint script and ProtonMail Bridge binaries
COPY gpgparams entrypoint.sh /protonmail/
COPY --from=build /build/proton-bridge/bridge /protonmail/
COPY --from=build /build/proton-bridge/proton-bridge /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
