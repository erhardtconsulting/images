![Nextcloud Logo](https://s32.postimg.org/69nev7aol/Nextcloud_logo.png)

# FreshRSS Rootless Docker Image

- **Official Website**: [Nextcloud](https://nextcloud.com)
- **Project License**: [GNU AGPL 3](https://www.gnu.org/licenses/agpl-3.0.html)

## Overview

This repository provides a rootless Docker image for Nextcloud, a self-hosted platform for file sharing, collaboration, and synchronization. It allows users to store and share files, calendars, and contacts, and integrates with many third-party apps to extend its functionality.

Our rootless Docker image is specifically designed to run securely in Kubernetes clusters without granting root privileges. It includes Nextcloud, running on NGINX and PHP-FPM, optimized for secure, rootless operation.

## Why Use a Rootless Image?

Security is a critical concern in containerized environments. Running containers with root privileges can pose significant security risks, such as privilege escalation and unauthorized access. By utilizing a rootless Docker image, you enhance the security of your Kubernetes cluster by ensuring that the application operates with the least privileges necessary. This image differs from the original project image by enabling rootless execution, making it more suitable for environments where security is a priority.

## Features

* Uses latest stable version of **[Alpine Linux](https://alpinelinux.org)**, bundled with **[PHP 8](https://php.net)** and **[Nginx](https://nginx.org)**.
* GPG check during building process.
* APCu already configured.
* Cron runs all 15 mins (Can be disabled).
* Persistence for data, configuration and apps.
* Nextcloud included apps that are persistent will be automatically updated during start.
* Works with MySQL/MariaDB and PostgreSQL (server not included).
* Supports uploads up to 10GB.
* Multi-architecture support (x86,amd64,armv7,arm64)

## Getting Started

**Run with podman**

```bash
podman create volume nextcloud_data

podman run --volume nextcloud_data:/data --user 1234:1234 -p 8080:8080 erhardtconsulting/nextcloud
```

**Run with docker**

```bash
docker create volume nextcloud_data

docker run --volume nextcloud_data:/data --user 1234:1234 -p 8080:8080 erhardtconsulting/nextcloud
```

### Volume Mounts

**Necessary Volumes:**

- **Data Volume**: `/data` \
  This volume is used for storing the data and config of Nextcloud. It has to be writeable by the container user.
- **Temporary Volume**: `/tmp` \
  This volume is used for storing process and session data. It has to be writeable by the container user.

### Included software

* Alpine Linux
* PHP 8
* APCu
* Nginx
* Supercronic
* SupervisorD

Everything is bundled in the newest stable version.

### Tags

* **latest**: Latest stable Nextcloud version (PHP 7)
* **X.X.X**: Stable version tags of Nextcloud (e.g. v9.0.52) (Version >= 12.0.0 use PHP 7)
* **develop**: Latest development branch (may unstable)
* **TAG-ARCHITECTURE** (Example: develop-arm64): Tag with fixed processor architecture

### Build-time arguments
* **NEXTCLOUD_GPG**: Fingerprint of Nextcloud signing key
* **NEXTCLOUD_VERSION**: Nextcloud version to install

### Exposed ports
- **80**: NGinx webserver running Nextcloud.

### Volumes
- **/data** : All data, including config and user downloaded apps (in subfolders).

## Usage

### Standalone

You can run Nextcloud without a separate database, but I don't recommend it for production setups as it uses SQLite. Another solution is to use an external database provided elsewhere, you can enter the credentials in the installer.

1. Pull the image: `docker pull erhardtconsulting/nextcloud`
2. Run it: `docker run -d --name nextcloud -p 8080:8080 -v my_local_data_folder:/data erhardtconsulting/nextcloud` (Replace *my_local_data_folder* with the path where do you want to store the persistent data)
3. Open [localhost](http://localhost) and profit!

The first time you run the application, you can use the Nextcloud setup wizard to install everything. Afterwards it will run directly.

### With a database container

For standard setups I recommend the use of MariaDB, because it is more reliable than SQLite. For example, you can use the offical docker image of MariaDB. For more information refer to the according docker image.

```
docker pull erhardtconsulting/nextcloud && docker pull mariadb:10

docker run -d --name nextcloud_db -v my_db_persistence_folder:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=supersecretpassword -e MYSQL_DATABASE=nextcloud -e MYSQL_USER=nextcloud -e MYSQL_PASSWORD=supersecretpassword mariadb:10

docker run -d --name nextcloud --link nextcloud_db:nextcloud_db -p 8080:8080 -v my_local_data_folder:/data erhardtconsulting/nextcloud
```

*The auto-connection of the database to nextcloud is not implemented yet. This is why you need to do that manually.*

## Configuration

You can configure Nextcloud via the occ command:

```bash
docker exec -ti nextcloud occ [...YOUR COMMANDS...]
```

The command uses the same user as the webserver.

## Other

### Nginx frontend proxy

This container does not support SSL or similar and is therefore not made for running directly in the world wide web. You better use a frontend proxy like another Nginx.

Here are some sample configs (The config need to be adapted):

```
server {
	listen 80;
	server_name cloud.example.net;

	# ACME handling for Letsencrypt
	location /.well-known/acme-challenge {
  	alias /var/www/letsencrypt/;
  	default_type "text/plain";
 		try_files $uri =404;
	}

	location / {
  	return 301 https://$host$request_uri;
	}
}

server {
  listen 443 ssl spdy;
  server_name cloud.example.net;

	ssl_certificate /etc/letsencrypt.sh/certs/cloud.example.net/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt.sh/certs/cloud.example.net/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt.sh/certs/cloud.example.net/chain.pem;
	ssl_dhparam /etc/nginx/dhparam.pem;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

	ssl_session_cache shared:SSL:10m;
	ssl_session_timeout 30m;

	ssl_prefer_server_ciphers on;
	ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";

	ssl_stapling on;
	ssl_stapling_verify on;

	add_header Strict-Transport-Security "max-age=31536000";

	access_log  /var/log/nginx/docker-nextcloud_access.log;
  error_log   /var/log/nginx/docker-nextcloud_error.log;

	location / {
    proxy_buffers 16 4k;
    proxy_buffer_size 2k;

    proxy_read_timeout 300;
    proxy_connect_timeout 300;
    proxy_redirect     off;

    proxy_set_header   Host              $http_host;
    proxy_set_header   X-Real-IP         $remote_addr;
    proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header   X-Frame-Options   SAMEORIGIN;

    client_max_body_size 10G;

    proxy_pass http://127.0.0.1:8000;
  }
}
```

## Issues and Contributions

For issues related to the container itself, please open an issue in this repository. For issues concerning the Nextcloud application, refer to the [original Nextcloud repository](https://github.com/nextcloud/server).

## Disclaimer

Erhardt Consulting GmbH is not affiliated with the Nextcloud project or its contributors. This rootless Docker image is provided "as is" to facilitate the deployment of Nextcloud in Kubernetes clusters without root privileges. All images are provided without warranty of any kind.

Please report any issues unrelated to containerization directly to the Nextcloud project. The code for the container configuration is provided under the terms of the [MIT License](LICENSE). Note that this license does not apply to the application code within the containers, which may be distributed under different, possibly more restrictive licenses. Users are responsible for complying with the licenses of the underlying applications.