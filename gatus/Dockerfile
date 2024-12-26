# build container
FROM docker.io/library/golang:1.23.4-bookworm@sha256:2e838582004fab0931693a3a84743ceccfbfeeafa8187e87291a1afea457ff7a AS builder

# renovate: datasource=github-releases depName=TwiN/gatus versioning=semver
ARG GATUS_VERSION="5.14.0"

RUN set -eux; \
    mkdir -p /app; \
    curl -fsSL "https://github.com/TwiN/gatus/archive/refs/tags/v${GATUS_VERSION}.tar.gz" \
      | tar xzf - -C /app --strip-components=1; \
    cd /app \
      && go mod tidy \
      && CGO_ENABLED=1 GOOS=linux go build -a -o gatus .

# app container
FROM docker.io/library/debian:bookworm-slim@sha256:1537a6a1cbc4b4fd401da800ee9480207e7dc1f23560c21259f681db56768f63

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
      bash \
      ca-certificates \
      inetutils-ping \
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