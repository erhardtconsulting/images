.PHONY: all nextcloud base-php

all: nextcloud

base-php:
	podman build --file base-php/Dockerfile -t erhardtconsulting/base-php base-php

nextcloud:
	podman build --file nextcloud/Dockerfile -t erhardtconsulting/nextcloud nextcloud