#!/usr/bin/env bash

if [[ -f "/usr/local/etc/env" && -z "${CONTAINERBASE_ENV+x}" ]]; then
    # shellcheck source=/dev/null
  . /usr/local/etc/env
fi

if [[ ! -d "/tmp/containerbase" ]]; then
  # initialize all prepared tools
  containerbase-cli init tool all
fi

# Check variables
if [[ -z "${CRONITOR_API_KEY}"     ||
      -z "${CRONITOR_MONITOR_KEY}"
]]; then
  echo "⛔ Cronitor is not configured!"
  [[ -z "${CRONITOR_API_KEY}" ]]     && echo "- CRONITOR_API_KEY is not set"
  [[ -z "${CRONITOR_MONITOR_KEY}" ]] && echo "- CRONITOR_MONITOR_KEY is not set"
  exit 255
fi

CRONITOR_URL="https://cronitor.link/p/${CRONITOR_API_KEY}/${CRONITOR_MONITOR_KEY}"

# Running renovate
curl -sS --output /dev/null "${CRONITOR_URL}?state=run"
if /usr/local/sbin/renovate; then
  curl -sS --output /dev/null "${CRONITOR_URL}?state=complete"
else
  curl -sS --output /dev/null "${CRONITOR_URL}?state=fail"
fi
