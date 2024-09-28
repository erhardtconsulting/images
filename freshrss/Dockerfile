# syntax=docker/dockerfile:1

ARG FRANKENPHP_VERSION="1.2.4"
ARG DEBIAN_VERSION="bookworm"

FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-${DEBIAN_VERSION}

# Get target arch
ARG TARGETARCH
ARG TARGETOS

# Set user
ARG USER="freshrss"

# Set versions
ARG SUPERCRONIC_VERSION="0.2.31"
ARG S6_OVERLAY_VERSION="3.2.0.0"
ARG FRESHRSS_VERSION="1.21.0"

# Set container root to read-only and production
ENV S6_READ_ONLY_ROOT="1"
ENV FRESHRSS_ENV="production"

# Copy root
COPY root/ /

RUN if [[ "${TARGETOS}" != "linux" ]]; then echo "unsupported os: ${TARGETOS}" && exit 1; fi; \
    curl -fLo "/usr/local/bin/supercronic" "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
    && chmod +x "/usr/local/bin/supercronic"; \
    # Install s6-overlay according to cpu architecture
    case ${TARGETARCH} in \
        "386") ARCH=i686 ;; \
        "amd64") ARCH=x86_64 ;; \
        "arm64") ARCH=aarch64 ;; \
        "arm") ARCH=armhf ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -C / -Jxpf - && \
    curl -fL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz | tar -C / -Jxpf -; \
    # Install php extensions
    install-php-extensions \
      curl \
      gmp \
      intl \
      mbstring \
      mysql \
      pgsql \
      sqlite3 \
      xml \
      zip; \
	# Add user freshrss
	useradd -m -d /opt/freshrss -s /bin/bash ${USER}; \
	# Remove default capability \
    setcap -r /usr/sbin/cron; \
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

# Run s6
ENTRYPOINT ["/init"]