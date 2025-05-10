FROM docker.io/library/php:8.3.13-fpm@sha256:14fa9f2b4b71f624a5547f3d2b125bb25cc9fca0ed65a9e7a178fb055b61a446

# renovate: datasource=github-releases depName=aptible/supercronic versioning=semver
ARG SUPERCRONIC_VERSION="v0.2.33"
# renovate: datasource=github-releases depName=mlocati/docker-php-extension-installer versioning=semver
ARG INSTALL_PHP_EXTENSIONS_VERSION="2.7.34"

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