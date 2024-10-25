.PHONY: all base-php freshrss nextcloud

all: base-php freshrss nextcloud

base-php:
	podman build --file base-php/Dockerfile -t erhardtconsulting/base-php base-php

freshrss:
	podman build --file freshrss/Dockerfile -t erhardtconsulting/freshrss freshrss

nextcloud:
	podman build --file nextcloud/Dockerfile -t erhardtconsulting/nextcloud nextcloud