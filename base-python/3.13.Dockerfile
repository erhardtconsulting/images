FROM docker.io/library/python:3.13.2-slim@sha256:8f3aba466a471c0ab903dbd7cb979abd4bda370b04789d25440cc90372b50e04

ARG TARGETARCH

# renovate: datasource=github-releases depName=python-poetry/poetry versioning=semver
ARG POETRY_VERSION="2.1.1"

# renovate: datasource=github-releases depName=astral-sh/uv versioning=semver
ARG UV_VERSION="0.6.10"

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
      curl \
      tini; \
    curl -sSL https://install.python-poetry.org | python3 -; \
    case "${TARGETARCH}" in \
      'amd64') export ARCH='x86_64' ;; \
      'arm64') export ARCH='aarch64' ;; \
    esac; \
    curl -fsSL "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${ARCH}-unknown-linux-gnu.tar.gz" \
      | tar xzf - -C /usr/local/bin --strip-components=1; \
    uv --version; \
    apt-get -y purge \
      curl; \
    apt-get -y autoremove; \
    apt-get clean

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Python 3.13 base image with Poetry and uv installed"
LABEL org.opencontainers.image.licenses="MIT"