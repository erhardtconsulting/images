# build container
FROM docker.io/library/golang:1.25.5-bookworm@sha256:09f53deea14d4019922334afe6258b7b776afc1d57952be2012f2c8c4076db05 AS builder

# renovate: datasource=github-releases depName=TwiN/gatus versioning=semver
ARG GATUS_VERSION="5.33.1"

RUN set -eux; \
    mkdir -p /app; \
    curl -fsSL "https://github.com/TwiN/gatus/archive/refs/tags/v${GATUS_VERSION}.tar.gz" \
      | tar xzf - -C /app --strip-components=1; \
    cd /app \
      && go mod tidy \
      && CGO_ENABLED=1 GOOS=linux go build -a -o gatus .

# app container
FROM docker.io/library/debian:bookworm-slim@sha256:e899040a73d36e2b36fa33216943539d9957cba8172b858097c2cabcdb20a3e2

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