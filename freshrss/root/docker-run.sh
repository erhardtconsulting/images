#!/bin/bash

# Prepare everything
/usr/local/bin/frankenphp php-cli /opt/freshrss/cli/prepare.php > /dev/null

# Run supervisord
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf