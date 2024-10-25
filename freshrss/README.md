![FreshRSS Logo](https://raw.githubusercontent.com/FreshRSS/FreshRSS/refs/heads/edge/docs/img/FreshRSS-logo.png)

# FreshRSS Rootless Docker Image

- **Official Website**: [FreshRSS.org](https://freshrss.org)
- **Project License**: [GNU AGPL 3](https://www.gnu.org/licenses/agpl-3.0.html)

## Overview

This repository provides a rootless Docker image for [FreshRSS](https://freshrss.org), a self-hosted RSS feed aggregator that allows you to collect and read news and articles from various sources in one place. FreshRSS is lightweight, customizable, and supports multiple users.

Our rootless Docker image is specifically designed to run securely in Kubernetes clusters without granting root privileges. It includes FreshRSS, running on NGINX and PHP-FPM, optimized for secure, rootless operation.

## Why Use a Rootless Image?

Security is a critical concern in containerized environments. Running containers with root privileges can pose significant security risks, such as privilege escalation and unauthorized access. By utilizing a rootless Docker image, you enhance the security of your Kubernetes cluster by ensuring that the application operates with the least privileges necessary. This image differs from the original project image by enabling rootless execution, making it more suitable for environments where security is a priority.

## Features

- **Rootless Operation**: Enhances security by running without root privileges.
- **Kubernetes Ready**: Easily deployable in Kubernetes clusters.
- **Volume Support**: Supports writable volumes for data and extensions.

## Getting Started

### Prerequisites

- **Docker**: For container management.
- **Docker Compose** (optional): For local deployment.
- **Kubernetes**: For cluster deployment.

### Container User

This container uses the user "freshrss" with UID 2000 and GID 2000 for running all his processes.

### Volume Mounts

**Necessary Volumes:**

- **Data Volume**: `/data` \
  This volume is used for storing the data and caches of FreshRSS. It has to be writeable by the user.
- **Temporary Volume**: `/tmp` \
  This volume is used for storing process and session data. It has to be writeable by the user.

**Optional Volumes:**

- **Extensions Volume**: `/opt/freshrss/extensions` \
  This volume is used for storing FreshRSS extensions. Download and install your extensions there, and they will be automatically loaded by FreshRSS.

### Environment Variables

- **TZ**: Set your local timezone (e.g., `Europe/Zurich`).

### Unsupported Environment Variables

The following environment variables from the original Docker image are not supported in this rootless version:

- `FRESHRSS_INSTALL`
- `FRESHRSS_USER`

Please use the installation assistant provided by FreshRSS for setup.

### Configuration

You can override the configuration using config maps by mounting them to:

- `/data/config.custom.php`
- `/data/config-user.custom.php`

## Usage Examples

### Kubernetes Deployment

Create a `freshrss-deployment.yaml` file with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: freshrss
spec:
  replicas: 1
  selector:
    matchLabels:
      app: freshrss
  template:
    metadata:
      labels:
        app: freshrss
    spec:
      securityContext:
        runAsUser: 2000
        runAsGroup: 2000
        fsGroup: 2000
      containers:
        - name: freshrss
          image: quay.io/erhardtconsulting/freshrss
          env:
            - name: TZ
              value: "Europe/Zurich"
          volumeMounts:
            - name: data
              mountPath: /data
            - name: tmp-tmpfs
              mountPath: /tmp
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: freshrss-data
        - name: tmp-tmpfs
          emptyDir:
            medium: Memory
```

Apply the deployment:

```bash
kubectl apply -f freshrss-deployment.yaml
```

### Docker Compose

See [docker-compose.yaml](docker-compose.yaml).

Start the container:

```bash
docker-compose up -d
```

## Additional Resources

- **FreshRSS Code Repository**: [GitHub](https://github.com/FreshRSS/FreshRSS)
- **FreshRSS Documentation**: [Official Docs](https://freshrss.github.io/FreshRSS/)

## Issues and Contributions

For issues related to the container itself, please open an issue in this repository. For issues concerning the FreshRSS application, refer to the [original FreshRSS repository](https://github.com/FreshRSS/FreshRSS).

## Disclaimer

Erhardt Consulting GmbH is not affiliated with the FreshRSS project or its contributors. This rootless Docker image is provided "as is" to facilitate the deployment of FreshRSS in Kubernetes clusters without root privileges. All images are provided without warranty of any kind.

Please report any issues unrelated to containerization directly to the FreshRSS project. The code for the container configuration is provided under the terms of the [MIT License](../LICENSE). Note that this license does not apply to the application code within the containers, which may be distributed under different, possibly more restrictive licenses. Users are responsible for complying with the licenses of the underlying applications.