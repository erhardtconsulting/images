FROM ghcr.io/erhardtconsulting/base-python:3.13.2@sha256:360051d1221ae6a83c66176dc5a2bbac22bc3b634b81cab22a9302c3231c4a4a

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