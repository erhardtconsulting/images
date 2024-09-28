![FreshRSS logo](https://raw.githubusercontent.com/FreshRSS/FreshRSS/refs/heads/edge/docs/img/FreshRSS-logo.png)

# FreshRSS Rootless Docker Image

* Official website: [FreshRSS.org](https://freshrss.org)
* Project License: [GNU AGPL 3](https://www.gnu.org/licenses/agpl-3.0.html)

This repository contains a rootless Docker image for the FreshRSS application, designed to run in a Kubernetes cluster. This image includes both FreshRSS and FrankenPHP, and is optimized for secure, rootless operation.

## Features

- **Rootless Operation**: Enhanced security by running without root privileges.
- **Kubernetes Ready**: Easily deployable in a Kubernetes cluster.
- **Volume Support**: Supports writable volumes for data and extensions.
- **Configurable Timezone**: Set your local timezone using the `TZ` environment variable.

## Getting Started

### Prerequisites

- Docker
- Docker Compose (optional, for local deployment)
- Kubernetes (for cluster deployment)

### Volume Mounts

- **Data Volume**: Mount a writable volume to `/opt/freshrss/data`.
- **Extensions Volume** *(optional)*: Mount a writable volume to `/opt/freshrss/extensions` (optional).

### Environment Variables

- **TZ**: Set this to your local timezone (e.g., `Europe/Zurich`).

### Unsupported Environment Variables

The following environment variables from the original Docker file are not supported:
- `FRESHRSS_INSTALL`
- `FRESHRSS_USER`

Use the installation assistant for setup instead.

### Configuration

You can overwrite the configuration using config maps by mounting them to:
- `/opt/freshrss/data/config.custom.php`
- `/opt/freshrss/data/config-user.custom.php`

## Example Usage

### Docker Compose

Create a `docker-compose.yml` file with the following content:

```yaml
version: '3.7'

services:
  freshrss:
    image: your-docker-image
    container_name: freshrss
    environment:
      - TZ=Europe/Zurich
    volumes:
      - ./data:/opt/freshrss/data
      - ./extensions:/opt/freshrss/extensions
    ports:
      - "8080:80"
```

Run the following command to start the container:
```bash
docker-compose up -d
```

### Kubernetes Deployment

Create a freshrss-deployment.yaml file with the following content:
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
      containers:
        - name: freshrss
          image: your-docker-image
          env:
            - name: TZ
              value: "Europe/Zurich"
          volumeMounts:
            - name: data
              mountPath: /opt/freshrss/data
            - name: extensions
              mountPath: /opt/freshrss/extensions
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: freshrss-data
        - name: extensions
          persistentVolumeClaim:
            claimName: freshrss-extensions
```

Apply the deployment with the following command:
```bash
kubectl apply -f freshrss-deployment.yaml
```

## Additional Resources

* **Code Repository**: [FreshRSS GitHub](https://github.com/FreshRSS/FreshRSS)
* **Documentation**: [FreshRSS Documentation](https://freshrss.github.io/FreshRSS/)

## Issues and Contributions

For issues and bugs related to the container itself, please open an issue in this repository. For all other issues, including those related to the FreshRSS application, please refer to the [original FreshRSS repository](https://github.com/FreshRSS/FreshRSS).

## Disclaimer

Erhardt Consulting GmbH is not connected in any way to this project. This image solely exists to enable the deployment of this software to Kubernetes clusters without root rights. This image is provided "as is" without any warranty.Erhardt Consulting GmbH is not connected in any way to this project. This image solely exists to enable the deployment of this software to Kubernetes clusters without root rights. This image is provided "as is" without any warranty.