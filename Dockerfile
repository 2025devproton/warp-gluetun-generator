FROM debian:bookworm-slim

ARG WGCF_VERSION=2.2.29

# Buildx args
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends bash ca-certificates curl dnsutils; \
    \
    case "${TARGETARCH}" in \
        amd64) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_amd64" ;; \
        386)   WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_386" ;; \
        arm64) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_arm64" ;; \
        arm) \
            case "${TARGETVARIANT}" in \
                v7) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_armv7" ;; \
                v6) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_armv6" ;; \
                *) echo "Unsupported ARM variant: ${TARGETVARIANT}"; exit 1 ;; \
            esac ;; \
        *) echo "Unsupported TARGETARCH=${TARGETARCH}"; exit 1 ;; \
    esac; \
    \
    curl -fsSL "https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/${WGCF_ASSET}" \
        -o /usr/local/bin/wgcf; \
    chmod +x /usr/local/bin/wgcf; \
    \
    apt-get purge -y --auto-remove curl; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY gen-warp.sh /usr/local/bin/gen-warp.sh
RUN chmod +x /usr/local/bin/gen-warp.sh

ENTRYPOINT ["/usr/local/bin/gen-warp.sh"]
