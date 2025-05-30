FROM quay.io/viaductoss/ksops:4.3.3@sha256:6b5ec4b6144307f78bcddffd8f09020482836eee34cf77bf4ce8614b0452a73c as ksops-builder
FROM quay.io/argoproj/argocd:v2.14.13@sha256:9d5675575a1a7f0f88e21a31fe336187de4c91b64c6f01d37ebec8cb18a71380

ARG SOPS_VERSION=3.9.0

ENV XDG_CONFIG_HOME=/.config

COPY --from=ksops-builder /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=ksops-builder /usr/local/bin/ksops /usr/local/bin/ksops

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="ArgoCD with ksops integrated"
LABEL org.opencontainers.image.licenses="MIT"