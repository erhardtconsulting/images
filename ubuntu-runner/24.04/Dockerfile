FROM docker.io/library/ubuntu:24.04@sha256:80dd3c3b9c6cecb9f1667e9290b3bc61b78c2678c02cbdae5f0fea92cc6734ab

# renovate: datasource=github-releases depName=getsops/sops versioning=semver
ARG SOPS_VERSION="v3.9.2"

# renovate: datasource=github-tags depName=nvm-sh/nvm versioning=semver
ARG NVM_VERSION="v0.40.1"

# renovate: datasource=github-tags depName=nodejs/node versioning=semver
ARG NODE_VERSION="v22.12.0"

# renovate: datasource=github-releases depName=rclone/rclone versioning=semver
ARG RCLONE_VERSION="v1.68.2"

# renovate: datasource=github-releases depName=dotenvx/dotenvx versioning=semver
ARG DOTENVX_VERSION="v1.31.3"

ADD --chmod=0755 https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops

RUN set -eux; \
    apt-get update; \
    # install some software
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
      age \
      bash \
      build-essential \
      ca-certificates \
      curl \
      docker.io \
      git \
      gnupg \
      podman \
      unzip \
      wget; \
    apt-get clean; \
    # install NodeJS
    # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
    export GNUPGHOME="$(mktemp -d)"; \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    for key in \
      C0D6248439F1D5604AAFFB4021D900FFDB233756 \
      DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
      CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      A363A499291CBBC940DD62E41F10027AF002F8B0;  \
    do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    done; \
    curl -fsSLO --compressed "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz"; \
    curl -fsSLO --compressed "https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt.asc"; \
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; \
    grep " node-$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c -; \
    tar -xJf "node-$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner; \
    rm "node-$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
    # smoke tests
    node --version; \
    npm --version; \
    # install rclone
    curl -fsSLO "https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip"; \
    unzip "rclone-${RCLONE_VERSION}-linux-amd64.zip"; \
    cp "rclone-${RCLONE_VERSION}-linux-amd64/rclone" /usr/local/bin/rclone; \
    chmod +x /usr/local/bin/rclone; \
    rm -rf "rclone-${RCLONE_VERSION}-linux-amd64"; \
    rm "rclone-${RCLONE_VERSION}-linux-amd64.zip"; \
    # install dotenvx
    DOTENVX_VERSION_STRIPPED="${DOTENVX_VERSION#v}"; \
    curl -fsSLO "https://github.com/dotenvx/dotenvx/releases/download/${DOTENVX_VERSION}/dotenvx-${DOTENVX_VERSION_STRIPPED}-linux-amd64.tar.gz"; \
    tar -xzf "dotenvx-${DOTENVX_VERSION_STRIPPED}-linux-amd64.tar.gz" -C /usr/local/bin; \
    rm "dotenvx-${DOTENVX_VERSION_STRIPPED}-linux-amd64.tar.gz"

CMD ["/bin/bash"]