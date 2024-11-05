FROM docker.io/ubuntu:24.04@sha256:5d070ad5f7fe63623cbb99b4fc0fd997f5591303d4b03ccce50f403957d0ddc4

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