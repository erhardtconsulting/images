# set php and debian version
ARG PHP_VERSION="8.3.12"
ARG DEBIAN_VERSION="bookworm"

FROM php:${PHP_VERSION}-fpm-${DEBIAN_VERSION}

# renovate: datasource=github-releases depName=aptible/supercronic versioning=semver
ARG SUPERCRONIC_VERSION="v0.2.33"

# sha1sums for supercronic
ARG SUPERCRONIC_AMD64_SHA1SUM=71b0d58cc53f6bd72cf2f293e09e294b79c666d8
ARG SUPERCRONIC_386_SHA1SUM=37c4c0b42c4b00be123d2f9736754bcf0659ae4e
ARG SUPERCRONIC_ARM_SHA1SUM=0d3e3da1eeceaa34991d44b48aecfcbb9d9fba5a
ARG SUPERCRONIC_ARM64_SHA1SUM=e0f0c06ebc5627e43b25475711e694450489ab00

# build variables
ARG TARGETARCH

# install dependencies
RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      nginx \
      supervisor \
      tini; \
    apt-get clean; \
    curl -fLo "/usr/local/bin/supercronic" "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}"; \
    chmod +x "/usr/local/bin/supercronic"; \
    [ "$TARGETARCH" = "amd64" ] && SUPERCRONIC_SHA1SUM="$SUPERCRONIC_AMD64_SHA1SUM"; \
    [ "$TARGETARCH" = "386" ] && SUPERCRONIC_SHA1SUM="$SUPERCRONIC_386_SHA1SUM"; \
    [ "$TARGETARCH" = "arm" ] && SUPERCRONIC_SHA1SUM="$SUPERCRONIC_ARM_SHA1SUM"; \
    [ "$TARGETARCH" = "arm64" ] && SUPERCRONIC_SHA1SUM="$SUPERCRONIC_ARM64_SHA1SUM"; \
    CHECKSUM_STAGE=$(echo -n $(echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c -) | tail -c 2); \
    if [ "${CHECKSUM_STAGE}" != "OK" ]; then echo "Warning! Checksum does not match!" && exit 1; fi

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Rootless PHP base image"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/tini", "--"]