FROM quay.io/viaductoss/ksops:v4.5.1@sha256:4def9fdd4e2f850265740ebe9592c5455d19b76891e88e602df8b52d74b95334 as ksops-builder
FROM quay.io/argoproj/argocd:v3.6.2@sha256:bbcc3b6e79c5963439bdc5170f6e20a52365b41878133fac5ce8d6810d2641dc

# renovate: datasource=github-releases depName=getsops/sops versioning=semver
ARG SOPS_VERSION="3.13.3"

ARG KUBECTL_VERSION=1.37.1

# renovate: datasource=github-releases depName=helmfile/vals versioning=semver
ARG VALS_VERSION=0.51.1

# renovate: datasource=github-releases depName=jkroepke/helm-secrets versioning=semver
ARG HELM_SECRETS_VERSION=4.7.11

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
    plugin_install_dir=$(mktemp -d); \
    mkdir -m 0700 "${plugin_install_dir}/gnupg"; \
    curl -fLo "${plugin_install_dir}/key.asc" https://github.com/jkroepke.gpg; \
    gpg --homedir "${plugin_install_dir}/gnupg" --batch --import "${plugin_install_dir}/key.asc"; \
    gpg --homedir "${plugin_install_dir}/gnupg" --batch \
      --export 1F34F95B4F30BC5B06E0D7CC3F619F17002790D8 > "${plugin_install_dir}/keyring.gpg"; \
    for plugin in secrets secrets-getter secrets-post-renderer; do \
      # Helm 4's HTTP installer uses HELM_DATA_HOME instead of HELM_PLUGINS.
      HELM_DATA_HOME="${plugin_install_dir}/data" HELM_CACHE_HOME="${plugin_install_dir}/cache" \
        "${HELM_SECRETS_HELM_PATH}" plugin install --verify \
          --keyring "${plugin_install_dir}/keyring.gpg" \
          "https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/${plugin}-${HELM_SECRETS_VERSION}.tgz"; \
      mv "${plugin_install_dir}/data/plugins/${plugin}" "${HELM_PLUGINS}/${plugin}"; \
    done; \
    rm -rf "${plugin_install_dir}"; \
    # enable wrapper
    ln -sf ${HELM_PLUGINS}/secrets/scripts/wrapper/helm.sh ${TOOLS_FOLDER}/bin/helm

USER ${ARGOCD_USER_ID}

ENV PATH="${TOOLS_FOLDER}/bin:${PATH}"

RUN set -eux; \
    helm secrets --version; \
    plugins=$(helm plugin list); \
    printf '%s\n' "${plugins}" | grep -E '^secrets[[:space:]]+[^[:space:]]+[[:space:]]+cli/v1[[:space:]]+v1[[:space:]]'; \
    printf '%s\n' "${plugins}" | grep -E '^secrets-getter[[:space:]]+[^[:space:]]+[[:space:]]+getter/v1[[:space:]]+v1[[:space:]]'; \
    printf '%s\n' "${plugins}" | grep -E '^secrets-post-renderer[[:space:]]+[^[:space:]]+[[:space:]]+postrenderer/v1[[:space:]]+v1[[:space:]]'

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/images"
LABEL org.opencontainers.image.description="ArgoCD with ksops and helm-secrets integrated"
LABEL org.opencontainers.image.licenses="MIT"