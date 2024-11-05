FROM docker.io/ubuntu:24.04@sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5

# renovate: datasource=github-releases depName=getsops/sops versioning=semver
ARG SOPS_VERSION="v3.9.1"

ADD --chmod=0755 https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
      age \
      bash \
      build-essential \
      ca-certificates \
      curl \
      git \
      rclone \
      wget; \
    apt-get clean

CMD ["/bin/bash"]