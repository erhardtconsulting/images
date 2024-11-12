FROM docker.io/library/alpine:3.20@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a

# renovate: datasource=repology depName=alpine_3_20/postgresql16-client versioning=loose
ARG PG_CLIENT_VERSION="16.4-r0"

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