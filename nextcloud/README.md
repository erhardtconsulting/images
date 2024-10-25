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

* Debian container, bundled with **[PHP 8](https://php.net)** and **[Nginx](https://nginx.org)**.
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

podman run --volume nextcloud_data:/data --user 1234:1234 -p 8080:8080 quay.io/erhardtconsulting/nextcloud
```

**Run with docker**

```bash
docker create volume nextcloud_data

docker run --volume nextcloud_data:/data --user 1234:1234 -p 8080:8080 quay.io/erhardtconsulting/nextcloud
```

### Environment Variables

| Environment variable                      | Default | Description                                                                |
|-------------------------------------------|---------|----------------------------------------------------------------------------|
| PHP_APCU_SHM_SIZE                         | 128M    | Size of each shared memory segment of APCu                                 |
| PHP_MAX_EXECUTION_TIME                    | 600     | Maximum time a php script is allowed to run                                |
| PHP_MEMORY_LIMIT                          | 512M    | Sets the maximum amount of memory that a php script is allowed to allocate |
| ENABLE_CONFIG_DOCKER                      | true    | Enables recommended config for containers (docker.config.php)              |
| ENABLE_CONFIG_DISABLE_SKELETONS_TEMPLATES | false   | Disable skeletons and templates directories                                |
| ENABLE_CRON                               | true    | Enables or disables the integrated supercronic service                     |

**Redis configuration**

| Environment variable | Default | Description                                |
|----------------------|---------|--------------------------------------------|
| ENABLE_CONFIG_REDIS  | false   | You must enable this variable to use redis |
| REDIS_HOST           |         | Redis host                                 |
| REDIS_HOST_PASSWORD  |         | Redis password (if needed)                 |
| REDIS_HOST_PORT      | 6379    | Redis port                                 |

**Reverse proxy configuration**

| Environment variable        | Default | Description                                                                           |
|-----------------------------|---------|---------------------------------------------------------------------------------------|
| ENABLE_CONFIG_REVERSE_PROXY | false   | You must enable this variable to configure reverse proxy settings                     |
| OVERWRITEHOST               |         | Host that should be used by Nextcloud                                                 |
| OVERWRITEPROTOCOL           |         | Protocol that should be used by Nextcloud                                             |
| OVERWRITECLIURL             |         | URL to be used by commandline tools                                                   |
| OVERWRITEWEBROOT            |         | Webroot to use for generating Nextcloud URLs                                          |
| OVERWRITECONDADDR           |         | Defines a manual override condition as a regular expression for the remote IP address |
| TRUSTED_PROXIES             |         | List of trusted proxy servers (e.g. 10.0.0.0/8 in Kubernetes)                         |

**S3 object store configuration**

| Environment variable         | Default | Description                                            |
|------------------------------|---------|--------------------------------------------------------|
| ENABLE_CONFIG_S3             | false   | You must enable this variable to configure s3 settings |
| OBJECTSTORE_S3_BUCKET        |         | Name of objectstore bucket                             |
| OBJECTSTORE_S3_SSL           |         | Enable SSL                                             |
| OBJECTSTORE_S3_USEPATH_STYLE |         | Use path style for bucket access                       |
| OBJECTSTORE_S3_LEGACYAUTH    |         | Use legacy authentication                              |
| OBJECTSTORE_S3_AUTOCREATE    |         | Enable auto-creation of buckets                        |
| OBJECTSTORE_S3_REGION        |         | Bucket region                                          |
| OBJECTSTORE_S3_HOST          |         | Host of objectstore                                    |
| OBJECTSTORE_S3_PORT          |         | Port of the objectstore bucket server                  |
| OBJECTSTORE_S3_STORAGE_CLASS |         | Storage class to use if necessary                      |
| OBJECTSTORE_S3_OBJECT_PREFIX |         | Object prefix to use if necessary                      |
| OBJECTSTORE_S3_KEY           |         | Access key                                             |
| OBJECTSTORE_S3_SECRET        |         | Secret key                                             |
| OBJECTSTORE_S3_SSE_C_KEY     |         | Key for server side encryption if necessary            |

**SMTP configuration**

| Environment variable | Default | Description                                              |
|----------------------|---------|----------------------------------------------------------|
| ENABLE_CONFIG_SMTP   | false   | You must enable this variable to configure smtp settings |
| SMTP_HOST            |         | Hostname of the SMTP Server                              |
| SMTP_PORT            |         | Port of the SMTP Server                                  |
| SMTP_SECURE          |         | If encryption should be used                             |
| SMTP_NAME            |         | SMTP username                                            |
| SMTP_PASSWORD        |         | SMTP password                                            |
| SMTP_AUTHTYPE        | LOGIN   | Authentication type used for SMTP                        |
| MAIL_FROM_ADDRESS    |         | Part before the @ used for sending mail                  |
| MAIL_DOMAIN          |         | Domain part of the sending address                       |

**Auto-configuration**

You can enable auto-configuration to setup your Nextcloud instance directly by this container. Make sure to remove all environment variables after the first run, to make sure there are no leaks.

| Environment variable     | Default | Description                                             |
|--------------------------|---------|---------------------------------------------------------|
| ENABLE_CONFIG_AUTOCONFIG | false   | You must enable this variable to use auto-configuration |
| SQLITE_DATABASE          |         | When using SQLite: Database name                        |
| MYSQL_DATABASE           |         | When using MySQL/MariaDB: Database name                 |
| MYSQL_USER               |         | When using MySQL/MariaDB: Database username             |
| MYSQL_PASSWORD           |         | When using MySQL/MariaDB: Database password             |
| MYSQL_HOST               |         | When using MySQL/MariaDB: Database host                 |
| POSTGRES_DB              |         | When using PostgreSQL: Database name                    |
| POSTGRES_USER            |         | When using PostgreSQL: Database username                |
| POSTGRES_PASSWORD        |         | When using PostgreSQL: Database password                |
| POSTGRES_HOST            |         | When using PostgreSQL: Database host                    |
| ADMIN_USERNAME           |         | Admin user to create                                    |
| ADMIN_PASSWORD           |         | Password of the newly created admin user                |

### Volume Mounts

**Necessary Volumes:**

- **Data Volume**: `/data` \
  This volume is used for storing the data and config of Nextcloud. It has to be writeable by the container user.
- **Temporary Volume**: `/tmp` \
  This volume is used for storing process and session data. It has to be writeable by the container user.

### Exposed ports
- **8080**: Nginx webserver running Nextcloud.

## Running OCC Command

You can configure Nextcloud via the occ command:

```bash
docker exec -ti nextcloud occ [...YOUR COMMANDS...]
```

The command uses the same user as the webserver.

## Other

### Nginx Frontend Proxy

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

    proxy_pass http://127.0.0.1:8080;
  }
}
```

## Additional Resources

- **Nextcloud Code Repository**: [GitHub](https://github.com/nextcloud/server)
- **Nextcloud Documentation**: [Official Docs](https://docs.nextcloud.com)

## Issues and Contributions

For issues related to the container itself, please open an issue in this repository. For issues concerning the Nextcloud application, refer to the [original Nextcloud repository](https://github.com/nextcloud/server).

## Disclaimer

Erhardt Consulting GmbH is not affiliated with the Nextcloud project or its contributors. This rootless Docker image is provided "as is" to facilitate the deployment of Nextcloud in Kubernetes clusters without root privileges. All images are provided without warranty of any kind.

Please report any issues unrelated to containerization directly to the Nextcloud project. The code for the container configuration is provided under the terms of the [MIT License](../LICENSE). Note that this license does not apply to the application code within the containers, which may be distributed under different, possibly more restrictive licenses. Users are responsible for complying with the licenses of the underlying applications.