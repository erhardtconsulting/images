FROM quay.io/viaductoss/ksops:4.3.3@sha256:6b5ec4b6144307f78bcddffd8f09020482836eee34cf77bf4ce8614b0452a73c as ksops-builder
FROM quay.io/argoproj/argocd:v2.14.13@sha256:9d5675575a1a7f0f88e21a31fe336187de4c91b64c6f01d37ebec8cb18a71380

# renovate: datasource=github-releases depName=getsops/sops versioning=semver
ARG SOPS_VERSION="v3.10.2"

ARG KUBECTL_VERSION=1.30.2

ARG VALS_VERSION=0.41.1
ARG HELM_SECRETS_VERSION=4.6.0

ARG TARGETARCH

ENV XDG_CONFIG_HOME=/.config \
    HELM_SECRETS_BACKEND="vals" \
    HELM_SECRETS_HELM_PATH=/usr/local/bin/helm \
    HELM_PLUGINS="/home/argocd/.local/share/helm/plugins/" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS=false \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH=false \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL=false \
    HELM_SECRETS_WRAPPER_ENABLED=false \
    HELM_SECRETS_CURL_PATH=/usr/bin/curl \
    HELM_SECRETS_SOPS_PATH=/usr/local/bin/sops \
    HELM_SECRETS_VALS_PATH=/usr/local/bin/vals \
    HELM_SECRETS_KUBECTL_PATH=/usr/local/bin/kubectl

ADD --chmod=0755 https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${TARGETARCH} /usr/local/bin/sops

COPY --from=ksops-builder /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=ksops-builder /usr/local/bin/ksops /usr/local/bin/ksops

USER root

RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      curl; \
    apt-get clean; \
    mkdir -p ${HELM_PLUGINS}; \
    GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/'); \
    # install kubectl
    curl -fLo /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${GO_ARCH}/kubectl"; \
    chmod +x /usr/local/bin/kubectl; \
    # install vals
    curl -fL "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${GO_ARCH}.tar.gz" | tar -xvz -C /tmp; \
    cp /tmp/vals /usr/local/bin/vals; \
    rm -rf /tmp/*; \
    # install helm-secrets
    curl -fL "https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz" | tar -xvz -C ${HELM_PLUGINS}; \
    # enable wrapper
    ln -sf ${HELM_PLUGINS}/helm-secrets/scripts/wrapper/helm.sh /usr/local/bin/helm

USER argocd

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="ArgoCD with ksops integrated"
LABEL org.opencontainers.image.licenses="MIT"