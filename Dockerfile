FROM debian:bookworm-slim

ARG WGCF_VERSION=2.2.29
ARG TARGETPLATFORM=linux/amd64

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends bash ca-certificates curl dnsutils; \
    case "${TARGETPLATFORM}" in \
        linux/amd64) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_amd64" ;; \
        linux/386) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_386" ;; \
        linux/arm64*) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_arm64" ;; \
        linux/arm/v7) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_armv7" ;; \
        linux/arm/v6) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_armv6" ;; \
        linux/arm/v5) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_armv5" ;; \
        linux/mips64le) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_mips64le_softfloat" ;; \
        linux/mips64) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_mips64_softfloat" ;; \
        linux/mipsle) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_mipsle_softfloat" ;; \
        linux/mips) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_mips_softfloat" ;; \
        linux/s390x) WGCF_ASSET="wgcf_${WGCF_VERSION}_linux_s390x" ;; \
        *) echo "Unsupported platform ${TARGETPLATFORM}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/${WGCF_ASSET}" \
        -o /usr/local/bin/wgcf; \
    chmod +x /usr/local/bin/wgcf; \
    apt-get purge -y --auto-remove curl; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY gen-warp.sh /usr/local/bin/gen-warp.sh
RUN chmod +x /usr/local/bin/gen-warp.sh

ENTRYPOINT ["/usr/local/bin/gen-warp.sh"]
