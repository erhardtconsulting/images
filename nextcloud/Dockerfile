ARG PHP_VERSION="8.3.12"
ARG BUILD_DATE
ARG VCS_REF

FROM php:${PHP_VERSION}-fpm-alpine

ARG TARGETARCH

LABEL maintainer="Simon Erhardt <hello@rootlogin.ch>" \
  org.label-schema.name="Nextcloud" \
  org.label-schema.description="Minimal Nextcloud docker image based on Alpine Linux." \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/erhardtconsulting/images" \
  org.label-schema.schema-version="1.0"

ARG NEXTCLOUD_GPG="2880 6A87 8AE4 23A2 8372  792E D758 99B9 A724 937A"

ARG NEXTCLOUD_VERSION="30.0.1"
ARG SUPERCRONIC_VERSION="0.2.33"
ARG IMAGICK_VERSION="3.7.0"

ARG UID=1501
ARG GID=1501

RUN set -ex \
  # Install supercronic
  && curl -fLo "/usr/local/bin/supercronic" "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
  && chmod +x "/usr/local/bin/supercronic" \
  # Install
  && apk update \
  && apk upgrade \
  && apk add \
    alpine-sdk \
    autoconf \
    bash \
    freetype \
    freetype-dev \
    gettext \
    gmp \
    gmp-dev \
    gnupg \
    icu-dev \
    icu-libs \
    imagemagick \
    imagemagick-dev \
    imagemagick-svg \
    libgomp \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libldap \
    libmcrypt \
    libmcrypt-dev \
    libmemcached \
    libmemcached-dev \
    libpng \
    libpng-dev \
    libzip \
    libzip-dev \
    nginx \
    oniguruma \
    oniguruma-dev \
    openldap-dev \
    openssl \
    pcre \
    pcre-dev \
    postgresql-dev \
    postgresql-libs \
    py3-jinja2 \
    py3-yaml \
    python3 \
    samba-client \
    sudo \
    supervisor \
    tar \
    tini \
    wget \
# PHP Extensions
# https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html
  && docker-php-ext-configure gd --with-freetype=/usr --with-jpeg=/usr \
  && docker-php-ext-configure ldap \
  && docker-php-ext-configure zip \
  && docker-php-ext-install -j "$(nproc)" \
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
    zip \
  && pecl channel-update pecl.php.net \
  && pecl install APCu-5.1.24 \
  # && pecl install imagick-3.7.0
  # Fix for php8.3 - https://gist.github.com/Wirone/d5c794b4fef0203146a27687e80588a6#file-workaround-dockerfile
  && curl -fLo /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/refs/tags/${IMAGICK_VERSION}.tar.gz \
  && tar --strip-components=1 -xf /tmp/imagick.tar.gz \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
  && rm -rf /tmp/* \
  # <<< End of Imagick installation
  && pecl install mcrypt-1.0.7 \
  && pecl install memcached-3.3.0 \
  && pecl install redis-6.1.0 \
  && docker-php-ext-enable apcu imagick mcrypt memcached redis \
# Remove dev packages
  && apk del \
    alpine-sdk \
    autoconf \
    freetype-dev \
    gmp-dev \
    icu-dev \
    imagemagick-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    openldap-dev \
    pcre-dev \
    postgresql-dev \
  && rm -rf /var/cache/apk/* \
  # Enable PHP production config
  && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Step 2: Install nextcloud
RUN set -ex \
  && mkdir -p /opt/nextcloud \
  # Download Nextcloud
  && cd /tmp \
  && NEXTCLOUD_TARBALL="nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" \
  && NEXTCLOUD_METADATA="nextcloud-${NEXTCLOUD_VERSION}.metadata" \
  && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL} \
  && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_METADATA} \
  && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.sha256 \
  && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.asc \
  && wget -q https://nextcloud.com/nextcloud.asc \
  # Verify checksum
  && echo "Verifying both integrity and authenticity of ${NEXTCLOUD_TARBALL}..." \
  && CHECKSUM_STATE=$(echo -n $(sha256sum -c ${NEXTCLOUD_TARBALL}.sha256) | tail -c 2) \
  && if [ "${CHECKSUM_STATE}" != "OK" ]; then echo "Warning! Checksum does not match!" && exit 1; fi \
  && gpg --import nextcloud.asc \
  && FINGERPRINT="$(LANG=C gpg --verify ${NEXTCLOUD_TARBALL}.asc ${NEXTCLOUD_TARBALL} 2>&1 | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
  && if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!" && exit 1; fi \
  && if [ "${FINGERPRINT}" != "${NEXTCLOUD_GPG}" ]; then echo "Warning! Wrong GPG fingerprint!" && exit 1; fi \
  && echo "All seems good, now unpacking ${NEXTCLOUD_TARBALL}..." \
  # Extract
  && tar xjf ${NEXTCLOUD_TARBALL} --strip-components=1 -C /opt/nextcloud \
  # Preserve install config
  && mkdir -p /opt/nextcloud.install \
  && cp -r /opt/nextcloud/config/* /opt/nextcloud.install \
  # Remove nextcloud updater for safety
  && rm -rf /opt/nextcloud/updater \
  && rm -rf /tmp/* /root/.gnupg \
  && rm -rf /opt/nextcloud/data /opt/nextcloud/config \
  && ln -sf /data/data /opt/nextcloud/data \
  && ln -sf /data/config /opt/nextcloud/config \
  && ln -sf /data/userapps /opt/nextcloud/userapps \
  && ln -sf /data/php.nextcloud.ini "$PHP_INI_DIR/conf.d/nextcloud.ini"

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
ENV \
  ENABLE_CONFIG_AUTOCONFIG="false" \
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

# Set tini as entrypoing
ENTRYPOINT ["/sbin/tini", "--"]

# Run everthing
CMD ["/docker-run.sh"]
