FROM docker.io/library/php:8.4.2-fpm@sha256:4c8b6976c635245f7646e575ccd53b4cc8e80d8c0997a4d3a50ef3f68f6457d5

# renovate: datasource=github-releases depName=aptible/supercronic versioning=semver
ARG SUPERCRONIC_VERSION="v0.2.33"
# renovate: datasource=github-releases depName=mlocati/docker-php-extension-installer versioning=semver
ARG INSTALL_PHP_EXTENSIONS_VERSION="2.7.14"

# build variables
ARG TARGETARCH

# install supercronic
ADD --chmod=0755 \
    "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
    "/usr/local/bin/supercronic"

# install install-php-extensions
ADD --chmod=0755 \
    "https://github.com/mlocati/docker-php-extension-installer/releases/download/${INSTALL_PHP_EXTENSIONS_VERSION}/install-php-extensions" \
    "/usr/local/bin/install-php-extensions"

# install dependencies
RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      nginx \
      supervisor \
      tini; \
    apt-get clean

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Rootless PHP base image"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/tini", "--"]