# syntax=docker/dockerfile:1

ARG FRANKENPHP_VERSION="1.2.5"
ARG DEBIAN_VERSION="bookworm"

FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-${DEBIAN_VERSION}

# Get target arch
ARG TARGETARCH
ARG TARGETOS

# Set user
ARG USER="freshrss"
ARG UID=2000
ARG GID=2000

# Set versions
ARG SUPERCRONIC_VERSION="0.2.32"
ARG FRESHRSS_VERSION="1.24.3"

# Set container root to read-only and production
ENV S6_READ_ONLY_ROOT="1"
ENV FRESHRSS_ENV="production"

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Rootless FreshRSS Image"
LABEL org.opencontainers.image.licenses="MIT"

# Copy root
COPY root/ /

RUN apt-get update  \
      && apt-get -y install \
        supervisor \
        tini \
      && rm -rf /var/lib/apt/lists/*; \
    # Install supercronic
    curl -fLo "/usr/local/bin/supercronic" "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
      && chmod +x "/usr/local/bin/supercronic"; \
    # Install php extensions
    install-php-extensions \
      gmp \
      intl \
      pdo_mysql \
      pdo_pgsql \
      zip; \
	# Check if the group exists; if not, create it
    if ! getent group ${GID} >/dev/null; then \
      groupadd -g ${GID} ${USER}; \
    else \
      # If GID exists, get the group name
      EXISTING_GROUP=$(getent group ${GID} | cut -d: -f1); \
    fi && \
    # Create the user with the specified UID and GID
    useradd -m -d /opt/freshrss -s /bin/bash -u ${UID} -g ${GID} ${USER}; \
	# Remove default capability \
	setcap -r /usr/local/bin/frankenphp; \
	# Give write access to /data/caddy and /config/caddy
	chown -R ${USER}:${USER} /data/caddy && chown -R ${USER}:${USER} /config/caddy; \
    # Download and install FreshRSS
    curl -sfL https://github.com/FreshRSS/FreshRSS/archive/${FRESHRSS_VERSION}.tar.gz | tar xz --strip-components=1 -C /opt/freshrss; \
    # Delete unnecessary folders \
    rm -rf \
      /opt/freshrss/.devcontainer \
      /opt/freshrss/data \
      /opt/freshrss/Docker \
      /opt/freshrss/docs \
      /opt/freshrss/tests; \
    mkdir /opt/freshrss/data; \
    # Enable production configuration for PHP
    cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini; \
    # Disable updating
    sed -r -i "\\#disable_update#s#^.*#\t'disable_update' => true,#" /opt/freshrss/config.default.php; \
    # Fix permissions
    chown -R freshrss:freshrss /opt/freshrss;

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