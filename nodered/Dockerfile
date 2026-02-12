#### Stage BASE ########################################################################################################
FROM docker.io/library/node:lts-trixie@sha256:0c36fcf0bfd7d2c60bb4615dbac143bf9d8309c9bfb13c158095602b396a0f3a AS base

# Copy scripts
COPY scripts/*.sh /tmp/
COPY healthcheck.js /

# Install tools, create Node-RED app and data dir, add user and set rights
RUN set -ex && \
    apt-get update && apt-get install -y \
        bash \
        tzdata \
        curl \
        nano \
        wget \
        git \
        openssl \
        openssh-client \
        ca-certificates \
        iputils-ping && \
    mkdir -p /usr/src/node-red /data && \
    deluser --remove-home node && \
    # adduser --home /usr/src/node-red --disabled-password --no-create-home node-red --uid 1000 && \
    useradd --home-dir /usr/src/node-red --uid 1000 node-red && \
    chown -R node-red:root /data && chmod -R g+rwX /data && \
    chown -R node-red:root /usr/src/node-red && chmod -R g+rwX /usr/src/node-red
    # chown -R node-red:node-red /data && \
    # chown -R node-red:node-red /usr/src/node-red

# Set work directory
WORKDIR /usr/src/node-red

# Setup SSH known_hosts file
COPY known_hosts.sh .
RUN ./known_hosts.sh /etc/ssh/ssh_known_hosts && rm /usr/src/node-red/known_hosts.sh
RUN echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/ssh_config

# package.json contains Node-RED NPM module and node dependencies
COPY package.json .
COPY flows.json /data
COPY scripts/entrypoint.sh .

#### Stage BUILD #######################################################################################################
FROM base AS build

# Install Build tools
RUN apt-get update && apt-get install -y build-essential python3 python-is-python3 && \
    npm install --unsafe-perm --no-update-notifier --no-fund --only=production && \
    npm uninstall node-red-node-gpio && \
    cp -R node_modules prod_node_modules

#### Stage RELEASE #####################################################################################################
FROM base AS release

LABEL org.opencontainers.image.description="Extended & customized Node-RED image" \
      org.opencontainers.image.authors="Simon Erhardt <simon@erhardt.consulting>" \
      org.opencontainers.image.source="https://github.com/erhardtconsulting/images"

COPY --from=build /usr/src/node-red/prod_node_modules ./node_modules

# Chown, install devtools & Clean up
RUN chown -R node-red:root /usr/src/node-red && \
    apt-get update && apt-get install -y build-essential python3-dev python3 && \
    rm -r /tmp/*

RUN npm config set cache /data/.npm --global

USER node-red

# Env variables
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules \
    PATH=/usr/src/node-red/node_modules/.bin:${PATH} \
    FLOWS=flows.json

# ENV NODE_RED_ENABLE_SAFE_MODE=true    # Uncomment to enable safe start mode (flows not running)
# ENV NODE_RED_ENABLE_PROJECTS=true     # Uncomment to enable projects option

# Expose the listening port of node-red
EXPOSE 1880

# Add a healthcheck (default every 30 secs)
HEALTHCHECK CMD node /healthcheck.js

ENTRYPOINT ["./entrypoint.sh"]