FROM docker.io/library/debian:bookworm-slim@sha256:d207e19faa1927ee8750bc2ebcfdb0b5db65a56de9a31d27d41a08ce56c6c9cf

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