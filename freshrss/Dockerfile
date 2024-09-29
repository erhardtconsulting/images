ARG PHP_VERSION="8.3.12"
ARG DEBIAN_VERSION="bookworm"

FROM php:${PHP_VERSION}-fpm-bookworm

# Get target arch
ARG TARGETARCH

# Set versions
ARG SUPERCRONIC_VERSION="0.2.32"
ARG FRESHRSS_VERSION="1.24.3"

# Set user
ARG USER="freshrss"
ARG UID=2000
ARG GID=2000

# Set labels
LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Rootless FreshRSS Image"
LABEL org.opencontainers.image.licenses="MIT"

RUN set -ex \
    # Add user and group
    && groupadd -g ${GID} ${USER} \
    && useradd -m -d /opt/freshrss -s /bin/bash -u ${UID} -g ${GID} ${USER} \
    # Install supercronic
    && curl -fLo "/usr/local/bin/supercronic" "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
    && chmod +x "/usr/local/bin/supercronic" \
    # Install Dependencies
    && apt-get update  \
    && apt-get -y install \
      libgmp-dev \
      libicu-dev \
      libpq-dev \
      libzip-dev \
      nginx \
      supervisor \
      tini \
    && rm -rf /var/lib/apt/lists/* \
    # Install PHP extensions
    && docker-php-ext-install -j "$(nproc)" \
      gmp \
      intl \
      pdo_mysql \
      pdo_pgsql \
      zip \
    # Enable PHP extensions
    && docker-php-ext-enable \
      gmp \
      intl \
      pdo_mysql \
      pdo_pgsql \
      zip \
    # Download and install FreshRSS
    && curl -sfL https://github.com/FreshRSS/FreshRSS/archive/${FRESHRSS_VERSION}.tar.gz | tar xz --strip-components=1 -C /opt/freshrss \
    # Delete unnecessary folders \
    && rm -rf \
      /opt/freshrss/.devcontainer \
      /opt/freshrss/data \
      /opt/freshrss/Docker \
      /opt/freshrss/docs \
      /opt/freshrss/tests \
    && mkdir /opt/freshrss/data \
    # Disable updating
    && sed -r -i "\\#disable_update#s#^.*#\t'disable_update' => true,#" /opt/freshrss/config.default.php \
    # Fix permissions
    && chown -R freshrss:freshrss /opt/freshrss \
    # Enable PHP production config
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy root
COPY root/ /

# Set up user
USER ${USER}

# Set up the working directory
WORKDIR /opt/freshrss

# Expose port for FrankenPHP
EXPOSE 8080

VOLUME [ "/tmp" ]

# Set tini as entrypoing
ENTRYPOINT ["/usr/bin/tini", "--"]

# Run everthing
CMD ["/docker-run.sh"]