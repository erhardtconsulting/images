# Rootless Docker Images

This repository provides rootless Docker images of various open-source projects, enabling secure deployment in Kubernetes clusters without granting root privileges.

## Why Rootless Docker Images?

Security is paramount in containerized environments. Running containers with root privileges can pose significant security risks. By utilizing rootless Docker images, we ensure that applications operate with the least privileges necessary, enhancing the overall security posture of your Kubernetes cluster.

## Available Images

### [Argo CD](./argocd)

The Argo CD image includes ksops, SOPS, vals, kubectl, and helm-secrets.
For Helm 4, it installs the separate `secrets`, `secrets-getter`, and
`secrets-post-renderer` plugins at the version pinned in `argocd/Dockerfile`.
The build verifies their signatures using the manufacturer's signing key
(`1F34F95B4F30BC5B06E0D7CC3F619F17002790D8`) fetched from
<https://github.com/jkroepke.gpg>. See the
[helm-secrets installation guide](https://github.com/jkroepke/helm-secrets/wiki/Installation#using-helm-plugin-manager).

The Helm wrapper remains enabled so `helm template` decrypts encrypted values
files using SOPS, including absolute paths passed by Argo CD. The `secrets://`
getter is also available. Decryption keys or KMS credentials must still be
provided by the deployment.

Build and check the image locally:

```sh
podman build --build-arg TARGETARCH="$(podman info --format '{{.Host.Arch}}')" \
  -f argocd/Dockerfile -t localhost/argocd:helm-secrets-test argocd
podman run --rm localhost/argocd:helm-secrets-test helm secrets --help
podman run --rm localhost/argocd:helm-secrets-test helm plugin list
```

The build checks CLI availability and all three Helm 4 plugin types as the
unprivileged Argo CD user.

### [FreshRSS](./freshrss)

[FreshRSS](https://freshrss.org/) is a self-hosted RSS feed aggregator that allows you to collect and read news and articles from various sources in one place. It's lightweight, customizable, and supports multiple users.

### [Nextcloud](./nextcloud)

[Nextcloud](https://nextcloud.com/) is a self-hosted platform that provides file storage, collaboration tools, and synchronization services. It allows users to store and share files, calendars, and contacts, and integrates with many third-party apps. Our rootless Nextcloud Docker image provides a secure way to deploy this powerful suite without root privileges, ideal for Kubernetes environments where security is critical.

## Container Builds

The reusable workflow in `.github/workflows/build-container.yml` builds images with Buildah for `linux/amd64` and `linux/arm64` by default. Callers can select architectures through the `architectures` JSON-array input.

Cross-architecture builds use `docker/setup-qemu-action` to register static QEMU emulators through a container, without depending on the runner distribution's `qemu-user-static` package. When publishing is enabled, the architecture-specific images are combined into a multiarch manifest.

## Disclaimer

Erhardt Consulting GmbH is not affiliated with the projects contained within these images. All images are provided "as-is" without any warranty. We aim to offer helpful resources, but we cannot guarantee the functionality or security of the applications themselves.

For issues unrelated to the containerization, please report them directly to the respective projects.

## License

The code for the container configurations in this repository is provided under the terms of the [MIT License](LICENSE). Please note that this license does not apply to the application code within the containers, which may be distributed under different, possibly more restrictive licenses. Users are responsible for complying with the licenses of the underlying applications.