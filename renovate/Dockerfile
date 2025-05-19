FROM docker.io/renovate/renovate:40.18.1@sha256:98e3f84b64a7393f0170bfe077958572a24c53ea1dd8e2cc0472aa5fb9ab6123

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