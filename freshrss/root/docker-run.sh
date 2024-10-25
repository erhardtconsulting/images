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
  echo "Directory Info: $(ls -lhd /data)"
  exit 255
fi

# Create session directory
mkdir -p /tmp/sessions

# Prepare everything
/usr/local/bin/php /opt/freshrss/cli/prepare.php > /dev/null

# Run supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf