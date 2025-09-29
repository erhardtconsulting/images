FROM docker.io/renovate/renovate:41.132.1@sha256:ed85314257fd20849fbf9a478067dfd14e6dc41283e988bd7ce9e55e919a7e3c

# Enable root
USER 0

# Install stuff
RUN set -eux; \
    echo "Installing dependencies..."; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
      bash \
      curl \
      tini; \
    apt-get clean

# Copy root
COPY root /

# Numeric user ID for the ubuntu user. Used to indicate a non-root user to OpenShift
USER 12021

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Renovate with integrated Cronitor push"
LABEL org.opencontainers.image.licenses="MIT"

# Set tini as entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

# Use custom script
CMD ["/docker-run.sh"]