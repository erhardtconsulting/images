#!/bin/bash

# Check if /tmp is writeable
if [ ! -w "/tmp" ]; then
  echo "⛔ Directory '/tmp' is not writeable by the user. Aborting!"
  echo "Directory Info: $(ls -lhd /tmp)"
  exit 255
fi

# Check if /data is writeable
if [ ! -w "/data" ]; then
  echo "⛔ Directory '/data' is not writeable by the user. Aborting!"
  echo "UID: $(id)"
  echo "Directory Info: $(ls -lhd /data)"
  exit 255
fi

# Bootstrap application
echo "Preparing environment..."

# Check if config exists
if [ ! -d /data/config ]; then
  mkdir /data/config

  # Allow installation
  touch /data/config/CAN_INSTALL

  # Copy sample config
  cp -f /opt/nextcloud.install/config.sample.php /data/config/
fi

# Create additional directories
mkdir -p /data/data /data/tmp /data/userapps /tmp/sessions

# Build nextcloud php config
envsubst < /opt/nextcloud.install/nextcloud.ini > /data/php.nextcloud.ini

if [ "$ENABLE_CONFIG_AUTOCONFIG" = "true" ]; then
  cp /opt/nextcloud.install/autoconfig.php /data/config/
fi

if [ "$ENABLE_CONFIG_DOCKER" = "true" ]; then
  cp /opt/nextcloud.install/docker.config.php /data/config/
fi

if [ "$ENABLE_CONFIG_REDIS" = "true" ]; then
  cp /opt/nextcloud.install/redis.config.php /data/config/
fi

if [ "$ENABLE_CONFIG_REVERSE_PROXY" = "true" ]; then
  cp /opt/nextcloud.install/reverse-proxy.config.php /data/config/
fi

if [ "$ENABLE_CONFIG_S3" = "true" ]; then
  cp /opt/nextcloud.install/s3.config.php /data/config/
fi

if [ "$ENABLE_CONFIG_SMTP" = "true" ]; then
  cp /opt/nextcloud.install/smtp.config.php /data/config/
fi

if [ "$ENABLE_CONFIG_SWIFT" = "true" ]; then
  cp /opt/nextcloud.install/swift.config.php /data/config/
fi

# Copy docker config
cp /opt/nextcloud.install/docker.config.php /data/config/

# Run supervisord
if [ "$ENABLE_CRON" = "true" ]; then
  echo "Cron: enabled"
  exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
else
  echo "Cron: disabled"
  exec /usr/bin/supervisord -c /etc/supervisor/supervisord-nocron.conf
fi
