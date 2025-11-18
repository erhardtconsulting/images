FROM docker.io/library/debian:bookworm-slim@sha256:b4aa902587c2e61ce789849cb54c332b0400fe27b1ee33af4669e1f7e7c3e22f

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
      postgresql-client-16; \
    apt-get clean

# Copy root
COPY root/ /

# Set workdir
WORKDIR /app

# Set user
USER nobody:nogroup

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="PostgreSQL 16 init database container"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/docker-run.sh"]