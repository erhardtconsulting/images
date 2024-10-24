FROM ghcr.io/erhardtconsulting/base-php:8.3.12@sha256:07adcf41d2bc383b7d211e202c79273c1c263e21688c0821c52b5714e64fc656

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
      gnupg \
      libfreetype6 \
      libfreetype6-dev \
      libgmp-dev \
      libgmp10 \
      libicu-dev \
      libicu72 \
      libjpeg62-turbo \
      libjpeg62-turbo-dev \
      libldap-2.5-0 \
      libldap-dev \
      libmagickwand-6.q16-6 \
      libmagickwand-6.q16-dev \
      libmcrypt-dev \
      libmcrypt4 \
      libmemcached-dev \
      libmemcached11 \
      libonig-dev \
      libonig5 \
      libpng-dev \
      libpng16-16 \
      libpq-dev \
      libpq5 \
      libzip-dev \
      libzip4 \
      zlib1g \
      zlib1g-dev; \
    docker-php-ext-configure gd --with-freetype=/usr --with-jpeg=/usr; \
    docker-php-ext-configure ldap; \
    docker-php-ext-configure zip; \
    docker-php-ext-install -j "$(nproc)" \
      bcmath \
      exif \
      gd \
      gmp \
      intl \
      ldap \
      mbstring \
      mysqli \
      opcache \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      sysvsem \
      zip; \
    pecl channel-update pecl.php.net; \
    pecl install APCu-5.1.24; \
    # && pecl install imagick-3.7.0
    # >>> Fix for php8.3 - https://gist.github.com/Wirone/d5c794b4fef0203146a27687e80588a6#file-workaround-dockerfile
    curl -fLo /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/refs/tags/${IMAGICK_VERSION}.tar.gz; \
    tar --strip-components=1 -xf /tmp/imagick.tar.gz; \
    phpize; \
    ./configure; \
    make; \
    make install; \
    #echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini; \
    rm -rf /tmp/*; \
    # <<< End of Imagick installation
    pecl install mcrypt-1.0.7; \
    pecl install memcached-3.3.0; \
    pecl install redis-6.1.0; \
    docker-php-ext-enable apcu imagick mcrypt memcached redis; \
    apt-get -y remove \
      libfreetype6-dev \
      libgmp-dev \
      libicu-dev \
      libjpeg62-turbo-dev \
      libldap-dev \
      libmagickwand-6.q16-dev \
      libmcrypt-dev \
      libmemcached-dev \
      libonig-dev \
      libpng-dev \
      libpq-dev \
      libzip-dev \
      zlib1g-dev; \
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