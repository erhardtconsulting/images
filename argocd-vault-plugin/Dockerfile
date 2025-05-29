FROM quay.io/argoproj/argocd:v2.14.13@sha256:9d5675575a1a7f0f88e21a31fe336187de4c91b64c6f01d37ebec8cb18a71380

# renovate: datasource=github-releases depName=argoproj-labs/argocd-vault-plugin versioning=semver
ARG AVP_VERSION="1.18.1"

# build variables
ARG TARGETARCH

# install argocd vault plugin
ADD --chmod=0755 \
    "https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_${TARGETARCH}" \
    "/usr/local/bin/argocd-vault-plugin"

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="ArgoCD CMP image with argo-vault-plugin"
LABEL org.opencontainers.image.licenses="MIT"

CMD ["/var/run/argocd/argocd-cmp-server"]