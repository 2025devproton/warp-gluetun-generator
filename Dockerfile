FROM debian:bookworm-slim

ARG WGCF_VERSION=2.2.29
ARG WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_amd64"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends bash ca-certificates curl dnsutils; \
    curl -fsSL "https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/${WGCF_ASSET}" \
        -o /usr/local/bin/wgcf; \
    chmod +x /usr/local/bin/wgcf; \
    apt-get purge -y --auto-remove curl; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY gen-warp.sh /usr/local/bin/gen-warp.sh
RUN chmod +x /usr/local/bin/gen-warp.sh

ENTRYPOINT ["/usr/local/bin/gen-warp.sh"]
