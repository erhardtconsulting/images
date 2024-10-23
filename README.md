# Rootless Docker Images

This repository provides rootless Docker images of various open-source projects, enabling secure deployment in Kubernetes clusters without granting root privileges.

## Why Rootless Docker Images?

Security is paramount in containerized environments. Running containers with root privileges can pose significant security risks. By utilizing rootless Docker images, we ensure that applications operate with the least privileges necessary, enhancing the overall security posture of your Kubernetes cluster.

## Available Images

### [FreshRSS](./freshrss)

[FreshRSS](https://freshrss.org/) is a self-hosted RSS feed aggregator that allows you to collect and read news and articles from various sources in one place. It's lightweight, customizable, and supports multiple users.

### [Nextcloud](./nextcloud)

[Nextcloud](https://nextcloud.com/) is a self-hosted platform that provides file storage, collaboration tools, and synchronization services. It allows users to store and share files, calendars, and contacts, and integrates with many third-party apps. Our rootless Nextcloud Docker image provides a secure way to deploy this powerful suite without root privileges, ideal for Kubernetes environments where security is critical.

## Disclaimer

Erhardt Consulting GmbH is not affiliated with the projects contained within these images. All images are provided "as-is" without any warranty. We aim to offer helpful resources, but we cannot guarantee the functionality or security of the applications themselves.

For issues unrelated to the containerization, please report them directly to the respective projects.

## License

The code for the container configurations in this repository is provided under the terms of the [MIT License](LICENSE). Please note that this license does not apply to the application code within the containers, which may be distributed under different, possibly more restrictive licenses. Users are responsible for complying with the licenses of the underlying applications.