.PHONY: all base-php freshrss nextcloud openclaw

all: base-php freshrss nextcloud openclaw

base-php:
	podman build --file base-php/Dockerfile -t erhardtconsulting/base-php base-php

freshrss:
	podman build --file freshrss/Dockerfile -t erhardtconsulting/freshrss freshrss

nextcloud:
	podman build --file nextcloud/Dockerfile -t erhardtconsulting/nextcloud nextcloud

openclaw:
	podman build --format docker --file openclaw/Dockerfile -t erhardtconsulting/openclaw openclaw
