FROM quay.io/argoproj/argocd:v2.14.13@sha256:9d5675575a1a7f0f88e21a31fe336187de4c91b64c6f01d37ebec8cb18a71380

# renovate: datasource=github-releases depName=argoproj-labs/argocd-vault-plugin versioning=semver
ARG KSOPS_VERSION="4.3.3"

# build variables
ARG TARGETARCH

# install argocd vault plugin
ADD --chmod=0755 \
    "https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_${TARGETARCH}" \
    "/usr/local/bin/argocd-vault-plugin"

https://github.com/viaduct-ai/kustomize-sops/releases/download/v4.3.3/ksops_4.3.3_Linux_x86_64.tar.gz

RUN set -ex; \
    case "${TARGETARCH}" in \
      'amd64') export ARCH='x86_64' ;; \
      'arm64') export ARCH='arm64' ;; \
    esac; \
    # Install uv
    curl -fsSL "github.com/viaduct-ai/kustomize-sops/releases/download/v${UV_VERSION}/ksops_-${ARCH}_Linux_${ARCH}.tar.gz" \
      | tar xzf - -C /usr/local/bin --strip-components=1

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="ArgoCD CMP image with argo-vault-plugin"
LABEL org.opencontainers.image.licenses="MIT"

CMD ["/var/run/argocd/argocd-cmp-server"]