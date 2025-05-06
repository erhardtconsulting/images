FROM ghcr.io/erhardtconsulting/base-php:8.4.2@sha256:4854e4ed99de78235ecb2b1fa4f3898ff77fc2a3711c1089bee198826892c45f

# Get target arch
ARG TARGETARCH

# renovate: datasource=github-tags depName=FreshRSS/FreshRSS versioning=semver
ARG FRESHRSS_VERSION="1.26.2"

RUN set -eux; \
    # Install PHP extensions
    /usr/local/bin/install-php-extensions \
      gmp \
      intl \
      pdo_mysql \
      pdo_pgsql \
      zip; \
    # Download and install FreshRSS
    mkdir -p /opt/freshrss; \
    curl -sfL https://github.com/FreshRSS/FreshRSS/archive/${FRESHRSS_VERSION}.tar.gz | tar xz --strip-components=1 -C /opt/freshrss; \
    # Delete unnecessary folders
    rm -rf \
      /opt/freshrss/.devcontainer \
      /opt/freshrss/data \
      /opt/freshrss/Docker \
      /opt/freshrss/docs \
      /opt/freshrss/tests; \
    # Disable updating
    sed -r -i "\\#disable_update#s#^.*#\t'disable_update' => true,#" /opt/freshrss/config.default.php; \
    # Enable PHP production config
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    ln -sf /data /opt/freshrss/data

# Copy root
COPY root/ /

# Set user
USER nobody:nogroup

# Set up the working directory
WORKDIR /opt/freshrss

# Expose port for FrankenPHP
EXPOSE 8080

VOLUME ["/tmp", "/data"]

# Set labels
LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Rootless FreshRSS Image"
LABEL org.opencontainers.image.licenses="MIT"

# Set tini as entrypoing
ENTRYPOINT ["/usr/bin/tini", "--"]

# Run everthing
CMD ["/docker-run.sh"]