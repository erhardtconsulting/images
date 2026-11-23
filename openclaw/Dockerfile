FROM ghcr.io/denoland/deno:bin-2.9.8@sha256:b507583d3c68ba69f3ed2ce5969ae5b8b70f43421c781279c7aea06435263543 AS deno
FROM ghcr.io/astral-sh/uv:0.13.9@sha256:d3b601f0c7b118bc1753febf7c41cc80981df678445e0254284eecf84db79a7d AS uv
FROM docker.io/library/eclipse-temurin:25.0.5_8-jdk-noble@sha256:8599ea2d8f71696f00dcdf46213a4b65fa97ceeaa318671fccba6b0af2727792 AS temurin
FROM docker.io/library/maven:3.10.2-eclipse-temurin-25@sha256:fdb6138e3d3600784c9e5f540d34d89c5c7c6074f80f611abd2c6025d9b81ef7 AS maven
FROM ghcr.io/openclaw/openclaw:2026.11.6@sha256:65e229536a2698f0ab211c8a3d1c5c8e2685d19379d153e95f93ff76f22779cf AS base

# renovate: datasource=github-releases depName=yt-dlp/yt-dlp versioning=pep440
ARG YTDLP_VERSION="2026.10.26"

USER root

COPY --from=deno /deno /usr/local/bin/deno
COPY --from=uv /uv /uvx /usr/local/bin/
COPY --from=temurin /opt/java/openjdk /opt/openclaw-tools/java
COPY --from=maven /usr/share/maven /opt/openclaw-tools/maven

ENV JAVA_HOME="/opt/openclaw-tools/java" \
    MAVEN_HOME="/opt/openclaw-tools/maven" \
    PYTHONDONTWRITEBYTECODE=1

ENV PATH="${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      7zip \
      bzip2 \
      dnsutils \
      ffmpeg \
      file \
      gh \
      imagemagick \
      iproute2 \
      iputils-ping \
      jq \
      less \
      libreoffice-nogui \
      make \
      netcat-openbsd \
      openscad \
      pandoc \
      patch \
      pdfgrep \
      poppler-utils \
      python3-docx \
      python3-openpyxl \
      python3-pdfminer \
      python3-pypdf \
      python3-reportlab \
      python3-trimesh \
      python3-venv \
      qpdf \
      rsync \
      sqlite3 \
      tree \
      unzip \
      vim \
      wget \
      xauth \
      xvfb \
      xz-utils \
      zip \
      zstd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

RUN case "$(dpkg --print-architecture)" in \
      amd64) asset=yt-dlp_linux ;; \
      arm64) asset=yt-dlp_linux_aarch64 ;; \
      *) echo "Unsupported yt-dlp architecture" >&2; exit 1 ;; \
    esac && \
    cd /tmp && \
    curl -fsSL --retry 3 -o "$asset" \
      "https://github.com/yt-dlp/yt-dlp/releases/download/${YTDLP_VERSION}/${asset}" && \
    curl -fsSL --retry 3 -o SHA2-256SUMS \
      "https://github.com/yt-dlp/yt-dlp/releases/download/${YTDLP_VERSION}/SHA2-256SUMS" && \
    grep "  ${asset}$" SHA2-256SUMS | sha256sum -c - && \
    install -m 755 "$asset" /usr/local/bin/yt-dlp && \
    rm "$asset" SHA2-256SUMS

FROM base AS qmd-build

# renovate: datasource=npm depName=@tobilu/qmd versioning=semver
ARG QMD_VERSION="2.9.0"

RUN apt-get update && \
    apt-get install -y --no-install-recommends g++ && \
    npm install --global --no-audit --no-fund \
      --allow-scripts=node-llama-cpp,tree-sitter-go,tree-sitter-python,tree-sitter-rust,tree-sitter-typescript,tree-sitter-javascript \
      "@tobilu/qmd@${QMD_VERSION}"

FROM base

COPY --from=qmd-build /usr/local/lib/node_modules/@tobilu/qmd /usr/local/lib/node_modules/@tobilu/qmd
RUN ln -s /usr/local/lib/node_modules/@tobilu/qmd/bin/qmd /usr/local/bin/qmd

USER node

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images" \
      org.opencontainers.image.description="OpenClaw with headless document, PDF, image and development tools"
