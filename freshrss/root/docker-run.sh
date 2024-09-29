#!/bin/bash

# Check if /tmp is writeable
if [ ! -w "/tmp" ]; then
  echo "⛔ Directory '/tmp' is not writeable by the user. Aborting!"
  exit 255
fi

# Create session directory
mkdir -p /tmp/sessions

# Prepare everything
/usr/local/bin/php /opt/freshrss/cli/prepare.php > /dev/null

# Run supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf