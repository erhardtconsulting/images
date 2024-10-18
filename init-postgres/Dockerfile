FROM docker.io/library/alpine:3.20

# renovate: datasource=repology depName=alpine_3_20/postgresql16-client versioning=loose
ARG PG_CLIENT_VERSION="16.3-r0"

USER root
WORKDIR /app

# Install dependencies
RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        postgresql16-client~"${PG_CLIENT_VERSION}" \
        tini

# Copy root
COPY root/ /

# Set user
USER nobody:nogroup

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/docker-run.sh"]