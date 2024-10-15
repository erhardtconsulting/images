FROM docker.io/library/alpine:3.20

ARG TARGETPLATFORM
ARG PG_CLIENT_VERSION="16.3-r0"
ARG CHANNEL

USER root
WORKDIR /app

#hadolint ignore=DL3018
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