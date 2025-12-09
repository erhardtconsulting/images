FROM docker.io/library/debian:bookworm-slim@sha256:e899040a73d36e2b36fa33216943539d9957cba8172b858097c2cabcdb20a3e2

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
      postgresql-client-17; \
    apt-get clean

# Copy root
COPY root/ /

# Set workdir
WORKDIR /app

# Set user
USER nobody:nogroup

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="PostgreSQL 17 init database container"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/docker-run.sh"]