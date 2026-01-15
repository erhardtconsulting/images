FROM ghcr.io/erhardtconsulting/base-python:3.12.9@sha256:60578e2d720223cc7939b7bb515fe4a3e6b9a7e4bcb200f41b12233a04362b9e

# renovate: datasource=pypi depName=mcpo versioning=semver
ARG MCPO_VERSION="0.0.17"

# Set global virtual env
ENV VIRTUAL_ENV=/app/.venv \
    PORT=8000

# Update node
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
      curl \
      ca-certificates; \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -; \
    apt-get install -y  \
      nodejs; \
    apt-get clean; \
    node -v; \
    npm -v

# Copy root
COPY root /

# Update path
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install mcpo
RUN uv venv "$VIRTUAL_ENV"; \
    uv pip install "mcpo==$MCPO_VERSION"

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="MCPO image for exposing MCP servers to Open WebUI"
LABEL org.opencontainers.image.licenses="MIT"

RUN chown -R appuser:appgroup /app

# Set user
USER appuser:appgroup

WORKDIR /home/appuser

EXPOSE $PORT

CMD ["/docker-run.sh"]