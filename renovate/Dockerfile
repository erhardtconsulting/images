FROM docker.io/renovate/renovate:41.132.4@sha256:b9d264b8deef69ed7f1221fbbcc7798a0b8d1a1e2c2fad19ab046caad5ab0a73

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