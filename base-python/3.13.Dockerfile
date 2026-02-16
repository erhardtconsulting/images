FROM docker.io/library/python:3.13.2-slim@sha256:6b3223eb4d93718828223966ad316909c39813dee3ee9395204940500792b740

ARG TARGETARCH
ARG APPUSER_UID="1000"
ARG APPUSER_GID="1000"

# renovate: datasource=github-releases depName=python-poetry/poetry versioning=semver
ARG POETRY_VERSION="2.3.2"

# renovate: datasource=github-releases depName=astral-sh/uv versioning=semver
ARG UV_VERSION="0.10.3"

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    # Python's configuration:
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED="random" \
    # Pip's configuration:
    PIP_NO_CACHE_DIR="off" \
    PIP_DISABLE_PIP_VERSION_CHECK="on" \
    PIP_DEFAULT_TIMEOUT=100 \
    # Poetry's configuration:
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE="false" \
    POETRY_CACHE_DIR="/var/cache/pypoetry" \
    POETRY_HOME="/usr/local" \
    # UV's configuration
    UV_COMPILE_BYTECODE=1 \
    UV_NO_CACHE=1 \
    UV_PYTHON_DOWNLOADS="never" \
    UV_LINK_MODE="copy"

# Install poetry
RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      bash \
      curl \
      tini; \
    # Install poetry
    curl -sSL https://install.python-poetry.org | python3 -; \
    case "${TARGETARCH}" in \
      'amd64') export ARCH='x86_64' ;; \
      'arm64') export ARCH='aarch64' ;; \
    esac; \
    # Install uv
    curl -fsSL "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${ARCH}-unknown-linux-gnu.tar.gz" \
      | tar xzf - -C /usr/local/bin --strip-components=1; \
    uv --version; \
    # Cleanup
    apt-get -y purge \
      curl; \
    apt-get -y autoremove; \
    apt-get clean; \
    # Create unprivileged user
    groupadd -g ${APPUSER_GID} appgroup && \
    useradd -u ${APPUSER_UID} -g appgroup -s /bin/bash -m appuser

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Python 3.13 base image with Poetry and uv installed"
LABEL org.opencontainers.image.licenses="MIT"

# Set tini as entrypoing
ENTRYPOINT ["/usr/bin/tini", "--"]