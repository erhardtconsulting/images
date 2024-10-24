FROM ghcr.io/erhardtconsulting/base-php:8.3.12@sha256:36fe5fc5a897be769932e59ee9d493e8d004a25fa9b4ca01739a3b9fc9066e15

# Nextcloud gpg key for verification
ARG NEXTCLOUD_GPG="2880 6A87 8AE4 23A2 8372  792E D758 99B9 A724 937A"

# renovate: datasource=github-releases depName=nextcloud/server versioning=semver
ARG NEXTCLOUD_VERSION="30.0.1"
# renovate: datasource=github-tags depName=Imagick/imagick versioning=semver
ARG IMAGICK_VERSION="3.7.0"

RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      gettext \
      gnupg; \
    /usr/local/bin/install-php-extensions \
      apcu \
      bcmath \
      exif \
      gd \
      gmp \
      intl \
      ldap \
      mbstring \
      mcrypt \
      memcached \
      mysqli \
      opcache \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      redis \
      sysvsem \
      zip; \
    # >>> Fix for php8.3 - https://gist.github.com/Wirone/d5c794b4fef0203146a27687e80588a6#file-workaround-dockerfile
    apt-get update;\
    apt-get -y install \
      libmagickcore-6.q16-6-extra \
      libmagickcore-6.q16-dev \
      libmagickwand-6.q16-6 \
      libmagickwand-6.q16-dev \
      libpng-dev \
      libpng16-16; \
    curl -fLo /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/refs/tags/${IMAGICK_VERSION}.tar.gz; \
    tar --strip-components=1 -xf /tmp/imagick.tar.gz; \
    phpize; \
    ./configure; \
    make; \
    make install; \
    rm -rf /tmp/*; \
    apt-get -y remove \
      libmagickcore-6.q16-dev \
      libmagickwand-6.q16-dev \
      libpng-dev; \
    # <<< End of Imagick installation
    docker-php-ext-enable apcu imagick mcrypt memcached redis; \
    apt-get -y autoremove; \
    apt-get clean; \
    # Enable PHP production settings
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    # Install nextcloud
    mkdir -p /opt/nextcloud; \
    # Download Nextcloud
    cd /tmp; \
    NEXTCLOUD_TARBALL="nextcloud-${NEXTCLOUD_VERSION}.tar.bz2"; \
    NEXTCLOUD_METADATA="nextcloud-${NEXTCLOUD_VERSION}.metadata"; \
    curl -fLO "https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}"; \
    curl -fLO "https://download.nextcloud.com/server/releases/${NEXTCLOUD_METADATA}"; \
    curl -fLO "https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.sha256"; \
    curl -fLO "https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.asc"; \
    curl -fLO "https://nextcloud.com/nextcloud.asc"; \
    # Verify checksum
    echo "Verifying both integrity and authenticity of ${NEXTCLOUD_TARBALL}..."; \
    CHECKSUM_STATE=$(echo -n $(sha256sum -c ${NEXTCLOUD_TARBALL}.sha256) | tail -c 2); \
    if [ "${CHECKSUM_STATE}" != "OK" ]; then echo "Warning! Checksum does not match!" && exit 1; fi; \
    gpg --import nextcloud.asc; \
    FINGERPRINT="$(LANG=C gpg --verify ${NEXTCLOUD_TARBALL}.asc ${NEXTCLOUD_TARBALL} 2>&1 | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")"; \
    if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!" && exit 1; fi; \
    if [ "${FINGERPRINT}" != "${NEXTCLOUD_GPG}" ]; then echo "Warning! Wrong GPG fingerprint!" && exit 1; fi; \
    echo "All seems good, now unpacking ${NEXTCLOUD_TARBALL}..."; \
    # Extract
    tar xjf ${NEXTCLOUD_TARBALL} --strip-components=1 -C /opt/nextcloud; \
    # Preserve install config
    mkdir -p /opt/nextcloud.install; \
    cp -r /opt/nextcloud/config/* /opt/nextcloud.install; \
    # Remove nextcloud updater for safety
    rm -rf /opt/nextcloud/updater; \
    rm -rf /tmp/*; \
    rm -rf /opt/nextcloud/data /opt/nextcloud/config; \
    ln -sf /data/data /opt/nextcloud/data; \
    ln -sf /data/config /opt/nextcloud/config; \
    ln -sf /data/userapps /opt/nextcloud/userapps; \
    ln -sf /data/php.nextcloud.ini "$PHP_INI_DIR/conf.d/nextcloud.ini"

# Copy config
COPY root /

# Set user
USER nobody:nobody

# Set up the working directory
WORKDIR /opt/nextcloud

# Expose port 8080
EXPOSE 8080

# Set tmp and data as volume
VOLUME ["/tmp", "/data"]

# Set env variables
ENV ENABLE_CONFIG_AUTOCONFIG="false" \
    ENABLE_CONFIG_DOCKER="true" \
    ENABLE_CONFIG_REDIS="false" \
    ENABLE_CONFIG_REVERSE_PROXY="false" \
    ENABLE_CONFIG_S3="false" \
    ENABLE_CONFIG_SMTP="false" \
    ENABLE_CONFIG_SWIFT="false" \
    ENABLE_CRON="true" \
    PHP_APCU_SHM_SIZE="128M" \
    PHP_MAX_EXECUTION_TIME="600" \
    PHP_MEMORY_LIMIT="512M"

LABEL org.opencontainers.image.description="Rootless all-in-one Nextcloud image, based on Alpine Linux" \
      org.opencontainers.image.version="${NEXTCLOUD_VERSION}" \
      org.opencontainers.image.authors="Simon Erhardt <simon@erhardt.consulting>" \
      org.opencontainers.image.source="https://github.com/erhardtconsulting/images"

# Run everthing
CMD ["/docker-run.sh"]