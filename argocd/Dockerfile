FROM quay.io/viaductoss/ksops:4.3.3@sha256:6b5ec4b6144307f78bcddffd8f09020482836eee34cf77bf4ce8614b0452a73c as ksops-builder
FROM quay.io/argoproj/argocd:v3.2.3@sha256:9ab6baab65a6b283044a7d7b7dbe50f589564de9c8898d67c77d84b2b5df46bc

# renovate: datasource=github-releases depName=getsops/sops versioning=semver
ARG SOPS_VERSION="3.11.0"

ARG KUBECTL_VERSION=1.33.3

# renovate: datasource=github-releases depName=helmfile/vals versioning=semver
ARG VALS_VERSION=0.42.0

# renovate: datasource=github-releases depName=jkroepke/helm-secrets versioning=semver
ARG HELM_SECRETS_VERSION=4.6.5

ARG TARGETARCH

ENV XDG_CONFIG_HOME=/.config \
    TOOLS_FOLDER="/opt/tools" \
    HELM_SECRETS_BACKEND="sops" \
    HELM_SECRETS_VALUES_ALLOW_SYMLINKS="false" \
    HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH="true" \
    HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL="false" \
    HELM_SECRETS_WRAPPER_ENABLED="true"

ENV HELM_PLUGINS="${TOOLS_FOLDER}/helm-plugins" \
    HELM_SECRETS_HELM_PATH="/usr/local/bin/helm" \
    HELM_SECRETS_CURL_PATH="/usr/bin/curl" \
    HELM_SECRETS_SOPS_PATH="${TOOLS_FOLDER}/bin/sops" \
    HELM_SECRETS_VALS_PATH="${TOOLS_FOLDER}/bin/vals" \
    HELM_SECRETS_KUBECTL_PATH="${TOOLS_FOLDER}/bin/kubectl"

# install sops
ADD --chmod=0755 https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${TARGETARCH} ${TOOLS_FOLDER}/bin/sops

COPY --from=ksops-builder /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=ksops-builder /usr/local/bin/ksops /usr/local/bin/ksops

USER root

RUN set -eux; \
    apt-get update; \
    apt-get -y install \
      curl; \
    apt-get clean; \
    mkdir -p ${TOOLS_FOLDER}/bin ${HELM_PLUGINS}; \
    GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/'); \
    # install kubectl
    curl -fLo ${TOOLS_FOLDER}/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${GO_ARCH}/kubectl"; \
    chmod +x ${TOOLS_FOLDER}/bin/kubectl; \
    # install vals
    curl -fL "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${GO_ARCH}.tar.gz" | tar -xvz -C /tmp; \
    cp /tmp/vals ${TOOLS_FOLDER}/bin/vals; \
    rm -rf /tmp/*; \
    # install helm-secrets
    curl -fL "https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz" | tar -xvz -C ${HELM_PLUGINS}; \
    # enable wrapper
    ln -sf ${HELM_PLUGINS}/helm-secrets/scripts/wrapper/helm.sh ${TOOLS_FOLDER}/bin/helm

USER ${ARGOCD_USER_ID}

ENV PATH="${TOOLS_FOLDER}/bin:${PATH}"

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="ArgoCD with ksops and helm-secrets integrated"
LABEL org.opencontainers.image.licenses="MIT"