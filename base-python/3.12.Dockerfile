FROM docker.io/library/python:3.12.9-slim@sha256:34656cd90456349040784165b9decccbcee4de66f3ead0a1168ba893455afd1e

# renovate: datasource=github-releases depName=python-poetry/poetry versioning=semver
ARG POETRY_VERSION="2.1.1"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # Poetry's configuration:
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR='/var/cache/pypoetry' \
    POETRY_HOME='/usr/local'

# Install poetry
RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      curl; \
    curl -sSL https://install.python-poetry.org | python3 -; \
    apt-get -y purge \
      curl; \
    apt-get clean

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="Python 3.12 base image with Poetry installed"
LABEL org.opencontainers.image.licenses="MIT"