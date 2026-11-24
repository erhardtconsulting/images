FROM docker.io/library/debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0

# https://www.postgresql.org/download/linux/debian/
RUN set -eux; \
    echo "Installing dependencies..."; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
      bash \
      extrepo \
      tini; \
    echo "Enabling PostgreSQL repository..."; \
    extrepo enable postgresql; \
    echo "Installing PostgreSQL..."; \
    apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
      postgresql-client-18; \
    apt-get clean

# Copy root
COPY root/ /

# Set workdir
WORKDIR /app

# Set user
USER nobody:nogroup

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="PostgreSQL 18 init database container"
LABEL org.opencontainers.image.licenses="MIT"
