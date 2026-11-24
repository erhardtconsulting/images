# build container
FROM docker.io/library/golang:1.27.4-trixie@sha256:f18c3d73a184fb0582828510722e723b63a93f7188d11dd223d9be6f6880e65d AS builder

# renovate: datasource=github-releases depName=TwiN/gatus versioning=semver
ARG GATUS_VERSION="5.38.0"

RUN set -eux; \
    mkdir -p /app; \
    curl -fsSL "https://github.com/TwiN/gatus/archive/refs/tags/v${GATUS_VERSION}.tar.gz" \
      | tar xzf - -C /app --strip-components=1; \
    cd /app \
      && go mod tidy \
      && CGO_ENABLED=1 GOOS=linux go build -a -o gatus .

# app container
FROM docker.io/library/debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0

# set environment
ENV TZ="Etc/UTC"
ENV GATUS_CONFIG_PATH="/config"
ENV GATUS_LOG_LEVEL="INFO"

# copy build artifacts
COPY --from=builder /app/gatus /usr/bin/gatus
COPY --from=builder /app/config.yaml /config/config.yaml

# install dependencies
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
      ca-certificates \
      tini; \
    apt-get clean

# expose port 8080
EXPOSE 8080

# use non-privileged user
USER nobody:nogroup

# set labels
LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.title="Gatus"
LABEL org.opencontainers.image.description="Debian-based Gatus container with ICMP enabled"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.authors="Simon Erhardt <simon@erhardt.consulting>"
LABEL org.opencontainers.image.vendor="erhardt consulting GmbH"

# set tini as entrypoint, run gatus
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/gatus"]