FROM docker.io/renovate/renovate:39.195.1@sha256:0b64cf7eaf76f7178f79604157989a031e3858684321ae063fea7df9ea21144d

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